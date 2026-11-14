#!/usr/bin/env python3
"""EDA 1: perfil de astronautas (astronauts_missions.csv, una fila por astronauta-misión, 1961-2019).

Salidas: eda/tables/astro_*.csv y eda/figures/fig_0[1-6]_*.png
Decisiones de limpieza (ver también FINDINGS.md):
  * Persona = (number, name): el `number` 385 lo comparten Baturin y Duque (error de la fuente) y
    "Aleksandrov, Aleksandr" son dos personas distintas (numbers 123 y 209).
  * Turistas / participantes de vuelo (12 filas, 11 personas) se excluyen de las estadísticas de "carrera"
    (edad de selección, militar/civil) porque su "selección" es un contrato comercial.
  * hours_mission == 0 (Challenger STS-51-L, aborto Soyuz MS-10) se excluye de la duración.
  * La base sólo contiene gente que SÍ voló hasta 2019: la década de selección 2010s está incompleta (n pequeño).
"""
import collections
from common import *

SRC = "Stavnichuk & Corlett (2020), base de astronautas vía TidyTuesday 2020-07-14; cálculo propio"
rows = read_csv(RAW / "nasa" / "astronauts_missions.csv")
for r in rows:
    for k in ("year_of_birth", "year_of_selection", "mission_number", "total_number_of_missions", "year_of_mission"):
        r[k] = int(r[k])
    for k in ("hours_mission", "total_hrs_sum", "eva_hrs_mission", "total_eva_hrs"):
        r[k] = float(r[k])
    r["pid"] = (r["number"], r["name"])
    occ = r["occupation"].lower()
    r["tourist"] = any(t in occ for t in ("tourist", "participant", "journalist"))
    r["role"] = ("Turista/participante" if r["tourist"] else
                 "Comandante/piloto" if occ in ("commander", "pilot") else
                 "Especialista/ingeniero de vuelo")  # MSP, PSP, flight engineer
    n = r["nationality"]
    r["grupo_pais"] = "EE.UU." if n == "U.S." else "URSS/Rusia" if n.startswith("U.S.S.R") else "Otros países"
    r["decada_mision"] = r["year_of_mission"] // 10 * 10

# ---- one row per person (first mission row) -------------------------------------------------
people = {}
for r in sorted(rows, key=lambda r: (r["pid"], r["mission_number"], r["year_of_mission"])):
    p = people.setdefault(r["pid"], dict(r, roles=set(), n_rows=0, first_mission_year=r["year_of_mission"]))
    p["roles"].add(r["role"]); p["n_rows"] += 1
    p["first_mission_year"] = min(p["first_mission_year"], r["year_of_mission"])
    p["tourist"] = p["tourist"] or r["tourist"]
P = list(people.values())
for p in P:
    p["edad_seleccion"] = p["year_of_selection"] - p["year_of_birth"]
    p["edad_primer_vuelo"] = p["first_mission_year"] - p["year_of_birth"]
    p["espera_anios"] = p["first_mission_year"] - p["year_of_selection"]
    d = p["year_of_selection"] // 10 * 10
    p["decada_sel"] = 1960 if d == 1950 else d  # 7 Mercury (1959) se suman a los 60
CAREER = [p for p in P if not p["tourist"]]
print(f"filas={len(rows)} personas={len(P)} carrera={len(CAREER)} turistas/participantes={len(P)-len(CAREER)}")
DEC = sorted({p["decada_sel"] for p in CAREER})
DLAB = {1960: "1959-69", 1970: "1970s", 1980: "1980s", 1990: "1990s", 2000: "2000s", 2010: "2010-18*"}

