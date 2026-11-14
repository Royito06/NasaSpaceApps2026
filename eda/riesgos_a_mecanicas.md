# De los riesgos de la NASA a las mecánicas del juego

Reto: *Build a Junior Astronaut Mission Trainer*. Público: niñas y niños de 9 a 14 años.
Este documento dice, para cada riesgo humano que la NASA tiene activo, si se puede jugar a esa edad, con qué mecánica, qué aprende el niño y qué acción saludable real se le puede invitar a hacer. Al final elige las 6 mecánicas para la demo del fin de semana.

- Tabla completa (una fila por riesgo): `eda/tables/riesgos_a_mecanicas.csv`, generada con `eda/05_riesgos_a_mecanicas.py`.
- Números reales para el juego (retraso de comunicación, duración del sol, dosis, etc.): `eda/tables/parametros_juego.csv`, con fuente y nota por cada valor. Aquí no se repite ningún valor: se cita el nombre del parámetro, para que haya un solo lugar donde corregirlos. La lista por mecánica está al final.

## Qué es de la NASA y qué es nuestro

| | De dónde sale | Cómo reconocerlo |
|---|---|---|
| **NASA** | Calificación de probabilidad × consecuencia (L×C) y disposición de cada riesgo, del Human Research Roadmap (consultado el 14-nov-2026). Copiadas sin cambios de `hrp_riesgos_clasificados.csv` y `hrp_riesgos_por_mision_largo.csv`. | Columnas `marte_*`, `leo_*`, `luna_*`, `elemento_nasa`, `url` |
| **Nuestro** | Si el riesgo es jugable, la mecánica, lo que aprende el niño, la acción saludable, la elección para la demo y el tema OSDR más cercano. | Columnas que terminan en `_propio` o `_propia`, y todo lo que este documento llama "mecánica" |

La NASA califica riesgos para astronautas adultos. **No dice que se entrenen con un juego ni con un programa escolar.** Eso es nuestra propuesta.

Las calificaciones que se citan son las de **operaciones en misión**. "Marte" es la misión planetaria de 730 a 1,224 días; "LEO" es la misión larga en órbita baja (30 días a 1 año); "Luna" es órbita más superficie, misión larga.

## Lo que hay que saber antes de diseñar

1. **Sólo 3 de los 21 riesgos activos tienen 5×5 para Marte, y los 3 se pueden jugar:** equipo, operación autónoma sin la Tierra y alimentación. Son las mecánicas M1, M2 y M3.
2. **El 5×5 es de Marte, no de la Luna.** En la superficie lunar esos mismos riesgos valen 5×3 (equipo), 5×3 (autonomía) y 5×4 (alimentación). Si la demo quiere usar el argumento del 5×5, la base tiene que estar en Marte. La Luna sirve como nivel de práctica, porque ahí la Tierra contesta casi de inmediato.
3. **La radiación no es un riesgo alto de operaciones.** El único riesgo de radiación en nuestra tabla (cáncer por radiación) tiene 1×1 "Accepted" en operaciones para Marte y 3×3 "Requires Mitigation" en salud a largo plazo. La propia página avisa que esa calificación se aprobó con la matriz anterior de 3×4 y está pendiente de actualizarse. El reto pide blindaje, así que lo incluimos, pero como **dosis que se acumula**, no como algo que daña a la tripulación en el momento. Además, según `parametros_juego.csv`, el blindaje reduce mucho la dosis de una tormenta solar y muy poco la de los rayos cósmicos (`blindaje_reduccion_tormenta_solar` contra `blindaje_reduccion_rayos_cosmicos`): esa diferencia es la lección de M5.
4. **El sueño tiene 5×2 en Marte y 5×2 en LEO: no sube.** Lo incluimos porque es fácil de jugar y útil para los niños, no porque sea de los riesgos más altos. Hay que decirlo así si un juez pregunta.
5. **Los datos abiertos de biología (OSDR) no respaldan las mecánicas de conducta.** Equipo y autonomía no tienen tema en OSDR, y sueño sólo aparece en 3 de 577 estudios. Lo que respalda esas mecánicas es la calificación del HRP. OSDR sí acompaña a las de cuerpo: hueso 115 estudios, músculo 105, radiación 146, dieta y nutrición 50. Son conteos por palabras clave, casi todos en animales, y no prueban nada sobre niños.

