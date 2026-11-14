#!/usr/bin/env python3
"""EDA 5: de los riesgos del NASA Human Research Program (HRP) a mecánicas de juego para niños de 9 a 14 años.

Entradas (no se modifican):
  eda/tables/hrp_riesgos_clasificados.csv     calificaciones oficiales L×C por riesgo (Marte planetario y LEO largo)
  eda/tables/hrp_riesgos_por_mision_largo.csv calificaciones por misión de referencia (de aquí sale la superficie lunar)
  eda/tables/osdr_por_tema.csv                conteo de estudios OSDR por tema (palabras clave, aproximado)
Salida:
  eda/tables/riesgos_a_mecanicas.csv

Las columnas de calificación se COPIAN de las tablas de entrada (son de la NASA). Todo lo que termina en
«_propio/_propia» es diseño nuestro: la NASA no dice que estos riesgos se entrenen con un juego.
El texto que explica esta tabla está en eda/riesgos_a_mecanicas.md.
"""
from common import TABLES, read_csv, write_csv

# Mecánicas de la demo (diseño propio).
DEMO = {
    "M1": "Retraso Tierra-Marte",
    "M2": "Roles y debrief",
    "M3": "Menú e invernadero",
    "M4": "Medidores de tripulación y planificador del sol",
    "M5": "Tormenta solar: blindaje contra energía",
}

