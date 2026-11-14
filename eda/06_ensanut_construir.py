#!/usr/bin/env python3
"""Construye eda/tables/mexico_ensanut.csv con las cifras oficiales de Ensanut (INSP) transcritas de las publicaciones listadas en data/raw/mexico/ensanut/FUENTES.md."""
# Aquí no se calcula nada: cada renglón se copió de un cuadro publicado por el INSP y este script sólo lo acomoda como CSV.
# Cada renglón lleva su fuente (cuadro, página, tamaño de muestra) y la URL del PDF del que salió.
# Para comprobar cada cifra contra el texto de su PDF: python3 eda/06_ensanut_verificar.py
# Uso, desde la carpeta del proyecto: python3 eda/06_ensanut_construir.py   (sólo usa la biblioteca estándar)
import csv
from pathlib import Path

OUT = Path(__file__).resolve().parent / "tables" / "mexico_ensanut.csv"

B = "https://ensanut.insp.mx/encuestas/"
U_OB24 = B + "ensanutcontinua2024/doctos/analiticos/17311-Texto%20del%20art%C3%ADculo-92189-1-10-20251118.pdf"
U_EST = B + "ensanutcontinua2024/doctos/analiticos20-24/17642-Texto%20del%20art%C3%ADculo-92946-2-10-20251219.pdf"
U_MOV24 = B + "ensanutcontinua2024/doctos/analiticos/16955-Texto%20del%20art%C3%ADculo-92185-1-10-20251118.pdf"
U_MOV23 = B + "ensanutcontinua2023/doctos/analiticos/15787-Texto%20del%20art%C3%ADculo-82495-2-10-20240821.pdf"
U_MOV22 = B + "ensanutcontinua2022/doctos/analiticos/33-Movimiento.en.poblacion-ENSANUT2022-14754-72522-2-10-20230619.pdf"
U_INF23 = B + "ensanutcontinua2023/doctos/informes/ensanut_23_112024.pdf"
U_DEP22 = B + "ensanutcontinua2022/doctos/analiticos/16-Sintomatologia.depresiva-ENSANUT2022-14827-72384-2-10-20230619.pdf"
U_OB23 = B + "ensanutcontinua2023/doctos/analiticos/15842-Texto%20del%20art%C3%ADculo-82492-3-10-20240822.pdf"

F_OB24 = "Shamah-Levy T y col. Salud Publica Mex 2025;67(6):609-621 (doi:10.21149/17311)"
F_EST = "Shamah-Levy T y col. Resultados estatales de la Ensanut Continua 2020-2024. Salud Publica Mex 2025;67(supl 1):s3-s219 (doi:10.21149/17642)"
F_MOV24 = "Medina C y col. Salud Publica Mex 2025;67(6):562-574 (doi:10.21149/16955)"
F_MOV23 = "Medina C y col. Salud Publica Mex 2024;66(4):435-445 (doi:10.21149/15787)"
F_MOV22 = "Medina C y col. Salud Publica Mex 2023;65(supl 1):S259-S267 (doi:10.21149/14754)"
F_INF23 = "INSP. Encuesta Nacional de Salud y Nutrición Continua 2023. Resultados Nacionales (2024)"
F_DEP22 = "Vázquez-Salas RA y col. Salud Publica Mex 2023;65(supl 1):S117-S125 (doi:10.21149/14827)"
F_OB23 = "Shamah-Levy T y col. Salud Publica Mex 2024;66(4):404-413 (doi:10.21149/15842)"

E2024 = "Ensanut Continua 2020-2024"
E2224 = "Ensanut Continua 2022-2024"
E2124 = "Ensanut Continua 2021-2024"
E2023P = "Ensanut Continua 2020-2023"
E2223 = "Ensanut Continua 2022-2023"
E23 = "Ensanut Continua 2023"
E22 = "Ensanut Continua 2022"
E12 = "Ensanut 2012"

ESC, ADO = "5 a 11 años", "12 a 19 años"
A1014, A1519, A1019 = "10 a 14 años", "15 a 19 años", "10 a 19 años"
T, M, H = "Total", "Mujeres", "Hombres"
NAC, PN, SON = "Nacional", "Pacífico-Norte", "Sonora"

