# Las preguntas más difíciles de los jueces

Escrito el 14-nov-2026. El público oficial del reto es de **7 a 12 años** (`CHALLENGE.md`). Cada respuesta dura unos 20 segundos. Las fuentes van abajo de cada una.

## 1. «¿Por qué agregaron la salud de la tripulación si el reto pide soporte vital, energía y blindaje?»

> Porque es lo que hace que las decisiones cuesten de verdad. No son sistemas extra: es un solo medidor junto a los tres recursos del reto. Si le quitas sueño a la tripulación para adelantar trabajo, mañana falla la reparación. Y no lo inventamos: para una misión a Marte, la NASA da su calificación más alta de riesgo humano sólo a tres cosas, y las tres son de la tripulación: el trabajo en equipo, operar sin ayuda de la Tierra y la alimentación. El propio reto sugiere usar los datos de salud de astronautas de la NASA.

- 3 de 21 riesgos activos con calificación 5×5 para Marte: NASA Human Research Roadmap, consultado el 14-nov-2026 (`eda/tables/hrp_riesgos_clasificados.csv`).
- El reto nombra el repositorio OSDR como fuente de "real astronaut health and biological research findings", y pide incluir el retraso de comunicación (`CHALLENGE.md`).
- El reto advierte que cinco o seis sistemas a la vez saturan a esta edad y recomienda dos o tres recursos. Tenemos tres recursos y un medidor de tripulación.
- La NASA califica esos riesgos para astronautas adultos. No dice que se entrenen con un juego.

## 2. «¿Más pantalla para niños que ya pasan demasiado tiempo en pantalla?»

> Es cierto: 8 de cada 10 niñas y niños de 10 a 14 años ya pasan más de dos horas diarias frente a una pantalla. Por eso el juego avanza por soles y cada sol es un punto para parar. Entre soles aparece la pausa de tripulación: una invitación de un minuto a moverse, tomar agua o descansar. No hay rachas, insignias ni avisos que te llamen a volver. No prometemos menos pantalla; hacemos que el rato de pantalla termine solo y mande al niño a otra cosa.

- 80.5% de 10 a 14 años pasa más de 2 horas diarias frente a una pantalla: Ensanut Continua 2022-2024, Shamah-Levy T y col., *Salud Pública de México* 2025;67(supl 1):s3-s219. Revisada por el equipo (`eda/tables/mexico_ensanut.csv`).
- La cifra es del grupo de 10 a 14 años: Ensanut no publica pantallas para menores de 10, así que sólo cubre la parte mayor de nuestro público.
- Las reglas de pausa, guardado y sin rachas están en las notas de construcción, "Hard design rules".
- Sólo vale si la demo trae la pausa de tripulación y el avance por soles.

## 3. «¿Cómo saben que funciona?»

> Para nuestro juego todavía no lo sabemos, y lo decimos. Lo que sí hay es evidencia de las piezas. Un metaanálisis de 57 estudios encontró que los juegos digitales mejoran el aprendizaje frente a la clase sin juego. Otro, de 46 muestras, encontró que hacer un debrief mejora el desempeño de un equipo entre 20 y 25%. Por eso el juego cierra cada misión con tres preguntas. Lo probamos con niñas y niños: preguntamos si jugarían otra vez y observamos si entendieron que cada decisión cuesta algo.

- Juegos digitales y aprendizaje: Clark, Tanner-Smith y Killingsworth (2016), *Review of Educational Research* 86(1):79-122; g = 0.33, 57 estudios. Leído en el resumen del artículo; no se abrió el texto completo.
- Debrief: Tannenbaum y Cerasoli (2013), *Human Factors* 55(1):231-245; alrededor de 20 a 25%. Leído en el resumen.
- Ninguna de las dos cifras se midió en este juego ni necesariamente en niños de 7 a 12 años. Sirven para justificar el diseño, no para prometer un resultado.
- La prueba dice si el juego se entiende y gusta. No prueba que cambie hábitos ni que mejore la cooperación.

## 4. «Si casi nadie llega a astronauta, ¿no están vendiendo un sueño falso?»

> Al revés. En 2025 la NASA eligió a 10 personas entre más de 8,000 aspirantes. Por eso no prometemos astronautas. El espacio es el gancho; lo que se queda es entender que toda decisión cuesta algo, trabajar en equipo y cuidarse. A José Hernández, hijo de jornaleros mexicanos, la NASA lo rechazó 11 veces antes de aceptarlo en 2004. Esa constancia es la que se practica cuando una misión falla y el juego te deja intentarlo otra vez.

- 10 de más de 8,000: anuncio de la NASA de su generación 2025, 22-sep-2025. Leído en notas de prensa; confirmar en nasa.gov.
- José Hernández: 11 rechazos y selección en 2004; voló en la misión STS-128 en 2009. Leído en una verificación de datos de Yahoo News y en su biografía de Wikipedia; confirmar en su biografía de la NASA antes de ponerlo en una lámina. `pitch/historical_missions.md` tiene su misión verificada.

## Otras dos que pueden caer

### «¿Qué datos de la NASA usan de verdad, y son en vivo?»

> Cinco fuentes abiertas. Las tormentas solares vienen de la base DONKI. Las dosis de radiación, del rover Curiosity. El oxígeno, el agua y la comida por tripulante, del documento de soporte vital de la NASA. Los riesgos humanos del Human Research Program deciden qué importa en el juego, y el repositorio de biología espacial OSDR los acompaña. Todo está en la pantalla "Datos NASA usados". Lo que mostramos hoy es un dato archivado con su fecha, no en vivo.

- Valores físicos y su fuente: `eda/tables/parametros_juego.csv` (93 filas).
- Riesgos: NASA Human Research Roadmap, consultado el 14-nov-2026.
- OSDR: conteo del equipo por tema (`eda/tables/osdr_por_tema.csv`): hueso 115, músculo 105, ejercicio 59 y dieta 50, de 577 estudios. Son conteos por palabras clave, casi todos en animales.
- Si la demo sí hace la consulta en vivo a DONKI, cambiar la última frase y decir la fecha de la tormenta. El reto pide no presentar datos guardados como si fueran en vivo.
- Los valores de balance (cuánto baja un medidor) son decisiones nuestras.

### «¿La NASA avala este juego?»

> No. Usamos datos públicos de la NASA y entrenamos en pequeño lo que la NASA entrena en sus tripulaciones: autocuidado, cuidado del equipo, comunicación, y liderar y saber seguir. La idea de entrenarlo con un juego para niños es nuestra.

- Lista de habilidades: presentación de Rachel Passmore, NTRS 20250011491, lámina "Expeditionary Skills Training". Abierta el 14-nov-2026. Es una presentación, no una norma.

## Si preguntan por lo que no sabemos

Decirlo. Las tres frases seguras:

- "Eso todavía no lo medimos."
- "Es una hipótesis de diseño, no un resultado."
- "Esa cifra es de otro contexto; la usamos para justificar el diseño."
