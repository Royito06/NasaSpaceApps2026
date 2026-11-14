#!/usr/bin/env python3
"""EDA 4: México y Sonora: salud de niñas, niños y adolescentes (Ensanut, INSP) y aprendizaje (PISA, OCDE).

Las series internacionales de la OMS se siguen tabulando como contexto (fuentes públicas bajadas con eda/00_fetch_mexico.py),
pero la figura 13 ya usa las cifras oficiales de México.

Entradas en data/raw/mexico/:
  who_NCD_BMI_PLUS2C_*.json  OMS/GHO: obesidad en niños y adolescentes 5-19 años (IMC > +2 DE), estimación cruda (NCD-RisC)
  who_NCD_BMI_PLUS1C_*.json  OMS/GHO: sobrepeso (incluye obesidad) 5-19 años (IMC > +1 DE)
  who_NCD_PAC_ADO_*.json     OMS/GHO: actividad física insuficiente en adolescentes escolarizados de 11-17 años (2016)
  wb_LO.PISA.*.json          Banco Mundial EdStats: medias PISA (sólo llega a 2018; PISA 2022 NO está en esta API)
  owid_pisa-*.csv            Our World in Data (fuente original OCDE): medias PISA hasta 2022
Entrada en eda/tables/:
  mexico_ensanut.csv         Ensanut Continua (INSP), cifras oficiales transcritas con eda/06_ensanut_construir.py
PISA 2025 no está en ninguna de esas fuentes: sus cifras se leyeron en los PDF de la OCDE y están escritas más abajo.
Salidas: eda/tables/mexico_*.csv (incluye mexico_pisa_2025_ocde.csv), eda/figures/fig_13_mexico_contexto.png
"""
import json, re
from common import *
MX = RAW / "mexico"
SRC = ("INSP, Ensanut Continua 2020-2024 (Salud Publica Mex 2025;67:609-621 y supl 1:s3-s219). "
       "OCDE, PISA 2003-2025 (hasta 2022 vía Our World in Data)")
NAME = {"MEX": "México", "USA": "EE.UU.", "GLOBAL": "Mundo", "AMR": "Américas (región OMS)", "OED": "Promedio OCDE"}
SEX = {"SEX_BTSX": "Total", "SEX_FMLE": "Mujeres", "SEX_MLE": "Hombres"}
def who(fn): return json.load(open(MX / fn))["value"]

rows = []
for code, lab in (("NCD_BMI_PLUS2C", "Obesidad 5-19 años (%)"), ("NCD_BMI_PLUS1C", "Sobrepeso u obesidad 5-19 años (%)")):
    for x in who(f"who_{code}_mex_usa.json"):
        rows.append({"indicador": lab, "codigo": code, "lugar": NAME[x["SpatialDim"]], "anio": x["TimeDim"], "sexo": SEX[x["Dim1"]],
                     "edad": x["Dim2"].replace("AGEGROUP_YEARS", ""), "valor": round(x["NumericValue"], 2), "ic_bajo": round(x["Low"], 2), "ic_alto": round(x["High"], 2)})
for x in who("who_NCD_PAC_ADO_mex_usa.json"):
    rows.append({"indicador": "Actividad física insuficiente 11-17 años (%)", "codigo": "NCD_PAC_ADO", "lugar": NAME[x["SpatialDim"]], "anio": x["TimeDim"], "sexo": SEX[x["Dim1"]],
                 "edad": "11-17", "valor": round(x["NumericValue"], 2), "ic_bajo": round(x["Low"], 2) if x["Low"] is not None else "", "ic_alto": round(x["High"], 2) if x["High"] is not None else ""})
rows.sort(key=lambda r: (r["codigo"], r["lugar"], r["edad"], r["sexo"], r["anio"]))
write_csv("mexico_oms_series.csv", rows)
def ser(code, lugar, sexo="Total", edad="05-19"): return [(r["anio"], r["valor"]) for r in rows if r["codigo"] == code and r["lugar"] == lugar and r["sexo"] == sexo and r["edad"] == edad]
def val(code, lugar, anio, sexo="Total", edad="05-19"): return dict(ser(code, lugar, sexo, edad)).get(anio)