# short_title -> (jugable, mecánica demo, mecánica, qué aprende, acción saludable, parámetros reales que necesita, cuidado)
D = {
    "Team": ("sí", "M2",
        "Roles de tripulación (comandante, ingeniería, salud, invernadero) con información repartida: cada rol ve un indicador que los demás no ven, "
        "y cada evento necesita el dato de dos roles. Cada sol, cada rol toma una decisión que sólo él puede tomar, y el puesto de comandante rota. "
        "Un medidor de cohesión sube cuando se reparten tareas y se atienden los avisos de otro rol, y afecta el éxito de las tareas en equipo. "
        "Al cerrar cada evento hay un debrief de 3 preguntas sin culpables.",
        "Nadie tiene toda la información; se decide mejor hablando. Un error se revisa en equipo, no se castiga.",
        "En el salón: hacer el debrief en voz alta y agradecer a un compañero. No hay acción física.",
        "Tamaño de tripulación de referencia",
        "La cohesión es del equipo ficticio. No se califica a ningún niño ni se comparan equipos. Fuentes del diseño cooperativo en riesgos_a_mecanicas.md."),
    "EIHSO": ("sí", "M1",
        "El botón «Llamar a la Tierra» manda la pregunta y la respuesta llega después del retraso real. Si la tripulación espera, la falla avanza; "
        "si no, usa el manual de a bordo (tarjetas de procedimiento, que siempre traen una solución) y decide sola. Es el único reloj del juego "
        "y no se premia decidir rápido. El mismo evento en la Luna sirve de contraste.",
        "En Marte no hay a quién preguntarle a tiempo: hay que prepararse antes, seguir un procedimiento y decidir con información incompleta.",
        "Sin acción física. Hábito que aplica: leer la instrucción completa antes de actuar y pedir ayuda a tiempo.",
        "Retraso de comunicación Tierra-Marte (mínimo y máximo, un sentido) y Tierra-Luna",
        ""),
    "Food and Nutrition": ("sí", "M3",
        "La comida no es un solo número: hay comida guardada e invernadero, y el menú tiene grupos (granos, verduras, proteína). "
        "Repetir el mismo menú muchos soles o quedarse sin un grupo baja la condición física, porque la tripulación come menos. "
        "La comida fresca o variada sube el ánimo. "
        "El invernadero da variedad pero gasta agua, energía y tiempo de un tripulante.",
        "Comer bien es variedad y planeación, no sólo cantidad. Lo que se siembra hoy se come semanas después.",
        "Invitación: toma agua ahora, o prueba hoy una fruta o verdura de otro color. Nunca se habla de peso, calorías ni comida «buena» o «mala».",
        "Días a cosecha de un cultivo probado por la NASA; comida por persona por día; duración de la misión",
        "La página del riesgo liga la fatiga de menú con comer menos y perder masa corporal, como posibilidad en estudio; no dice que baje el ánimo. "
        "Que la comida fresca suba el ánimo es regla nuestra. Con niños se dice «pierde fuerza», no se habla de peso. Detalle en parametros_juego.md."),
    "Muscle and Aerobic": ("sí", "M4",
        "Bloque de ejercicio en el horario de cada sol. Cuesta tiempo y energía eléctrica. Si se salta varios soles baja el medidor de condición física, "
        "y las tareas pesadas (cargar, reparar afuera) tardan más o fallan.",
        "En baja gravedad el cuerpo pierde fuerza si no se usa. El ejercicio es parte del trabajo, no un extra.",
        "Pausa activa opcional de 1 minuto junto con la tripulación (estirarse, saltar, bailar). Es juego de movimiento, no rutina de astronauta adulto.",
        "Tiempo de ejercicio diario de la tripulación en la Estación Espacial; gravedad de la Luna y de Marte",
        ""),
    "Sleep": ("sí", "M4",
        "Planificador del sol con bloques de trabajo, descanso y sueño. Quitar sueño para arreglar una falla sirve hoy, pero baja el medidor de descanso "
        "y mañana suben los errores en todas las tareas.",
        "Dormir es parte de la misión. Una tripulación cansada se equivoca más.",
        "La sesión termina cuando la tripulación se va a dormir, con invitación a hacer lo mismo. Sin rachas diarias ni avisos de noche.",
        "Duración del sol marciano; horas de sueño programadas para astronautas",
        "La calificación oficial es 5x2 y no sube de órbita baja a Marte. Entra a la demo por lo fácil de jugar y lo útil para niños, no por ser de las más altas."),
    "Behavioral Health": ("parcial", "M4",
        "Medidor de ánimo por tripulante. Baja con monotonía, aislamiento (mensajes de casa que tardan) y exceso de trabajo. "
        "Sube con tiempo libre, mensajes a la familia, cuidar el invernadero y actividades en grupo. Con ánimo bajo fallan más tareas.",
        "El ánimo es un recurso de la misión, y pedir apoyo es una habilidad de tripulación.",
        "Invitación opcional: di con una palabra cómo te sientes hoy (no se guarda), o cuéntale a alguien de confianza algo de tu día.",
        "Duración de la misión; retraso de los mensajes",
        "Sólo se juega ánimo, estrés y aislamiento. No se mencionan trastornos ni se evalúa al niño."),
    "Bone Fracture": ("parcial", "M4",
        "Se une al medidor de condición física («huesos y músculos»). Al final de la misión, el regreso a la gravedad sale mejor si el medidor se mantuvo.",
        "Los huesos se mantienen fuertes cuando cargan peso y se mueven.",
        "La misma pausa activa (saltar, correr).",
        "",
        "FINDINGS.md pide una cita médica antes de afirmar algo sobre actividad física y hueso en el crecimiento."),
    "Carcinogenesis": ("parcial", "M5",
        "Más blindaje protege pero cuesta energía y materiales. Con una alerta de tormenta solar la tripulación va al refugio y el trabajo se detiene. "
        "La radiación se muestra como una barra de dosis acumulada de toda la misión, no como daño inmediato.",
        "La radiación no se siente en el momento; se acumula. Protegerse cuesta, y hay que decidir cuánto.",
        "Analogía (no equivalencia) con el sol de Sonora: sombra, gorra y bloqueador al mediodía.",
        "Dosis por día en la superficie de Marte, en tránsito y en la Estación Espacial; límite de dosis de carrera de la NASA",
        "Para Marte la NASA califica 1x1 en operaciones y 3x3 en salud a largo plazo, aprobado con la matriz anterior de 3x4 y pendiente de actualizar. "
        "Por eso es dosis acumulada y no un evento mortal. Con niños se dice «dosis», no «cáncer»."),
    "Medical Conditions": ("parcial", "",
        "Tarjeta de evento: un tripulante se lastima o se enferma leve. No hay evacuación: se usa el botiquín limitado, descansa y los demás se reparten sus tareas.",
        "Lejos de la Tierra la prevención vale más que la cura. Saber primeros auxilios básicos ayuda a todo el equipo.",
        "Lavarse las manos; avisar a un adulto cuando te sientes mal.",
        "",
        "Relación indirecta (así está marcada en hrp_riesgos_clasificados.csv). Sin lesiones gráficas."),
    "EVA": ("parcial", "",
        "Planear la salida: tiempo límite, siempre en pareja, y sólo salen tripulantes descansados y en forma. Reutiliza los medidores de descanso y condición física.",
        "Afuera todo se planea antes, y nadie sale solo.",
        "Calentar antes de hacer deporte y tomar agua.",
        "Duración típica de una caminata espacial",
        "Relación indirecta. No se juegan las lesiones."),
    "Sensorimotor": ("parcial", "",
        "Los primeros soles después de aterrizar la tripulación está torpe: manejar el rover y las tareas finas fallan más. Conviene programar primero tareas sencillas.",
        "El cuerpo necesita tiempo para adaptarse cuando cambia la gravedad.",
        "Juego de equilibrio opcional (pararse en un pie).",
        "Días de adaptación después de un cambio de gravedad",
        ""),
    "Dust": ("parcial", "",
        "Después de cada salida hay un paso de limpieza en la esclusa que cuesta tiempo. Saltárselo ensucia los filtros del soporte vital y baja la salud de la tripulación.",
        "El polvo de la Luna y de Marte es un problema real de ingeniería y de salud.",
        "",
        "",
        ""),
    "Renal Stone": ("parcial", "",
        "Dentro del medidor de agua: si se raciona el agua de beber varios soles, sube la probabilidad de un evento médico.",
        "El agua de beber no es donde se ahorra.",
        "Tomar agua simple, sobre todo con calor.",
        "Agua de beber por persona por día",
        "Confirmado en la página del riesgo: la hidratación está entre las contramedidas. Detalle en parametros_juego.md."),
    "Hypoxia": ("parcial", "",
        "Es el medidor de oxígeno del soporte vital que ya pide el reto. Con poco oxígeno la tripulación piensa más lento y fallan más tareas.",
        "El aire de la base se fabrica y se vigila.",
        "",
        "Oxígeno por persona por día",
        "El riesgo oficial trata sobre todo de la atmósfera de baja presión que prepara las caminatas. Nuestro uso (falla del soporte vital) aparece en la página sólo como factor adicional."),
    "DCS": ("parcial", "",
        "Antes de salir hay un tiempo de preparación que no se puede saltar, aunque haya una emergencia afuera.",
        "Algunas reglas de seguridad toman tiempo y no se saltan.",
        "",
        "Tiempo de preparación (pre-respiración) antes de una caminata espacial",
        "Los tiempos de preparación con fuente están en parametros_juego.csv (eva_prerespiracion_*)."),
    "Microhost": ("parcial", "",
        "Tarea de limpieza del hábitat en el horario. Si se deja varios soles, sube la probabilidad de que alguien se enferme.",
        "En un lugar cerrado la higiene es de todos.",
        "Lavarse las manos.",
        "",
        ""),
    "Cardiovascular": ("no", "",
        "Sin mecánica propia. El bloque de ejercicio del medidor de condición física lo cubre de forma general.",
        "", "", "", ""),
    "Immune": ("no", "",
        "Sin mecánica: es demasiado clínico para esta edad.",
        "", "", "", ""),
    "Dynamic Loads": ("no", "",
        "Sin mecánica: depende del diseño de asientos, trajes y vehículos.",
        "", "", "", ""),
    "Pharm": ("no", "",
        "Sin mecánica: no queremos medicamentos como tema de juego para niños.",
        "", "", "", ""),
    "SANS": ("no", "",
        "Sin mecánica. Puede ser una tarjeta de dato curioso.",
        "", "", "",
        "No convertirlo en mensaje sobre la vista de los niños: usar lentes no descarta a nadie."),
}

