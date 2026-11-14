# De los riesgos de la NASA a las mecánicas del juego

Reto: *Build a Junior Astronaut Mission Trainer*. Público oficial: niñas y niños de **7 a 12 años**. El texto oficial está en `CHALLENGE.md` y manda sobre cualquier supuesto anterior.

Este documento dice, para cada riesgo humano que la NASA tiene activo, si se puede jugar a esa edad, con qué mecánica, qué aprende el niño y qué acción saludable real se le puede invitar a hacer. Después define las 6 mecánicas de la demo y las reglas de diseño.

- Tabla completa (una fila por riesgo): `eda/tables/riesgos_a_mecanicas.csv`, generada con `eda/05_riesgos_a_mecanicas.py`.
- Números reales para el juego: `eda/tables/parametros_juego.csv`, con fuente y nota por cada valor. Aquí no se repite ningún valor: se cita el nombre del parámetro, para que haya un solo lugar donde corregirlos.

## Qué cambió con el texto oficial del reto

| El reto dice | Qué cambió aquí |
|---|---|
| Edad de 7 a 12 años | Antes diseñábamos para 9 a 14. Ahora hay lectores principiantes: iconos, texto muy corto y voz opcional. Ver "Lenguaje y pantalla para 7 a 12 años" |
| "Dos o tres recursos centrales (soporte vital, energía, blindaje) suelen funcionar mejor que cinco o seis" | La pantalla muestra 3 recursos: soporte vital, energía y escudo. La comida vive dentro del soporte vital. Descanso, ánimo y condición física se juntan en un solo medidor, "Tripulación" |
| Las decisiones incluyen el retraso de comunicación | M1 está nombrada en el objetivo oficial. Es una decisión dentro de un evento, no un medidor |
| "Evita una opción segura sin costo" | Cada opción de M1 a M6 cuesta algo. Ver "Cada decisión cuesta algo" |
| Destaca quien liga la decisión de blindaje con el clima espacial real y actual (DONKI), quien se puede volver a jugar y quien explica qué datos usó | Ver "Reglas que pide el reto: datos reales y volver a jugar" |
| OSDR aparece como la fuente de hallazgos de salud de astronautas | El medidor Tripulación cita OSDR, además del HRP |
| Guía de evaluación (`JUDGING.md`): todo material ligado a la entrega va en inglés, incluido el juego | El juego que ven los jueces abre en inglés, con botón para español. La tabla de términos tiene columna en inglés |
| Guía de evaluación (`JUDGING.md`): la NASA revisa a los equipos por su restricción de financiamiento con China | El juego no usa ningún valor de la misión china Chang'E 4. El nivel de la Luna usa Artemis I |

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
5. **OSDR respalda el cuerpo, no la conducta.** El reto nombra a OSDR como fuente de hallazgos de salud de astronautas, así que el medidor Tripulación es el lugar para citarlo: de los 577 estudios que revisamos, 115 mencionan hueso y 105 músculo. La barra de dosis puede citar los 146 de radiación. En cambio, equipo y autonomía no tienen tema en OSDR, y sueño sólo aparece en 3 estudios: esas mecánicas las respalda la calificación del HRP. Son conteos por palabras clave, casi todos en animales, y no prueban nada sobre niños.
6. **El reto pide el retraso de comunicación por nombre.** El objetivo oficial lista "communication delay" junto a soporte vital, blindaje, energía y comida. M1 no es un extra nuestro: es parte de lo que se califica.

## Los 21 riesgos activos

Resumen: **5 jugables, 11 jugables en parte, 5 no jugables** para niños de 7 a 12 años. Ordenados por jugabilidad y luego por calificación para Marte. Al bajar la edad no cambió ninguna clasificación; cambió cómo se presenta cada mecánica (iconos, menos texto, menos cosas que vigilar).

### Jugables (5)

| Riesgo | Marte (NASA) | LEO (NASA) | Mecánica (nuestra) | Qué aprende | Acción saludable |
|---|---|---|---|---|---|
| Operación autónoma sin la Tierra (EIHSO) | 5×5 | 5×2 | **M1.** Ante una falla: esperar la respuesta de la Tierra (se pierde soporte vital mientras llega) o actuar con la tarjeta de pasos (cuesta trabajo de la tripulación) | Prepararse antes, seguir los pasos, decidir sin tener toda la información | Ninguna física. Hábito: ver todos los pasos antes de empezar y pedir ayuda a tiempo |
| Alimentación y nutrición | 5×5 | 5×2 | **M3.** La comida es parte del soporte vital. El invernadero gasta energía y agua hoy y da comida fresca después; vivir sólo de comida guardada ahorra energía y baja poco a poco a la tripulación | La comida se planea: lo que se siembra hoy se come después | Tomar agua; probar una fruta o verdura de otro color |
| Equipo (cooperación y comunicación) | 5×5 | 4×2 | **M2.** Cuatro roles y cada uno cuida un solo indicador; cada evento necesita a dos roles; comandante que rota; plática de equipo de 3 preguntas sin culpables | Nadie ve todo; se decide mejor hablando; un error se revisa en equipo | Plática de equipo en voz alta y agradecer a un compañero |
| Músculo y capacidad aeróbica | 5×4 | 5×1 | **M4.** Bloque de "moverse" en el plan del sol; si se salta, baja el medidor Tripulación y cada tarea cuesta más | En baja gravedad el cuerpo pierde fuerza si no se usa | Pausa activa de 1 minuto con la tripulación |
| Sueño y carga de trabajo | 5×2 | 5×2 | **M4.** Bloques de descanso en el plan del sol; quitarlos para trabajar ayuda hoy y mañana cada tarea cuesta más | Dormir es parte de la misión | La sesión termina cuando la tripulación se duerme |

