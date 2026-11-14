#!/usr/bin/env python3
"""EDA 3: línea base de hábitos y aprendizaje en jóvenes de EE.UU. (CDC YRBSS y NAEP). OJO: son datos de EE.UU.

Entradas (eda/tables/ramona/, generadas en Ramona; los crudos de varios GB nunca salen de Ramona):
  yrbss_hs_national.csv      YRBSS preparatoria (grados 9-12), nacional, 2015 y 2017 (el archivo grande sólo trae esos años)
  cdc_npao_us.csv            CDC nutrición/actividad física/obesidad, nacional, 2001-2023 (misma encuesta YRBSS)
  cdc_mental_health_slim.csv CDC indicadores de salud mental YRBSS 2019-2023 (Area_abbr XX = Estados Unidos)
  yrbss_ms_summary.csv       YRBSS secundaria (grados 6-8): NO hay muestra nacional; mediana no ponderada entre estados participantes
  naep_national.csv          NAEP matemáticas/ciencias, medias nacionales
Salidas: eda/tables/jovenes_*.csv, eda/figures/fig_10..12
"""
from common import *
RAM = TABLES / "ramona"
SRC_Y = "CDC, Youth Risk Behavior Surveillance System (YRBSS), data.cdc.gov; datos de EE.UU.; cálculo propio"
SRC_N = "NAEP (The Nation's Report Card), nationsreportcard.gov, medias nacionales de EE.UU.; cálculo propio"
f = lambda s: float(s) if s not in ("", None) else None

# ---- tendencias nacionales (preparatoria) ---------------------------------------------------
npao = read_csv(RAM / "cdc_npao_us.csv"); mh = read_csv(RAM / "cdc_mental_health_slim.csv"); hs = read_csv(RAM / "yrbss_hs_national.csv")
SX = {"Total": "Total", "Female": "Mujeres", "Male": "Hombres", "Hispanic": "Hispanos", "Hispanic or Latino": "Hispanos"}
trend = []
for x in npao:
    if x["QuestionID"] in ("Q048", "Q038", "Q049", "Q039") and x["strat"] in SX and x["pct"]:
        trend.append({"indicador": {"Q048": "Logra 60 min diarios de actividad física", "Q038": "Tiene obesidad", "Q049": "Educación física diaria",
                                    "Q039": "Tiene sobrepeso"}[x["QuestionID"]], "anio": int(x["Year"]), "grupo": SX[x["strat"]], "pct": f(x["pct"]),
                      "ic_bajo": f(x["lo"]), "ic_alto": f(x["hi"]), "n": x["n"], "archivo": "cdc_npao_us.csv"})
MHQ = {"MH1": "Tristeza o desesperanza persistente (12 meses)", "MH2": "Consideró seriamente el suicidio (12 meses)", "MH5": "Mala salud mental (30 días)"}
for x in mh:
    if x["Area_abbr"] == "XX" and x["q"] in MHQ:
        trend.append({"indicador": MHQ[x["q"]], "anio": int(x["Year"]), "grupo": SX[x["dval"]], "pct": f(x["pct"]), "ic_bajo": f(x["lo"]), "ic_alto": f(x["hi"]),
                      "n": "", "archivo": "cdc_mental_health_slim.csv"})
for x in hs:  # 2015 and 2017 for the same YRBS questions (H25 sad/hopeless, H26 considered suicide)
    if x["c"] in ("H25", "H26") and x["grade"] == "Total" and (x["sex"] == "Total" or x["race"] == "Total"):
        g = SX[x["race"]] if x["race"] != "Total" else SX[x["sex"]]
        trend.append({"indicador": MHQ["MH1" if x["c"] == "H25" else "MH2"], "anio": int(x["y"]), "grupo": g, "pct": round(f(x["pct"]), 1),
                      "ic_bajo": round(f(x["lo"]), 1), "ic_alto": round(f(x["hi"]), 1), "n": x["n"], "archivo": "yrbss_hs_national.csv"})