I_SP = "Sobrepeso"
I_OB = "Obesidad"
I_SPOB = "Sobrepeso + obesidad"
I_ACT = "Físicamente activos (al menos 60 min de actividad en 4 o más de los últimos 7 días)"
I_INA = "Físicamente inactivos (no alcanzan 60 min de actividad en 4 o más de los últimos 7 días)"
I_EST = "No hace 60 min de actividad los 7 días de la semana (criterio estricto, guías OMS 2010)"
I_CUM = "Cumple la recomendación de actividad física (promedio de 60 min diarios de actividad moderada-vigorosa)"
I_INA15 = "Físicamente inactivos (no promedian 60 min diarios de actividad moderada-vigorosa)"
I_IN20 = "Inactividad física, criterio OMS 2020 según Medina y col. 2025"
I_IN10 = "Inactividad física, criterio OMS 2010 según Medina y col. 2025"
I_PAN = "Más de 2 horas diarias frente a pantalla"
I_SEN = "Tiempo sentado elevado (más de 420 min al día)"
I_SUE = "Sueño fuera del rango recomendado para la edad"
I_NIN = "No cumple ninguna de las tres recomendaciones (actividad física, pantalla y sueño)"
I_TRE = "Cumple las tres recomendaciones (actividad física, pantalla y sueño)"
I_DEP = "Sintomatología depresiva (CESD-7 de 9 puntos o más; punto de corte provisional, no validado en adolescentes)"
I_NOD = "No durmió bien todo el tiempo o la mayoría del tiempo en la última semana (reactivo de la CESD-7)"
I_UNS = "Presentó al menos un síntoma depresivo frecuente en la última semana (CESD-7)"
I_PUN = "Puntaje promedio de la CESD-7 (escala de 0 a 21 puntos; no es porcentaje)"
I_SUI = "Intento de suicidio alguna vez en la vida"
PEND = "[DATO PENDIENTE]"

rows = []


def r(ind, edad, sexo, region, valor, ic, edicion, fuente, detalle, url):
    rows.append([ind, edad, sexo, region, valor, ic, edicion,
                 fuente + ("; " + detalle if detalle else ""), url])


# ---------- Sobrepeso y obesidad, 5 a 11 años ----------
r(I_SP, ESC, T, NAC, "19.0", "17.8-20.3", E2024, F_OB24, "cuadro I; n=10 979", U_OB24)
r(I_OB, ESC, T, NAC, "17.6", "16.3-18.9", E2024, F_OB24, "cuadro I; n=10 979", U_OB24)
r(I_SPOB, ESC, T, NAC, "36.6", "35.0-38.2", E2024, F_OB24, "cuadro I; n=10 979", U_OB24)
r(I_SPOB, ESC, H, NAC, "38.6", "36.2-41.0", E2024, F_OB24, "cuadro III; n=5 589; CV=3.2%", U_OB24)
r(I_SPOB, ESC, M, NAC, "34.4", "32.2-36.6", E2024, F_OB24, "cuadro III; n=5 390; CV=3.3%", U_OB24)
r(I_SP, ESC, T, PN, "20.9", "18.1-24.1", E2024, F_OB24, "cuadro I; n=1 320", U_OB24)
r(I_OB, ESC, T, PN, "18.4", "15.7-21.5", E2024, F_OB24, "cuadro I; n=1 320", U_OB24)
r(I_SPOB, ESC, T, PN, "39.4", "35.9-42.9", E2024, F_OB24, "cuadro I; n=1 320", U_OB24)
r(I_SP, ESC, T, SON, "18.2", "13.3-24.3", E2024, F_EST, "tabla Sonora, prevalencia 99, p. S182; n=299; CV=15%", U_EST)
r(I_OB, ESC, T, SON, "20.0", "15.2-26.0", E2024, F_EST, "tabla Sonora, prevalencia 100, p. S182; n=299; CV=14%", U_EST)
r(I_SPOB, ESC, T, SON, "38.2", "31.0-46.0", E2024, F_OB24, "cuadro III; n=299; CV=10.0%", U_OB24)
r(I_SPOB, ESC, H, SON, "42.6", "33.9-51.8", E2024, F_OB24, "cuadro III; n=161; CV=10.8%", U_OB24)
r(I_SPOB, ESC, M, SON, "33.6", "23.8-45.1", E2024, F_OB24, "cuadro III; n=138; CV=16.4%", U_OB24)
r(I_SPOB, ESC, T, NAC, "36.5", "35.0-37.9", E2023P, F_OB23, "cuadro I; n=8 363", U_OB23)

