# Parámetros reales para el juego

`parametros_juego.csv` tiene los valores físicos que usan las mecánicas del juego: 104 filas, 102 con valor y 2 marcadas `[DATO PENDIENTE]`. Cada valor se leyó el 14-nov-2026 en la fuente de su fila (22 páginas o documentos distintos de NASA, JPL y cuatro artículos científicos). Ningún valor se escribió de memoria.

**Tres filas no se usan en el juego ni en el pitch.** `dosis_diaria_superficie_luna`, `razon_dosis_luna_vs_eei` y `dosis_diaria_eei` se leyeron en un artículo de la misión china Chang'E 4. Por la regla de elegibilidad de Space Apps sobre China (`JUDGING.md`), el equipo decidió no usarlas; su nota empieza con "NO USAR EN JUEGO NI PITCH". Se conservan sólo como registro de lo que se consultó. Para la Luna, los datos de la NASA son los de Artemis I (`dosis_diaria_orion_artemis_i_*`) y los del orbitador LRO (`dosis_absorbida_superficie_luna_crater_max`).

Los valores de balance del juego (cuánto baja una barra, cuánto pesa en el éxito de una tarea) no están aquí: son decisiones de diseño.

## Columnas

| Columna | Qué trae |
|---|---|
| `parametro` | Nombre corto, sin espacios |
| `valor` | Número, rango (`75-90`) o `[DATO PENDIENTE]` |
| `unidad` | Unidad del valor |
| `contexto` | Luna, Marte, EEI (Estación Espacial Internacional), tránsito o combinación |
| `fuente` | Documento y tabla o sección |
| `url` | Dirección que se abrió |
| `nota` | Condiciones de la medición y avisos. Si empieza con "Calculado", el valor es una operación sobre un dato de la fuente |

## Qué filas usa cada mecánica

| Mecánica | Filas |
|---|---|
| M1 Retraso Tierra–Marte | `retraso_*` |
| M2 Roles y debrief | `tripulacion_referencia`, `eva_tripulantes_minimos` |
| M3 Menú e invernadero | `comida_*`, `cultivo_*`, `invernadero_*`, `mision_*` |
| M4 Medidores y planificador del sol | `duracion_sol_marte`, `sueno_*`, `ejercicio_*`, `gravedad_*` |
| M5 Tormenta solar | `dosis_*`, `limite_*`, `blindaje_*`, `refugio_*` |
| Soporte vital | `oxigeno_consumido`, `co2_producido`, `agua_*` |
| Energía | `potencia_*`, `irradiancia_*`, `tormenta_polvo_*` |
| Segunda versión | `eva_*`, `adaptacion_tras_cambio_de_gravedad` |

## Lo que los datos le dicen al diseño

- **El retraso con Marte va de 3 a 22 minutos por sentido; con la Luna es de 1.2 a 1.4 segundos.** Por eso el nivel de práctica en la Luna puede "llamar a la Tierra" y el de Marte no. Para el pitch, la frase de la NASA es "hasta 20 minutos en un sentido".
- **El blindaje casi no detiene los rayos cósmicos (7%), pero sí las tormentas solares (50%).** En el ejemplo de la NASA, refugiarse detrás de bolsas de agua baja la dosis de una tormenta de 210–259 mSv a 65–68 mSv. La versión honesta de M5 es: el blindaje y el refugio sirven para la tormenta, no para la dosis de todos los días.
- **Para la Luna hay medición de la NASA, pero dentro de la nave.** En Artemis I (2022) los sensores de la NASA dentro de Orion midieron de 0.96 a 1.24 mSv por día de rayos cósmicos, y unos 27 a 35 mSv en toda la misión de 25.5 días. Con 80% más blindaje la dosis bajó sólo 30%; al cruzar el cinturón de protones la diferencia entre el lugar más y el menos blindado fue de 4 veces. Es la misma lección que en Marte, ahora con datos de la NASA. Para la superficie, el instrumento CRaTER del orbitador LRO de la NASA da una dosis absorbida máxima de 11.7 cGy por año (unos 0.32 mGy por día), ajustada desde la órbita; es dosis absorbida, no equivalente, así que no se compara con el límite de 600 mSv.
- **La barra de dosis diaria se mueve muy despacio.** Con 0.67 mSv por día en la superficie de Marte y un tope de 600 mSv, tres soles suman unos 2 mSv (0.3% de la barra). En una demo corta, lo que mueve la barra es la tormenta.
- **Marte recibe 43% de la luz solar de la Tierra** y una tormenta de polvo global puede durar semanas. Eso justifica tener un reactor además de paneles.
- **Los astronautas duermen unas 6 horas aunque tienen 8.5 programadas.** El evento "¿se quita sueño para reparar?" está basado en un problema medido.
- **Un cultivo rápido tarda de 25 a 30 días** (rábano, lechuga, espinaca); el tomate 85 y la papa 132. Un invernadero no salva una misión corta: hay que sembrar al principio.

