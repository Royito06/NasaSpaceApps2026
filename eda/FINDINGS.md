# Hallazgos del EDA para el Entrenador de Misión de Astronauta Junior

Generado el 14-nov-2026 para el pitch de NASA Space Apps Hermosillo. Reordenado el mismo día alrededor del juego: el entregable ahora es un juego interactivo para niñas y niños de ~9 a 14 años que administran una base en la Luna o en Marte (reto oficial "Build a Junior Astronaut Mission Trainer"). Nuestra ventaja es el lado humano de la misión: la salud de la tripulación (equipo, autonomía, alimentación, sueño, actividad física) funciona como recurso del juego junto a energía, comida, blindaje y soporte vital.

> **Aviso sobre el reto.** El texto oficial del reto no se pudo leer desde estas máquinas (spaceappschallenge.org no carga); lo resumido arriba viene de repositorios públicos de otros equipos. Alguien del equipo debe leer la redacción exacta en el sitio de Space Apps.

Todo número de este documento sale de un script de `eda/` y de una tabla en `eda/tables/`, salvo PISA 2025, cuya fuente se indica en su sección. Nada está citado de memoria. Lo que no pudimos calcular aparece como `[DATO PENDIENTE]`.

**Aviso sobre el origen de los datos.** Los datos de México vienen de la OMS y de PISA (OCDE); el dato nacional de ENSANUT lo está preparando otra sesión (ver secciones pendientes). Los datos de jóvenes de EE.UU. (CDC YRBSS, NAEP) pasaron al apéndice: sirven como referencia, no como diagnóstico de México.

## Resumen en una pantalla

Ordenado por cuánto justifica o alimenta al entrenador.

| # | Hallazgo | Número clave | Uso en el juego | Figura |
|---|---|---|---|---|
| 1 | Los riesgos humanos más altos para ir a Marte son de equipo, autonomía y alimentación | 3 de 3 riesgos con calificación máxima 5×5 | Recursos de tripulación del juego y su peso relativo | `fig_08_riesgos_hrp.png` |
| 2 | Las misiones son cada vez más largas | Mediana de 7 días (años 80) a 163 días (2010s) | Duración de una partida y desgaste acumulado | `fig_03_misiones_mas_largas.png` |
| 3 | Lejos de la Tierra, la tripulación resuelve sola | Riesgo de operación autónoma: 5×2 en órbita baja a 5×5 en Marte; retraso de comunicación `[DATO PENDIENTE]` | Mecánica de retraso: la ayuda de "Control de Misión" llega tarde o no llega | `fig_08_riesgos_hrp.png` |
| 4 | En México los hábitos base de niñas y niños están en mal estado | Obesidad 5-19 años de 4% a 18%; 83% de adolescentes sin actividad física suficiente | Por qué el juego conecta la salud de la tripulación con la del jugador | `fig_13_mexico_contexto.png` |
| 5 | La NASA estudia lo que el cuerpo resiente en el espacio | 577 estudios: defensas 213, hueso 115, músculo 105; sueño 3 | Eventos del juego con respaldo en datos abiertos | `fig_09_osdr_temas.png` |
| 6 | México está lejos del promedio OCDE en matemáticas y ciencias | PISA 2025: matemáticas 388 contra 463; 30% alcanza el nivel básico contra 65% | Mecánicas que piden calcular y decidir con números | `fig_13_mexico_contexto.png` (aún con PISA 2022) |
| 7 | El espacio sigue siendo poco diverso | 11% mujeres; México 1 de 565 personas | Tripulación diversa y personajes mexicanos | `fig_05_mujeres.png`, `fig_06_nacionalidades.png` |
| 8 | Hay una pista de ~20 a 25 años entre el jugador y la edad de selección | Edad mediana de selección: 34 años | Mensaje final: "lo que practicas hoy cuenta" | `fig_02_edad_seleccion.png` |

Las figuras están en `eda/figures/` (PNG de 1920 px de ancho, textos en español, con fuente al pie). Lo de EE.UU. y el hallazgo de pilotos y civiles están en el apéndice A.

---

## Hallazgos, del más útil al menos útil para el juego

### 1. Los 3 riesgos humanos con calificación máxima para Marte son de equipo, autonomía y alimentación