# ---- 1. militar vs civil por década de selección y grupo de país ---------------------------
t = []
for d in DEC:
    for g in ("Todos", "EE.UU.", "URSS/Rusia", "Otros países"):
        s = [p for p in CAREER if p["decada_sel"] == d and (g == "Todos" or p["grupo_pais"] == g)]
        civ = sum(p["military_civilian"] == "civilian" for p in s)
        t.append({"decada_seleccion": DLAB[d], "grupo_pais": g, "n": len(s), "civiles": civ, "militares": len(s) - civ,
                  "pct_civiles": round(pct(civ, len(s)), 1) if s else ""})
write_csv("astro_militar_civil_por_decada.csv", t)
T = {(x["decada_seleccion"], x["grupo_pais"]): x for x in t}
allciv = sum(p["military_civilian"] == "civilian" for p in CAREER)
print(f"civiles (carrera, todas las décadas): {allciv}/{len(CAREER)} = {pct(allciv, len(CAREER)):.1f}%")
for d in DEC:
    print("  ", DLAB[d], {g: (T[(DLAB[d], g)]["pct_civiles"], T[(DLAB[d], g)]["n"]) for g in ("Todos", "EE.UU.", "URSS/Rusia", "Otros países")})

# role mix by mission decade (seat-level)
t2 = []
for d in sorted({r["decada_mision"] for r in rows}):
    s = [r for r in rows if r["decada_mision"] == d]
    c = collections.Counter(r["role"] for r in s)
    t2.append({"decada_mision": d, "asientos": len(s), **{k: c[k] for k in ("Comandante/piloto", "Especialista/ingeniero de vuelo", "Turista/participante")},
               "pct_especialista": round(pct(c["Especialista/ingeniero de vuelo"], len(s)), 1),
               "pct_civiles": round(pct(sum(r["military_civilian"] == "civilian" for r in s), len(s)), 1)})
write_csv("astro_roles_por_decada_mision.csv", t2)

R = {x["decada_mision"]: x for x in t2}
fig, (a1, a2) = fig_ax(ncols=2, gridspec_kw={"wspace": 0.2})
md = sorted(R); xs = list(range(len(md)))
esp = [R[d]["pct_especialista"] for d in md]
a1.bar(xs, esp, color=BLUE, width=0.62)
for i, d in enumerate(md):
    a1.text(i, esp[i] + 1.5, f"{esp[i]:.0f}%", ha="center", va="bottom", fontweight="bold", fontsize=13)
    a1.text(i, -0.075, f"n={R[d]['asientos']}", ha="center", va="top", fontsize=9.5, color=MUTED, transform=a1.get_xaxis_transform())
a1.set_xticks(xs); a1.set_xticklabels([f"{d}s" for d in md]); a1.set_ylim(0, 100); a1.set_yticks([0, 25, 50, 75, 100])
a1.set_ylabel("% de los asientos de la década"); a1.grid(axis="x", visible=False)
a1.set_xlabel("Década de la misión", labelpad=20)
a1.set_title("Asientos de especialista o ingeniero de vuelo\n(el resto: comandante o piloto)")
x = list(range(len(DEC))); civ = [T[(DLAB[d], "Todos")]["pct_civiles"] for d in DEC]; ns = [T[(DLAB[d], "Todos")]["n"] for d in DEC]
a2.bar(x, civ, color=[ORANGE if d != 2010 else "#f6c4b0" for d in DEC], width=0.62)
for i, (c, n) in enumerate(zip(civ, ns)):
    a2.text(i, c + 1.5, f"{c:.0f}%", ha="center", va="bottom", fontweight="bold", fontsize=13)
    a2.text(i, -0.075, f"n={n}", ha="center", va="top", fontsize=9.5, color=MUTED, transform=a2.get_xaxis_transform())