### Jugables en parte (11)

"En parte" quiere decir que sólo se juega el lado que un niño puede entender y practicar, o que el riesgo se suma a otra mecánica en vez de tener la suya.

| Riesgo | Marte (NASA) | LEO (NASA) | Mecánica (nuestra) | Qué aprende | Acción saludable |
|---|---|---|---|---|---|
| Lesiones en caminata espacial (EVA) | 5×4 | 4×2 | Planear la salida: tiempo límite, siempre en pareja, sólo con la tripulación en buen estado | Afuera todo se planea y nadie sale solo | Calentar antes del deporte; tomar agua |
| Condiciones médicas en misión | 5×4 | 4×2 | Evento: alguien se lastima o enferma leve; sin evacuación, botiquín limitado, los demás se reparten sus tareas | Cuidarse antes vale más que curarse después | Lavarse las manos; avisar a un adulto si te sientes mal |
| Sensoriomotor/vestibular | 4×5 | 1×2 | Los primeros soles tras aterrizar, manejar y las tareas finas cuestan más | El cuerpo tarda en acostumbrarse a otra gravedad | Juego de equilibrio opcional |
| Fractura de hueso | 4×4 | 1×2 | **M4.** Parte de "fuerza" del medidor Tripulación, junto con músculo | Los huesos se mantienen fuertes cuando cargan peso | La misma pausa activa |
| Polvo lunar/marciano | 4×4 | No aplica | Limpieza en la esclusa después de salir; saltársela baja el soporte vital | El polvo es un problema real de ingeniería y de salud | No aplica |
| Cálculos renales | 4×4 | 3×4 | Dentro del soporte vital: racionar el agua de beber baja a la tripulación | El agua de beber no es donde se ahorra | Tomar agua simple, sobre todo con calor |
| Salud conductual y cognitiva | 5×3 | 5×2 | **M4.** Parte de "ánimo" del medidor Tripulación: baja con aburrimiento, aislamiento y exceso de trabajo; sube con tiempo libre, mensajes a casa y comida fresca | El ánimo cuenta para la misión; pedir apoyo es de buen tripulante | Decir con una carita cómo te sientes (no se guarda) |
| Enfermedad por descompresión | 5×3 | 2×2 | Tiempo de preparación antes de salir que no se puede saltar | Hay reglas de seguridad que toman tiempo | No aplica |
| Interacción microbios-huésped | 4×3 | 2×3 | Tarea de limpieza del hábitat en el plan del sol | En un lugar cerrado la limpieza es de todos | Lavarse las manos |
| Hipoxia | 3×3 | 3×2 | Es el aire del soporte vital que ya pide el reto | El aire de la base se fabrica y se cuida | No aplica |
| Cáncer por radiación | 1×1 (largo plazo: 3×3) | 1×1 | **M5.** Escudo contra energía, refugio en tormenta solar real (DONKI), barra de radiación recibida | La radiación no se siente, se va juntando | Analogía con el sol de Sonora: sombra, gorra, bloqueador |

### No jugables (5)

| Riesgo | Marte (NASA) | LEO (NASA) | Por qué no |
|---|---|---|---|
| Cardiovascular | 4×4 | 4×3 | No tiene mecánica propia; el bloque de "moverse" lo cubre de forma general |
| Cargas dinámicas (impactos) | 4×4 | 4×3 | Depende del diseño de asientos, trajes y vehículos |
| Síndrome neuro-ocular (SANS) | 4×4 | 4×3 | Sólo como tarjeta de dato curioso. No debe volverse un mensaje sobre la vista de los niños: usar lentes no descarta a nadie |
| Medicamentos ineficaces | 5×3 | 1×1 | No queremos medicamentos como tema de juego para niños |
| Respuesta inmune | 4×3 | 4×2 | Demasiado clínico para esta edad |

## Lo que se ve en pantalla: 3 recursos y una tripulación

| En pantalla | Qué junta | Mecánicas que lo mueven |
|---|---|---|
| **Soporte vital** | Aire, agua y comida. El invernadero lo alimenta | M1, M3 |
| **Energía** | Lo que producen paneles o reactor y lo que gastan aire, invernadero, escudo y antena | M3, M5 |
| **Escudo** | Cuánto protege la base y cuánta radiación lleva recibida la tripulación (una barra que sólo sube) | M5 |
| **Tripulación** | Descanso, ánimo y fuerza en un solo medidor. Al tocarlo se ve cuál de los tres lo tiene bajo y por qué | M2, M4, M6 |

- **Son tres recursos y un medidor de personas: cuatro cosas en total.** Queda dentro de lo que recomienda el reto sólo si la tripulación no se dibuja como una cuarta barra. Propuesta: mostrarla como las caras de los tripulantes, con tres estados (bien, cansada, muy cansada). Si en la prueba con niños siguen siendo demasiadas cosas, lo primero que se junta es Escudo y radiación en un solo icono.
- **En modo cooperativo cada niño cuida una sola cosa.** Los cuatro roles de M2 corresponden a los cuatro indicadores: Ingeniería cuida Energía, Huerto cuida Soporte vital, Protección cuida Escudo y Salud cuida Tripulación. Así el juego en equipo es más fácil de seguir que el juego solo.
- **El retraso de comunicación no es un medidor.** Aparece como decisión cuando hay una falla (M1).
- **El medidor Tripulación tiene efecto visible, sin dados ocultos.** Con la tripulación bien, una tarea cuesta lo normal; con la tripulación cansada, cuesta más bloques de trabajo. El niño ve la causa y puede corregirla. Cuánto más cuesta es un valor de balance nuestro.
- **Por dentro pueden seguir existiendo tres valores** (descanso, ánimo, fuerza) y mostrarse el más bajo. La versión mínima guarda un solo número y la última causa ("bajó porque durmieron poco").