## Los 21 riesgos activos

Resumen: **5 jugables, 11 jugables en parte, 5 no jugables.** Ordenados por jugabilidad y luego por calificación para Marte.

### Jugables (5)

| Riesgo | Marte (NASA) | LEO (NASA) | Mecánica (nuestra) | Qué aprende | Acción saludable |
|---|---|---|---|---|---|
| Operación autónoma sin la Tierra (EIHSO) | 5×5 | 5×2 | **M1.** "Llamar a la Tierra" tarda lo que tarda de verdad; esperar deja avanzar la falla, así que la tripulación decide con su manual de a bordo | Prepararse antes, seguir un procedimiento, decidir con información incompleta | Ninguna física. Hábito: leer la instrucción completa y pedir ayuda a tiempo |
| Alimentación y nutrición | 5×5 | 5×2 | **M3.** Comida guardada más invernadero; el menú tiene grupos; repetir el menú o quedarse sin un grupo baja la condición física (la tripulación come menos), y la comida fresca del invernadero sube el ánimo | Comer bien es variedad y planeación, no sólo cantidad | Tomar agua; probar una fruta o verdura de otro color |
| Equipo (cooperación y comunicación) | 5×5 | 4×2 | **M2.** Roles con información repartida (cada uno ve un indicador que los demás no), una decisión propia por sol, comandante que rota y debrief de 3 preguntas sin culpables | Nadie tiene toda la información; un error se revisa en equipo | Debrief en voz alta y agradecer a un compañero |
| Músculo y capacidad aeróbica | 5×4 | 5×1 | **M4.** Bloque de ejercicio en el horario; si se salta, las tareas pesadas tardan más o fallan | En baja gravedad el cuerpo pierde fuerza si no se usa | Pausa activa de 1 minuto con la tripulación |
| Sueño y carga de trabajo | 5×2 | 5×2 | **M4.** Planificador del sol; quitar sueño ayuda hoy y mañana suben los errores | Dormir es parte de la misión | La sesión termina cuando la tripulación se duerme |

### Jugables en parte (11)

"En parte" quiere decir que sólo se juega el lado que un niño puede entender y practicar, o que el riesgo se suma a otra mecánica en vez de tener la suya.

| Riesgo | Marte (NASA) | LEO (NASA) | Mecánica (nuestra) | Qué aprende | Acción saludable |
|---|---|---|---|---|---|
| Lesiones en caminata espacial (EVA) | 5×4 | 4×2 | Planear la salida: tiempo límite, siempre en pareja, sólo tripulantes descansados y en forma | Afuera todo se planea y nadie sale solo | Calentar antes del deporte; tomar agua |
| Condiciones médicas en misión | 5×4 | 4×2 | Evento: alguien se lastima o enferma leve; sin evacuación, botiquín limitado, los demás se reparten sus tareas | La prevención vale más que la cura | Lavarse las manos; avisar a un adulto si te sientes mal |
| Sensoriomotor/vestibular | 4×5 | 1×2 | Los primeros soles tras aterrizar, manejar y las tareas finas fallan más | El cuerpo tarda en adaptarse a otra gravedad | Juego de equilibrio opcional |
| Fractura de hueso | 4×4 | 1×2 | **M4.** Mismo medidor que músculo ("huesos y músculos") | Los huesos se mantienen fuertes cuando cargan peso | La misma pausa activa |
| Polvo lunar/marciano | 4×4 | No aplica | Limpieza en la esclusa después de salir; saltársela ensucia los filtros | El polvo es un problema real de ingeniería y de salud | No aplica |
| Cálculos renales | 4×4 | 3×4 | Dentro del medidor de agua: racionar el agua de beber sube la probabilidad de un evento médico | El agua de beber no es donde se ahorra | Tomar agua simple, sobre todo con calor |
| Salud conductual y cognitiva | 5×3 | 5×2 | **M4.** Medidor de ánimo: baja con monotonía, aislamiento y exceso de trabajo; sube con tiempo libre, mensajes a casa e invernadero | El ánimo es un recurso de la misión; pedir apoyo es habilidad de tripulación | Decir con una palabra cómo te sientes (no se guarda) |
| Enfermedad por descompresión | 5×3 | 2×2 | Tiempo de preparación antes de salir que no se puede saltar | Hay reglas de seguridad que toman tiempo | No aplica |
| Interacción microbios-huésped | 4×3 | 2×3 | Tarea de limpieza del hábitat en el horario | En un lugar cerrado la higiene es de todos | Lavarse las manos |
| Hipoxia | 3×3 | 3×2 | Medidor de oxígeno del soporte vital que ya pide el reto | El aire de la base se fabrica y se vigila | No aplica |
| Cáncer por radiación | 1×1 (largo plazo: 3×3) | 1×1 | **M5.** Blindaje contra energía, refugio en tormenta solar, barra de dosis acumulada | La radiación no se siente, se acumula | Analogía con el sol de Sonora: sombra, gorra, bloqueador |

