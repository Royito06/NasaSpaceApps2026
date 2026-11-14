#!/usr/bin/env python3
"""EDA 4: México frente a EE.UU. y el mundo (fuentes internacionales públicas bajadas con eda/00_fetch_mexico.py).

Entradas en data/raw/mexico/:
  who_NCD_BMI_PLUS2C_*.json  OMS/GHO: obesidad en niños y adolescentes 5-19 años (IMC > +2 DE), estimación cruda (NCD-RisC)
  who_NCD_BMI_PLUS1C_*.json  OMS/GHO: sobrepeso (incluye obesidad) 5-19 años (IMC > +1 DE)
  who_NCD_PAC_ADO_*.json     OMS/GHO: actividad física insuficiente en adolescentes escolarizados de 11-17 años (2016)
  wb_LO.PISA.*.json          Banco Mundial EdStats: medias PISA (sólo llega a 2018; PISA 2022 NO está en esta API)
Salidas: eda/tables/mexico_*.csv, eda/figures/fig_13_mexico_contexto.png
"""
import json
from common import *
MX = RAW / "mexico"
SRC = "OMS Global Health Observatory (NCD_BMI_PLUS2C, NCD_PAC_ADO) ; PISA: OCDE (2023) vía Our World in Data; cálculo propio"
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

fig, axs = fig_ax(ncols=3, gridspec_kw={"wspace": 0.3})
STY = {"México": (ORANGE, "o", 2.8), "EE.UU.": (BLUE, "s", 1.8), "Mundo": (GRAY, "D", 1.8), "Promedio OCDE": (GRAY, "D", 1.8)}
ax = axs[0]
for l in ("México", "EE.UU.", "Mundo"):
    s = [p for p in ser("NCD_BMI_PLUS2C", l) if p[0] >= 1990]; c, m, w = STY[l]
    ax.plot([a for a, _ in s], [b for _, b in s], color=c, lw=w, label=l); ax.text(s[-1][0] + 0.6, s[-1][1], f"{s[-1][1]:.0f}%", va="center", fontsize=11.5, fontweight="bold" if l == "México" else "normal")
ax.set_ylim(0, 30); ax.set_xlim(1990, ob_mx[-1][0] + 5); ax.set_title("Obesidad, 5 a 19 años"); ax.set_ylabel("% de niñas, niños y adolescentes"); ax.legend(loc="upper left", fontsize=10.5)
ax = axs[1]
labs = ["México", "EE.UU.", "Mundo"]; xs = list(range(3))
ax.bar([x - 0.2 for x in xs], [pa[(l, "Mujeres")] for l in labs], width=0.38, color=MAGENTA, label="Mujeres")
ax.bar([x + 0.2 for x in xs], [pa[(l, "Hombres")] for l in labs], width=0.38, color=BLUE, label="Hombres")
for x, l in zip(xs, labs):
    ax.text(x - 0.2, pa[(l, "Mujeres")] + 1, f"{pa[(l, 'Mujeres')]:.0f}%", ha="center", fontsize=11); ax.text(x + 0.2, pa[(l, "Hombres")] + 1, f"{pa[(l, 'Hombres')]:.0f}%", ha="center", fontsize=11)
ax.set_xticks(xs); ax.set_xticklabels(labs); ax.set_ylim(0, 100); ax.grid(axis="x", visible=False); ax.set_title("Actividad física insuficiente,\n11-17 años (2016)")
ax.legend(loc="lower center", ncol=2, fontsize=10.5, bbox_to_anchor=(0.5, -0.2))
ax = axs[2]
for l in ("México", "EE.UU.", "Promedio OCDE"):
    s = oser("Matemáticas", l); c, m, w = STY[l]
    if not s: continue
    ax.plot([a for a, _ in s], [b for _, b in s], color=c, lw=w, marker=m, ms=6 if len(s) > 1 else 9, label=l)
    ax.text(s[-1][0] + 0.6, s[-1][1], f"{s[-1][1]:.0f}", va="center", fontsize=11.5, fontweight="bold" if l == "México" else "normal")
ax.set_ylim(360, 520); ax.set_xlim(2002, 2026.5); ax.set_xticks([2003, 2009, 2015, 2022]); ax.set_title("PISA matemáticas,\nestudiantes de 15 años"); ax.set_ylabel("Puntaje medio"); ax.legend(loc="lower right", fontsize=10)
mxp, oep = mx22, oe22
finish(fig, "fig_13_mexico_contexto.png",
       f"México: la obesidad de 5 a 19 años pasó de {val('NCD_BMI_PLUS2C','México',1990):.0f}% (1990) a {ob_mx[-1][1]:.0f}% ({ob_mx[-1][0]}) y {pa[('México','Total')]:.0f}% de los adolescentes no se mueve lo suficiente",
       f"México frente a EE.UU. y el mundo. En PISA 2022 México obtuvo {mxp[2022]:.0f} puntos en matemáticas, {oep[2022] - mxp[2022]:.0f} menos que el promedio OCDE "
       f"({oep[2022]:.0f}). Son estimaciones internacionales (OMS, OCDE); falta el dato nacional de ENSANUT.", SRC, bottom=0.16)