trend.sort(key=lambda r: (r["indicador"], r["grupo"], r["anio"]))
write_csv("jovenes_eeuu_tendencias.csv", trend)
def ser(ind, grp): return [(r["anio"], r["pct"]) for r in trend if r["indicador"] == ind and r["grupo"] == grp]
def last(ind, grp): return ser(ind, grp)[-1]
PA, SAD, OB = "Logra 60 min diarios de actividad física", MHQ["MH1"], "Tiene obesidad"
for ind in (PA, SAD, OB, MHQ["MH5"], "Educación física diaria"):
    for g in ("Total", "Mujeres", "Hombres", "Hispanos"): print(f"  {ind[:38]:38s} {g:8s}", ser(ind, g))

fig, axs = fig_ax(ncols=3, gridspec_kw={"wspace": 0.28})
for ax, ind, ttl, ymax in ((axs[0], PA, "Hace 60 min diarios\nde actividad física", 60), (axs[1], SAD, "Tristeza o desesperanza\npersistente", 60), (axs[2], OB, "Tiene obesidad\n ", 60)):
    for g, col, mk in (("Mujeres", MAGENTA, "o"), ("Hombres", BLUE, "s"), ("Total", INK, "D")):
        s = ser(ind, g)
        ax.plot([a for a, _ in s], [b for _, b in s], color=col, marker=mk, lw=2.6 if g == "Total" else 1.8, ms=6 if g == "Total" else 5, label=g)
        ax.text(s[-1][0] + 0.5, s[-1][1], f"{s[-1][1]:.0f}%", color=INK, fontsize=11.5, va="center", fontweight="bold" if g == "Total" else "normal")
    ax.set_ylim(0, ymax); ax.set_title(ttl); xs = [a for a, _ in ser(ind, "Total")]
    ax.set_xlim(xs[0] - 1, xs[-1] + 3.2); ax.set_xticks(xs[::2] if len(xs) > 6 else xs); ax.tick_params(axis="x", labelsize=10.5)
axs[0].set_ylabel("% de estudiantes de preparatoria (grados 9-12)"); axs[0].legend(loc="upper right", fontsize=10.5)
pa, sad, ob = last(PA, "Total"), last(SAD, "Total"), last(OB, "Total")
finish(fig, "fig_10_jovenes_eeuu_tendencias.png",
       f"EE.UU.: sólo {pa[1]:.0f}% de los jóvenes hace una hora diaria de ejercicio y {sad[1]:.0f}% reporta tristeza persistente ({sad[0]})",
       "Estudiantes de preparatoria de EE.UU., muestra nacional del YRBSS (bienal). Tristeza: 2015-2017 del archivo histórico y 2019-2023 del tablero de salud mental "
       "(misma pregunta). No son datos de México.", SRC_Y, bottom=0.11)

# ---- foto 2017: secundaria (mediana de estados) vs preparatoria (nacional) -------------------
ms = read_csv(RAM / "yrbss_ms_summary.csv")
PAIRS = [("No hace 60 min de actividad física los 7 días", "QNPA7DAY", "QNPA7DAY"), ("Duerme menos de 8 horas entre semana", "M48", "H88"),
         ("3 h o más al día de pantalla recreativa", "M43", "H81"), ("No juega en ningún equipo deportivo", "M45", "H83"),
         ("No tiene educación física diaria", "QNDLYPE", "QNDLYPE")]