### No jugables (5)

| Riesgo | Marte (NASA) | LEO (NASA) | Por qué no |
|---|---|---|---|
| Cardiovascular | 4×4 | 4×3 | No tiene mecánica propia; el bloque de ejercicio lo cubre de forma general |
| Cargas dinámicas (impactos) | 4×4 | 4×3 | Depende del diseño de asientos, trajes y vehículos |
| Síndrome neuro-ocular (SANS) | 4×4 | 4×3 | Sólo como tarjeta de dato curioso. No debe volverse un mensaje sobre la vista de los niños: usar lentes no descarta a nadie |
| Medicamentos ineficaces | 5×3 | 1×1 | No queremos medicamentos como tema de juego para niños |
| Respuesta inmune | 4×3 | 4×2 | Demasiado clínico para esta edad |

## Las 6 mecánicas para la demo

El reto ya pide cuatro recursos de la base: soporte vital, blindaje, energía y comida. Casi todos los equipos van a construir sólo eso. Nuestras seis mecánicas se montan encima, y dos de ellas (M3 y M5) cubren de paso dos de los cuatro recursos.

| | Mecánica | Riesgos HRP que usa (calificación NASA para Marte) | Por qué entra |
|---|---|---|---|
| **M1** | **Retraso Tierra–Marte** | Autonomía 5×5 | Es el momento que un juez recuerda: aprieta "Llamar a la Tierra" y ve que la respuesta no llega a tiempo. Es un reloj y unas tarjetas de procedimiento. Ningún juego de recursos lo tiene |
| **M2** | **Roles y debrief** | Equipo 5×5 | Es nuestra diferencia frente a los demás equipos. El debrief son tres preguntas en pantalla. En la presentación dos jueces pueden tomar un rol cada uno. La NASA entrena estas habilidades en sus tripulaciones con el nombre de *Expeditionary Skills* |
| **M3** | **Menú e invernadero** | Alimentación 5×5 | Cumple el recurso "comida" del reto y lo mejora: variedad en vez de un solo número. Conecta con la acción saludable más fácil (agua, fruta) |
| **M4** | **Medidores de tripulación y planificador del sol** | Sueño 5×2, salud conductual 5×3, músculo 5×4, hueso 4×4 | Es el motor del "lado humano": tres barras (descanso, ánimo, condición física) que cambian el éxito de cualquier tarea. Un solo sistema cubre cuatro riesgos. Autocuidado y cuidado del equipo son dos de las *Expeditionary Skills* |
| **M5** | **Tormenta solar: blindaje contra energía** | Cáncer por radiación (operaciones 1×1, largo plazo 3×3) | El reto exige blindaje. La versión honesta, con dosis acumulada, enseña algo que los otros juegos van a enseñar mal |
| **M6** | **Pausa de tripulación** | Ninguno propio; acompaña a sueño, músculo y alimentación | Es donde el juego toca la salud real del niño: una invitación de 1 minuto entre soles. Es una sola pantalla |

