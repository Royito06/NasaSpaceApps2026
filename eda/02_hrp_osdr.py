#!/usr/bin/env python3
"""EDA 2: riesgos del NASA Human Research Program (HRP) y estudios del NASA Open Science Data Repository (OSDR).

Entradas (versiones "slim" generadas en Ramona con eda/ramona/slim_small_sources.py; los crudos viven en Ramona):
  eda/tables/ramona/hrp_risks_slim.csv   22 riesgos: elemento, estado, tabla LxC por misión de referencia (DRM), enunciado
  eda/tables/ramona/osdr_slim.csv        577 estudios: organismo, tipo de proyecto, programa de vuelo, banderas de tema
Salidas: eda/tables/hrp_*.csv, eda/tables/osdr_*.csv, eda/figures/fig_08_*.png, fig_09_*.png
"""
import re, collections, datetime
from common import *

RAM = TABLES / "ramona"
SRC_HRP = "NASA Human Research Roadmap, humanresearchroadmap.nasa.gov/Risks (consultado 14-nov-2026); clasificación «entrenable» propia"
SRC_OSDR = "NASA Open Science Data Repository (OSDR), osdr.nasa.gov, 577 estudios (consultado 14-nov-2026); temas por palabras clave, cálculo propio"

# ---------------------------------------------------------------- HRP
DRMS = ["LEO corto (<30 d)", "LEO largo (30 d-1 año)", "Órbita lunar corto", "Órbita lunar largo", "Luna órbita+superficie corto",
        "Luna órbita+superficie largo", "Marte preparatorio (<1 año)", "Marte planetario (730-1224 d)"]
CELL = re.compile(r"(\dx\d|Not Applicable|TBD)\s+(Requires Mitigation/Standard Refinement|Requires Mitigation|Requires Characterization|"
                  r"Accepted with Monitoring|Accepted with Optimization|Accepted|Not Applicable|TBD)")
LABEL = re.compile(r"(Low Earth Orbit Short \(<30 days\)|Lunar Orbital \+ Surface Short \(<30 days\)|Lunar Orbital Short \(<30 days\)|"
                   r"Long \(30 days-1 year\)|Mars Preparatory \(<1 year\)|Mars Planetary \(730-1224 days\))")
# Our own mapping (NOT NASA's): what a school-age program can build early. Everything else = "no entrenable en la escuela".
TRAIN = {
    "Team": ("Conducta y equipo", "Trabajo en equipo y comunicación"),
    "Behavioral Health": ("Conducta y equipo", "Manejo de estrés y resiliencia"),
    "Sleep": ("Conducta y equipo", "Hábitos de sueño"),
    "EIHSO": ("Conducta y equipo", "Autonomía para resolver problemas"),
    "Food and Nutrition": ("Hábitos de salud física", "Alimentación saludable"),
    "Muscle and Aerobic": ("Hábitos de salud física", "Actividad física regular"),
    "Bone Fracture": ("Hábitos de salud física", "Actividad física en el crecimiento"),
}
# Indirect links only (the risk itself is mitigated by suit design / on-board medical capability, not by habits).
INDIRECT = {"Medical Conditions": "Relación indirecta: primeros auxilios y autocuidado", "EVA": "Relación indirecta: natación/buceo y condición física"}
ES = {"Team": "Equipo (cooperación y comunicación)", "Behavioral Health": "Salud conductual y cognitiva", "Sleep": "Sueño y carga de trabajo",
      "EIHSO": "Operación autónoma sin la Tierra (EIHSO)", "Food and Nutrition": "Alimentación y nutrición", "Muscle and Aerobic": "Músculo y capacidad aeróbica",
      "Bone Fracture": "Fractura de hueso", "Medical Conditions": "Condiciones médicas en misión", "EVA": "Lesiones en caminata espacial (EVA)",
      "Microhost": "Interacción microbios-huésped", "Dust": "Polvo lunar/marciano", "Sensorimotor": "Sensoriomotor/vestibular", "Cardiovascular": "Cardiovascular",
      "Immune": "Respuesta inmune", "Dynamic Loads": "Cargas dinámicas (impactos)", "Pharm": "Medicamentos ineficaces", "DCS": "Enfermedad por descompresión",
      "Carcinogenesis": "Cáncer por radiación", "Hypoxia": "Hipoxia", "Renal Stone": "Cálculos renales", "SANS": "Síndrome neuro-ocular (SANS)", "IVD": "Daño de disco intervertebral"}