## Cuidados

- **Los valores de oxígeno, agua y comida son de un astronauta adulto de 82 kg que hace 90 minutos de ejercicio al día.** Sirven para la tripulación del juego. No son metas para niños, y el juego no debe mostrar calorías.
- **Las dos horas diarias de ejercicio son para adultos en microgravedad.** No se presentan como meta para quien juega.
- **Las dosis de radiación son mediciones de periodos concretos.** La de la Luna y la del viaje a Marte se tomaron con el Sol tranquilo; una tormenta solar las cambia mucho. Las mediciones son "dosis equivalente" y los límites de la NASA son "dosis efectiva": compararlas sirve para la escala del juego, no para afirmar un riesgo de salud.
- **Las tres filas marcadas "NO USAR EN JUEGO NI PITCH" no llevan etiqueta "Dato real NASA" ni aparecen en ninguna lámina.** Falta una fuente de la NASA para la dosis diaria dentro de la Estación.
- **Dos unidades distintas de dosis.** Artemis I y Curiosity dan dosis equivalente (mSv), que es la que se compara con los límites. CRaTER da dosis absorbida (cGy o mGy). No se suman ni se comparan entre sí. El valor de CRaTER en mSv (`dosis_diaria_orbita_lunar_crater`) se leyó citado en otro artículo.
- **Los retrasos de comunicación están calculados** con las distancias de la hoja de datos de la NASA y la velocidad de la luz (299,792.458 km/s).
- **Tres duraciones vienen de estudios viejos** (1997 y 2005–2007) citados en el documento BVAD: estancia y tránsito de Marte y la base lunar de 210 días. La nota de cada fila lo dice. La duración que la NASA usa hoy para Marte es 730–1224 días.
- **Los planes de Artemis cambian.** La página de Artemis IV decía "aproximadamente una semana" en la superficie y lanzamiento a inicios de 2028 el día de la consulta.
- **Los días a cosecha son de cámaras de cultivo en tierra**, no de cultivos en órbita.

## Las tres reglas que estaban pendientes de cita

Pedidas en `eda/riesgos_a_mecanicas.md`. Se revisó la página de cada riesgo en el Human Research Roadmap.

| Regla | Qué dice la NASA | Resultado |
|---|---|---|
| Repetir el menú baja el ánimo | La página del riesgo de alimentación tiene un estudio llamado "Food Acceptability, Menu Fatigue, and Aversion on ISS Missions". Dice que "es posible" que la fatiga de menú haga que la tripulación acepte menos la comida y la rechace, y que eso contribuya a la pérdida de masa corporal. Aparte, la estrategia de mitigación dice que la comida puede ser una contramedida "fisiológica y psicológica" | **A medias.** La NASA liga la fatiga de menú con comer menos y perder masa, y lo plantea como posibilidad en estudio. No dice que baje el ánimo. Regla sugerida: repetir el menú baja la barra de condición física (la tripulación come menos) y la comida fresca o variada sube el ánimo |
| Tomar agua protege de los cálculos renales | La página del riesgo de cálculos renales dice que sus modelos calculan el riesgo "en función de la hidratación, las contramedidas nutricionales y la gravedad", y tiene una tarea para medir el efecto de "contramedidas, incluidas la hidratación y el citrato". También cuenta el ejercicio como contramedida válida | **Confirmada.** Se puede atribuir a la NASA que la hidratación es una de las contramedidas |
| Hay un protocolo de preparación antes de una caminata espacial | La página del riesgo de descompresión dice que los protocolos actuales de prerrespiración "requieren horas" y varios pasos con apoyo de la Tierra y de la tripulación. El documento BVAD describe los cuatro protocolos de la Estación; los valores están en las filas `eva_prerespiracion_*` | **Confirmada** |

Direcciones: alimentación `https://humanresearchroadmap.nasa.gov/Risks/?i=176`, cálculos renales `?i=81`, descompresión `?i=168`.

## Dos referencias de diseño verificadas

No son parámetros físicos; respaldan las reglas de cooperación y de calma de `eda/riesgos_a_mecanicas.md`. Se abrieron el 14-nov-2026.

**Habilidades expedicionarias de la NASA.** La lámina "Expeditionary Skills Training" dice, textual: "Non-technical skills for long-duration spaceflight: Self-Care, Team Care, Teamwork and Group Living, Communication, and Leadership/Followership". Agrega que se entrenan en aula y en operación junto con un "debrief method", y con observación directa y retroalimentación en ejercicios de equipo. La misma presentación define Liderazgo/Seguimiento como "Moves flexibly between leader and follower roles to accomplish mission goals".

- Fuente: Rachel Passmore, *Operational Psychology in Practice: NASA's Behavioral Health and Performance Operations Overview*, presentación, NTRS 20250011491 (publicada en NTRS el 13-ene-2026). https://ntrs.nasa.gov/api/citations/20250011491/downloads/BHP%20Operations%20Overview_Navy_Revised.pdf
- Cuidado: es una presentación para internos de psicología de la Marina de EE.UU., no una norma de la NASA. Son cinco áreas; "Teamwork and Group Living" es una sola.