Con M1, M2 y M3 la demo cubre **los tres riesgos que la NASA califica 5×5 para Marte**. Esa frase es el argumento central de Relevancia y es verificable en la página de la NASA.

### Cómo funcionan juntas

- El juego avanza por **soles**, y sólo cuando el jugador aprieta "Avanzar". Cada sol se arma el horario de la tripulación (M4), se ven los recursos de la base y se resuelve a lo más un evento.
- **La dificultad está en coordinarse entre roles, no en la velocidad ni en el ruido.** Las reglas que lo garantizan están en "Diseño: calma y cooperación".
- Las tres barras de M4 y la cohesión de M2 **modifican la probabilidad de éxito** de las tareas. Así el lado humano no es un adorno: una tripulación cansada o desanimada pierde energía, comida o aire porque falla reparaciones.
- Los valores de balance (cuánto baja una barra, cuánto pesa en el éxito) son **de diseño nuestro** y se ajustan jugando. Los valores físicos (retraso, duración del sol, tiempo de ejercicio, dosis) salen de `parametros_juego.csv`. Varios son de astronautas adultos (ejercicio, comida, oxígeno): sirven para la tripulación del juego, nunca como meta para un niño.

### Versión de fin de semana de cada una

- **M1.** Un evento de falla con dos caminos: esperar la respuesta de la Tierra o seguir la tarjeta de procedimiento, que siempre trae una solución. El reloj del retraso es el único reloj del juego. Corre acelerado sólo si se elige esperar, con su valor verdadero escrito al lado. Mientras se lee la tarjeta nada empeora, y decidir rápido no da ningún premio.
- **M2.** Cuatro roles. Cada uno ve un indicador que los demás no ven (por ejemplo, sólo ingeniería ve la batería), y cada evento necesita el dato de dos roles. Cada sol, cada rol toma una decisión que sólo él puede tomar, y el puesto de comandante rota. Los recursos de la base son compartidos y limitados. Con un solo dispositivo, se pasa de mano en el turno de cada rol. Si juega un solo niño lleva los cuatro roles y se pierde la información repartida; el debrief aparece igual. Las tres preguntas: ¿qué salió bien?, ¿qué cambiaríamos?, ¿quién ayudó a quién?
- **M3.** Tres grupos de comida, una reserva que baja cada sol y un invernadero con un solo cultivo que tarda en dar. Dos reglas: repetir el mismo menú varios soles baja la barra de condición física, porque la tripulación come con menos ganas (la NASA estudia esto con el nombre de fatiga de menú); y la comida fresca o variada sube el ánimo (regla nuestra). Como hasta los cultivos más rápidos tardan semanas (`cultivo_*_dias_a_cosecha`), en una demo de tres soles el invernadero empieza ya sembrado o el juego salta en el tiempo hasta la cosecha.
- **M4.** Horario con bloques de trabajo, ejercicio, tiempo libre y sueño. Tres barras por tripulación (no por tripulante, para ahorrar tiempo de programación). Las barras cambian despacio y sin alarmas: se ven al armar el horario del siguiente sol. Dato para el reporte de misión: los astronautas reales duermen menos de lo que tienen programado (`sueno_real_eei` contra `sueno_programado`).
- **M5.** Una decisión de construcción al inicio (cuánto blindaje) y una tormenta solar con guion en un sol fijo. La barra de dosis sube un poco cada sol aunque haya blindaje (rayos cósmicos) y sube mucho en la tormenta si no hay blindaje ni refugio.
- **M6.** Una pantalla entre soles con una invitación y dos botones: "Listo" y "Ahora no". Es también el punto natural para parar: ahí se guarda la partida y se puede cerrar. No da insignias ni manda avisos.