risks, long = [], []
for r in read_csv(RAM / "hrp_risks_slim.csv"):
    parts = LABEL.split(r["drm_table_raw"])[1:]
    cells = [CELL.findall(parts[i + 1]) for i in range(0, len(parts), 2)]
    assert len(cells) == 8 and all(len(c) == 2 for c in cells), (r["short_title"], cells)
    cat, skill = TRAIN.get(r["short_title"], ("No entrenable en la escuela (medicina/ingeniería)", ""))
    d = {"risk_id": r["risk_id"], "short_title": r["short_title"], "nombre_es": ES[r["short_title"]], "risk_name": r["risk_name"],
         "elemento_nasa": r["element"], "activo": int(r["status"].startswith("Active")), "categoria_propia": cat, "habilidad_infantil_propia": skill,
         "relacion_indirecta_propia": INDIRECT.get(r["short_title"], ""), "hsrb_aprobado": r["hsrb_approved"], "url": r["url"]}
    for name, ((ol, od), (hl, hd)) in zip(DRMS, cells):
        prod = (lambda s: int(s[0]) * int(s[2]) if "x" in s else "")
        long.append({"risk_id": r["risk_id"], "short_title": r["short_title"], "drm": name, "ops_LxC": ol, "ops_disposicion": od, "ops_producto": prod(ol),
                     "salud_largo_plazo_LxC": hl, "salud_largo_plazo_disposicion": hd, "slp_producto": prod(hl)})
    d["marte_ops_LxC"], d["marte_ops_disp"] = cells[7][0]; d["marte_slp_LxC"], d["marte_slp_disp"] = cells[7][1]
    d["leo_largo_ops_LxC"], d["leo_largo_ops_disp"] = cells[1][0]
    d["marte_ops_producto"] = int(d["marte_ops_LxC"][0]) * int(d["marte_ops_LxC"][2]) if "x" in d["marte_ops_LxC"] else ""
    d["leo_largo_ops_producto"] = int(d["leo_largo_ops_LxC"][0]) * int(d["leo_largo_ops_LxC"][2]) if "x" in d["leo_largo_ops_LxC"] else ""
    d["enunciado_riesgo"] = r["risk_statement"]
    risks.append(d)
write_csv("hrp_riesgos_clasificados.csv", risks)
write_csv("hrp_riesgos_por_mision_largo.csv", long)
act = [r for r in risks if r["activo"]]
el = collections.Counter(r["elemento_nasa"] for r in act); catc = collections.Counter(r["categoria_propia"] for r in act)
print(f"HRP: {len(risks)} riesgos, {len(act)} activos. Por elemento NASA: {dict(el)}. Categoría propia: {dict(catc)}")
top = sorted(act, key=lambda r: (-(r["marte_ops_producto"] or 0), r["short_title"]))
for r in top: print(f"   {r['short_title']:20s} Marte ops {r['marte_ops_LxC']:4s} {r['marte_ops_disp']:40s} LEO largo {r['leo_largo_ops_LxC']:4s} | {r['categoria_propia']}")
n55 = [r for r in act if r["marte_ops_LxC"] == "5x5"]
mit = [r for r in act if r["marte_ops_disp"].startswith("Requires Mitigation")]
train = [r for r in act if not r["categoria_propia"].startswith("No entrenable")]
hi = [r for r in act if (r["marte_ops_producto"] or 0) >= 20]; hi_train = [r for r in hi if r in train]
up = [r for r in act if r["leo_largo_ops_producto"] != "" and r["marte_ops_producto"] > r["leo_largo_ops_producto"]]
summ = [{"metrica": "riesgos listados", "valor": len(risks)}, {"metrica": "riesgos activos", "valor": len(act)},
        {"metrica": "riesgos con 5x5 en Marte planetario (operaciones)", "valor": "; ".join(r["short_title"] for r in n55)},
        {"metrica": "riesgos activos que 'Requieren mitigación' en Marte planetario (operaciones)", "valor": len(mit)},
        {"metrica": "riesgos activos con hábito/habilidad entrenable (clasificación propia)", "valor": len(train)},
        {"metrica": "riesgos con producto LxC >= 20 en Marte planetario (operaciones)", "valor": "; ".join(r["short_title"] for r in hi)},
        {"metrica": "de esos (>= 20), cuántos son entrenables (clasificación propia)", "valor": len(hi_train)},
        {"metrica": "riesgos activos cuya calificación sube de LEO largo a Marte planetario (producto)", "valor": f"{len(up)} de {sum(r['leo_largo_ops_producto'] != '' for r in act)}"},
        {"metrica": "riesgos activos del elemento HFBP (factores humanos y conducta)", "valor": el.get("Human Factors and Behavioral Performance (HFBP)", 0)}]