- **Número.** El Human Research Program (HRP) de la NASA lista 22 riesgos, 21 activos. Para la misión planetaria a Marte (730 a 1,224 días), sólo 3 tienen la calificación máxima de probabilidad × consecuencia (5×5) en operaciones: **Equipo** (cooperación, coordinación y comunicación), **Operación autónoma sin apoyo de la Tierra** (EIHSO) y **Alimentación y nutrición**. En una misión larga en órbita baja esos mismos riesgos valen 4×2, 5×2 y 5×2.
- **Más números.** 18 de los 20 riesgos con calificación en ambas misiones suben de órbita baja a Marte. 17 de 21 quedan como "requiere mitigación" para Marte. 5 de los 21 pertenecen al elemento de la NASA "Factores Humanos y Desempeño Conductual". De los 7 riesgos con producto ≥ 20, 4 son de conducta o hábitos según nuestra clasificación.
- **Uso en el juego.** Es la base del diseño: los tres riesgos 5×5 son los recursos de tripulación que más pesan, y el salto de órbita baja a Marte justifica que el juego sea más difícil en Marte que en la Luna. El paso de cada riesgo a una mecánica concreta lo prepara otra sesión (ver "Pendiente: tabla riesgo → mecánica").
- **Cómo se calculó.** `eda/02_hrp_osdr.py` lee la tabla de calificaciones por misión de referencia de cada página de riesgo. Tablas: `hrp_riesgos_clasificados.csv`, `hrp_riesgos_por_mision_largo.csv`, `hrp_resumen.csv`.
- **Figura.** `fig_08_riesgos_hrp.png`. Título corregido el 14-nov-2026: "...son de equipo, autonomía y alimentación, y son habilidades que se pueden empezar a formar desde la infancia" (antes decía "se forman desde la infancia", que se leía como afirmación de la NASA).
- **Criterio.** Relevancia (fuente oficial de la NASA) y Validez (el juego practica lo que la NASA califica más alto).
- **Cuidado.**
  - La calificación L×C es oficial. El **producto** (5×5 = 25) y la etiqueta "habilidades que se pueden empezar a formar desde la infancia" son **nuestros**: la NASA no dice que estos riesgos se entrenen en la infancia ni que se mitiguen con juegos o programas escolares.
  - Clasificamos como entrenables 7 riesgos: equipo, salud conductual, sueño, operación autónoma, alimentación, músculo y capacidad aeróbica, y fractura de hueso. Dejamos fuera EVA y condiciones médicas porque dependen del traje y de la capacidad médica a bordo (la relación con primeros auxilios o natación es indirecta).
  - "Actividad física en el crecimiento" para el riesgo de hueso necesita una cita médica antes de usarse.
  - Las páginas se consultaron el 14-nov-2026; las calificaciones cambian cuando el Human System Risk Board las revisa.

### 2. Las misiones se alargan: de 7 a 163 días de mediana

- **Número.** Duración mediana por vuelo individual: 4.0 días (años 60), 9.1 (70), 7.0 (80), 10.0 (90), 12.9 (2000s) y **163.3 días (2010s)**. Los vuelos de 150 días o más pasaron de 0% (años 60) a 8% (años 90) y a **56%** (2010s). El vuelo más largo de la base dura 437.7 días.
- **Caminatas espaciales.** Las horas-persona de EVA pasaron de 36 (años 60) a 1,820 (2000s). La proporción de vuelos con al menos una EVA subió de 21% a 53% (2010s).
- **Uso en el juego.** Escala de tiempo de la partida: una misión a Marte (730 a 1,224 días, hallazgo 1) dura más que el vuelo más largo de la base (437.7 días). En un juego largo los hábitos diarios se acumulan: dormir mal o no hacer ejercicio un día pesa poco, cien días pesan mucho.
- **Cómo se calculó.** `eda/01_astronautas.py`. Tablas: `astro_duracion_eva_por_decada.csv`, `astro_duracion_eva_por_anio.csv`.
- **Figuras.** `fig_03_misiones_mas_largas.png`, `fig_04_eva_caminatas.png`.
- **Criterio.** Relevancia: conecta con el hallazgo 1 (más tiempo aislado, más peso de la conducta y la salud).
- **Cuidado.** El salto de los 2010s se debe en gran parte al retiro del transbordador en 2011: desde entonces casi todos los vuelos son expediciones largas a la Estación Espacial. Es un cambio de tipo de misión, no una subida gradual. Las horas de EVA de los 2010s (1,117) son menores que las de los 2000s (1,820). Se excluyen 6 vuelos con 0 horas (Challenger y el aborto de la Soyuz MS-10).