# ---------- Sobrepeso y obesidad, 12 a 19 años ----------
r(I_SP, ADO, T, NAC, "23.1", "21.7-24.6", E2024, F_OB24, "cuadro II; n=9 142", U_OB24)
r(I_OB, ADO, T, NAC, "17.0", "15.8-18.2", E2024, F_OB24, "cuadro II; n=9 142", U_OB24)
r(I_SPOB, ADO, T, NAC, "40.1", "38.5-41.8", E2024, F_OB24, "cuadro II; n=9 142", U_OB24)
r(I_SPOB, ADO, H, NAC, "40.2", "37.9-42.5", E2024, F_OB24, "cuadro IV; n=4 487; CV=2.9%", U_OB24)
r(I_SPOB, ADO, M, NAC, "40.1", "37.9-42.2", E2024, F_OB24, "cuadro IV; n=4 655; CV=2.7%", U_OB24)
r(I_SP, ADO, T, PN, "24.1", "19.9-28.9", E2024, F_OB24, "cuadro II; n=1 172", U_OB24)
r(I_OB, ADO, T, PN, "23.1", "19.9-26.7", E2024, F_OB24, "cuadro II; n=1 172", U_OB24)
r(I_SPOB, ADO, T, PN, "47.2", "43.3-51.2", E2024, F_OB24, "cuadro II; n=1 172", U_OB24)
r(I_SP, ADO, T, SON, "21.8", "16.3-28.7", E2024, F_EST, "tabla Sonora, prevalencia 103, p. S182; n=245; CV=14%", U_EST)
r(I_OB, ADO, T, SON, "17.9", "14.2-22.5", E2024, F_EST, "tabla Sonora, prevalencia 104, p. S182; n=245; CV=12%", U_EST)
r(I_SPOB, ADO, T, SON, "39.8", "33.5-46.3", E2024, F_OB24, "cuadro IV; n=245; CV=8.2%", U_OB24)
r(I_SPOB, ADO, H, SON, "42.7", "33.0-53.0", E2024, F_OB24, "cuadro IV; n=118; CV=12.1%", U_OB24)
r(I_SPOB, ADO, M, SON, "36.7", "28.2-46.1", E2024, F_OB24, "cuadro IV; n=127; CV=12.6%", U_OB24)
r(I_SPOB, ADO, T, NAC, "40.4", "38.9-41.9", E2023P, F_OB23, "cuadro I; n=6 746", U_OB23)

# ---------- Actividad física, 10 a 14 años ----------
r(I_ACT, A1014, T, NAC, "34.6", "31.0-38.5", E2224, F_EST, "tabla Nacional, prevalencia 108, p. S26; n=3 029; CV=5%", U_EST)
r(I_ACT, A1014, T, SON, "25.5", "18.1-34.7", E2224, F_EST, "tabla Sonora, prevalencia 108, p. S182; n=77; CV=17%", U_EST)
r(I_INA, A1014, T, NAC, "67.6", "62.4-72.5", E2223, F_MOV23, "cuadro I; n=1 838", U_MOV23)
r(I_INA, A1014, T, NAC, "67.4", "57.5-76.0", E23, F_INF23, "cuadro 8.4.1, p. 187; n=553", U_INF23)
r(I_INA, A1014, M, NAC, "80.6", "70.9-87.6", E23, F_INF23, "cuadro 8.4.1, p. 187; n=272", U_INF23)
r(I_INA, A1014, H, NAC, "57.8", "44.3-70.3", E23, F_INF23, "cuadro 8.4.1, p. 187; n=281", U_INF23)
r(I_INA, A1014, T, NAC, "68.3", "64.2-72.1", E22, F_MOV22, "cuadro II (actividad física 1); n=1 343", U_MOV22)
r(I_INA, A1014, M, NAC, "73.1", "67.7-77.9", E22, F_MOV22, "cuadro II (actividad física 1)", U_MOV22)
r(I_INA, A1014, H, NAC, "64.1", "58.7-69.1", E22, F_MOV22, "cuadro II (actividad física 1)", U_MOV22)
r(I_EST, A1014, T, NAC, "84.5", "81.0-87.4", E22, F_MOV22, "cuadro II (actividad física 2); n=1 343", U_MOV22)
r(I_EST, A1014, M, NAC, "86.4", "81.5-90.2", E22, F_MOV22, "cuadro II (actividad física 2)", U_MOV22)
r(I_EST, A1014, H, NAC, "82.8", "77.8-86.9", E22, F_MOV22, "cuadro II (actividad física 2)", U_MOV22)