## Las 6 mecánicas para la demo

Casi todos los equipos van a construir sólo los recursos de la base. Nuestras mecánicas agregan el lado humano sin agregar barras: usan los mismos tres recursos y el medidor Tripulación.

| | Mecánica | Riesgos HRP que usa (calificación NASA para Marte) | Por qué entra |
|---|---|---|---|
| **M1** | **Retraso Tierra–Marte** | Autonomía 5×5 | El reto lo pide por nombre. Es el momento que un juez recuerda: pide ayuda a la Tierra y ve que la respuesta no llega a tiempo. Es una decisión con un reloj y una tarjeta de pasos |
| **M2** | **Roles y plática de equipo** | Equipo 5×5 | Es nuestra diferencia frente a los demás equipos. Un papá, una maestra o un hermano mayor pueden tomar un rol, que es lo que sugiere el reto para ampliar el público. La NASA entrena estas habilidades en sus tripulaciones con el nombre de *Expeditionary Skills* |
| **M3** | **Invernadero y comida fresca** | Alimentación 5×5 | Cumple "producción de comida" del reto con una decisión clara: energía hoy a cambio de comida fresca después |
| **M4** | **Tripulación y plan del sol** | Sueño 5×2, salud conductual 5×3, músculo 5×4, hueso 4×4 | Es el motor del lado humano: un solo medidor que cambia cuánto cuesta cada tarea. Cubre cuatro riesgos y es donde se cita OSDR. Autocuidado y cuidado del equipo son dos de las *Expeditionary Skills* |
| **M5** | **Tormenta solar real: escudo contra energía** | Cáncer por radiación (operaciones 1×1, largo plazo 3×3) | El reto pide blindaje y premia ligarlo con el clima espacial real de DONKI. La versión honesta, con radiación que se acumula, enseña algo que otros juegos van a enseñar mal |
| **M6** | **Pausa de tripulación** | Ninguno propio; acompaña a sueño, músculo y alimentación | Es donde el juego toca la salud real del niño: una invitación de 1 minuto al cerrar el sol. En el juego, la pausa cuesta trabajo |

Con M1, M2 y M3 la demo cubre **los tres riesgos que la NASA califica 5×5 para Marte**. Esa frase es el argumento central de Relevancia y es verificable en la página de la NASA.

### Cómo funcionan juntas

- El juego avanza por **soles** (un sol es un día en Marte), y sólo cuando el jugador aprieta "Avanzar".
- Cada sol la tripulación tiene unos cuantos **bloques** para repartir entre trabajar, moverse y descansar. Trabajar sube los recursos de la base; moverse y descansar suben a la tripulación. Nunca alcanza para todo.
- Cada sol trae a lo más **un evento** de la baraja (ver "Eventos del juego").
- **La dificultad está en coordinarse entre roles, no en la velocidad ni en el ruido.** Las reglas están en "Diseño: calma y cooperación".
- Los valores de balance (cuántos bloques hay, cuánto baja una barra) son **de diseño nuestro** y se ajustan jugando. Los valores físicos (retraso, duración del sol, dosis, días a cosecha) salen de `parametros_juego.csv`. Varios son de astronautas adultos (ejercicio, comida, oxígeno): sirven para la tripulación del juego, nunca como meta para un niño.

### Cada decisión cuesta algo

El reto pide que no exista una opción segura y gratis. Revisión opción por opción:

| | Opción | Qué da | Qué cuesta |
|---|---|---|---|
| **M1** | Esperar a la Tierra | La respuesta correcta | Soporte vital que se pierde mientras llega la respuesta, y energía de la antena |
| | Actuar con la tarjeta de pasos | Se arregla hoy | Bloques de trabajo; más bloques si la tripulación está cansada |
| **M2** | Decisión propia de cada rol, cada sol | Sube el indicador que cuida ese rol | Sale de recursos compartidos: lo que gasta un rol no lo tiene otro |
| **M3** | Encender el invernadero | Comida fresca más adelante; sube soporte vital y ánimo | Energía y agua desde hoy, y bloques de trabajo de un tripulante |
| | Vivir de la comida guardada | Ahorra energía | La reserva se acaba y la tripulación come con menos ganas: baja Tripulación |
| **M4** | Más bloques de trabajo | Suben los recursos de la base | Baja Tripulación, y mañana cada tarea cuesta más |
| | Más bloques de moverse y descansar | Sube Tripulación | Menos trabajo hecho hoy |
| **M5** | Reforzar el escudo | Menos radiación en la tormenta | Energía de esta noche y bloques de trabajo |
| | Ir al refugio durante la tormenta | Casi no sube la radiación recibida | Se pierde el trabajo de ese sol |
| | Seguir trabajando en la tormenta | El trabajo del sol se hace | La barra de radiación recibida sube mucho, y no baja nunca |
| **M6** | Tomar la pausa | Sube Tripulación | El primer bloque de trabajo del sol siguiente |
| | Seguir sin pausa | Se conserva ese bloque | Baja un poco Tripulación |

Tres cosas no son decisiones y por eso no tienen costo:

- **La plática de equipo** (debrief) pasa siempre al cerrar un evento.
- **La invitación saludable real** de M6 no cambia nada en el juego. "Listo" y "Ahora no" dan lo mismo. El costo de la pausa lo paga la tripulación ficticia, nunca el niño.
- **Llamar a la Tierra desde la Luna** en el nivel de práctica: la respuesta llega casi de inmediato, así que casi siempre conviene. Es la única opción casi gratis y existe para que se note el contraste con Marte. Para cumplir la regla también ahí, la llamada gasta energía de la antena.