# Tema OSDR más cercano a cada riesgo (asignación propia; los temas se marcaron por palabras clave).
OSDR = {"Muscle and Aerobic": "t_musculo", "Bone Fracture": "t_hueso", "Food and Nutrition": "t_nutricion_dieta", "Carcinogenesis": "t_radiacion",
        "Sleep": "t_sueno_circadiano", "Behavioral Health": "t_aislamiento_confinamiento", "Cardiovascular": "t_cardiovascular", "Immune": "t_inmune",
        "Microhost": "t_microbioma", "SANS": "t_ojo_SANS", "Renal Stone": "t_rinon"}

risks = [r for r in read_csv(TABLES / "hrp_riesgos_clasificados.csv") if r["activo"] == "1"]
luna = {r["short_title"]: r for r in read_csv(TABLES / "hrp_riesgos_por_mision_largo.csv") if r["drm"] == "Luna órbita+superficie largo"}
temas = {r["bandera"]: r for r in read_csv(TABLES / "osdr_por_tema.csv")}
assert {r["short_title"] for r in risks} == set(D), set(D) ^ {r["short_title"] for r in risks}

ORDEN = {"sí": 0, "parcial": 1, "no": 2}
rows = []
for r in risks:
    jug, demo, mec, apr, acc, par, cui = D[r["short_title"]]
    t = temas.get(OSDR.get(r["short_title"], ""))
    rows.append({
        # --- NASA (copiado de las tablas de entrada)
        "risk_id": r["risk_id"], "short_title": r["short_title"], "nombre_es": r["nombre_es"], "elemento_nasa": r["elemento_nasa"],
        "marte_ops_LxC": r["marte_ops_LxC"], "marte_ops_disp": r["marte_ops_disp"],
        "marte_slp_LxC": r["marte_slp_LxC"], "marte_slp_disp": r["marte_slp_disp"],
        "leo_largo_ops_LxC": r["leo_largo_ops_LxC"], "leo_largo_ops_disp": r["leo_largo_ops_disp"],
        "luna_sup_largo_ops_LxC": luna[r["short_title"]]["ops_LxC"], "luna_sup_largo_ops_disp": luna[r["short_title"]]["ops_disposicion"],
        "url": r["url"],
        # --- cálculo propio sobre datos NASA
        "marte_ops_producto_propio": r["marte_ops_producto"],
        # --- diseño propio
        "jugable_9_14_propio": jug, "mecanica_propia": mec, "aprendizaje_propio": apr, "accion_saludable_propia": acc,
        "en_demo_propio": "sí" if demo else "no", "mecanica_demo_propia": f"{demo} {DEMO[demo]}" if demo else "",
        "parametros_reales_necesarios": par, "cuidado": cui,
        # --- OSDR (conteo de osdr_por_tema.csv; la asignación riesgo-tema es propia)
        "osdr_tema_cercano_propio": t["tema"] if t else "", "osdr_estudios": t["estudios"] if t else "",
    })
rows.sort(key=lambda x: (ORDEN[x["jugable_9_14_propio"]], -int(x["marte_ops_producto_propio"]), x["short_title"]))
p = write_csv("riesgos_a_mecanicas.csv", rows)

n = lambda k: sum(x["jugable_9_14_propio"] == k for x in rows)
print(f"{p.name}: {len(rows)} riesgos activos | jugable sí={n('sí')} parcial={n('parcial')} no={n('no')} | en demo={sum(x['en_demo_propio'] == 'sí' for x in rows)}")
for x in rows:
    print(f"  {x['jugable_9_14_propio']:8s} {x['short_title']:20s} Marte {x['marte_ops_LxC']:4s} LEO {x['leo_largo_ops_LxC']:14s} Luna {x['luna_sup_largo_ops_LxC']:4s} "
          f"SLP {x['marte_slp_LxC']:14s} {x['mecanica_demo_propia'][:2]:3s} OSDR {x['osdr_estudios']}")