# ---------- Actividad física, 15 a 19 años ----------
r(I_CUM, A1519, T, NAC, "53.8", "50.7-56.8", E2224, F_EST, "tabla Nacional, prevalencia 109, p. S26; n=2 561; CV=3%", U_EST)
r(I_CUM, A1519, T, SON, "42.3", "24.2-62.7", E2224, F_EST, "tabla Sonora, prevalencia 109, p. S182; n=59; CV=24%", U_EST)
r(I_INA15, A1519, T, NAC, "46.2", "41.8-50.7", E2223, F_MOV23, "cuadro I; n=1 494", U_MOV23)
r(I_INA15, A1519, T, NAC, "50.1", "42.9-57.4", E23, F_INF23, "cuadro 8.4.3, p. 188; n=534", U_INF23)
r(I_INA15, A1519, M, NAC, "54.1", "44.9-63.1", E23, F_INF23, "cuadro 8.4.3, p. 188; n=303", U_INF23)
r(I_INA15, A1519, H, NAC, "44.6", "35.2-54.5", E23, F_INF23, "cuadro 8.4.3, p. 188; n=231", U_INF23)
r(I_INA15, A1519, T, NAC, "42.6", "38.9-46.4", E22, F_MOV22, "cuadro II (actividad física 1); n=1 063", U_MOV22)
r(I_INA15, A1519, M, NAC, "49.5", "44.0-54.9", E22, F_MOV22, "cuadro II (actividad física 1)", U_MOV22)
r(I_INA15, A1519, H, NAC, "34.8", "29.4-40.7", E22, F_MOV22, "cuadro II (actividad física 1)", U_MOV22)
r(I_EST, A1519, T, NAC, "45.8", "42.0-49.6", E22, F_MOV22, "cuadro II (actividad física 2); n=1 063", U_MOV22)
r(I_IN20, A1519, T, NAC, "32.8", "29.9-35.8", E2224, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_IN20, A1519, M, NAC, "40.9", "36.8-45.1", E2224, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_IN20, A1519, H, NAC, "23.0", "20.0-26.3", E2224, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_IN20, A1519, T, NAC, "28.8", "25.9-31.8", E12, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_IN10, A1519, T, NAC, "35.9", "33.0-38.9", E2224, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_IN10, A1519, M, NAC, "44.3", "40.3-48.4", E2224, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_IN10, A1519, H, NAC, "25.7", "22.5-29.1", E2224, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_IN10, A1519, T, NAC, "32.5", "29.5-35.6", E12, F_MOV24, "cuadro IV, p. 569", U_MOV24)

# ---------- Tiempo frente a pantalla y tiempo sentado ----------
r(I_PAN, A1014, T, NAC, "80.5", "77.3-83.3", E2224, F_EST, "tabla Nacional, prevalencia 107, p. S26; n=3 035; CV=2%", U_EST)
r(I_PAN, A1014, T, SON, "88.1", "76.0-94.6", E2224, F_EST, "tabla Sonora, prevalencia 107, p. S182; n=75; CV=5%", U_EST)
r(I_PAN, A1014, T, NAC, "80.1", "75.0-84.3", E2223, F_MOV23, "cuadro I; n=1 838", U_MOV23)
r(I_PAN, A1014, T, NAC, "76.4", "66.5-84.1", E23, F_INF23, "cuadro 8.4.2, p. 187; n=560", U_INF23)
r(I_PAN, A1014, M, NAC, "76.4", "65.9-84.4", E23, F_INF23, "cuadro 8.4.2, p. 187; n=280", U_INF23)
r(I_PAN, A1014, H, NAC, "76.5", "59.2-87.9", E23, F_INF23, "cuadro 8.4.2, p. 187; n=280", U_INF23)
r(I_PAN, A1519, T, NAC, "91.5", "89.4-93.3", E2223, F_MOV23, "cuadro I; n=1 494", U_MOV23)
r(I_PAN, A1519, T, NAC, "92.5", "89.4-94.8", E23, F_INF23, "cuadro 8.4.4, p. 189; n=522", U_INF23)
r(I_PAN, A1519, M, NAC, "92.8", "88.6-95.6", E23, F_INF23, "cuadro 8.4.4, p. 189; n=294", U_INF23)
r(I_PAN, A1519, H, NAC, "92.0", "87.1-95.2", E23, F_INF23, "cuadro 8.4.4, p. 189; n=228", U_INF23)
r(I_SEN, A1519, T, NAC, "25.0", "22.6-27.6", E2224, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_SEN, A1519, M, NAC, "27.8", "24.4-31.4", E2224, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_SEN, A1519, H, NAC, "21.7", "18.7-25.1", E2224, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_SEN, A1519, T, NAC, "20.3", "17.8-23.1", E12, F_MOV24, "cuadro IV, p. 569", U_MOV24)

# ---------- Sueño ----------
r(I_SUE, A1014, T, NAC, "62.6", "58.6-66.4", E2223, F_MOV23,
  "cuadro I; n=1 838; fuera de 9-11 h a los 10-13 años o de 8-10 h a los 14", U_MOV23)
