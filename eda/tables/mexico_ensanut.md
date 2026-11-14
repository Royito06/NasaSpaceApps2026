# Ensanut frente a la OMS: qué cifra usar en la lámina de México

Preparado el 14-nov-2026. Las cifras de Ensanut salen de publicaciones del INSP que se abrieron y se guardaron en `data/raw/mexico/ensanut/` (la lista está en `FUENTES.md`). La tabla completa, con intervalo de confianza y fuente en cada renglón, es `mexico_ensanut.csv`. Cada renglón se comparó con el texto de su PDF, y las tablas de las cifras recomendadas se revisaron además a la vista. Las cifras de la OMS son las que ya usa el EDA (`mexico_numeros_clave.csv`).

## Lo esencial

1. **Peso.** Ensanut confirma a la OMS. Se puede cambiar la estimación modelada por la medición oficial sin que cambie el mensaje.
2. **Actividad física.** El 83% de la OMS no es la cifra que el INSP publica hoy. Depende del criterio: hay que escoger uno y decir cuál es.
3. **Sonora tiene dato propio.** La edición 2020-2024 publica estimaciones por estado.
4. **Ensanut da lo que la OMS no:** pantallas, sueño y síntomas depresivos.

## Comparación

| Tema | OMS (lámina actual) | Ensanut (oficial) | ¿Coinciden? |
|---|---|---|---|
| Obesidad | 18.3% de 5 a 19 años en 2024 (17.7% en 2022); estimación modelada | 17.6% de 5 a 11 años y 17.0% de 12 a 19; peso y talla medidos, 2020-2024 | Sí |
| Sobrepeso + obesidad | 39.5% de 5 a 19 años en 2024 | 36.6% de 5 a 11 años y 40.1% de 12 a 19; 2020-2024 | Sí |
| Actividad física | 83.2% de 11 a 17 años no alcanza 60 minutos diarios (2016) | 84.5% de 10 a 14 años no hace 60 minutos los 7 días (2022). Con el criterio actual del INSP, 34.6% es activo (2022-2024) | Sólo con el criterio estricto |
| Niñas contra niños, sin actividad suficiente | 87.6% contra 78.8% | Criterio estricto: 86.4% contra 82.8% (2022). Criterio actual: 80.6% contra 57.8% (2023). De 10 a 14 años | Misma dirección |

Las dos fuentes clasifican el peso igual: índice de masa corporal para la edad por encima de +1 (sobrepeso) y +2 (obesidad) desviaciones estándar de la referencia de la OMS.

El criterio actual del INSP cuenta como activo a quien hizo 60 minutos de actividad en 4 o más de los últimos 7 días. El INSP lo toma como equivalente a la guía de la OMS de 2020, que pide un promedio de 60 minutos diarios.

## Cifras recomendadas para la lámina

- **Sobrepeso + obesidad.** 36.6% de 5 a 11 años y 40.1% de 12 a 19 (Ensanut Continua 2020-2024). En Sonora, 38.2% y 39.8%.
- **Actividad física.** Sólo 1 de cada 3 niñas y niños de 10 a 14 años es activo (34.6%); en Sonora, 1 de cada 4 (25.5%). Ensanut Continua 2022-2024.
- **Pantallas.** 8 de cada 10 pasan más de 2 horas diarias frente a una pantalla (80.5% de 10 a 14 años; 88.1% en Sonora). Ensanut Continua 2022-2024.
- **Sueño.** 1 de cada 3 adolescentes de 15 a 19 años duerme fuera de lo recomendado (34.8% en 2022-2024). En 2012 era 21.7%.
- **Todo junto.** Sólo 1.5% de 10 a 14 años cumple las tres recomendaciones de actividad, pantalla y sueño (Ensanut Continua 2022).
- **Ánimo.** 7.0% de los adolescentes de 10 a 19 años alcanzó el puntaje de síntomas depresivos, y 20.3% dijo que no durmió bien todo o casi todo el tiempo en la última semana (Ensanut Continua 2023).

## Cuidados antes de citarlas

- **Sonora contra el país.** Los intervalos de confianza de Sonora se traslapan con los nacionales en todos los indicadores. Ejemplo: activos de 10 a 14 años, de 18.1 a 34.7 en Sonora (77 niñas y niños) contra 31.0 a 38.5 nacional. Se puede decir "en Sonora la estimación es 25.5%", no "Sonora está peor".
- **No usar la región para hablar de Sonora.** Pacífico-Norte (Baja California, Baja California Sur, Nayarit, Sinaloa y Sonora) tiene 47.2% de adolescentes con sobrepeso u obesidad, la más alta de las ocho regiones. El dato propio de Sonora es 39.8%.
- **Actividad física de 15 a 19 años.** Las publicaciones dan entre 32.8% y 50.1% de inactivos según el criterio y los años. El dato de Sonora (42.3% cumple la recomendación) sale de 59 personas y su intervalo va de 24.2 a 62.7: no sirve como titular.
- **Sueño.** "Fuera de lo recomendado" también cuenta a quien duerme de más. Otro artículo del INSP da 42.3% para la misma edad con datos de 2022-2023: hay que citar una sola edición.
- **Síntomas depresivos.** El punto de corte (9 puntos en la escala CESD-7) es provisional y no está validado en adolescentes; por eso el artículo de Ensanut 2022 no publicó prevalencia. Es tamizaje, no diagnóstico. No es comparable con el 40% de tristeza persistente de EE.UU. que usa el EDA: son preguntas distintas.
- **Son respuestas a cuestionario.** Actividad, pantallas y sueño no se midieron con aparatos. El cuestionario de 10 a 14 años es distinto al de 15 a 19, así que no conviene comparar un grupo de edad con el otro.
- **Cifras casi iguales entre publicaciones.** El artículo de sobrepeso da 36.6% y el suplemento estatal 36.5% para el mismo periodo. El 36.5% y el 40.4% que ya circulaban en el equipo son de la edición anterior (2020-2023).
- **Intento de suicidio.** Está en la tabla porque es el único indicador de salud mental adolescente publicado para Sonora (3.6%; nacional 5.6%). El equipo decide si cabe en un pitch sobre un juego para niñas y niños.

## Lo que falta

- `[DATO PENDIENTE]` Actividad física, pantallas y sueño de 5 a 9 años: las publicaciones revisadas los miden desde los 10 años.
- `[DATO PENDIENTE]` Sueño, síntomas depresivos y pantallas de 15 a 19 años en Sonora: el suplemento estatal no los trae. Saldrían de los microdatos del INSP.
- `[DATO PENDIENTE]` Actividad, pantallas y sueño por región: sólo hay un mapa sin cifras (Ensanut 2022).
- `[DATO PENDIENTE]` Ficha de la OMS del indicador de actividad física, para confirmar que su criterio es 60 minutos todos los días. No se abrió en esta revisión.
- Ensanut Continua 2025: al 14-nov-2026 el sitio del INSP sólo lista el diseño metodológico, sin resultados.