### Orden de construcción y qué recortar

1. Estado de la base y ciclo de soles con los cuatro recursos del reto (sin esto no hay juego).
2. M4, porque todas las demás mecánicas leen sus barras.
3. M1, el momento más fuerte de la demo.
4. M3 y M5, que son reglas sobre recursos que ya existen.
5. M2 y M6, que son pantallas de texto.

Si falta tiempo: M5 se queda en un solo evento con guion, M3 en dos grupos de comida y M2 sin medidor de cohesión (roles con información repartida y debrief). M1, M4 y M6 no se recortan: son los tres que nos distinguen.

### Demo de 3 minutos para los jueces

1. **Sol 1.** El juez arma el horario y le quita sueño a la tripulación para adelantar trabajo.
2. **Sol 2.** Falla el soporte vital. Llama a la Tierra y la respuesta no llega; la tripulación cansada falla el primer intento. Lo resuelve con la tarjeta de procedimiento.
3. **Sol 3.** Alerta de tormenta solar: refugio, trabajo detenido, la barra de dosis sube poco porque hubo blindaje.
4. **Cierre.** Debrief de tres preguntas y pausa de tripulación.

### Lo que se queda fuera de la demo

Caminata espacial, polvo, adaptación sensoriomotora, descompresión y limpieza del hábitat son buenas mecánicas, pero todas necesitan primero un sistema de salidas al exterior. Son la segunda versión. Condiciones médicas puede entrar como una tarjeta de evento si sobra tiempo. El agua de beber (cálculos renales) y el oxígeno (hipoxia) viven dentro del medidor de soporte vital.

## Diseño: calma y cooperación

**Regla central: la dificultad está en coordinarse entre roles, no en la velocidad ni en la intensidad de luces y sonidos.** Un sol difícil es uno donde hay que juntar lo que sabe cada rol, no uno donde hay que apretar rápido.

Las fuentes de esta sección vienen de la investigación del equipo del 14-nov-2026. Se abrieron las dos páginas de la NASA y la presentación de las *Expeditionary Skills*; el estudio del cronómetro se leyó en una nota de prensa. Las demás no se abrieron de nuevo para escribir esto: antes de citar una cifra en el pitch hay que abrir la fuente.

### El gancho para Relevancia: la NASA ya entrena esto

- La NASA entrena en sus tripulaciones las *Expeditionary Skills*, habilidades no técnicas para vuelos de larga duración. Son cinco áreas: autocuidado, cuidado del equipo, trabajo en equipo y vida en grupo (una sola área), comunicación, y liderazgo y saber seguir. Se entrenan con un método de debrief. La lista se leyó en el PDF de la presentación: Rachel Passmore (KBR), "Operational Psychology in Practice: NASA's Behavioral Health and Performance Operations Overview", NTRS 20250011491, publicada el 13-ene-2026, https://ntrs.nasa.gov/api/citations/20250011491. La cita textual y la liga al PDF están en `eda/tables/parametros_juego.md`, sección "Dos referencias de diseño verificadas". **Cuidado: es una plática para internos de psicología de la Marina de EE.UU., no una norma de la NASA.** En el pitch se dice "la NASA entrena", no "la NASA exige".
- La NASA y 4-H lanzaron una versión para jóvenes, "Expeditionary Skills for Life", el 14-dic-2016: https://www.nasa.gov/news-release/nasa-4-h-launch-expeditionary-skills-for-life/. El comunicado nombra cuatro temas: autocuidado y cuidado del equipo, competencia cultural, liderazgo y saber seguir, y trabajo en equipo. No da rango de edad, y es de 2016: no sabemos si el programa sigue activo.
- Cómo se usa: M2 entrena comunicación, liderazgo y saber seguir (por eso el comandante rota cada sol); M4 entrena autocuidado y cuidado del equipo. La frase para el pitch es "entrenamos en pequeño lo que la NASA entrena en sus tripulaciones", no "la NASA avala nuestro juego".