snap = []
for lab, cm, ch in PAIRS:
    m = [x for x in ms if x["QuestionCode"] == cm and x["YEAR"] == "2017" and x["Sex"] == "Total" and x["Race"] == "Total" and x["Grade"] == "Total"]
    h = {x["sex"]: x for x in hs if x["c"] == ch and x["y"] == "2017" and x["race"] == "Total" and x["grade"] == "Total"}
    mm = {x["Sex"]: x for x in ms if x["QuestionCode"] == cm and x["YEAR"] == "2017" and x["Race"] == "Total" and x["Grade"] == "Total"}
    snap.append({"indicador": lab, "codigo_secundaria": cm, "codigo_prepa": ch,
                 "secundaria_mediana_estados_pct": f(m[0]["states_median"]) if m else "", "secundaria_n_estados": m[0]["n_states"] if m else "",
                 "secundaria_min_estado": m[0]["states_min"] if m else "", "secundaria_max_estado": m[0]["states_max"] if m else "",
                 "secundaria_mujeres_mediana": mm.get("Female", {}).get("states_median", ""), "secundaria_hombres_mediana": mm.get("Male", {}).get("states_median", ""),
                 "prepa_nacional_pct": round(f(h["Total"]["pct"]), 1), "prepa_ic_bajo": round(f(h["Total"]["lo"]), 1), "prepa_ic_alto": round(f(h["Total"]["hi"]), 1),
                 "prepa_n": h["Total"]["n"], "prepa_mujeres_pct": round(f(h["Female"]["pct"]), 1), "prepa_hombres_pct": round(f(h["Male"]["pct"]), 1)})
write_csv("jovenes_eeuu_foto_2017.csv", snap)
for s in snap: print("  ", s)
mst = [{"codigo": x["QuestionCode"], "pregunta": x["Greater_Risk_Question"], "anio": x["YEAR"], "sexo": x["Sex"], "n_estados": x["n_states"], "mediana_estados": x["states_median"],
        "min": x["states_min"], "max": x["states_max"]} for x in ms if x["Race"] == "Total" and x["Grade"] == "Total" and x["QuestionCode"] in ("M48", "QNPA7DAY", "M43", "M42", "M45", "M14", "M12", "QNBK7DAY", "QNDLYPE")]
write_csv("jovenes_eeuu_secundaria_mediana_estados.csv", mst)

fig, ax = fig_ax()
ys = list(range(len(snap)))[::-1]
ax.barh([y + 0.19 for y in ys], [s["secundaria_mediana_estados_pct"] for s in snap], height=0.34, color=AQUA, label="Secundaria (grados 6-8): mediana de los estados que midieron")
ax.barh([y - 0.19 for y in ys], [s["prepa_nacional_pct"] for s in snap], height=0.34, color=BLUE, label="Preparatoria (grados 9-12): muestra nacional")
for y, s in zip(ys, snap):
    ax.text(s["secundaria_mediana_estados_pct"] + 0.8, y + 0.19, f"{s['secundaria_mediana_estados_pct']:.0f}%  ({s['secundaria_n_estados']} estados)", va="center", fontsize=11)
    ax.text(s["prepa_nacional_pct"] + 0.8, y - 0.19, f"{s['prepa_nacional_pct']:.0f}%", va="center", fontsize=11, fontweight="bold")
ax.set_yticks(ys); ax.set_yticklabels([s["indicador"] for s in snap], fontsize=11.5); ax.set_xlim(0, 100); ax.grid(axis="y", visible=False)
ax.set_xlabel("% de estudiantes, 2017"); ax.legend(loc="upper left", bbox_to_anchor=(-0.02, -0.12), ncol=1, fontsize=10.5)
S = {s["codigo_prepa"]: s for s in snap}
finish(fig, "fig_11_habitos_que_faltan_eeuu.png",
       f"Los hábitos de tripulación faltan desde la secundaria: {S['QNPA7DAY']['secundaria_mediana_estados_pct']:.0f}% no se activa a diario y en prepa {S['H88']['prepa_nacional_pct']:.0f}% duerme menos de 8 horas",
       "EE.UU., 2017 (último año con ambas encuestas en los archivos descargados). Para secundaria no existe muestra nacional: se muestra la mediana simple entre estados. "
       "No son datos de México.", SRC_Y, left=0.4, bottom=0.2)