a2.set_xticks(x); a2.set_xticklabels([DLAB[d] for d in DEC]); a2.set_ylim(0, 100); a2.set_yticks([0, 25, 50, 75, 100])
a2.set_ylabel("% de los astronautas seleccionados"); a2.set_xlabel("Década de selección", labelpad=20); a2.grid(axis="x", visible=False)
a2.set_title("Astronautas civiles (el resto: militares)\n ")
c60, c90, c00 = (T[(DLAB[d], "Todos")]["pct_civiles"] for d in (1960, 1990, 2000))
finish(fig, "fig_01_militar_a_civil.png",
       f"Ya no es sólo cosa de pilotos: los especialistas pasaron de {R[1960]['pct_especialista']:.0f}% de los asientos (años 60) a ~{R[1990]['pct_especialista']:.0f}% (años 90)",
       f"Izquierda: {len(rows)} vuelos individuales 1961-2019 según el puesto. Derecha: {len(CAREER)} astronautas de carrera según su origen; los civiles subieron de "
       f"{c60:.0f}% a {c90:.0f}%, pero los militares siguen siendo mayoría. *2010-18 incompleto: sólo quienes ya habían volado en 2019.", SRC, bottom=0.17)

# ---- 2. edad de selección -------------------------------------------------------------------
ages = [p["edad_seleccion"] for p in CAREER]
med, q1, q3 = median(ages), quantile(ages, .25), quantile(ages, .75)
p10, p90 = quantile(ages, .10), quantile(ages, .90)
af = [p["edad_primer_vuelo"] for p in CAREER]; wait = [p["espera_anios"] for p in CAREER]
print(f"edad selección carrera: mediana={med} IQR={q1}-{q3} p10-p90={p10}-{p90} min={min(ages)} max={max(ages)}")
print(f"edad primer vuelo: mediana={median(af)} IQR={quantile(af,.25)}-{quantile(af,.75)}; espera selección→vuelo mediana={median(wait)} IQR={quantile(wait,.25)}-{quantile(wait,.75)}")
t = []
for d in DEC + ["Todas"]:
    for g in ("Todos", "EE.UU.", "URSS/Rusia", "Otros países"):
        s = [p for p in CAREER if (d == "Todas" or p["decada_sel"] == d) and (g == "Todos" or p["grupo_pais"] == g)]
        if not s: continue
        a = [p["edad_seleccion"] for p in s]; f = [p["edad_primer_vuelo"] for p in s]; w = [p["espera_anios"] for p in s]
        t.append({"decada_seleccion": DLAB.get(d, d), "grupo_pais": g, "n": len(s), "edad_sel_mediana": median(a),
                  "edad_sel_q1": quantile(a, .25), "edad_sel_q3": quantile(a, .75), "edad_sel_min": min(a), "edad_sel_max": max(a),
                  "edad_primer_vuelo_mediana": median(f), "espera_mediana_anios": median(w),
                  "espera_q1": quantile(w, .25), "espera_q3": quantile(w, .75)})
write_csv("astro_edad_seleccion_por_decada.csv", t)
TA = {(x["decada_seleccion"], x["grupo_pais"]): x for x in t}
for sx in ("male", "female"):
    a = [p["edad_seleccion"] for p in CAREER if p["sex"] == sx]; print(f"   edad sel {sx}: mediana={median(a)} n={len(a)}")
dist = collections.Counter(ages)
write_csv("astro_edad_seleccion_distribucion.csv", [{"edad_seleccion": k, "personas": dist[k]} for k in sorted(dist)])
share_26_40 = pct(sum(26 <= a <= 40 for a in ages), len(ages))