### Versión de fin de semana de cada una

- **M1.** Un evento de falla con dos caminos: esperar a la Tierra o seguir la tarjeta de pasos, que siempre trae una solución. El reloj del retraso es el único reloj del juego. Corre acelerado sólo si se elige esperar, con su valor verdadero escrito al lado. Mientras se mira la tarjeta nada empeora, y decidir rápido no da ningún premio. La tarjeta son tres pasos con dibujo, no un párrafo.
- **M2.** Cuatro roles, cada uno con un color, un icono y un solo indicador a su cargo. Cada evento necesita lo que ven dos roles. Cada sol, cada rol toma una decisión que sólo él puede tomar. El comandante no es un rol fijo: es un gorro que rota cada sol, y quien lo trae aprieta "Avanzar" y desempata. Con un solo dispositivo, se pasa de mano en el turno de cada rol. Para los más chicos (7 y 8 años): dos roles, cada uno con dos indicadores, o un adulto que lee en voz alta. Si juega un solo niño lleva los cuatro roles y ve todo; la plática de equipo aparece igual.
- **M3.** Una decisión: encender o no el invernadero, con un solo cultivo. Dos reglas: vivir muchos soles sólo de comida guardada baja Tripulación, porque la tripulación come con menos ganas (la NASA estudia esto con el nombre de fatiga de menú); y la comida fresca sube Tripulación por el lado del ánimo (regla nuestra). Como hasta los cultivos más rápidos tardan semanas (`cultivo_*_dias_a_cosecha`), en una demo de tres soles el invernadero empieza ya sembrado o el juego salta en el tiempo hasta la cosecha.
- **M4.** Plan del sol con fichas de tres tipos: trabajar, moverse y descansar. Un solo medidor para toda la tripulación. Cambia despacio y sin alarmas: se ve al armar el plan del siguiente sol. Dato para el reporte de misión: los astronautas reales duermen menos de lo que tienen programado (`sueno_real_eei` contra `sueno_programado`).
- **M5.** Una decisión de escudo antes de la tormenta y una decisión de refugio durante ella. La tormenta sale de un evento real de DONKI (ver la sección siguiente). La barra de radiación recibida sube un poquito cada sol aunque haya escudo (rayos cósmicos) y sube mucho en la tormenta si no hay escudo ni refugio. En el nivel de práctica de la Luna, el dato de radiación es el de Artemis I (instrumento HERA de la NASA), con su etiqueta: "medido dentro de la nave Orion, en vuelo". No se usa ningún valor de Chang'E 4.
- **M6.** Al cerrar el sol, dos pantallas. Primero la decisión del juego: pausa o seguir. Después la invitación real con dos botones, "Listo" y "Ahora no". Es también el punto natural para parar: ahí se guarda la partida y se puede cerrar. No da insignias ni manda avisos.

### Orden de construcción y qué recortar

1. Estado de la base (3 recursos y Tripulación) y ciclo de soles con fichas. Sin esto no hay juego.
2. M4, porque todas las demás mecánicas leen el medidor Tripulación.
3. M1, el momento más fuerte de la demo.
4. M5 con un evento real de DONKI archivado dentro del juego.
5. M3 como una sola decisión.
6. M2, M6, las etiquetas "Dato real NASA" y la pantalla "Datos NASA usados".

Si falta tiempo: M2 se queda en dos roles, M3 en el invernadero ya sembrado y la baraja en tres eventos fijos. No se recortan M1, M4, M5 con su dato real, las etiquetas de fuente ni la pantalla "Datos NASA usados": son lo que el reto califica y lo que nos distingue. La llamada en vivo a DONKI es lo último: la demo nunca debe depender de ella.

### Demo de 3 minutos para los jueces

1. **Luna, práctica.** Se pide ayuda a la Tierra y contesta casi de inmediato.
2. **Marte, sol 1.** El juego muestra el clima espacial real. El juez reparte la energía entre escudo e invernadero, y le quita descanso a la tripulación para adelantar trabajo.
3. **Sol 2.** Falla el soporte vital. Pide ayuda a la Tierra y la respuesta no llega; con la tripulación cansada, seguir la tarjeta cuesta más bloques.
4. **Sol 3.** Tormenta solar tomada de un evento real: refugio y trabajo perdido, o trabajo hecho y radiación recibida.
5. **Cierre.** Plática de equipo, pausa de tripulación y la pantalla "Datos NASA usados".

### Lo que se queda fuera de la demo

Caminata espacial, polvo, adaptación sensoriomotora, descompresión y limpieza del hábitat son buenas mecánicas, pero todas necesitan primero un sistema de salidas al exterior. Son la segunda versión. Condiciones médicas puede entrar como una carta de la baraja si sobra tiempo. El agua de beber (cálculos renales) y el aire (hipoxia) viven dentro del soporte vital.

## Reglas que pide el reto: datos reales y volver a jugar

### La decisión de escudo ligada al clima espacial real (DONKI)