# ---- NAEP ------------------------------------------------------------------------------------
na = [x for x in read_csv(RAM / "naep_national.csv") if x["displayable"] == "1"]   # drops 3 non-displayable cells (value 999)
def nser(subj, g, grp): return {int(x["year"]): float(x["mean_score"]) for x in na if x["subject"] == subj and x["grade"] == str(g) and x["group"] == grp}
gaps = []
for subj, g in (("mathematics", 4), ("mathematics", 8), ("science", 4), ("science", 8), ("science", 12)):
    tot, ma, fe, el, ne = (nser(subj, g, k) for k in ("All students", "Male", "Female", "Eligible", "Not eligible"))
    for y in sorted(tot):
        gaps.append({"materia": {"mathematics": "matemáticas", "science": "ciencias"}[subj], "grado": g, "anio": y, "media_total": round(tot[y], 1),
                     "hombres": round(ma[y], 1) if y in ma else "", "mujeres": round(fe[y], 1) if y in fe else "",
                     "brecha_hombres_menos_mujeres": round(ma[y] - fe[y], 1) if y in ma and y in fe else "",
                     "almuerzo_subsidiado": round(el[y], 1) if y in el else "", "sin_subsidio": round(ne[y], 1) if y in ne else "",
                     "brecha_ingreso": round(ne[y] - el[y], 1) if y in el and y in ne else ""})
write_csv("naep_brechas.csv", gaps)
for x in gaps:
    if x["materia"] == "matemáticas" or x["anio"] >= 2019: print("  ", x)
G = {(x["materia"], x["grado"], x["anio"]): x for x in gaps}
fig, (a1, a2) = fig_ax(ncols=2, gridspec_kw={"wspace": 0.22})
el, ne = nser("mathematics", 8, "Eligible"), nser("mathematics", 8, "Not eligible"); ys_ = sorted(el)
a1.plot(ys_, [ne[y] for y in ys_], color=BLUE, marker="o", label="Sin subsidio de almuerzo (mayor ingreso)")
a1.plot(ys_, [el[y] for y in ys_], color=ORANGE, marker="s", label="Con almuerzo gratuito o reducido (menor ingreso)")
a1.fill_between(ys_, [el[y] for y in ys_], [ne[y] for y in ys_], color=GRID, alpha=0.6)
for y, dx, ha in ((ys_[0], 0.4, "left"), (ys_[-1], -0.4, "right")): a1.text(y + dx, (el[y] + ne[y]) / 2, f"{ne[y]-el[y]:.1f} pts", ha=ha, va="center", fontsize=11.5, fontweight="bold")
a1.set_ylim(240, 305); a1.set_ylabel("Puntaje NAEP de matemáticas, 8.º grado"); a1.set_title("Brecha por ingreso familiar"); a1.legend(loc="lower right", fontsize=10)
a1.set_xticks(ys_[::2])
for g, col, mk in ((4, AQUA, "o"), (8, VIOLET, "s")):
    yy = sorted(y for (m, gg, y) in G if m == "matemáticas" and gg == g)
    v = [G[("matemáticas", g, y)]["brecha_hombres_menos_mujeres"] for y in yy]
    a2.plot(yy, v, color=col, marker=mk, label=f"{g}.º grado"); a2.text(yy[-1] + 0.5, v[-1], f"{v[-1]:+.0f}", va="center", fontsize=11.5, fontweight="bold")
a2.axhline(0, color=INK2, lw=1); a2.set_ylim(-3, 8); a2.set_ylabel("Hombres − mujeres (puntos)"); a2.set_title("Brecha de género en matemáticas")
a2.legend(loc="upper left", fontsize=10.5); a2.set_xlim(1999, 2027); a2.set_xticks([2000, 2005, 2011, 2017, 2024])
g8 = G[("matemáticas", 8, 2022)]; g24 = G[("matemáticas", 8, 2024)]; g19 = G[("matemáticas", 8, 2019)]
finish(fig, "fig_12_naep_brechas.png",
       f"Matemáticas en EE.UU.: la brecha por ingreso es de {g8['brecha_ingreso']:.1f} puntos y la de género reapareció ({g19['brecha_hombres_menos_mujeres']:+.0f} en 2019, {g24['brecha_hombres_menos_mujeres']:+.0f} en 2024)",
       "Medias nacionales NAEP. Ingreso: elegibilidad para almuerzo escolar gratuito o reducido (último dato descargado: 2022). Se omiten 3 celdas no publicables. "
       "No son datos de México.", SRC_N)