fig, (a1, a2) = fig_ax(ncols=2, gridspec_kw={"width_ratios": [1.5, 1], "wspace": 0.2})
ks = list(range(min(ages), max(ages) + 1))
a1.bar(ks, [dist[k] for k in ks], color=[BLUE if q1 <= k <= q3 else "#9ec5f4" for k in ks], width=0.86)
a1.axvline(med, color=INK, lw=1.6, ls="--")
a1.text(med + 0.4, max(dist.values()) * 1.02, f"Mediana: {med:.0f} años", fontweight="bold", fontsize=13, va="bottom")
a1.text(q3 + 4.2, max(dist.values()) * 0.72, f"La mitad central:\n{q1:.0f} a {q3:.0f} años\n\n{share_26_40:.0f}% fue seleccionado\nentre los 26 y los 40", fontsize=11.5, color=INK2, va="top")
a1.set_xlabel("Edad al ser seleccionado (año de selección − año de nacimiento)"); a1.set_ylabel("Número de astronautas")
a1.grid(axis="x", visible=False); a1.set_ylim(0, max(dist.values()) * 1.14); a1.set_title("Distribución de la edad de selección")
xs = list(range(len(DEC)))
a2.fill_between(xs, [TA[(DLAB[d], "Todos")]["edad_sel_q1"] for d in DEC], [TA[(DLAB[d], "Todos")]["edad_sel_q3"] for d in DEC], color="#cde2fb", label="Rango intercuartil")
a2.plot(xs, [TA[(DLAB[d], "Todos")]["edad_sel_mediana"] for d in DEC], color=BLUE, marker="o", label="Edad mediana de selección")
a2.plot(xs, [TA[(DLAB[d], "Todos")]["edad_primer_vuelo_mediana"] for d in DEC], color=ORANGE, marker="s", label="Edad mediana al primer vuelo")
for i, d in enumerate(DEC):
    a2.text(i, TA[(DLAB[d], "Todos")]["edad_sel_mediana"] - 1.1, f'{TA[(DLAB[d], "Todos")]["edad_sel_mediana"]:.0f}', ha="center", va="top", fontsize=10.5, color=INK2)
    a2.text(i, TA[(DLAB[d], "Todos")]["edad_primer_vuelo_mediana"] + 0.7, f'{TA[(DLAB[d], "Todos")]["edad_primer_vuelo_mediana"]:.0f}', ha="center", va="bottom", fontsize=10.5, color=INK2)
a2.set_xticks(xs); a2.set_xticklabels([DLAB[d] for d in DEC], fontsize=10.5); a2.set_ylim(22, 50); a2.set_ylabel("Edad (años)")
a2.set_title("Por década de selección"); a2.legend(loc="upper left", fontsize=10.5)
finish(fig, "fig_02_edad_seleccion.png",
       f"Edad mediana de selección: {med:.0f} años. Desde 4.º de primaria (9 años) hay ~{med-9:.0f} años de pista",
       f"Astronautas de carrera que volaron 1961-2019 (n={len(CAREER)}; sin turistas). La edad se calcula con años calendario (±1 año). "
       "*2010-18 incompleto.", SRC)

# ---- 3. duración de misiones y EVA ----------------------------------------------------------
M = [r for r in rows if r["hours_mission"] > 0]
t = []
for d in sorted({r["decada_mision"] for r in M}):
    s = [r for r in M if r["decada_mision"] == d]; allr = [r for r in rows if r["decada_mision"] == d]
    days = [r["hours_mission"] / 24 for r in s]
    t.append({"decada_mision": d, "asientos_con_duracion": len(s), "dias_mediana": round(median(days), 1),
              "dias_q1": round(quantile(days, .25), 1), "dias_q3": round(quantile(days, .75), 1), "dias_media": round(sum(days) / len(days), 1),
              "pct_30_dias_o_mas": round(pct(sum(x >= 30 for x in days), len(days)), 1),
              "pct_150_dias_o_mas": round(pct(sum(x >= 150 for x in days), len(days)), 1),
              "horas_eva_total": round(sum(r["eva_hrs_mission"] for r in allr), 1),
              "asientos_con_eva": sum(r["eva_hrs_mission"] > 0 for r in allr),
              "pct_asientos_con_eva": round(pct(sum(r["eva_hrs_mission"] > 0 for r in allr), len(allr)), 1),
              "horas_eva_mediana_si_hubo": round(median([r["eva_hrs_mission"] for r in allr if r["eva_hrs_mission"] > 0]), 1) if any(r["eva_hrs_mission"] > 0 for r in allr) else ""})