- **Regla.** Antes de decidir cuánta energía va al escudo, el jugador ve el clima espacial real. La tormenta de M5 es un evento que DONKI registró, con su fecha.
- **Qué hay disponible.** Según las notas de construcción (probado el 14-nov-2026), en api.nasa.gov funcionan las tormentas geomagnéticas (GST, con índice Kp) y los eventos de partículas solares (SEP); el de fulguraciones (FLR) dio error 404. Para M5 el tipo que corresponde es SEP, porque son las partículas las que elevan la dosis.
- **Etiquetas honestas.** Un evento bajado hoy dice "registrada por NASA DONKI el [fecha]". La copia que viene dentro del juego dice "dato archivado". **Nunca se presenta un dato archivado como si fuera en vivo.**
- **La demo no depende de la red.** El juego lee un archivo del día y, si no está, usa la copia incluida.
- **Límites honestos.**
  - DONKI dice que hubo un evento y cuándo. **No dice cuánta radiación recibiría una base en Marte.** Cuánto sube la barra en el juego es regla nuestra, apoyada en `refugio_tormenta_dosis_*` y `blindaje_reduccion_tormenta_solar`.
  - Los eventos de DONKI se observan desde cerca de la Tierra. Una tormenta que llega a la Tierra no siempre llega a Marte. El juego puede decir "esta tormenta ocurrió de verdad", no "esta tormenta golpeó Marte".
  - El índice Kp mide la perturbación del campo magnético de la Tierra. Sirve para mostrar "así está hoy el clima espacial", no para calcular dosis.

### Volver a jugar

- **Baraja de eventos que cambia.** En cada partida salen eventos distintos y en otro orden: tormentas reales de fechas diferentes, la falla de M1 en otro sol, y el retraso según la distancia de ese día entre la Tierra y Marte (dentro de `retraso_tierra_marte_min` y `retraso_tierra_marte_max`). La lista de cartas está en "Eventos del juego".
- **Modo demo.** Para los jueces, una baraja fija en el orden del guion de 3 minutos.
- **Fallar con explicación.** Si un recurso llega a cero, el juego no dice "perdiste". Muestra qué pasó y por qué ("se acabó el aire porque la energía se fue al escudo"), con el dato real que hay detrás. Ofrece volver a intentar desde el inicio de ese sol o empezar otra misión.
- **Sin dados ocultos.** La variación viene de la baraja, no de un azar que el niño no ve. Así cada fracaso se puede explicar.

### Datos reales a la vista

- **Etiqueta "Dato real NASA".** Cada número que viene de una fuente lleva una etiqueta pequeña; al tocarla se ve la fuente y la fecha. Los textos salen de las columnas `fuente` y `url` de `parametros_juego.csv`.
- **No se usa ningún valor de Chang'E 4 en el juego.** La NASA revisa a los equipos por su restricción de financiamiento con China (ver `JUDGING.md`). Citar un artículo no es colaborar, pero para no dejar duda, las filas `dosis_diaria_superficie_luna` y `razon_dosis_luna_vs_eei` de `parametros_juego.csv` (medidas por la misión china Chang'E 4) no aparecen en ninguna pantalla, etiqueta ni carta. Tampoco se usa `dosis_diaria_eei`: es del instrumento europeo DOSIS 3D, no es dato de la NASA, y su valor se leyó en el mismo artículo de Chang'E 4.
- **El nivel de la Luna usa Artemis I** (`dosis_diaria_orion_artemis_i_min` y `dosis_diaria_orion_artemis_i_max`, instrumento HERA de la NASA). Se midió dentro de la nave Orion en vuelo, no en la superficie, y la etiqueta lo dice: "medido dentro de la nave Orion, en vuelo". No tenemos un valor de la NASA medido en la superficie lunar, y el juego no debe sugerir que lo es.
- **Antes de poner la etiqueta "Dato real NASA" se lee la columna `fuente` de la fila.** Si la fuente no es de la NASA, la fila no entra al juego.
- **Los valores de balance no llevan etiqueta.** Cuántos bloques tiene un sol o cuánto baja una barra son reglas del juego. Si se marcan, se marcan como "regla del juego".
- **La etiqueta es discreta.** No se abre sola ni interrumpe una decisión (ver las reglas de calma).
- **Pantalla "Datos NASA usados".** Dentro del juego, con una línea por fuente: qué es, para qué se usó y si es en vivo o archivado.

| Fuente | Para qué se usa en el juego | En vivo o archivado |
|---|---|---|
| DONKI (clima espacial) | La tormenta de M5 y el clima espacial del día | En vivo si hay red; si no, archivado y dicho así |
| OSDR (estudios de biología espacial) | El medidor Tripulación (hueso, músculo) y la barra de radiación | Archivado: conteos del 14-nov-2026 |
| Human Research Roadmap (riesgos del HRP) | Por qué existen M1 a M5 y qué tan alto califica la NASA cada riesgo | Archivado: consultado el 14-nov-2026 |
| Documento de valores de soporte vital de la NASA (BVAD) y las demás fuentes de la NASA y JPL en `parametros_juego.csv` | Aire, agua, comida, dosis en Marte, retraso, cultivos | Archivado; la fecha de cada uno está en `parametros_juego.md` |
| JPL Horizons | La distancia del día entre la Tierra y Marte, para el retraso | Se baja antes de jugar; se dice la fecha |
| Artemis I, instrumento HERA de la NASA | La radiación en el nivel de práctica de la Luna | Archivado (misión de 2022). Se dice que se midió dentro de la nave Orion, en vuelo |

### OSDR en el medidor Tripulación

- **Qué se puede decir hoy:** "De 577 estudios abiertos de la NASA que revisamos, 115 hablan de hueso y 105 de músculo". Va en el detalle del medidor Tripulación, con su etiqueta.
- **Para niños:** "La NASA estudia cómo cambian los huesos y los músculos en el espacio".
- **Qué no se puede decir:** un conteo de estudios no es un hallazgo. Casi todos son en ratones y el tema se asignó por palabras clave.
- **Qué falta para citar un hallazgo real de salud de astronautas,** que es lo que el reto valora: abrir un estudio y copiar su resultado. Los candidatos están en `eda/tables/osdr_musculo_hueso_ejemplos.csv`. `[DATO PENDIENTE: abrir un estudio de OSDR de hueso o músculo y citar un resultado con su número de acceso]`