# ranking de países, obesidad 5-19 (2022) y actividad física insuficiente (2016)
rank = []
for fn, code, yr, edad in (("who_NCD_BMI_PLUS2C_2022_all_countries.json", "NCD_BMI_PLUS2C", 2022, "AGEGROUP_YEARS05-19"), ("who_NCD_PAC_ADO_2016_all_countries.json", "NCD_PAC_ADO", 2016, "AGEGROUP_YEARS11-17")):
    v = sorted(((x["NumericValue"], x["SpatialDim"]) for x in who(fn) if x["Dim1"] == "SEX_BTSX" and x["Dim2"] == edad and x["NumericValue"] is not None), reverse=True)
    for i, (a, c) in enumerate(v, 1):
        rank.append({"codigo": code, "anio": yr, "pais_iso3": c, "valor": round(a, 2), "lugar_de_mayor_a_menor": i, "n_paises": len(v)})
write_csv("mexico_oms_ranking_paises.csv", rank)
R = {(r["codigo"], r["pais_iso3"]): r for r in rank}
for k in (("NCD_BMI_PLUS2C", "MEX"), ("NCD_BMI_PLUS2C", "USA"), ("NCD_PAC_ADO", "MEX"), ("NCD_PAC_ADO", "USA")): print("  ", R.get(k))

# PISA (Banco Mundial EdStats)
pisa = []
for code, lab in (("LO.PISA.MAT", "Matemáticas"), ("LO.PISA.MAT.FE", "Matemáticas, mujeres"), ("LO.PISA.MAT.MA", "Matemáticas, hombres"), ("LO.PISA.SCI", "Ciencias"),
                  ("LO.PISA.SCI.FE", "Ciencias, mujeres"), ("LO.PISA.SCI.MA", "Ciencias, hombres")):
    p = MX / f"wb_{code}.json"
    if not p.exists(): print("   falta", p.name); continue
    for x in json.load(open(p))[1]:
        if x["countryiso3code"] in ("MEX", "USA", "OED") and x["value"] is not None:
            pisa.append({"indicador": lab, "codigo": code, "lugar": NAME[x["countryiso3code"]], "anio": int(x["date"]), "puntaje": round(x["value"], 1)})
pisa.sort(key=lambda r: (r["codigo"], r["lugar"], r["anio"])); write_csv("mexico_pisa_banco_mundial.csv", pisa)
def pser(code, lugar): return [(r["anio"], r["puntaje"]) for r in pisa if r["codigo"] == code and r["lugar"] == lugar]
for c in ("LO.PISA.MAT", "LO.PISA.SCI", "LO.PISA.MAT.FE", "LO.PISA.MAT.MA"):
    for l in ("México", "EE.UU.", "Promedio OCDE"): print("  ", c, l, pser(c, l))

ob_mx, ob_us, ob_w = ser("NCD_BMI_PLUS2C", "México"), ser("NCD_BMI_PLUS2C", "EE.UU."), ser("NCD_BMI_PLUS2C", "Mundo")
ow_mx = ser("NCD_BMI_PLUS1C", "México")
print("   obesidad MX", ob_mx[0], ob_mx[-1], "| sobrepeso+obesidad MX", ow_mx[-1], "| EE.UU.", ob_us[-1], "| mundo", ob_w[-1])
pa = {(l, s): dict(ser("NCD_PAC_ADO", l, s, "11-17")).get(2016) for l in ("México", "EE.UU.", "Mundo") for s in ("Total", "Mujeres", "Hombres")}
print("   act. física insuficiente 2016:", pa)
key = [{"metrica": f"obesidad 5-19 México {ob_mx[0][0]}", "valor": ob_mx[0][1]}, {"metrica": f"obesidad 5-19 México {ob_mx[-1][0]}", "valor": ob_mx[-1][1]},
       {"metrica": "obesidad 5-19 México 2022", "valor": val("NCD_BMI_PLUS2C", "México", 2022)}, {"metrica": "obesidad 5-19 EE.UU. 2022", "valor": val("NCD_BMI_PLUS2C", "EE.UU.", 2022)},
       {"metrica": "obesidad 5-19 Mundo 2022", "valor": val("NCD_BMI_PLUS2C", "Mundo", 2022)},
       {"metrica": f"sobrepeso u obesidad 5-19 México {ow_mx[-1][0]}", "valor": ow_mx[-1][1]},
       {"metrica": "lugar de México en obesidad 5-19, 2022 (de mayor a menor)", "valor": f"{R[('NCD_BMI_PLUS2C','MEX')]['lugar_de_mayor_a_menor']} de {R[('NCD_BMI_PLUS2C','MEX')]['n_paises']}"},
       {"metrica": "act. física insuficiente 11-17 México 2016 (total / mujeres / hombres)", "valor": f"{pa[('México','Total')]} / {pa[('México','Mujeres')]} / {pa[('México','Hombres')]}"},
       {"metrica": "act. física insuficiente 11-17 EE.UU. 2016 (total)", "valor": pa[("EE.UU.", "Total")]}, {"metrica": "act. física insuficiente 11-17 Mundo 2016 (total)", "valor": pa[("Mundo", "Total")]}]