write_csv("astro_duracion_eva_por_decada.csv", t)
for x in t: print("  ", x)
ty = []
for y in sorted({r["year_of_mission"] for r in M}):
    days = [r["hours_mission"] / 24 for r in M if r["year_of_mission"] == y]
    ty.append({"anio_mision": y, "asientos": len(days), "dias_mediana": round(median(days), 2), "dias_media": round(sum(days) / len(days), 2),
               "horas_eva_total": round(sum(r["eva_hrs_mission"] for r in rows if r["year_of_mission"] == y), 2)})
write_csv("astro_duracion_eva_por_anio.csv", ty)

fig, (a1, a2) = fig_ax(ncols=2, gridspec_kw={"wspace": 0.22})
dl = [f"{x['decada_mision']}s" for x in t]; xs = list(range(len(t)))
a1.bar(xs, [x["dias_mediana"] for x in t], color=BLUE, width=0.62)
for i, x in enumerate(t):
    a1.text(i, x["dias_mediana"] + 3, f"{x['dias_mediana']:.0f} días" if x["dias_mediana"] >= 10 else f"{x['dias_mediana']:.1f}", ha="center", va="bottom", fontsize=11.5, fontweight="bold")
    a1.text(i, -0.085, f"n={x['asientos_con_duracion']}", ha="center", va="top", fontsize=9.5, color=MUTED, transform=a1.get_xaxis_transform())
a1.set_xticks(xs); a1.set_xticklabels(dl); a1.set_ylabel("Días en el espacio por misión (mediana)"); a1.grid(axis="x", visible=False)
a1.set_title("Duración mediana de una misión"); a1.set_ylim(0, max(x["dias_mediana"] for x in t) * 1.15)
a2.bar(xs, [x["pct_150_dias_o_mas"] for x in t], color=ORANGE, width=0.62)
for i, x in enumerate(t):
    a2.text(i, x["pct_150_dias_o_mas"] + 1.2, f"{x['pct_150_dias_o_mas']:.0f}%", ha="center", va="bottom", fontsize=11.5, fontweight="bold")
a2.set_xticks(xs); a2.set_xticklabels(dl); a2.set_ylabel("% de misiones individuales"); a2.grid(axis="x", visible=False)
a2.set_title("Misiones de 150 días o más (≈5 meses)"); a2.set_ylim(0, max(x["pct_150_dias_o_mas"] for x in t) * 1.18)
D = {x["decada_mision"]: x for x in t}
finish(fig, "fig_03_misiones_mas_largas.png",
       f"Las misiones se alargan: de {D[1980]['dias_mediana']:.0f} días (años 80) a {D[2010]['dias_mediana']:.0f} días (2010s) de mediana",
       "Cada barra resume los vuelos individuales (un asiento = una persona en una misión) por década de la misión, 1961-2019. "
       "Se excluyen 6 vuelos con 0 h (Challenger, aborto Soyuz MS-10).", SRC, bottom=0.15)

fig, (a1, a2) = fig_ax(ncols=2, gridspec_kw={"wspace": 0.22})
a1.bar(xs, [x["horas_eva_total"] for x in t], color=AQUA, width=0.62)
for i, x in enumerate(t): a1.text(i, x["horas_eva_total"] + 15, f"{x['horas_eva_total']:,.0f} h", ha="center", va="bottom", fontsize=11.5, fontweight="bold")
a1.set_xticks(xs); a1.set_xticklabels(dl); a1.set_ylabel("Horas-persona de caminata espacial"); a1.grid(axis="x", visible=False); a1.set_title("Horas totales de EVA por década"); a1.set_ylim(0, max(x["horas_eva_total"] for x in t) * 1.12)
a2.bar(xs, [x["pct_asientos_con_eva"] for x in t], color=AQUA, width=0.62)
for i, x in enumerate(t): a2.text(i, x["pct_asientos_con_eva"] + 0.8, f"{x['pct_asientos_con_eva']:.0f}%", ha="center", va="bottom", fontsize=11.5, fontweight="bold")
a2.set_xticks(xs); a2.set_xticklabels(dl); a2.set_ylabel("% de vuelos individuales con al menos una EVA"); a2.grid(axis="x", visible=False); a2.set_title("¿En cuántos vuelos hubo caminata espacial?"); a2.set_ylim(0, max(x["pct_asientos_con_eva"] for x in t) * 1.12)
finish(fig, "fig_04_eva_caminatas.png",
       f"Caminatas espaciales (EVA): de {D[1960]['horas_eva_total']:,.0f} horas-persona en los 60 a {D[2000]['horas_eva_total']:,.0f} en los 2000",
       "EVA = actividad extravehicular. Suma de eva_hrs_mission de todos los astronautas por década de la misión. 2010s llega hasta 2019.", SRC)