write_csv("hrp_resumen.csv", summ)
for s in summ: print("   ", s)

COL = {"Conducta y equipo": ORANGE, "Hábitos de salud física": BLUE, "No entrenable en la escuela (medicina/ingeniería)": GRAY}
fig, ax = fig_ax(figsize=(12, 7.6))
rs = top[::-1]; ys = list(range(len(rs)))
ax.barh(ys, [r["leo_largo_ops_producto"] or 0 for r in rs], height=0.28, color="#d9d8d3", align="edge", label="Órbita baja, misión larga (hoy: EEI)")
for cat, col in COL.items():
    idx = [i for i, r in enumerate(rs) if r["categoria_propia"] == cat]
    ax.barh([i - 0.34 for i in idx], [rs[i]["marte_ops_producto"] for i in idx], height=0.34, color=col, align="edge", label=f"Marte: {cat[0].lower() + cat[1:]}")
for i, r in enumerate(rs):
    ax.text(r["marte_ops_producto"] + 0.3, i - 0.17, r["marte_ops_LxC"].replace("x", "×"), va="center", fontsize=10.5, fontweight="bold")
    if r["habilidad_infantil_propia"]:
        ax.text(27.2, i - 0.02, "→ " + r["habilidad_infantil_propia"], va="center", fontsize=9.6, color=INK2)
ax.set_yticks([y - 0.03 for y in ys]); ax.set_yticklabels([r["nombre_es"] for r in rs], fontsize=10.5)
ax.set_xlim(0, 41); ax.set_xticks([0, 5, 10, 15, 20, 25]); ax.grid(axis="y", visible=False)
ax.set_xlabel("Probabilidad × consecuencia para operaciones (máx. 5×5 = 25)", loc="left", fontsize=11)
ax.legend(loc="upper left", fontsize=10, bbox_to_anchor=(-0.02, -0.13), ncol=2, columnspacing=1.5)
finish(fig, "fig_08_riesgos_hrp.png",
       f"Los {len(n55)} riesgos humanos con calificación máxima (5×5) para ir a Marte son de equipo, autonomía y alimentación, y son habilidades que se pueden empezar a formar desde la infancia",
       f"{len(act)} riesgos activos del Human Research Program de la NASA. Etiqueta = calificación oficial (probabilidad × consecuencia) para una misión "
       "a Marte de 730-1224 días. Los colores y la columna «→» son clasificación nuestra.", SRC_HRP, left=0.3, bottom=0.2, right=0.98)

# ---------------------------------------------------------------- OSDR
O = read_csv(RAM / "osdr_slim.csv")
def ptype(s):
    s = s.lower()
    return ("Vuelo espacial" if "space" in s or s.startswith("flight") else "Estudio en tierra" if "ground" in s else
            "Otro (altitud, parabólico, suborbital)" if s else "Sin dato")
def org(s):
    first = s.split(";")[0].strip()
    return {"Mus musculus": "Ratón", "Homo sapiens": "Humano (células, tejidos o personas)", "Arabidopsis thaliana": "Planta Arabidopsis",
            "Microbiota": "Microbiota", "Drosophila melanogaster": "Mosca de la fruta", "Rattus norvegicus": "Rata",
            "Caenorhabditis elegans": "Gusano C. elegans"}.get(first, "Otros organismos")
for o in O:
    o["tipo"] = ptype(o["Project Type"]); o["org"] = org(o["organism"])
    try: o["anio"] = datetime.datetime.fromtimestamp(float(o["Study Public Release Date"]), datetime.timezone.utc).year
    except ValueError: o["anio"] = ""
N = len(O)
tc = collections.Counter(o["tipo"] for o in O); oc = collections.Counter(o["org"] for o in O)
write_csv("osdr_por_tipo.csv", [{"tipo_proyecto": k, "estudios": v, "pct": round(pct(v, N), 1)} for k, v in tc.most_common()])
write_csv("osdr_por_organismo.csv", [{"organismo": k, "estudios": v, "pct": round(pct(v, N), 1)} for k, v in oc.most_common()])
write_csv("osdr_por_anio.csv", [{"anio_publicacion": k, "estudios": v} for k, v in sorted(collections.Counter(o["anio"] for o in O).items(), key=lambda x: str(x[0]))])
TOP = {"t_musculo": "Músculo", "t_hueso": "Hueso", "t_inmune": "Sistema inmune / inflamación", "t_cardiovascular": "Corazón y vasos",
       "t_cerebro_conducta": "Cerebro, sistema nervioso y estrés", "t_ojo_SANS": "Ojo / visión", "t_sueno_circadiano": "Sueño / ritmo circadiano",
       "t_radiacion": "Radiación", "t_microbioma": "Microbioma", "t_higado_metabolismo": "Hígado y metabolismo", "t_nutricion_dieta": "Dieta / nutrición",
       "t_ejercicio_contramedida": "Ejercicio y contramedidas", "t_aislamiento_confinamiento": "Análogos: aislamiento, reposo en cama", "t_plantas": "Plantas",
       "t_piel": "Piel", "t_rinon": "Riñón", "t_astronautas_humanos": "Astronautas / tripulación"}