**Estudio del cronómetro y la ansiedad.** Maki, Zaslofsky, Codding y Woods (2024), "Math anxiety in elementary students: Examining the role of timing and task complexity", *Journal of School Psychology*, vol. 106. Con 113 estudiantes de 4.º y 5.º grado, no hubo diferencia significativa en la ansiedad reportada entre tareas con cronómetro a la vista y con tiempo oculto; la ansiedad subió con los problemas más difíciles.

- Fuente abierta: Education Week, 7-ago-2024, que entrevista a la autora y da la muestra y los resultados. https://www.edweek.org/teaching-learning/do-timed-tasks-really-worsen-math-anxiety/2024/08
- Cuidado: el título y el volumen salen de catálogos; no se abrió el artículo. La muestra es chica y la ansiedad es autorreportada. El estudio es de matemáticas en el aula, no de videojuegos.

## Lo que falta

- **Energía solar que queda durante una tormenta de polvo.** Hay opacidad (tau 10.8 en 2018) pero no los watts-hora de los paneles de Opportunity antes y durante la tormenta. La prensa cita 645 y 22 Wh; no se encontró en una página de NASA o JPL. Buscar en los reportes de estado de Opportunity.
- **Días de adaptación tras un cambio de gravedad.** No se abrió la página del riesgo sensoriomotor (`?i=88`).
- **Potencia de un reactor en Marte y noche lunar.** Las cifras de reactores son de proyectos para la Luna; no se buscó cuánta energía se necesita guardar para los ~14.8 días de noche lunar.
- **Dosis diaria en la Estación en otros años.** El valor es de enero–febrero de 2019.

## Fuentes

| Fuente | Para qué se usó |
|---|---|
| NASA, *Life Support Baseline Values and Assumptions Document*, NASA/TP-2015-218570 Rev 2 (feb 2022). https://ntrs.nasa.gov/api/citations/20210024855/downloads/BVAD_2.15.22-final.pdf | Oxígeno, CO₂, agua, comida, tripulación, cultivos, caminatas espaciales |
| NASA NSSDCA, hojas de datos de Marte, la Luna y la Tierra. https://nssdc.gsfc.nasa.gov/planetary/factsheet/ | Distancias, sol, gravedad, luz solar |
| Zhang et al. 2020, *Science Advances* 6:eaaz1334 (misión china Chang'E 4). https://pmc.ncbi.nlm.nih.gov/articles/PMC7518862/ | **No se usa en el juego ni en el pitch.** Origen de las tres filas marcadas "NO USAR" |
| Schwadron et al. 2012, *Journal of Geophysical Research* 117:E00H13 (instrumento CRaTER del orbitador LRO de la NASA). https://prediccs.sr.unh.edu/papers/schwadron2011JE003978.pdf | Dosis absorbida de rayos cósmicos referida a la superficie lunar |
| George et al. 2024, *Nature* 634:48-52 (misión Artemis I de la NASA). https://www.nature.com/articles/s41586-024-07927-7 | Dosis dentro de Orion alrededor de la Luna, efecto del blindaje y valor del instrumento CRaTER |
| NASA, "Artemis I Radiation Measurements Validate Orion Safety for Astronauts" (9-oct-2024). https://www.nasa.gov/humans-in-space/artemis-i-radiation-measurements-validate-orion-safety-for-astronauts/ | Resumen de la NASA de los mismos resultados |
| NASA/JPL, comunicados del 30-may-2013 y 9-dic-2013 (instrumento RAD de Curiosity) | Dosis en tránsito y en la superficie de Marte |
| NASA OCHMO, Technical Brief OCHMO-TB-020 Rev E | Límites de dosis y efecto del blindaje |
| NASA Human Research Program, "Hazard: Distance from Earth" y Human Research Roadmap | Retraso citado, duración de la misión a Marte, las tres reglas |
| NASA, *International Space Station Facts and Figures* | Potencia de los paneles, ejercicio |
| NASA, comunicado de Kilopower (2-may-2018) y artículo de Fission Surface Power (31-ene-2024) | Reactores |
| NASA/JPL, bitácora de Opportunity y comunicado del 13-jun-2018 | Tormenta de polvo |
| NASA, página de Artemis IV | Estancia en la Luna |
| Barger et al. 2014, *Lancet Neurology* 13(9):904–912. https://pmc.ncbi.nlm.nih.gov/articles/PMC4188436/ | Sueño |
| NASA, "Counteracting Bone and Muscle Loss in Microgravity", "Growing Plants in Space" y "What Is a Spacewalk?" | Ejercicio, cultivos en órbita, duración de caminatas |

La dirección exacta de cada dato está en la columna `url` del CSV. Las copias descargadas no se guardaron en el repositorio.