# ---- 4. mujeres -----------------------------------------------------------------------------
t = []
for d in DEC:
    s = [p for p in CAREER if p["decada_sel"] == d]; w = sum(p["sex"] == "female" for p in s)
    t.append({"eje": "decada_seleccion (personas de carrera)", "decada": DLAB[d], "n": len(s), "mujeres": w, "pct_mujeres": round(pct(w, len(s)), 1)})
for d in sorted({r["decada_mision"] for r in rows}):
    s = [r for r in rows if r["decada_mision"] == d]; w = sum(r["sex"] == "female" for r in s)
    t.append({"eje": "decada_mision (asientos, todos)", "decada": f"{d}s", "n": len(s), "mujeres": w, "pct_mujeres": round(pct(w, len(s)), 1)})
write_csv("astro_mujeres_por_decada.csv", t)
wall = sum(p["sex"] == "female" for p in P)
print(f"mujeres: {wall}/{len(P)} personas = {pct(wall, len(P)):.1f}%; asientos {sum(r['sex']=='female' for r in rows)}/{len(rows)}")
tw = [x for x in t if x["eje"].startswith("decada_sel")]
tg = []
for g in ("EE.UU.", "URSS/Rusia", "Otros países"):
    s = [p for p in P if p["grupo_pais"] == g]; w = sum(p["sex"] == "female" for p in s)
    tg.append({"grupo_pais": g, "personas": len(s), "mujeres": w, "pct_mujeres": round(pct(w, len(s)), 1)})
write_csv("astro_mujeres_por_pais.csv", tg); print("  ", tg)
fig, ax = fig_ax()
xs = list(range(len(tw)))
ax.bar(xs, [x["pct_mujeres"] for x in tw], color=MAGENTA, width=0.6)
for i, x in enumerate(tw):
    ax.text(i, x["pct_mujeres"] + 0.8, f"{x['pct_mujeres']:.0f}%", ha="center", va="bottom", fontsize=14, fontweight="bold")
    ax.text(i, -0.075, f"{x['mujeres']} de {x['n']}", ha="center", va="top", fontsize=10.5, color=MUTED, transform=ax.get_xaxis_transform())
ax.axhline(50, color=INK2, lw=1.2, ls="--"); ax.text(len(tw) - 0.55, 51, "Paridad (50%)", ha="right", color=INK2, fontsize=11)
ax.set_xticks(xs); ax.set_xticklabels([x["decada"] for x in tw]); ax.set_ylim(0, 58); ax.set_ylabel("% de mujeres entre los seleccionados"); ax.grid(axis="x", visible=False)
ax.set_xlabel("Década de selección", labelpad=22)
finish(fig, "fig_05_mujeres.png",
       f"Sólo {pct(wall, len(P)):.0f}% de quienes han ido al espacio son mujeres ({wall} de {len(P)}); ninguna década llega a la paridad",
       "% de mujeres entre astronautas de carrera que volaron, por década de selección. *2010-18 incompleto (n pequeño).", SRC, bottom=0.17)