## Lenguaje y pantalla para 7 a 12 años

El reto pide lenguaje sencillo y explicar cada término en su contexto. Entre los 7 y los 12 años hay niños que apenas leen de corrido.

- **Icono más una frase corta.** Cada carta, botón y medidor tiene un dibujo. Ningún texto de decisión pasa de una frase.
- **Sin escribir.** Todo se contesta tocando. La plática de equipo se responde con caritas o en voz alta.
- **Voz opcional.** Un botón "Escuchar" lee la carta. El sonido sigue apagado al iniciar; la voz sólo suena si se pide.
- **Botones grandes** y una sola decisión por pantalla.
- **El juego abre en inglés.** La guía de evaluación pide inglés en todo material ligado a la entrega, incluido el juego (`JUDGING.md`). La versión que ven los jueces arranca en inglés y tiene un botón para cambiar a español. Para la prueba con niños en Hermosillo se cambia a español con ese botón.
- **Todos los textos existen en los dos idiomas desde el principio.** Un texto que sólo está en español no entra a la versión de los jueces.
- **Los términos se explican la primera vez que salen,** dentro del juego:

| Término | En español | In English |
|---|---|---|
| Sol | "Un sol es un día en Marte. Dura un poquito más que un día en la Tierra" (`duracion_sol_marte`) | "A sol is one day on Mars. It lasts a little longer than a day on Earth" |
| Dosis de radiación | "Radiación recibida: no se siente, pero se va juntando" | "Radiation dose: you can't feel it, but it adds up" |
| Soporte vital | "Aire, agua y comida" | "Life support: air, water and food" |
| Blindaje | "Escudo" | "Shield" |
| Microgravedad, baja gravedad | "Aquí todo pesa menos, y el cuerpo se pone flojo si no se mueve" | "Everything weighs less here, and your body gets weak if it doesn't move" |
| Debrief | "Plática de equipo" | "Team talk" |
| Retraso de comunicación | "La Tierra está tan lejos que su respuesta tarda en llegar" | "Earth is so far away that its answer takes a while to arrive" |
| Fatiga de menú | "La tripulación come con menos ganas y pierde fuerza" | "The crew eats with less appetite and loses strength" |
| EIHSO, HRP, L×C | No aparecen en el juego. Son para el pitch | Not shown in the game |

Textos fijos de la pantalla, en los dos idiomas:

| Dónde | En español | In English |
|---|---|---|
| Recursos | Soporte vital · Energía · Escudo | Life support · Power · Shield |
| Medidor de personas | Tripulación (descanso, ánimo, fuerza) | Crew (rest, mood, strength) |
| Roles | Ingeniería · Huerto · Protección · Salud · Comandante | Engineering · Garden · Protection · Health · Commander |
| Fichas del plan del sol | Trabajar · Moverse · Descansar | Work · Move · Rest |
| Botones | Avanzar · Escuchar · Listo · Ahora no | Next sol · Listen · Done · Not now |
| M1 | Llamar a la Tierra · Usar la tarjeta de pasos | Call Earth · Use the step card |
| M5 | Reforzar el escudo · Ir al refugio · Seguir trabajando | Strengthen the shield · Go to the shelter · Keep working |
| M6 | Pausa de tripulación | Crew break |
| Plática de equipo | ¿Qué salió bien? · ¿Qué cambiaríamos? · ¿Quién ayudó a quién? | What went well? · What would we change? · Who helped whom? |
| Etiqueta de dato | Dato real NASA | Real NASA data |
| Etiqueta de regla | Regla del juego | Game rule |
| Tormenta en vivo | Registrada por NASA DONKI el [fecha] | Recorded by NASA DONKI on [date] |
| Tormenta incluida | Dato archivado | Archived data |
| Dato de la Luna | Medido dentro de la nave Orion, en vuelo | Measured inside the Orion spacecraft, in flight |
| Pantalla de fuentes | Datos NASA usados | NASA data used |

Las frases en inglés son propuesta nuestra y conviene que las revise quien grabe el video.

- **El juego crece con quien juega.** Solo, un niño de 10 a 12 años lleva todo. En equipo, cada quien cuida una cosa y un adulto o un hermano mayor puede tomar un rol. En el salón, la maestra lee las cartas y el grupo decide.

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
| Roles complementarios con información repartida: cada rol cuida un indicador que los demás no ven, y cada evento necesita a dos roles | M2 | Rocha, Mascarenhas y Prada (2008); El-Nasr et al. (2010) |
| Una decisión por sol que sólo puede tomar cada rol | M2 | Johnson y Johnson: interdependencia positiva más responsabilidad individual; efectos reportados de alrededor de 0.58 a 0.70 |
| Comandante que rota cada sol | M2 | *Expeditionary Skills* (liderazgo y saber seguir) |
| Plática de equipo (debrief) de 3 preguntas al cerrar cada evento | M2 | Tannenbaum y Cerasoli (2013), meta-análisis de 46 muestras: alrededor de 20 a 25% mejor desempeño |
| Recursos compartidos y limitados (soporte vital, energía, escudo) | Base, M3, M5 | Rocha, Mascarenhas y Prada (2008) |

### Reglas de calma