for l in ("México", "EE.UU.", "Promedio OCDE"):
    s = pser("LO.PISA.MAT", l)
    if s: key.append({"metrica": f"PISA matemáticas {l} {s[-1][0]}", "valor": s[-1][1]})
write_csv("mexico_numeros_clave.csv", key)

# PISA 2022 (Our World in Data, fuente original OCDE 2023): el Banco Mundial sólo llega a 2018
ow = []
for slug, lab in (("pisa-test-score-mean-performance-on-the-mathematics-scale", "Matemáticas"), ("pisa-test-score-mean-performance-on-the-reading-scale", "Lectura")):
    p = MX / f"owid_{slug}.csv"
    if not p.exists(): print("   falta", p.name); continue
    for x in read_csv(p):
        if x["entity"] in ("Mexico", "United States", "OECD average"):
            col = [k for k in x if k.startswith("pisa_")][0]
            ow.append({"indicador": lab, "lugar": {"Mexico": "México", "United States": "EE.UU.", "OECD average": "Promedio OCDE"}[x["entity"]], "anio": int(x["year"]), "puntaje": round(float(x[col]), 1)})
ow.sort(key=lambda r: (r["indicador"], r["lugar"], r["anio"])); write_csv("mexico_pisa_owid_ocde.csv", ow)
def oser(lab, lugar): return [(r["anio"], r["puntaje"]) for r in ow if r["indicador"] == lab and r["lugar"] == lugar]
for l in ("México", "EE.UU.", "Promedio OCDE"): print("   OWID mate", l, oser("Matemáticas", l))
mx22, oe22 = dict(oser("Matemáticas", "México")), dict(oser("Matemáticas", "Promedio OCDE"))
key += [{"metrica": "PISA 2022 matemáticas México (OWID/OCDE)", "valor": mx22.get(2022)}, {"metrica": "PISA 2022 matemáticas promedio OCDE (OWID/OCDE)", "valor": oe22.get(2022)},
        {"metrica": "PISA 2022 matemáticas EE.UU. (OWID/OCDE)", "valor": dict(oser("Matemáticas", "EE.UU.")).get(2022)},
        {"metrica": "PISA 2022 lectura México (OWID/OCDE)", "valor": dict(oser("Lectura", "México")).get(2022)},
        {"metrica": "PISA 2018 matemáticas México mujeres / hombres (Banco Mundial)", "valor": f"{dict(pser('LO.PISA.MAT.FE','México')).get(2018)} / {dict(pser('LO.PISA.MAT.MA','México')).get(2018)}"}]
write_csv("mexico_numeros_clave.csv", key)

# PISA 2025 (la OCDE lo publicó el 8-sep-2026): todavía no está en Our World in Data ni en el Banco Mundial.
# Las cifras se leyeron el 14-nov-2026 en los PDF de la OCDE (guardados en data/raw/mexico/pisa2025/, ver su FUENTES.md):
#   medias: "PISA 2025 Results (Volume I)", Table I.1, pp. 28-29; la media de México también está rotulada en las
#   figuras 2 y 3 de la nota de país. Porcentajes con nivel 2 o más: nota de país de México, pp. 5-6.
P25_INFORME = "https://www.oecd.org/content/dam/oecd/en/publications/reports/2026/09/pisa-2025-results-volume-i_5265bfb1/73451bc5-en.pdf"
P25_NOTA = "https://www.oecd.org/content/dam/oecd/en/publications/reports/2026/09/pisa-2025-results-volume-i-country-notes_88d1164e/mexico_40016e3e/85702d30-en.pdf"
p25 = []
for lab, mx, oe in (("Matemáticas", 388, 463), ("Lectura", 408, 461), ("Ciencias", 414, 482)):
    for lugar, v in (("México", mx), ("Promedio OCDE", oe)):
        p25.append({"indicador": lab, "medida": "puntaje medio", "lugar": lugar, "anio": 2025, "valor": v,
                    "fuente": "OCDE, PISA 2025 Results (Volume I), Table I.1, pp. 28-29", "url": P25_INFORME})
