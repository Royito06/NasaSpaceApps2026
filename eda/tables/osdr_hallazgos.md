# Hallazgos de salud de OSDR para el medidor «Tripulación»

Preparado el 14-nov-2026. El reto pide "a real astronaut health finding" del repositorio OSDR de la NASA, y un conteo de estudios no es un hallazgo. Aquí hay tres estudios de OSDR con una cifra que se le puede explicar a una niña o un niño. Cada cifra se leyó en el artículo que OSDR liga a ese estudio. La tabla es `osdr_hallazgos.csv` (seis renglones, con la frase en español y en inglés y la cita textual del artículo). La escribe y la comprueba `python3 eda/07_osdr_hallazgos.py --verificar`.

## Los tres estudios

| Estudio en OSDR | Quiénes y dónde | Qué encontró |
|---|---|---|
| OSD-342 | Ratones, 33 días en la Estación Espacial (SpaceX-19) | Regresaron con 18% menos del músculo sóleo y 9% menos masa magra que los ratones en Tierra. En 22 días, la densidad mineral de sus huesos bajó 8% (en el fémur, 8% y 11%). |
| OSD-714 | Ratones, cerca de un mes en la Estación (JAXA y NASA), con una centrífuga que imita la gravedad de la Luna | En microgravedad el sóleo quedó 17% menor y sus fibras 40% más chicas. Con gravedad lunar (1/6 g) el músculo se conservó, pero sus fibras sí cambiaron de tipo. |
| OSD-540 | 11 hombres jóvenes, en Tierra | Con una pierna sin apoyar durante 10 días, el músculo del muslo se achicó 4.5%. La fuerza volvió por completo a los 21 días de ejercicio de fuerza; a los 10 días todavía no. |

Dos experimentos distintos dan casi la misma cifra para el mismo músculo: 17% y 18% en cerca de un mes.

## Qué le dicen al medidor «Tripulación» (M4)

Esto es lectura nuestra para el diseño; los artículos no hablan del juego.

1. **Sin gravedad, la fuerza baja pronto.** La parte de fuerza del medidor debe bajar de forma visible dentro de la misión si nadie usa fichas de «moverse».
2. **La gravedad de la Luna ayuda, pero no lo arregla todo.** En el nivel de la Luna la fuerza puede bajar más despacio que en el viaje, no quedarse fija. Para Marte (0.38 g) estos estudios no dicen nada: `[DATO PENDIENTE]`.
3. **Perder es rápido y recuperar es lento.** Lo que se perdió en 10 días tardó 21 en volver. En el juego, moverse cada sol debe costar menos que recuperarse después.

## Para la pantalla «Datos NASA usados»

- Atribución sugerida: "Fuente: repositorio OSDR de la NASA, estudio OSD-342. Lee y col., PNAS 2020." En inglés: "Source: NASA Open Science Data Repository, study OSD-342. Lee et al., PNAS 2020."
- Decir "datos del repositorio OSDR de la NASA", no "la NASA descubrió". OSD-714 es de JAXA y la NASA, y OSD-540 lo pagó la Agencia Espacial Italiana; los tres están publicados en el repositorio de la NASA.
- La tabla trae para cada renglón la dirección del estudio en OSDR y la del artículo en PubMed Central.

## Cuidados

- **No son astronautas.** Son ratones (dos estudios) y hombres jóvenes con una pierna en reposo (uno). El artículo de OSD-714 dice que no se sabe si su resultado aplica a personas.
- **Los ratones no entrenaron.** Una tripulación real hace unas 2 horas diarias de ejercicio (fila `ejercicio_diario_eei` de `parametros_juego.csv`). Las cifras de ratones no son lo que pierde una tripulación que sí entrena.
- **Las cifras de músculo son tamaño o peso del músculo, no fuerza.** En el texto para niñas y niños conviene decir "músculo" o "fuerza" y no hablar de peso.
- **Grupos chicos.** En OSD-714 hubo de 3 a 6 ratones por grupo en vuelo y los músculos se tomaron dos días después de aterrizar. En OSD-342 fueron 8 ratones por grupo.
- **No son metas ni avisos para quien juega.** Describen a la tripulación del juego.

## Revisados y no elegidos

- **OSD-942 y OSD-946** (estudio de la NASA: 70 días en cama, 22 hombres, con y sin ejercicio). El reposo cambió la actividad de 2,113 genes del músculo y el ejercicio atenuó el cambio en 511; el artículo concluye que el ejercicio no contrarrestó todo. Respalda que moverse ayuda sin ser un escudo total, pero una cifra de genes es difícil de explicar a los 7 años.
- **OSD-51** (60 días en cama, mujeres, con ejercicio). La descripción en OSDR dice que el ejercicio redujo 89% y 96% el número de genes alterados en dos músculos. El artículo no está en acceso abierto, así que no se leyó.
- **OSD-195, OSD-104 y OSD-417.** Se leyeron sus metadatos; lo revisado no daba una cifra sencilla.

## Cómo se verificó

- La página de cada estudio en OSDR responde, pero su contenido se carga con JavaScript; se leyó en la API pública de OSDR.
- Los tres artículos se leyeron completos en PubMed Central. Las páginas de PNAS y de Journal of Physiology rechazaron la descarga automática.
- `--verificar` da 9 de 9: OSDR liga cada artículo, cada cita textual está en su artículo y cada cifra está en su cita. También corre sin archivos locales, bajando todo de OSDR y de PubMed Central.
- Los archivos bajados están en `data/raw/nasa/osdr_hallazgos/` (lista en su `FUENTES.md`).