# ---- 5. nacionalidades ----------------------------------------------------------------------
nat = collections.Counter(p["nationality"] for p in P)
seats = collections.Counter(r["nationality"] for r in rows)
FIX = {"Hungry": "Hungría", "Malysia": "Malasia", "Netherland": "Países Bajos", "U.S.": "EE.UU.", "U.S.S.R/Russia": "URSS/Rusia",
       "U.S.S.R/Ukraine": "URSS/Ucrania", "U.K./U.S.": "Reino Unido/EE.UU.", "U.K.": "Reino Unido", "Japan": "Japón", "France": "Francia",
       "Canada": "Canadá", "Germany": "Alemania", "Italy": "Italia", "Switzerland": "Suiza", "Belgium": "Bélgica", "Spain": "España",
       "Sweden": "Suecia", "Mexico": "México", "Brazil": "Brasil", "Republic of South Africa": "Sudáfrica", "Korea": "Corea del Sur",
       "Saudi Arabia": "Arabia Saudita", "Syria": "Siria", "Afghanistan": "Afganistán", "Denmark": "Dinamarca", "Kazakhstan": "Kazajistán",
       "Czechoslovakia": "Checoslovaquia", "Poland": "Polonia", "Romania": "Rumania", "Slovakia": "Eslovaquia", "UAE": "Emiratos Árabes"}
t = [{"nacionalidad_fuente": k, "nacionalidad_es": FIX.get(k, k), "personas": v, "asientos_mision": seats[k], "pct_personas": round(pct(v, len(P)), 2)}
     for k, v in nat.most_common()]
write_csv("astro_nacionalidades.csv", t)
mx = [r for r in rows if r["nationality"] == "Mexico"]
latam = {k: nat[k] for k in ("Mexico", "Cuba", "Brazil")}
top2 = nat["U.S."] + nat["U.S.S.R/Russia"]
print(f"países={len(nat)}; EE.UU.+URSS/Rusia={top2}/{len(P)}={pct(top2,len(P)):.1f}%; LatAm por bandera={latam}; México={[(r['name'], r['year_of_mission'], r['mission_title'], r['hours_mission']) for r in mx]}")
print("   José Hernández:", [(r["name"], r["nationality"], r["year_of_mission"], r["mission_title"]) for r in rows if r["name"].startswith("Hernandez")])
fig, ax = fig_ax()
others = [x for x in t if x["nacionalidad_fuente"] not in ("U.S.", "U.S.S.R/Russia")]
big = [x for x in others if x["personas"] >= 2]; one = [x for x in others if x["personas"] == 1]
labs = ["EE.UU.", "URSS/Rusia"] + [x["nacionalidad_es"] for x in big] + ["México", f"Otros {len(one)-1} países con 1"]
vals = [nat["U.S."], nat["U.S.S.R/Russia"]] + [x["personas"] for x in big] + [1, len(one) - 1]
cols = [GRAY] * (len(labs) - 2) + [ORANGE, GRAY]
ys = list(range(len(labs)))[::-1]
ax.barh(ys, vals, color=cols, height=0.66)
for y, v, l in zip(ys, vals, labs):
    ax.text(v + 3, y, f"{v}" + ("  ← Rodolfo Neri Vela, STS-61-B, 1985" if l == "México" else ""), va="center", fontsize=11.5, fontweight="bold" if l == "México" else "normal")
ax.set_yticks(ys); ax.set_yticklabels(labs, fontsize=11); ax.set_xlabel("Personas que han volado al espacio (1961-2019)"); ax.grid(axis="y", visible=False)
ax.set_xlim(0, nat["U.S."] * 1.12)
finish(fig, "fig_06_nacionalidades.png",
       f"{pct(top2, len(P)):.0f}% de los astronautas son de EE.UU. o URSS/Rusia; México aparece una sola vez en 58 años",
       f"{len(P)} personas de {len(nat)} banderas. La nacionalidad es la de la misión: José Hernández (2009) cuenta como EE.UU. "
       "La base termina en 2019 (no incluye a Katya Echazarreta, 2022).", SRC, left=0.17)