for lab, mx, oe in (("Matemáticas", 30, 65), ("Lectura", 50, 69), ("Ciencias", 50, 74)):
    for lugar, v in (("México", mx), ("Promedio OCDE", oe)):
        p25.append({"indicador": lab, "medida": "% de estudiantes en nivel 2 o más", "lugar": lugar, "anio": 2025, "valor": v,
                    "fuente": "OCDE, PISA 2025 Results (Volume I) - Country notes: Mexico, pp. 5-6", "url": P25_NOTA})
write_csv("mexico_pisa_2025_ocde.csv", p25)
def p25v(lab, lugar, medida="puntaje medio"): return [r["valor"] for r in p25 if (r["indicador"], r["lugar"], r["medida"]) == (lab, lugar, medida)][0]
mx25, oe25 = p25v("Matemáticas", "México"), p25v("Matemáticas", "Promedio OCDE")

# Ensanut (INSP): cifras oficiales de eda/tables/mexico_ensanut.csv, sin los renglones marcados [DATO PENDIENTE]
ens = [r for r in read_csv(TABLES / "mexico_ensanut.csv") if not r["valor"].startswith("[")]
def ens_val(indicador, edad, region, edicion, sexo="Total"):
    m = [r for r in ens if r["indicador"].startswith(indicador) and (r["grupo_edad"], r["region"], r["edicion"], r["sexo"]) == (edad, region, edicion, sexo)]
    assert len(m) == 1, (indicador, edad, region, edicion, len(m))
    lo, hi = (float(x) for x in m[0]["ic95"].split("-"))
    return {"v": float(m[0]["valor"]), "lo": lo, "hi": hi, "n": int(re.search(r"n=([\d ]+)", m[0]["fuente"]).group(1).replace(" ", ""))}
E20, E22 = "Ensanut Continua 2020-2024", "Ensanut Continua 2022-2024"
FILAS = [("Sobrepeso u obesidad\n5 a 11 años", "Sobrepeso + obesidad", "5 a 11 años", E20),
         ("Sobrepeso u obesidad\n12 a 19 años", "Sobrepeso + obesidad", "12 a 19 años", E20),
         ("Físicamente activos*\n10 a 14 años", "Físicamente activos", "10 a 14 años", E22),
         ("Más de 2 horas al día\nde pantalla, 10 a 14 años", "Más de 2 horas diarias frente a pantalla", "10 a 14 años", E22)]
REG = (("Nacional", "México (nacional)", ORANGE), ("Sonora", "Sonora", AQUA))
d = {(i, reg): ens_val(ind, edad, reg, ed) for i, (_, ind, edad, ed) in enumerate(FILAS) for reg, _, _ in REG}
for i, f in enumerate(FILAS): print("   Ensanut", f[0].replace("\n", " "), {reg: d[(i, reg)] for reg, _, _ in REG})

IZQ = 0.235   # margen izquierdo de la figura: deja lugar a los nombres de los indicadores
fig, axs = fig_ax(ncols=2, gridspec_kw={"width_ratios": [1.5, 1], "wspace": 0.3})
ax = axs[0]   # barra = porcentaje estimado; línea oscura = intervalo de confianza de 95%
for i in range(len(FILAS)):
    for (reg, lab, col), dy in zip(REG, (-0.155, 0.155)):
        x, y = d[(i, reg)], i + dy
        ax.barh(y, x["v"], height=0.26, color=col, label=lab if i == 0 else None)
        ax.plot([x["lo"], x["hi"]], [y, y], color=INK, lw=1.5, solid_capstyle="butt")
        for b in (x["lo"], x["hi"]): ax.plot([b, b], [y - 0.075, y + 0.075], color=INK, lw=1.5)
        ax.text(x["hi"] + 1.5, y, f"{x['v']:.1f}%", va="center", fontsize=12, fontweight="bold" if reg == "Nacional" else "normal")