### 3. Lejos de la Tierra, la tripulación resuelve sola

- **Número.** El riesgo de operación autónoma (EIHSO) pasa de **5×2** en una misión larga en órbita baja a **5×5** en la misión planetaria a Marte (hallazgo 1). El enunciado oficial del riesgo dice: *"Given decreasing real-time ground support for execution of Earth independent critical, complex operations during future exploration missions, there is a possibility of adverse performance outcomes, most consequentially that crew are unable to adequately respond to unanticipated critical malfunctions or execute safety-critical procedures."*
- **Retraso de comunicación Tierra-Marte.** `[DATO PENDIENTE]`. Ningún archivo del EDA trae el retraso de la señal en minutos; no lo calculamos ni lo citamos de memoria. Hay que tomarlo de una página de la NASA y anotar la URL.
- **Uso en el juego.** Mecánica de retraso: en la Luna "Control de Misión" responde casi al instante; en Marte la ayuda llega tarde y la tripulación debe decidir sola. Es el riesgo que más cambia entre destinos y el más fácil de convertir en juego.
- **Cómo se calculó.** Mismo script y tablas que el hallazgo 1 (`hrp_riesgos_clasificados.csv`, columna `enunciado_riesgo`).
- **Criterio.** Relevancia y Creatividad.
- **Cuidado.** El enunciado habla de menos apoyo en tiempo real, no da una cifra de retraso.

### 4. México: obesidad infantil de 4% a 18% y 83% de adolescentes sin actividad física suficiente

- **Número.** Según la OMS, la obesidad en personas de 5 a 19 años en México pasó de **4.4% (1990)** a **18.3% (2024)**; sumando sobrepeso llega a **39.5%**. En 2022 México ocupó el lugar 29 de 199 países (17.7%; EE.UU. 21.6%; mundo 7.7%). En actividad física, **83.2%** de los adolescentes mexicanos de 11 a 17 años no alcanza 60 minutos diarios (mujeres 87.6%, hombres 78.8%; EE.UU. 72.1%; mundo 81.0%; dato de 2016).
- **Uso en el juego.** Es la línea base que justifica conectar la salud de la tripulación con la del jugador: las mismas palancas (comer bien, moverse, dormir) que mantienen viva la base son las que faltan en casa.
- **Cómo se calculó.** `eda/00_fetch_mexico.py` baja los datos y `eda/04_mexico.py` los resume. Tablas: `mexico_numeros_clave.csv`, `mexico_oms_series.csv`, `mexico_oms_ranking_paises.csv`. Crudos en `data/raw/mexico/`.
- **Figura.** `fig_13_mexico_contexto.png`.
- **Criterio.** Impacto: es el dato local que los jueces van a pedir.
- **Cuidado.**
  - Son **estimaciones modeladas** de la OMS (intervalo de la obesidad 2024: 15.9% a 20.8%), no la encuesta nacional. Para el pitch conviene citar ENSANUT (ver "Pendiente: ENSANUT").
  - El dato de actividad física es de 2016.
  - No hay ningún dato de Sonora ni de Hermosillo.

### 5. Los datos abiertos de biología espacial se concentran en defensas, hueso y músculo

- **Número.** De 577 estudios del repositorio OSDR, 322 (56%) son de vuelo espacial y 239 en tierra. Por palabras clave: sistema inmune 213 (37%), hueso 115 (20%), músculo 105 (18%), corazón y vasos 81, ejercicio y contramedidas 59, sueño o ritmo circadiano sólo 3. Músculo o hueso suman 156 estudios (27%). El organismo principal es el ratón (211, 37%); humano (células, tejidos o personas) 115 (20%).
- **Uso en el juego.** Respaldo para las mecánicas de salud física: sin ejercicio la tripulación pierde músculo y hueso, que es lo que más estudia la NASA. `osdr_musculo_hueso_ejemplos.csv` sirve para escoger un estudio concreto y citarlo en un evento del juego. El sueño casi no aparece (3 estudios), así que la mecánica de sueño se apoya en el HRP (hallazgo 1), no en OSDR.
- **Cómo se calculó.** `eda/02_hrp_osdr.py`. Tablas: `osdr_por_tema.csv`, `osdr_por_organismo.csv`, `osdr_por_tipo.csv`, `osdr_musculo_hueso_ejemplos.csv`.
- **Figura.** `fig_09_osdr_temas.png`.
- **Criterio.** Relevancia (uso de datos abiertos de la NASA).
- **Cuidado.** El tema se asigna con palabras clave en título, descripción y factores: es aproximado y un estudio cuenta en varios temas. "Cerebro y estrés" (183) incluye estrés celular, no sólo conducta. Son estudios moleculares, en su mayoría en animales: **no** prueban nada sobre niños. No abrimos los datos de ningún estudio.