### Reglas de cooperación

| Regla del juego | Dónde vive | Fuente |
|---|---|---|
| Roles complementarios con información repartida: cada rol ve un indicador que los demás no ven, y cada evento necesita a dos roles | M2 | Rocha, Mascarenhas y Prada (2008); El-Nasr et al. (2010) |
| Una decisión por sol que sólo puede tomar cada rol | M2 | Johnson y Johnson: interdependencia positiva más responsabilidad individual; efectos reportados de alrededor de 0.58 a 0.70 |
| Comandante que rota cada sol | M2 | *Expeditionary Skills* (liderazgo y saber seguir) |
| Debrief de 3 preguntas al cerrar cada evento | M2 | Tannenbaum y Cerasoli (2013), meta-análisis de 46 muestras: alrededor de 20 a 25% mejor desempeño |
| Recursos compartidos y limitados (energía, agua, comida) | Base, M3, M5 | Rocha, Mascarenhas y Prada (2008) |

### Reglas de calma

| Regla del juego | Dónde vive | Fuente |
|---|---|---|
| Los soles avanzan al ritmo del jugador, con un botón "Avanzar". A lo más un evento por sol y nunca dos alarmas a la vez | M4 y ciclo de soles | Diseño nuestro |
| El reloj del retraso es el único reloj. Nunca se califica la velocidad, y la respuesta siempre se puede alcanzar con una tarjeta de procedimiento | M1 | Maki, Zaslofsky, Codding y Woods (2024), *Journal of School Psychology*, vol. 106: con 113 alumnos de 4.º y 5.º, la ansiedad reportada no cambió entre cronómetro a la vista y tiempo oculto, y subió con los problemas más difíciles |
| Sin animación decorativa, sonido ni datos curiosos mientras se decide | Todas | Sundararajan y Adesope (2020), 58 estudios |
| Nada parpadea más de 3 veces por segundo, sin alarmas rojas intermitentes, ajuste de movimiento reducido y sonido apagado al iniciar | Todas | WCAG 2.3.1 |
| Pausa y guardado siempre visibles; los soles terminan en puntos naturales para parar; sin exceso de insignias ni de avisos | M6 y ciclo de soles | Children's Code de la ICO (Reino Unido) |

Los datos curiosos (por ejemplo, la tarjeta de SANS) van en el reporte de misión o entre soles, nunca dentro de una decisión.

### Cómo cambia cada mecánica

- **M1.** El reloj cuenta el tiempo de la misión, no el del jugador. Corre sólo si la tripulación elige esperar a la Tierra. Leer la tarjeta de procedimiento no cuesta nada, y la tarjeta siempre trae una solución.
- **M2.** Información repartida, una decisión propia por sol, comandante que rota y recursos compartidos. El debrief se queda como estaba.
- **M4.** Un evento por sol como máximo. Las barras bajan de forma gradual y se revisan al planear, sin alarmas.
- **M6.** Es el punto natural para parar y guardar. No da insignias, no lleva rachas y no manda avisos.

### Prueba con niños este fin de semana

- **Fun Toolkit** (Read y MacFarlane, 2006): un *Smileyometer* (caritas) antes y después de jugar, y la pregunta "¿jugarías otra vez?" con respuestas sí, tal vez o no.
- **Observación.** Mientras juegan, contar cuántas veces planean juntos, se ayudan y se esperan, y cuántas veces un solo niño toma el control.
- Con un adulto responsable presente y permiso de la familia. No se anotan nombres ni datos de salud.

### Límites honestos