| Regla del juego | Dónde vive | Fuente |
|---|---|---|
| Los soles avanzan al ritmo del jugador, con un botón "Avanzar". A lo más un evento por sol y nunca dos alarmas a la vez | M4 y ciclo de soles | Diseño nuestro |
| El reloj del retraso es el único reloj. Nunca se califica la velocidad, y la respuesta siempre se puede alcanzar con una tarjeta de pasos | M1 | Maki, Zaslofsky, Codding y Woods (2024), *Journal of School Psychology*, vol. 106: con 113 alumnos de 4.º y 5.º, la ansiedad reportada no cambió entre cronómetro a la vista y tiempo oculto, y subió con los problemas más difíciles |
| Sin animación decorativa, sonido ni datos curiosos mientras se decide | Todas | Sundararajan y Adesope (2020), 58 estudios |
| Nada parpadea más de 3 veces por segundo, sin alarmas rojas intermitentes, ajuste de movimiento reducido y sonido apagado al iniciar | Todas | WCAG 2.3.1 |
| Pausa y guardado siempre visibles; los soles terminan en puntos naturales para parar; sin exceso de insignias ni de avisos | M6 y ciclo de soles | Children's Code de la ICO (Reino Unido) |

Los datos curiosos (por ejemplo, la tarjeta de SANS) van en el reporte de misión o entre soles, nunca dentro de una decisión. La etiqueta "Dato real NASA" no cuenta como dato curioso: marca el número que se está usando para decidir, y su detalle sólo se abre si el niño la toca.

### Cómo aplica a cada mecánica

- **M1.** El reloj cuenta el tiempo de la misión, no el del jugador. Corre sólo si la tripulación elige esperar a la Tierra. Mirar la tarjeta de pasos no gasta tiempo real; lo que cuesta es aplicarla (bloques de trabajo).
- **M2.** Información repartida, una decisión propia por sol, comandante que rota y recursos compartidos. La plática de equipo pasa siempre.
- **M4.** Un evento por sol como máximo. El medidor Tripulación cambia de forma gradual y se revisa al planear, sin alarmas.
- **M6.** Es el punto natural para parar y guardar. No da insignias, no lleva rachas y no manda avisos.

### Prueba con niños este fin de semana

- **Fun Toolkit** (Read y MacFarlane, 2006): un *Smileyometer* (caritas) antes y después de jugar, y la pregunta "¿jugarías otra vez?" con respuestas sí, tal vez o no.
- **Observación.** Mientras juegan, contar cuántas veces planean juntos, se ayudan y se esperan, y cuántas veces un solo niño toma el control.
- **Probar los dos extremos de edad.** Al menos un niño de 7 u 8 años y uno de 11 o 12: ver si el chico entiende las cartas sin que se las lean y si el grande no se aburre.
- **Contar cuántas cosas vigilan.** Al terminar, preguntar "¿qué tenías que cuidar?". Si no nombran los tres recursos y la tripulación, hay demasiado en pantalla.
- Con un adulto responsable presente y permiso de la familia. No se anotan nombres ni datos de salud.

### Límites honestos

- **No hay evidencia sólida de que los juegos "sobreestimulen" a niños de 7 a 12 años.** El estudio que más se cita (Lillard y Peterson, 2011) fue con niños de 4 años, una caricatura de 9 minutos y una medición inmediata. Las reglas de calma se presentan como **precaución y buen diseño**, no como un beneficio de salud comprobado.
- **La evidencia sobre los cronómetros está en disputa.** Por eso dejamos un solo reloj y no calificamos la velocidad, pero no afirmamos que los cronómetros dañen. El estudio de Maki y colegas (2024) es de matemáticas en el salón, no de videojuegos; la muestra es chica y la ansiedad la reportaron los propios alumnos. Sus resultados se tomaron de una nota de Education Week (7-ago-2024): el artículo no se abrió. Detalle en `eda/tables/parametros_juego.md`, sección "Dos referencias de diseño verificadas".
- **Los grupos mal estructurados pueden rendir peor que trabajar solo** (Johnson y Johnson). Poner a cuatro niños frente a una pantalla no basta: sin información repartida y sin decisión propia, uno juega y los demás miran.
- **Las cifras de efecto vienen de otros contextos.** Ni el 0.58 a 0.70 ni el 20 a 25% se midieron en este juego ni necesariamente en niños de esta edad. Sirven para justificar el diseño, no para prometer un resultado.
- **La prueba del fin de semana es de usabilidad.** Con pocos niños y una sola sesión dice si el juego se entiende y gusta, no si mejora la cooperación.
- **No sabemos si un niño de 7 años puede con la información repartida.** La versión de dos roles y la lectura en voz alta son nuestra respuesta, sin probar todavía.

## Eventos del juego: la baraja

Cada carta nace de un riesgo activo del HRP. El texto de la carta es nuestro. En cada partida salen en otro orden, y sale a lo más una por sol.

| Carta | Riesgo HRP (Marte, NASA) | Mecánica | Recurso que toca |
|---|---|---|---|
| Falla del soporte vital y la Tierra tarda en contestar | Autonomía 5×5 | M1 | Soporte vital |
| Dos roles quieren la misma energía para cosas distintas | Equipo 5×5 | M2 | Energía |
| La comida guardada va a la mitad y el invernadero no está encendido | Alimentación 5×5 | M3 | Soporte vital |
| Muchos soles con la misma comida: la tripulación come con menos ganas | Alimentación 5×5 | M3, M4 | Tripulación |
| Reparación urgente de noche: ¿se quita descanso? | Sueño 5×2 | M4 | Tripulación, Energía |
| El mensaje de la familia llega tarde | Salud conductual 5×3 | M4 | Tripulación |
| Hay que cargar equipo pesado y se saltaron los bloques de moverse | Músculo 5×4 | M4 | Tripulación |
| Tormenta solar (una carta por cada evento real de DONKI) | Cáncer por radiación 1×1 (largo plazo 3×3) | M5 | Escudo, Energía |
| Un tripulante se torció la muñeca | Condiciones médicas 5×4 | Opcional | Tripulación |

## Reglas para que el juego sea sano