### 6. PISA 2025: México con 388 en matemáticas contra 463 del promedio OCDE

- **Número (PISA 2025, publicado el 8-sep-2026).** México obtuvo **388** en matemáticas, **408** en lectura y **414** en ciencias; el promedio OCDE fue 463, 461 y 482. **30%** de los estudiantes mexicanos alcanza al menos el nivel 2 (básico) en matemáticas, contra **65%** en la OCDE.
- **Fuente.** OCDE, *PISA 2025 Results (Volume I): Mexico*, nota de país: https://www.oecd.org/en/publications/pisa-2025-results-volume-i-country-notes_2d4ff9ea-en/mexico_85702d30-en.html. **La página no se pudo abrir desde esta máquina**: las cifras se tomaron del resumen de un buscador que cita esa nota, y coinciden con las que otra sesión encontró en Expansión. Hay que abrir la nota y confirmarlas antes de ponerlas en una lámina. El resumen del buscador también mostraba un 387 en ciencias en un pasaje de la misma página; lo tratamos como error y usamos 414, que es la cifra que se repite.
- **Serie anterior (se conserva).** En PISA 2022 México obtuvo **395** en matemáticas contra 472 del promedio OCDE (77 puntos menos) y había bajado desde 409 en 2018. En PISA 2018 las mujeres mexicanas obtuvieron 403 y los hombres 415. Las tablas traen las medias de matemáticas y lectura de 2003 a 2022: `mexico_pisa_owid_ocde.csv`, `mexico_pisa_banco_mundial.csv`.
- **Uso en el juego.** Las decisiones de la base (repartir energía, calcular raciones) son práctica de matemáticas con un propósito. No conviene presentar el juego como remedio para PISA: no tenemos evidencia de eso.
- **Criterio.** Impacto.
- **Cuidado.**
  - `fig_13_mexico_contexto.png` todavía muestra PISA 2022; no se regeneró porque las cifras de 2025 no están en ninguna tabla del EDA. `[DATO PENDIENTE]`: agregar PISA 2025 a `eda/04_mexico.py` cuando se confirme la nota de país.
  - PISA 2022 se tomó de Our World in Data, que cita a la OCDE (2023); es fuente secundaria. El promedio OCDE de 2018 difiere entre fuentes (487.0 en Our World in Data, 489.3 en el Banco Mundial).
  - Las fuentes no coinciden en si lectura y ciencias cambiaron frente a 2022: no afirmamos ningún cambio en esas dos áreas.
  - No usar "a los niños no les interesa la ciencia": en PISA 2015, 45% de los hombres y 36% de las mujeres de México esperaban una carrera científica, arriba del promedio OCDE (dato reportado por otra sesión; no verificado aquí). Encuadre sugerido: el interés existe, el camino no.

### 7. Sólo 11% de quienes han ido al espacio son mujeres, y México aparece una vez