- **No hay evidencia sólida de que los juegos "sobreestimulen" a niños de 9 a 14 años.** El estudio que más se cita (Lillard y Peterson, 2011) fue con niños de 4 años, una caricatura de 9 minutos y una medición inmediata. Las reglas de calma se presentan como **precaución y buen diseño**, no como un beneficio de salud comprobado.
- **La evidencia sobre los cronómetros está en disputa.** Por eso dejamos un solo reloj y no calificamos la velocidad, pero no afirmamos que los cronómetros dañen. El estudio de Maki y colegas (2024) es de matemáticas en el salón, no de videojuegos; la muestra es chica y la ansiedad la reportaron los propios alumnos. Sus resultados se tomaron de una nota de Education Week (7-ago-2024): el artículo no se abrió. Detalle en `eda/tables/parametros_juego.md`, sección "Dos referencias de diseño verificadas".
- **Los grupos mal estructurados pueden rendir peor que trabajar solo** (Johnson y Johnson). Poner a cuatro niños frente a una pantalla no basta: sin información repartida y sin decisión propia, uno juega y los demás miran.
- **Las cifras de efecto vienen de otros contextos.** Ni el 0.58 a 0.70 ni el 20 a 25% se midieron en este juego ni necesariamente en niños de esta edad. Sirven para justificar el diseño, no para prometer un resultado.
- **La prueba del fin de semana es de usabilidad.** Con pocos niños y una sola sesión dice si el juego se entiende y gusta, no si mejora la cooperación.

## Eventos del juego tomados de la lista de riesgos

Cada evento nace de un riesgo activo del HRP. El texto del evento es nuestro.

| Evento | Riesgo HRP (Marte, NASA) | Mecánica |
|---|---|---|
| Falla del soporte vital y la Tierra tarda en contestar | Autonomía 5×5 | M1 |
| Dos tripulantes quieren usar la misma energía para tareas distintas | Equipo 5×5 | M2 |
| Se acabó un grupo de comida antes de la cosecha | Alimentación 5×5 | M3 |
| Llevan muchos soles con el mismo menú y comen con menos ganas | Alimentación 5×5 | M3, M4 |
| Reparación urgente de noche: ¿se quita sueño? | Sueño 5×2 | M4 |
| El mensaje de la familia llega tarde | Salud conductual 5×3 | M4 |
| Hay que cargar equipo pesado y se saltó el ejercicio | Músculo 5×4 | M4 |
| Alerta de tormenta solar | Cáncer por radiación 1×1 (largo plazo 3×3) | M5 |
| Un tripulante se torció la muñeca | Condiciones médicas 5×4 | Opcional |

## Reglas para que el juego sea sano

El juego puede invitar a hábitos sanos. No debe medir ni juzgar a ningún niño.

- **Las barras son de la tripulación ficticia, nunca del niño.** El juego no pregunta peso, estatura, qué comió ni cuánto durmió, y no guarda datos de salud.
- **La acción saludable es una invitación.** "Listo" y "Ahora no" dan el mismo resultado en el juego. La respuesta es un mensaje de la tripulación, no puntos. Así nadie tiene motivo para mentir ni para sentirse mal.
- **Calma.** Las reglas de ritmo, pantalla y sonido están en "Diseño: calma y cooperación".
- **Sin tabla de posiciones.** El juego es cooperativo. Al final hay un reporte de misión con lo que aprendió la tripulación, no un lugar entre compañeros.
- **Fallar lleva a un debrief, no a un regaño.** Las preguntas hablan de lo que pasó, no de quién tuvo la culpa.
- **Comida: variedad, nunca restricción.** No se habla de peso, calorías ni de comida "buena" o "mala".
- **Ejercicio: juego de movimiento.** No se copian rutinas de astronautas adultos ni se cuentan repeticiones.
- **Ánimo: sin diagnósticos.** Sólo ánimo, estrés y aislamiento de los personajes. Si se invita al niño a decir cómo se siente, no se guarda, y el mensaje es "cuéntale a alguien de confianza".
- **Sueño: el juego no compite con dormir.** Sin rachas diarias ni avisos de noche; la sesión cierra cuando la tripulación se va a dormir.

## Cuidados antes de usarlo en el pitch