El juego puede invitar a hábitos sanos. No debe medir ni juzgar a ningún niño.

- **El medidor es de la tripulación ficticia, nunca del niño.** El juego no pregunta peso, estatura, qué comió ni cuánto durmió, y no guarda datos de salud.
- **La acción saludable es una invitación.** "Listo" y "Ahora no" dan el mismo resultado en el juego. La respuesta es un mensaje de la tripulación, no puntos. Así nadie tiene motivo para mentir ni para sentirse mal.
- **El costo de la pausa es del juego, no del niño.** La tripulación ficticia pierde un bloque de trabajo si toma la pausa. Que el niño se estire o no en la vida real no cambia nada en la partida.
- **Calma.** Las reglas de ritmo, pantalla y sonido están en "Diseño: calma y cooperación".
- **Sin tabla de posiciones.** El juego es cooperativo. Al final hay un reporte de misión con lo que aprendió la tripulación, no un lugar entre compañeros.
- **Fallar lleva a una explicación y a otra oportunidad, no a un regaño.** Las preguntas hablan de lo que pasó, no de quién tuvo la culpa.
- **Comida: variedad, nunca restricción.** No se habla de peso, calorías ni de comida "buena" o "mala".
- **Ejercicio: juego de movimiento.** No se copian rutinas de astronautas adultos ni se cuentan repeticiones.
- **Ánimo: sin diagnósticos.** Sólo ánimo, cansancio y aislamiento de los personajes. Si se invita al niño a decir cómo se siente, no se guarda, y el mensaje es "cuéntale a alguien de confianza".
- **Sueño: el juego no compite con dormir.** Sin rachas diarias ni avisos de noche; la sesión cierra cuando la tripulación se va a dormir.

## Cuidados antes de usarlo en el pitch

- **"El juego es bueno para la salud real de los niños" es una hipótesis de diseño.** Ningún dato de este EDA prueba que un juego cambie hábitos. Lo que sí se puede decir: el juego invita a tomar agua, moverse y dormir, sin medir ni comparar a nadie.
- **Tres recursos y una tripulación son cuatro cosas en pantalla.** El reto recomienda dos o tres. Hay que poder explicar por qué la tripulación no es un cuarto recurso, y tener lista la versión que junta escudo y radiación.
- **El dato de DONKI es real; su efecto en el juego es regla nuestra.** No decir "esta tormenta habría dado tanta radiación en Marte".
- **Un conteo de estudios de OSDR no es un hallazgo de salud.** Falta abrir un estudio para citar un resultado.
- **Ningún valor de Chang'E 4 en el juego ni en el pitch.** Tres filas de `parametros_juego.csv` quedan fuera: `dosis_diaria_superficie_luna`, `razon_dosis_luna_vs_eei` y `dosis_diaria_eei`. El dato lunar es el de Artemis I, y siempre se dice que se midió dentro de la nave Orion en vuelo.
- **Este documento está en español y la guía pide inglés en todo material ligado a la entrega.** Si el repositorio se liga en la entrega, hace falta una versión en inglés de este documento o un resumen en inglés que lo sustituya.
- **Las tres reglas que estaban pendientes de cita ya se revisaron** en la página de cada riesgo del Human Research Roadmap. El detalle y las direcciones están en `eda/tables/parametros_juego.md`, sección "Las tres reglas que estaban pendientes de cita".
  - **Tomar agua y cálculos renales: confirmada.** La página del riesgo cuenta la hidratación entre las contramedidas, así que se puede atribuir a la NASA.
  - **Preparación antes de una caminata espacial: confirmada.** Los tiempos están en las filas `eva_prerespiracion_*`.
  - **Fatiga de menú: confirmada a medias.** La NASA la liga con aceptar menos la comida, comer menos y perder masa corporal, y lo plantea como una posibilidad en estudio. **No dice que baje el ánimo.** Por eso en M3 la comida repetida baja a la tripulación por el lado de la fuerza, y "la comida fresca sube el ánimo" queda como regla nuestra. En el pitch no se debe decir "la NASA dice que repetir el menú desanima".
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
| M5 | `dosis_diaria_superficie_marte`, `dosis_diaria_transito_marte`, `limite_dosis_carrera_nasa` (tope de la barra), `limite_dosis_tormenta_solar`, `blindaje_reduccion_tormenta_solar`, `blindaje_reduccion_rayos_cosmicos`, `refugio_tormenta_dosis_*` |
| M5 en la Luna (práctica) | `dosis_diaria_orion_artemis_i_min`, `dosis_diaria_orion_artemis_i_max`, `refugio_orion_tormenta_solar_max` (NASA, Artemis I; medidos o diseñados para dentro de la nave Orion) |
| No se usan | `dosis_diaria_superficie_luna`, `razon_dosis_luna_vs_eei` (Chang'E 4) y `dosis_diaria_eei` (DOSIS 3D, leído en el artículo de Chang'E 4) |
| Soporte vital y energía | `oxigeno_consumido`, `co2_producido`, `agua_para_beber`, `agua_total_base_inicial`, `potencia_reactor_kilopower`, `irradiancia_solar_marte` |
| Segunda versión | `eva_duracion_propuesta_marte`, `eva_prerespiracion_meta_exploracion` |

Los eventos de DONKI y la distancia del día de JPL Horizons no están en `parametros_juego.csv`: son datos que el juego lee de su archivo del día o de la copia incluida.

Dos parámetros siguen como `[DATO PENDIENTE]` en ese archivo: `adaptacion_tras_cambio_de_gravedad` (lo usa la mecánica sensoriomotora, que no entra a la demo) y `tormenta_polvo_energia_solar_restante`. Ninguna de las seis mecánicas de la demo depende de ellos.