- **Número.** 64 de 565 personas (11.3%) son mujeres. Por década de selección: 1% (1959-69), 8% (70), 13% (80), 15% (90), 14% (2000s). Por país: EE.UU. 14.8%, URSS/Rusia 3.3%, otros 9.2%. El 82% de las personas voló con bandera de EE.UU. o URSS/Rusia (466 de 565). Hay 40 banderas; **México aparece una vez**: Rodolfo Neri Vela, STS-61-B, 1985. Con bandera latinoamericana hay 3 personas (México, Cuba, Brasil).
- **Uso en el juego.** Tripulación con niñas y personajes mexicanos; Neri Vela como referencia histórica.
- **Cómo se calculó.** `eda/01_astronautas.py`. Tablas: `astro_mujeres_por_decada.csv`, `astro_mujeres_por_pais.csv`, `astro_nacionalidades.csv`.
- **Figuras.** `fig_05_mujeres.png`, `fig_06_nacionalidades.png`.
- **Criterio.** Impacto y Creatividad.
- **Cuidado.** La nacionalidad es la que registra la base: José Hernández (STS-128, 2009) figura como EE.UU. La base termina en 2019, así que no incluye a Katya Echazarreta (2022). El 33% de mujeres en 2010-18 se basa en 12 personas.

### 8. Edad mediana de selección: 34 años

- **Número.** Entre 554 astronautas de carrera que volaron de 1961 a 2019, la edad mediana al ser seleccionados es **34 años** (mitad central: 31 a 37; 88% entre 26 y 40; mínimo 23, máximo 55). La edad mediana al primer vuelo es **40 años**, y la espera mediana entre selección y primer vuelo es de **6 años** (mitad central: 3 a 8).
- **Tendencia.** La edad mediana de selección subió de 33 (1959-69) a 36 (años 2000). Mujeres: 32; hombres: 34.
- **Uso en el juego.** Para un jugador de 9 a 14 años, la edad mediana de selección está a 20 a 25 años. Sirve para el cierre del juego ("lo que practicas hoy cuenta"), no para una mecánica.
- **Cómo se calculó.** `eda/01_astronautas.py`: año de selección menos año de nacimiento, una fila por persona. Tablas: `astro_edad_seleccion_por_decada.csv`, `astro_edad_seleccion_distribucion.csv`, `astro_espera_seleccion_a_vuelo.csv`.
- **Figuras.** `fig_02_edad_seleccion.png`, `fig_07_espera_primer_vuelo.png`.
- **Criterio.** Impacto.
- **Cuidado.** La edad usa años calendario (error de ±1 año). La base sólo incluye a quienes **sí volaron**, así que no dice nada de los seleccionados que nunca volaron ni de los aspirantes rechazados. La década 2010-18 tiene sólo 12 personas y subestima la espera.

---

## Secciones pendientes de otras sesiones

Estas secciones las llenan otras sesiones que trabajan en paralelo. No editar su contenido desde aquí.

### Pendiente: parámetros del juego (BVAD)

A cargo de la sesión **nasa-2f**, que escribe `eda/tables/parametros_juego.csv` con números del documento de valores de referencia para soporte vital de la NASA (BVAD). `[DATO PENDIENTE]`

### Pendiente: tabla riesgo → mecánica

A cargo de la sesión **nasa-c1**: cómo se convierte cada riesgo del HRP (hallazgo 1) en una mecánica del juego. `[DATO PENDIENTE]`

### Pendiente: ENSANUT

A cargo de la sesión **nasa-3d**: datos oficiales mexicanos de sobrepeso y obesidad, actividad física, sueño y salud mental en escolares y adolescentes, nacional y de Sonora si existe. Reemplaza o complementa las estimaciones de la OMS del hallazgo 4. `[DATO PENDIENTE]`

---

## Rarezas de los datos y cómo se manejaron

| Fuente | Rareza | Qué hicimos |
|---|---|---|
| Astronautas | El `number` 385 lo comparten Yuri Baturin y Pedro Duque | La persona se identifica con `number` + `name`: 565 personas en 1,277 filas |
| Astronautas | "Aleksandrov, Aleksandr" tiene dos `number` (123 y 209) | Se tratan como dos personas distintas |
| Astronautas | 12 filas de turistas, participantes y un periodista (11 personas) | Fuera de edad de selección, militar/civil y espera; dentro de mujeres, nacionalidades y duración |
| Astronautas | Etiquetas "U.S.S.R/Russia" y "U.S.S.R/Ukraine" | Agrupadas como URSS/Rusia en los grupos de país (123 personas) |
| Astronautas | Nombres mal escritos ("Neri Vela, Rodolfl", "Hungry", "Malysia") | Corregidos sólo en etiquetas de figuras y tablas |
| Astronautas | 6 vuelos con 0 horas | Excluidos de la duración |
| Astronautas | Sólo incluye a quienes volaron hasta 2019 | 2010-18 marcado con asterisco como incompleto |
| HRP | 1 riesgo inactivo (disco intervertebral) | Excluido de los conteos de riesgos activos |
| OSDR | Tipo de proyecto con mayúsculas y nombres inconsistentes | Normalizado a vuelo espacial, tierra u otro |
| YRBSS prepa | El encabezado del CSV trae espacios al final de cada nombre de columna | Se limpian al leer |
| YRBSS prepa | El archivo de 6 GB sólo trae 2015 y 2017 | Tendencias tomadas de los dos archivos chicos de CDC |
| YRBSS | Celdas vacías por muestra insuficiente | Descartadas; se conservan intervalos de confianza y tamaño de muestra |
| YRBSS secundaria | No hay muestra nacional | Mediana simple entre estados, con el número de estados |
| NAEP | 3 celdas no publicables (999) y sin ciencias 2024 para 4.º y 12.º | Excluidas; la API devolvió error 400 para esas combinaciones |