r(I_SUE, A1519, T, NAC, "34.8", "32.3-37.4", E2224, F_MOV24,
  "cuadro IV, p. 569; fuera de 8-10 h a los 15-17 años o de 7-9 h a los 18-19", U_MOV24)
r(I_SUE, A1519, M, NAC, "34.4", "30.7-38.2", E2224, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_SUE, A1519, H, NAC, "35.2", "31.9-38.7", E2224, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_SUE, A1519, T, NAC, "21.7", "18.9-24.9", E12, F_MOV24, "cuadro IV, p. 569", U_MOV24)
r(I_SUE, A1519, T, NAC, "42.3", "38.5-46.2", E2223, F_MOV23,
  "cuadro I; n=1 494; fuera de 8-10 h a los 15-17 años o de 7-9 h a los 18-19", U_MOV23)

# ---------- Las tres recomendaciones en conjunto ----------
r(I_NIN, A1014, T, NAC, "36.7", "31.9-41.7", E2223, F_MOV23, "cuadro I; n=1 838", U_MOV23)
r(I_NIN, A1519, T, NAC, "13.1", "10.3-16.6", E2223, F_MOV23, "cuadro I; n=1 494", U_MOV23)
r(I_TRE, A1014, T, NAC, "1.5", "0.8-2.5", E22, F_MOV22, "cuadro III (escolares 1)", U_MOV22)
r(I_TRE, A1519, T, NAC, "4.7", "3.2-6.8", E22, F_MOV22, "cuadro III", U_MOV22)

# ---------- Salud mental en adolescentes ----------
r(I_DEP, A1019, T, NAC, "7.0", "5.2-9.4", E23, F_INF23, "cuadro 5.7.1, p. 111; n=1 924", U_INF23)
r(I_NOD, A1019, T, NAC, "20.3", "17.7-23.2", E23, F_INF23, "cuadro 5.7.1, p. 111; n=1 924", U_INF23)
r(I_NOD, A1019, T, NAC, "15.6", "13.6-17.7", E22, F_DEP22, "cuadro III; n=3 547", U_DEP22)
r(I_UNS, A1019, T, NAC, "45.8", "", E22, F_DEP22, "texto de resultados, p. S121; n=3 547; el artículo no publica IC95% para este valor", U_DEP22)
r(I_PUN, A1019, T, NAC, "3.2", "", E22, F_DEP22, "cuadro III; n=3 547; desviación estándar 3.4 (no es IC95%)", U_DEP22)
r(I_SUI, A1019, T, NAC, "5.6", "5.0-6.3", E2124, F_EST, "tabla Nacional, prevalencia 53, p. S24; n=13 350; CV=6%", U_EST)
r(I_SUI, A1019, T, SON, "3.6", "2.2-5.8", E2124, F_EST, "tabla Sonora, prevalencia 53, p. S180; n=362; CV=25%", U_EST)

# ---------- Huecos ----------
r("Actividad física, tiempo frente a pantalla y sueño", "5 a 9 años", T, NAC, PEND, "", "",
  "Las publicaciones de Ensanut revisadas miden estos comportamientos a partir de los 10 años", "", "")
r("Actividad física, tiempo frente a pantalla y sueño", A1019, T, PN, PEND, "", "",
  "Medina C y col. 2023 sólo muestra el cumplimiento por región en un mapa (figura I), sin cifras", "", "")
r(I_SUE, A1019, T, SON, PEND, "", "",
  "El suplemento de resultados estatales 2020-2024 no incluye sueño; habría que calcularlo con los microdatos del INSP", "", "")
r(I_PAN, A1519, T, SON, PEND, "", "",
  "El suplemento de resultados estatales 2020-2024 sólo reporta pantalla para 10 a 14 años", "", "")
r("Sintomatología depresiva", A1019, T, SON, PEND, "", "",
  "El suplemento de resultados estatales 2020-2024 sólo reporta sintomatología depresiva en adultos", "", "")

with open(OUT, "w", newline="", encoding="utf-8") as fh:
    w = csv.writer(fh, lineterminator="\n")
    w.writerow(["indicador", "grupo_edad", "sexo", "region", "valor", "ic95", "edicion", "fuente", "url"])
    w.writerows(rows)

pendientes = sum(r[4] == PEND for r in rows)
print(f"{len(rows)} renglones ({len(rows) - pendientes} con cifra, {pendientes} marcados {PEND}) -> eda/tables/{OUT.name}")