tt = []
for k, lab in TOP.items():
    s = [o for o in O if o[k] == "1"]
    tt.append({"tema": lab, "bandera": k, "estudios": len(s), "pct_de_577": round(pct(len(s), N), 1),
               "en_vuelo_espacial": sum(o["tipo"] == "Vuelo espacial" for o in s), "en_raton_o_rata": sum(o["org"] in ("Ratón", "Rata") for o in s),
               "en_humano": sum(o["org"].startswith("Humano") for o in s)})
tt.sort(key=lambda x: -x["estudios"]); write_csv("osdr_por_tema.csv", tt)
print(f"OSDR: {N} estudios; tipo={dict(tc)}; organismo={dict(oc)}")
for x in tt: print("   ", x)
mb = [o for o in O if o["t_musculo"] == "1" or o["t_hueso"] == "1"]
print(f"   músculo o hueso: {len(mb)} ({pct(len(mb), N):.1f}%)")
write_csv("osdr_musculo_hueso_ejemplos.csv", [{k: o[k] for k in ("Accession", "Study Title", "organism", "Project Type", "Mission", "t_musculo", "t_hueso", "t_ejercicio_contramedida")} for o in mb])

fig, (a1, a2) = fig_ax(ncols=2, gridspec_kw={"width_ratios": [1.25, 1], "wspace": 0.75})
HEALTH = {"t_musculo", "t_hueso", "t_inmune", "t_cardiovascular", "t_cerebro_conducta", "t_sueno_circadiano", "t_ojo_SANS"}
sel = [x for x in tt if x["bandera"] not in ("t_plantas", "t_astronautas_humanos", "t_piel", "t_rinon")][::-1]
ys = list(range(len(sel)))
a1.barh(ys, [x["estudios"] for x in sel], color=[BLUE if x["bandera"] in HEALTH else GRAY for x in sel], height=0.66)
for y, x in zip(ys, sel): a1.text(x["estudios"] + 3, y, f"{x['estudios']}  ({x['pct_de_577']:.0f}%)", va="center", fontsize=10.5)
a1.set_yticks(ys); a1.set_yticklabels([x["tema"] for x in sel], fontsize=10.5); a1.grid(axis="y", visible=False)
a1.set_xlim(0, max(x["estudios"] for x in sel) * 1.3); a1.set_xlabel("Estudios que mencionan el tema"); a1.set_title("Temas (un estudio puede tocar varios)")
oo = oc.most_common()[::-1]; ys = list(range(len(oo)))
a2.barh(ys, [v for _, v in oo], color=[ORANGE if k == "Ratón" else GRAY for k, _ in oo], height=0.66)
for y, (k, v) in zip(ys, oo): a2.text(v + 3, y, f"{v}  ({pct(v, N):.0f}%)", va="center", fontsize=10.5)
a2.set_yticks(ys); a2.set_yticklabels([k for k, _ in oo], fontsize=10.5); a2.grid(axis="y", visible=False)
a2.set_xlim(0, max(oc.values()) * 1.35); a2.set_xlabel("Estudios"); a2.set_title("Organismo principal")
T = {x["bandera"]: x for x in tt}
finish(fig, "fig_09_osdr_temas.png",
       f"Los datos abiertos de biología espacial de la NASA se concentran en lo que el cuerpo resiente: defensas ({T['t_inmune']['estudios']} estudios), hueso ({T['t_hueso']['estudios']}) y músculo ({T['t_musculo']['estudios']})",
       f"{N} estudios del repositorio OSDR/GeneLab; {tc['Vuelo espacial']} son de vuelo espacial. Tema asignado por palabras clave en título, descripción y factores "
       "(aproximado: ver tabla osdr_por_tema.csv).", SRC_OSDR, left=0.24, bottom=0.13)