## Dónde viven los datos

- **Laptop.** `data/raw/nasa/astronauts_missions.csv` y `data/raw/mexico/` (OMS, Banco Mundial, Our World in Data).
- **Ramona** (el servidor de cómputo del equipo). Todos los crudos "chicos" (OSDR, HRP, NAEP, los dos CSV chicos de CDC) y los dos YRBSS grandes. **Los crudos chicos NO están en la laptop**: la red de la laptop iba a unos 5 KB/s, así que se bajaron en Ramona con el mismo `scripts/fetch_data.py small`.
- **Versiones reducidas en la laptop.** `eda/tables/ramona/`, generadas por `eda/ramona/slim_small_sources.py`. Se filtran filas y se recorta texto largo; no se modifica ningún número.

## Cómo volver a correr

```bash
cd NasaSpaceApps2026
# 1. (opcional) regenerar las tablas reducidas en Ramona y traerlas
ssh <servidor> 'cd <dir-servidor> && python3 eda/yrbss_extract.py data/raw/youth_health/yrbss_high_school_incl_sexual_orientation.csv eda/out/hs_extract.csv ALL && python3 eda/slim_small_sources.py && cd eda/out && tar czf slim.tgz slim'
ssh <servidor> 'cat <dir-servidor>/eda/out/slim.tgz' | tar xz -C eda/tables/ramona --strip-components=1
# 2. (opcional) volver a bajar los datos de México
python3 eda/00_fetch_mexico.py
# 3. análisis y figuras (sólo necesita numpy y matplotlib; no usa pandas)
for f in 01_astronautas 02_hrp_osdr 03_jovenes_eeuu 04_mexico; do .venv/bin/python eda/$f.py; done
```

`nasa/.venv` se creó con `--system-site-packages` porque la instalación de pandas no terminó con esa red. Los scripts de Ramona (`eda/ramona/*.py`) usan sólo la biblioteca estándar y leen los CSV por flujo. La tabla de secundaria (`yrbss_ms_summary.csv`) se generó en Ramona con `yrbss_extract.py` (códigos M40, QNBK7DAY, M48, M41-M45, QNDLYPE, QNPA0DAY, QNPA7DAY, M12-M16, M38, M39) y luego `yrbss_aggregate.py` en modo `states`.

---

## Dónde podemos ganar ventaja

Ordenado por cuánto cambiaría la calificación de los jueces. ENSANUT, los parámetros BVAD y la tabla riesgo → mecánica ya están asignados a otras sesiones (ver "Secciones pendientes").

### 1. Retraso de comunicación Tierra-Marte

Es la base de la mecánica del hallazgo 3 y hoy no tiene número.