# ---- 6. espera selección → primer vuelo -----------------------------------------------------
t = [{"decada_seleccion": DLAB[d], "n": TA[(DLAB[d], "Todos")]["n"], "espera_mediana_anios": TA[(DLAB[d], "Todos")]["espera_mediana_anios"],
      "espera_q1": TA[(DLAB[d], "Todos")]["espera_q1"], "espera_q3": TA[(DLAB[d], "Todos")]["espera_q3"]} for d in DEC]
write_csv("astro_espera_seleccion_a_vuelo.csv", t)
fig, ax = fig_ax()
xs = list(range(len(t)))
ax.bar(xs, [x["espera_mediana_anios"] for x in t], color=VIOLET, width=0.6)
ax.errorbar(xs, [x["espera_mediana_anios"] for x in t], yerr=[[x["espera_mediana_anios"] - x["espera_q1"] for x in t], [x["espera_q3"] - x["espera_mediana_anios"] for x in t]],
            fmt="none", ecolor=INK2, capsize=5, lw=1.4)
for i, x in enumerate(t):
    ax.text(i + 0.08, x["espera_mediana_anios"] + 0.15, f"{x['espera_mediana_anios']:g} años", ha="left", va="bottom", fontsize=13, fontweight="bold")
    ax.text(i, -0.075, f"n={x['n']}", ha="center", va="top", fontsize=10.5, color=MUTED, transform=ax.get_xaxis_transform())
ax.set_xticks(xs); ax.set_xticklabels([x["decada_seleccion"] for x in t]); ax.set_ylabel("Años entre la selección y el primer vuelo"); ax.grid(axis="x", visible=False)
ax.set_xlabel("Década de selección", labelpad=22)
finish(fig, "fig_07_espera_primer_vuelo.png",
       f"Ser seleccionado no es volar: la espera mediana hasta el primer vuelo es de {median(wait):.0f} años",
       f"Barra = mediana; línea = rango intercuartil. Astronautas de carrera (n={len(CAREER)}). *2010-18 sesgado a la baja: sólo incluye a quienes ya volaron.",
       SRC, bottom=0.17)

# ---- resumen de números clave ---------------------------------------------------------------
key = [
    {"metrica": "filas (astronauta-misión)", "valor": len(rows)}, {"metrica": "personas únicas (number+name)", "valor": len(P)},
    {"metrica": "personas de carrera (sin turistas/participantes)", "valor": len(CAREER)},
    {"metrica": "edad selección mediana", "valor": med}, {"metrica": "edad selección q1", "valor": q1}, {"metrica": "edad selección q3", "valor": q3},
    {"metrica": "edad selección p10", "valor": p10}, {"metrica": "edad selección p90", "valor": p90},
    {"metrica": "edad selección min", "valor": min(ages)}, {"metrica": "edad selección max", "valor": max(ages)},
    {"metrica": "% seleccionados entre 26 y 40", "valor": round(share_26_40, 1)},
    {"metrica": "edad primer vuelo mediana", "valor": median(af)}, {"metrica": "espera selección→primer vuelo mediana (años)", "valor": median(wait)},
    {"metrica": "% civiles (carrera, todas las décadas)", "valor": round(pct(allciv, len(CAREER)), 1)},
    {"metrica": "mujeres (personas)", "valor": wall}, {"metrica": "% mujeres (personas)", "valor": round(pct(wall, len(P)), 1)},
    {"metrica": "banderas distintas", "valor": len(nat)}, {"metrica": "% personas EE.UU. + URSS/Rusia", "valor": round(pct(top2, len(P)), 1)},
    {"metrica": "personas con bandera México", "valor": nat["Mexico"]},
    {"metrica": "misión más larga (días)", "valor": round(max(r["hours_mission"] for r in rows) / 24, 1)},
]
write_csv("astro_numeros_clave.csv", key)