ax.set_yticks(range(len(FILAS))); ax.set_yticklabels([f[0] for f in FILAS], fontsize=12, ha="left"); ax.set_ylim(len(FILAS) - 0.45, -0.55)
ax.tick_params(axis="y", length=0, pad=(IZQ - 0.03) * 12 * 72)   # nombres alineados a la izquierda con el título (la figura mide 12 pulgadas de ancho)
ax.set_xlim(0, 112); ax.set_xticks(range(0, 101, 20)); ax.set_xticklabels([f"{t}%" for t in range(0, 101, 20)]); ax.spines["bottom"].set_bounds(0, 100)
ax.grid(axis="y", visible=False); ax.set_title("Salud: Ensanut Continua 2020-2024 (INSP)"); ax.legend(loc="center right", fontsize=10.5)
fig.text(0.03, 0.118, "La línea oscura sobre cada barra marca el intervalo de confianza de 95%.\n"
         "* Hicieron al menos 60 minutos de actividad en 4 o más de los últimos 7 días. Actividad y pantallas: rondas 2022-2024.",
         fontsize=9.5, color=MUTED, va="top", ha="left", linespacing=1.35)
ax = axs[1]
STY = {"México": (ORANGE, "o", 2.8), "Promedio OCDE": (GRAY, "D", 1.8)}
for l in ("México", "Promedio OCDE"):
    s = oser("Matemáticas", l) + [(2025, float(p25v("Matemáticas", l)))]; c, m, w = STY[l]
    ax.plot([a for a, _ in s], [b for _, b in s], color=c, lw=w, marker=m, ms=6, label=l)
    ax.text(s[-1][0] + 0.8, s[-1][1], f"{s[-1][1]:.0f}", va="center", fontsize=11.5, fontweight="bold" if l == "México" else "normal")
ax.set_ylim(360, 520); ax.set_xlim(2002, 2029.5); ax.set_xticks([2003, 2009, 2015, 2025]); ax.set_title("Aprendizaje: PISA (OCDE),\nmatemáticas a los 15 años"); ax.set_ylabel("Puntaje medio"); ax.legend(loc="center right", fontsize=10)

# El título y el subtítulo sólo valen mientras los datos los respalden: si la tabla cambia, que falle aquí y no en la lámina
# "casi 4 de cada 10": en México y en Sonora cada grupo de edad está entre 35% y 40.5%, y el promedio simple de los dos grupos queda abajo de 40%
for reg, _, _ in REG:
    peso = [d[(i, reg)]["v"] for i in (0, 1)]
    assert all(35 <= v < 40.5 for v in peso) and sum(peso) / len(peso) < 40, f"'casi 4 de cada 10' ya no describe el sobrepeso u obesidad en {reg}: {peso}"
# "la mayoría de 10 a 14 años no es activa": el límite superior del intervalo de los activos queda abajo de 50%
assert all(d[(2, reg)]["hi"] < 50 for reg, _, _ in REG), "'la mayoría no es activa' ya no se sostiene"
se_traslapan = all(d[(i, "Sonora")]["lo"] <= d[(i, "Nacional")]["hi"] and d[(i, "Nacional")]["lo"] <= d[(i, "Sonora")]["hi"] for i in range(len(FILAS)))
ns = [d[(i, "Sonora")]["n"] for i in range(len(FILAS))]
sonora = (f"Los intervalos de Sonora son anchos (de {min(ns)} a {max(ns)} casos por indicador) y se traslapan con los nacionales: no permiten decir que Sonora esté mejor ni peor."
          if se_traslapan else f"Los intervalos de Sonora son anchos (de {min(ns)} a {max(ns)} casos por indicador).")
finish(fig, "fig_13_mexico_contexto.png",
       "En México y en Sonora, casi 4 de cada 10 niñas, niños y adolescentes tienen sobrepeso u obesidad, y la mayoría de 10 a 14 años no es activa",
       f"Estimación nacional y de Sonora. {sonora} En PISA 2025 México quedó {oe25 - mx25:.0f} puntos abajo del promedio OCDE en matemáticas "
       f"({mx25:.0f} contra {oe25:.0f}) y {mx22[2022] - mx25:.0f} abajo de su resultado de 2022.", SRC, bottom=0.185, left=IZQ)