- **Dónde.** Páginas de la NASA sobre comunicación con Marte (por ejemplo, el sitio de Mars Exploration o la Deep Space Network en https://www.nasa.gov/).
- **Qué sacar.** Retraso de ida, mínimo y máximo, y retraso a la Luna para comparar; anotar URL y fecha de consulta.
- **Estado.** No se buscó en esta sesión. `[DATO PENDIENTE]`

### 2. Confirmar PISA 2025 y agregarlo a la figura

- **Qué sacar.** Confirmar 388, 408 y 414 (y 30% contra 65% en nivel 2 de matemáticas) en la nota de país; si se puede, resultados por sexo y expectativas de carrera científica de México en PISA 2025.
- **Dónde.** https://www.oecd.org/pisa/ y https://pisadataexplorer.oecd.org/ide/idepisa/
- **Estado.** Ver hallazgo 6. `[DATO PENDIENTE]`

### 3. Evidencia de que aprender con juegos funciona

Ningún dato de este EDA prueba que un juego o una misión simulada mejore hábitos o aprendizaje. Es el punto más débil en Validez.

- **Qué buscar.** Evaluaciones publicadas de juegos serios sobre alimentación, actividad física o trabajo en equipo en niños de 9 a 14 años, con tamaño de efecto. Buscar en https://eric.ed.gov/ y en Google Scholar; citar 2 o 3 con número de efecto.
- **Estado.** No se buscó en esta sesión. `[DATO PENDIENTE]`

### 4. Probabilidades de selección

- **Qué falta.** El HANDOFF cita ~12,000 aspirantes para 10 lugares (2021), ~18,300 para 12 (2017) y 8,000+ para 10 (2025). Otra sesión (nasa-2f) dice haberlas verificado en notas de prensa sobre anuncios de la NASA; **no se verificó aquí** y no están en ninguno de nuestros archivos.
- **Dónde.** Comunicados de selección de astronautas de la NASA en https://www.nasa.gov/news/ `[DATO PENDIENTE]`

### 5. Contexto local

- **Población objetivo.** Niñas y niños de 9 a 14 años en Hermosillo y Sonora: Censo 2020 de INEGI (https://www.inegi.org.mx/programas/ccpv/2020/).
- **Actividad física.** MOPRADEF de INEGI (https://www.inegi.org.mx/programas/mopradef/).
- **Salud mental.** ENBIARE 2021 de INEGI (https://www.inegi.org.mx/programas/enbiare/2021/) y datos de CONASAMA.
- **Qué existe hoy.** Programas educativos de la Agencia Espacial Mexicana (https://www.gob.mx/aem), para mostrar el hueco que cubre el juego.

### 6. Matrícula STEM por sexo en México y en Sonora

- **Dónde.** Anuarios Estadísticos de Educación Superior de ANUIES (http://www.anuies.mx/informacion-y-servicios/informacion-estadistica-de-educacion-superior/anuario-estadistico-de-educacion-superior) y Principales Cifras de la SEP (https://www.planeacion.sep.gob.mx/estadisticaeindicadores.aspx).
- **Qué sacar.** Matrícula de licenciatura por campo de formación y sexo, nacional y Sonora; matrícula de la Universidad de Sonora en ingeniería y ciencias.
- **Estado.** La consulta al Banco Mundial (proporción de mujeres entre graduados STEM, `SE.TER.GRAD.FE.SI.ZS`) falló con error 502. Se puede reintentar con `eda/00_fetch_mexico.py`.

Las URL de esta sección se escribieron sin abrirlas en esta sesión (salvo las de OMS, Banco Mundial y Our World in Data, que sí se usaron). Hay que verificarlas antes de ponerlas en una lámina.

### Qué no se pudo hacer

- Instalar pandas y seaborn en la laptop (red lenta). No hizo falta para el análisis.
- Ciencias de PISA 2022, PISA de ciencias por sexo y mujeres en STEM del Banco Mundial (errores 502 y 404).
- Abrir la nota de país de PISA 2025 de la OCDE ni el sitio de Space Apps (no cargan desde esta máquina).
- Tendencias de YRBSS de preparatoria anteriores a 2015 para sueño y pantallas.
- Abrir datos de estudios individuales de OSDR o leer el texto completo de las páginas del HRP (sólo se usaron encabezado, tabla de calificaciones y enunciado del riesgo).

---

## Apéndice A. Material de EE.UU. y "cualquier camino STEM"

Se conserva completo, pero ya no sostiene el pitch: es de EE.UU. o no apoya al juego.

### A.1. EE.UU.: sólo 25% de los jóvenes hace una hora diaria de ejercicio y 40% reporta tristeza persistente

- **Número (preparatoria, muestra nacional).** En 2023, **24.6%** logra 60 minutos diarios de actividad física (mujeres 16.6%, hombres 32.2%); en 2011 era 28.7%. **39.7%** reporta tristeza o desesperanza persistente (mujeres 52.6%, hombres 27.7%); en 2015 era 29.9%. La obesidad subió de 10.5% (2001) a 15.9% (2023). En 2017, **74.6%** dormía menos de 8 horas.
- **Número (secundaria, grados 6 a 8).** En 2017, la mediana entre estados fue: 69.8% no hace 60 minutos diarios (14 estados), 46.4% duerme menos de 8 horas (11 estados) y 44.4% pasa 3 horas o más al día en videojuegos o computadora no escolar (13 estados; en 2007 era 25.2% con 9 estados).
- **Cómo se calculó.** `eda/03_jovenes_eeuu.py`. Tablas: `jovenes_eeuu_tendencias.csv`, `jovenes_eeuu_foto_2017.csv`, `jovenes_eeuu_secundaria_mediana_estados.csv`.
- **Figuras.** `fig_10_jovenes_eeuu_tendencias.png`, `fig_11_habitos_que_faltan_eeuu.png`.
- **Cuidado.**
  - **Es EE.UU., no México.**
  - No existe muestra nacional de secundaria: usamos la mediana simple (sin ponderar) entre los estados que midieron cada año, y el grupo de estados cambia de un año a otro. No es comparable con el dato nacional de prepa.
  - La serie de tristeza une dos archivos de la misma encuesta (2015-2017 y 2019-2023).
  - El archivo grande de preparatoria (13.6 millones de filas) sólo trae 2015 y 2017, por eso la foto es de 2017.
  - Son autorreportes. El dato de educación física diaria de 2021 (19.0%) coincide con la pandemia.

### A.2. EE.UU.: la brecha por ingreso en matemáticas es de 27.5 puntos y la de género reapareció

- **Número.** En matemáticas de 8.º grado (NAEP 2022), los estudiantes sin subsidio de almuerzo obtienen 287.0 y los que reciben almuerzo gratuito o reducido 259.5: **27.5 puntos** de brecha (30.1 en 2000). La brecha de género (hombres menos mujeres) en 8.º pasó de −1.0 (2019) a +4.1 (2024); en 4.º, de +3.1 a +5.4.
- **Cómo se calculó.** `eda/03_jovenes_eeuu.py`. Tabla: `naep_brechas.csv`. Figura: `fig_12_naep_brechas.png`.
- **Cuidado.** Es de EE.UU. y es contexto, no evidencia de que el juego funcione. El dato por ingreso llega a 2022. Se omiten 3 celdas no publicables (valor 999). No se descargaron errores estándar, así que no afirmamos significancia estadística de los cambios.

### A.3. Ya no es sólo cosa de pilotos, pero los militares siguen siendo mayoría ("cualquier camino STEM")

- **Número.** Los asientos de especialista o ingeniero de vuelo pasaron de **12%** (años 60) a 60% (años 80) y **66%** (años 90); desde entonces rondan 62%. Los astronautas civiles subieron de 26% (seleccionados en 1959-69) a 47% (años 90).
- **Lo que no se confirma.** La idea "pasamos de militares a civiles" es cierta sólo a medias: en ninguna década los civiles son mayoría, en total son 39.9% (221 de 554) y entre los seleccionados en los 2000s bajan a 33%. Por país, en los años 90: EE.UU. 46%, URSS/Rusia 39%, otros países 57%.
- **Cómo se calculó.** `eda/01_astronautas.py`. Tablas: `astro_militar_civil_por_decada.csv`, `astro_roles_por_decada_mision.csv`.
- **Figura.** `fig_01_militar_a_civil.png`.
- **Cuidado.** Usar la frase "ya no es sólo cosa de pilotos", **no** "la mayoría son científicos civiles". La base no trae carrera ni grado académico, así que "cualquier camino STEM" no se puede probar con estos datos. "Ingeniero de vuelo" no equivale a "científico". La fuente para probarlo sería "NASA Astronauts, 1959-Present", con licenciatura y posgrado por astronauta: https://www.kaggle.com/datasets/nasa/astronaut-yearbook (requiere cuenta).
- **Ojo con otra cifra.** La sesión nasa-2f calculó una proporción de civiles algo distinta (1960s 27%, 2000s 41%) con otra llave de persona (nombre + año de nacimiento). Las cifras de esta sección son las de `astro_militar_civil_por_decada.csv`; no se reconciliaron.