- **"El juego es bueno para la salud real de los niños" es una hipótesis de diseño.** Ningún dato de este EDA prueba que un juego cambie hábitos. Lo que sí se puede decir: el juego invita a tomar agua, moverse y dormir, sin medir ni comparar a nadie.
- **Las tres reglas que estaban pendientes de cita ya se revisaron** en la página de cada riesgo del Human Research Roadmap. El detalle y las direcciones están en `eda/tables/parametros_juego.md`, sección "Las tres reglas que estaban pendientes de cita".
  - **Tomar agua y cálculos renales: confirmada.** La página del riesgo cuenta la hidratación entre las contramedidas, así que se puede atribuir a la NASA.
  - **Preparación antes de una caminata espacial: confirmada.** Los tiempos están en las filas `eva_prerespiracion_*`.
  - **Fatiga de menú: confirmada a medias.** La NASA la liga con aceptar menos la comida, comer menos y perder masa corporal, y lo plantea como una posibilidad en estudio. **No dice que baje el ánimo.** Por eso en M3 el menú repetido baja la condición física, y "la comida fresca sube el ánimo" queda como regla nuestra. En el pitch no se debe decir "la NASA dice que repetir el menú desanima".
  - Con los niños se dice "la tripulación come con menos ganas y pierde fuerza". No se habla de peso.
- **Actividad física y hueso en el crecimiento** sigue pendiente de cita médica, igual que en `FINDINGS.md`.
- **El sol de Sonora es una analogía.** La radiación ultravioleta y la radiación espacial son distintas; sirve para explicar "protegerse de algo que no se siente", no para igualarlas.
- **El "producto" L×C (5×5 = 25) es un cálculo nuestro** para ordenar; la NASA publica el par, no el producto.
- **Nuestra tabla tiene 21 riesgos activos**, que son los que se bajaron del Human Research Roadmap el 14-nov-2026. Las calificaciones cambian cuando el Human System Risk Board las revisa.
- **La asignación de tema OSDR a cada riesgo es nuestra** y aproximada. El tema "aislamiento" (31 estudios) mezcla aislamiento con reposo en cama.

## Parámetros reales que usa cada mecánica

Nombres tal como están en `eda/tables/parametros_juego.csv` (columna `parametro`). El valor, la unidad, la fuente y la nota se leen ahí.

| Mecánica | Parámetros |
|---|---|
| M1 | `retraso_tierra_marte_min`, `retraso_tierra_marte_max`, `retraso_tierra_marte_citado_nasa` (la cifra para el pitch), `retraso_tierra_luna_min`, `retraso_tierra_luna_max`, `retraso_simulado_analogo_hera` (referencia para el reloj acelerado) |
| M2 | `tripulacion_referencia`, `eva_tripulantes_minimos` |
| M3 | `cultivo_*_dias_a_cosecha`, `comida_solidos_secos`, `comida_suministro_con_empaque`, `invernadero_agua_para_cultivos`, `mision_marte_estancia_superficie` |
| M4 | `duracion_sol_marte`, `sueno_programado`, `sueno_real_eei`, `ejercicio_diario_eei`, `ejercicio_supuesto_bvad`, `gravedad_marte`, `gravedad_luna` |
| M5 | `dosis_diaria_superficie_marte`, `dosis_diaria_transito_marte`, `dosis_diaria_eei`, `limite_dosis_carrera_nasa` (tope de la barra), `limite_dosis_tormenta_solar`, `blindaje_reduccion_tormenta_solar`, `blindaje_reduccion_rayos_cosmicos`, `refugio_tormenta_dosis_*` |
| Soporte vital y energía | `oxigeno_consumido`, `co2_producido`, `agua_para_beber`, `agua_total_base_inicial`, `potencia_reactor_kilopower`, `irradiancia_solar_marte` |
| Segunda versión | `eva_duracion_propuesta_marte`, `eva_prerespiracion_meta_exploracion` |

Dos parámetros siguen como `[DATO PENDIENTE]` en ese archivo: `adaptacion_tras_cambio_de_gravedad` (lo usa la mecánica sensoriomotora, que no entra a la demo) y `tormenta_polvo_energia_solar_restante`. Ninguna de las seis mecánicas de la demo depende de ellos.
