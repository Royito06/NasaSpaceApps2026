#!/usr/bin/env python3
"""EDA 5: de los riesgos del NASA Human Research Program (HRP) a mecánicas de juego para niños de 7 a 12 años.

La edad (7 a 12) y los límites de diseño (3 recursos en pantalla, ninguna opción gratis) vienen del texto oficial
del reto, en CHALLENGE.md.

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

# Mecánicas de la demo (diseño propio). M6 «Pausa de tripulación» no usa ningún riesgo propio.
DEMO = {
    "M1": "Retraso Tierra-Marte",
    "M2": "Roles y plática de equipo",
    "M3": "Invernadero y comida fresca",
    "M4": "Tripulación y plan del sol",
    "M5": "Tormenta solar real: escudo contra energía",
}

# short_title -> (jugable, mecánica demo, indicador en pantalla, mecánica, qué aprende, acción saludable,
#                 parámetros reales que necesita, cuidado)
# En pantalla sólo hay 3 recursos (Soporte vital, Energía, Escudo) y un medidor de Tripulación.
D = {
    "Team": ("sí", "M2", "Tripulación",
        "Cuatro roles, cada uno con un color, un icono y un solo indicador a su cargo: Ingeniería cuida Energía, Huerto cuida Soporte vital, "
        "Protección cuida Escudo y Salud cuida Tripulación. Cada evento necesita lo que ven dos roles. Cada sol, cada rol toma una decisión que "
        "sólo él puede tomar, y esa decisión gasta recursos compartidos. El comandante es un gorro que rota cada sol. "
        "Al cerrar cada evento hay una plática de equipo (debrief) de 3 preguntas sin culpables. Para 7 y 8 años: dos roles o un adulto que lee.",
        "Nadie ve todo; se decide mejor hablando. Un error se revisa en equipo, no se castiga.",
        "En el salón: hacer la plática de equipo en voz alta y agradecer a un compañero. No hay acción física.",
        "tripulacion_referencia; eva_tripulantes_minimos",
        "No se califica a ningún niño ni se comparan equipos. Fuentes del diseño cooperativo en riesgos_a_mecanicas.md."),
    "EIHSO": ("sí", "M1", "Soporte vital",
        "Decisión dentro de un evento de falla, no un medidor. Esperar a la Tierra da la respuesta correcta, pero se pierde soporte vital "
        "mientras llega (retraso real) y se gasta energía de la antena. Actuar con la tarjeta de pasos (tres pasos con dibujo, siempre trae una "
        "solución) arregla hoy, pero cuesta bloques de trabajo, y más si la tripulación está cansada. Es el único reloj del juego y no se premia "
        "decidir rápido. El mismo evento en la Luna sirve de contraste.",
        "En Marte no hay a quién preguntarle a tiempo: hay que prepararse antes, seguir los pasos y decidir sin tener toda la información.",
        "Sin acción física. Hábito que aplica: ver todos los pasos antes de empezar y pedir ayuda a tiempo.",
        "retraso_tierra_marte_min; retraso_tierra_marte_max; retraso_tierra_marte_citado_nasa; retraso_tierra_luna_min; retraso_tierra_luna_max",
        "El reto oficial pide el retraso de comunicación por nombre."),
    "Food and Nutrition": ("sí", "M3", "Soporte vital",
        "La comida es parte del soporte vital. Encender el invernadero gasta energía y agua desde hoy y bloques de trabajo, y da comida fresca "
        "más adelante. Vivir sólo de la comida guardada ahorra energía, pero la reserva se acaba y la tripulación come con menos ganas: "
        "baja el medidor Tripulación. La comida fresca sube Tripulación por el lado del ánimo.",
        "La comida se planea: lo que se siembra hoy se come semanas después.",
        "Invitación: toma agua ahora, o prueba hoy una fruta o verdura de otro color. Nunca se habla de peso, calorías ni comida «buena» o «mala».",
        "cultivo_*_dias_a_cosecha; comida_solidos_secos; invernadero_agua_para_cultivos; mision_marte_estancia_superficie",
        "La página del riesgo liga la fatiga de menú con comer menos y perder masa corporal, como posibilidad en estudio; no dice que baje el ánimo. "
        "Que la comida fresca suba el ánimo es regla nuestra. Con niños se dice «pierde fuerza», no se habla de peso. Detalle en parametros_juego.md."),
    "Muscle and Aerobic": ("sí", "M4", "Tripulación",
        "Fichas de «moverse» en el plan del sol. Alimentan la parte de fuerza del medidor Tripulación. Cuestan fichas de trabajo: "
        "si se saltan varios soles, baja Tripulación y cada tarea cuesta más bloques.",
        "En baja gravedad el cuerpo pierde fuerza si no se usa. Moverse es parte del trabajo, no un extra.",
        "Pausa activa opcional de 1 minuto junto con la tripulación (estirarse, saltar, bailar). Es juego de movimiento, no rutina de astronauta adulto.",
        "ejercicio_diario_eei; ejercicio_supuesto_bvad; gravedad_marte; gravedad_luna",
        "El detalle del medidor Tripulación es el lugar para citar OSDR. Los tiempos de ejercicio son de adultos: no son meta para un niño."),
    "Sleep": ("sí", "M4", "Tripulación",
        "Fichas de «descansar» en el plan del sol. Alimentan la parte de descanso del medidor Tripulación. Quitarlas para trabajar "
        "sube los recursos hoy, pero mañana cada tarea cuesta más bloques.",
        "Dormir es parte de la misión. Una tripulación cansada tarda más en todo.",
        "La sesión termina cuando la tripulación se va a dormir, con invitación a hacer lo mismo. Sin rachas diarias ni avisos de noche.",
        "duracion_sol_marte; sueno_programado; sueno_real_eei",
        "La calificación oficial es 5x2 y no sube de órbita baja a Marte. Entra a la demo por lo fácil de jugar y lo útil para niños, no por ser de las más altas."),
    "Behavioral Health": ("parcial", "M4", "Tripulación",
        "Parte de ánimo del medidor Tripulación. Baja con aburrimiento, aislamiento (mensajes de casa que tardan) y exceso de trabajo. "
        "Sube con tiempo libre, mensajes a la familia, comida fresca y la pausa de tripulación.",
        "El ánimo cuenta para la misión, y pedir apoyo es de buen tripulante.",
        "Invitación opcional: di con una carita cómo te sientes hoy (no se guarda), o cuéntale a alguien de confianza algo de tu día.",
        "mision_marte_duracion_min; mision_marte_duracion_max",
        "Sólo se juega ánimo, cansancio y aislamiento. No se mencionan trastornos ni se evalúa al niño."),
    "Bone Fracture": ("parcial", "M4", "Tripulación",
        "Parte de fuerza del medidor Tripulación, junto con músculo. Al final de la misión, el regreso a la gravedad sale mejor si el medidor se mantuvo.",
        "Los huesos se mantienen fuertes cuando cargan peso y se mueven.",
        "La misma pausa activa (saltar, correr).",
        "",
        "FINDINGS.md pide una cita médica antes de afirmar algo sobre actividad física y hueso en el crecimiento. "
        "El detalle del medidor Tripulación es el lugar para citar OSDR."),
    "Carcinogenesis": ("parcial", "M5", "Escudo",
        "Reforzar el escudo baja la radiación de la tormenta, pero cuesta la energía de esta noche y bloques de trabajo. Durante la tormenta, "
        "ir al refugio casi no sube la radiación recibida y se pierde el trabajo de ese sol; seguir trabajando hace el trabajo y sube mucho la barra. "
        "La tormenta sale de un evento real de DONKI, con su fecha. La radiación se muestra como una barra que sólo sube, no como daño inmediato.",
        "La radiación no se siente en el momento; se va juntando. Protegerse cuesta, y hay que decidir cuánto.",
        "Analogía (no equivalencia) con el sol de Sonora: sombra, gorra y bloqueador al mediodía.",
        "dosis_diaria_superficie_marte; dosis_diaria_transito_marte; limite_dosis_carrera_nasa; limite_dosis_tormenta_solar; "
        "blindaje_reduccion_tormenta_solar; blindaje_reduccion_rayos_cosmicos; refugio_tormenta_dosis_*",
        "Para Marte la NASA califica 1x1 en operaciones y 3x3 en salud a largo plazo, aprobado con la matriz anterior de 3x4 y pendiente de actualizar. "
        "Por eso es radiación que se acumula y no un evento mortal. Con niños se dice «radiación recibida», no «cáncer». "
        "DONKI dice que hubo un evento, no cuánta radiación llegaría a Marte: cuánto sube la barra es regla nuestra."),
    "Medical Conditions": ("parcial", "", "Tripulación",
        "Carta de evento: un tripulante se lastima o se enferma leve. No hay evacuación: se usa el botiquín limitado, descansa y los demás se reparten sus tareas.",
        "Lejos de la Tierra, cuidarse antes vale más que curarse después.",
        "Lavarse las manos; avisar a un adulto cuando te sientes mal.",
        "",
        "Relación indirecta (así está marcada en hrp_riesgos_clasificados.csv). Sin lesiones gráficas."),
    "EVA": ("parcial", "", "Tripulación",
        "Planear la salida: tiempo límite, siempre en pareja, y sólo con la tripulación en buen estado. Reutiliza el medidor Tripulación.",
        "Afuera todo se planea antes, y nadie sale solo.",
        "Calentar antes de hacer deporte y tomar agua.",
        "eva_duracion_propuesta_marte; eva_tripulantes_minimos",
        "Relación indirecta. No se juegan las lesiones. Segunda versión."),
    "Sensorimotor": ("parcial", "", "Tripulación",
        "Los primeros soles después de aterrizar, manejar el rover y las tareas finas cuestan más bloques. Conviene programar primero tareas sencillas.",
        "El cuerpo necesita tiempo para acostumbrarse cuando cambia la gravedad.",
        "Juego de equilibrio opcional (pararse en un pie).",
        "adaptacion_tras_cambio_de_gravedad",
        "El parámetro sigue pendiente en parametros_juego.csv. Segunda versión."),
    "Dust": ("parcial", "", "Soporte vital",
        "Después de cada salida hay un paso de limpieza en la esclusa que cuesta un bloque. Saltárselo ensucia los filtros y baja el soporte vital.",
        "El polvo de la Luna y de Marte es un problema real de ingeniería y de salud.",
        "",
        "",
        "Segunda versión."),
    "Renal Stone": ("parcial", "", "Soporte vital",
        "Dentro del soporte vital: si se raciona el agua de beber varios soles, baja el medidor Tripulación.",
        "El agua de beber no es donde se ahorra.",
        "Tomar agua simple, sobre todo con calor.",
        "agua_para_beber",
        "Confirmado en la página del riesgo: la hidratación está entre las contramedidas. Detalle en parametros_juego.md."),
    "Hypoxia": ("parcial", "", "Soporte vital",
        "Es el aire del soporte vital que ya pide el reto. Con poco aire, cada tarea cuesta más bloques.",
        "El aire de la base se fabrica y se cuida.",
        "",
        "oxigeno_consumido; co2_producido",
        "El riesgo oficial trata sobre todo de la atmósfera de baja presión que prepara las caminatas. Nuestro uso (falla del soporte vital) aparece en la página sólo como factor adicional."),
    "DCS": ("parcial", "", "Tripulación",
        "Antes de salir hay un tiempo de preparación que no se puede saltar, aunque haya una emergencia afuera.",
        "Algunas reglas de seguridad toman tiempo y no se saltan.",
        "",
        "eva_prerespiracion_meta_exploracion",
        "Los tiempos de preparación con fuente están en parametros_juego.csv (eva_prerespiracion_*). Segunda versión."),
    "Microhost": ("parcial", "", "Tripulación",
        "Ficha de limpieza del hábitat en el plan del sol. Si se deja varios soles, baja el medidor Tripulación.",
        "En un lugar cerrado la limpieza es de todos.",
        "Lavarse las manos.",
        "",
        "Segunda versión."),
    "Cardiovascular": ("no", "", "",
        "Sin mecánica propia. Las fichas de «moverse» del medidor Tripulación lo cubren de forma general.",
        "", "", "", ""),
    "Immune": ("no", "", "",
        "Sin mecánica: es demasiado clínico para esta edad.",
        "", "", "", ""),
    "Dynamic Loads": ("no", "", "",
        "Sin mecánica: depende del diseño de asientos, trajes y vehículos.",
        "", "", "", ""),
    "Pharm": ("no", "", "",
        "Sin mecánica: no queremos medicamentos como tema de juego para niños.",
        "", "", "", ""),
    "SANS": ("no", "", "",
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

# Los parámetros que se citan tienen que existir en parametros_juego.csv (archivo de entrada: sólo se lee).
PARAMS = {r["parametro"] for r in read_csv(TABLES / "parametros_juego.csv")}
def existe(nombre):
    if "*" in nombre:
        pre, suf = nombre.split("*", 1)
        return any(p.startswith(pre) and p.endswith(suf) for p in PARAMS)
    return nombre in PARAMS
faltan = sorted({n for v in D.values() for n in v[6].split("; ") if n and not existe(n)})
assert not faltan, f"parámetros citados que no existen en parametros_juego.csv: {faltan}"
# Regla de JUDGING.md: el juego no usa ningún valor de la misión china Chang'E 4 (ni el de DOSIS 3D, que se leyó en ese artículo).
FUENTE = {r["parametro"]: r["fuente"] for r in read_csv(TABLES / "parametros_juego.csv")}
def coincide(nombre, p):
    if "*" in nombre:
        pre, suf = nombre.split("*", 1)
        return p.startswith(pre) and p.endswith(suf)
    return nombre == p
vetados = sorted({p for v in D.values() for n in v[6].split("; ") if n for p in PARAMS
                  if coincide(n, p) and any(x in FUENTE[p] for x in ("Chang'E", "DOSIS 3D", "Zhang"))})
assert not vetados, f"parámetros citados con fuente Chang'E 4 o DOSIS 3D: {vetados}"

ORDEN = {"sí": 0, "parcial": 1, "no": 2}
rows = []
for r in risks:
    jug, demo, ind, mec, apr, acc, par, cui = D[r["short_title"]]
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
        "jugable_7_12_propio": jug, "mecanica_propia": mec, "aprendizaje_propio": apr, "accion_saludable_propia": acc,
        "en_demo_propio": "sí" if demo else "no", "mecanica_demo_propia": f"{demo} {DEMO[demo]}" if demo else "",
        "indicador_en_pantalla_propio": ind,
        "parametros_juego_csv": par, "cuidado": cui,
        # --- OSDR (conteo de osdr_por_tema.csv; la asignación riesgo-tema es propia)
        "osdr_tema_cercano_propio": t["tema"] if t else "", "osdr_estudios": t["estudios"] if t else "",
    })
rows.sort(key=lambda x: (ORDEN[x["jugable_7_12_propio"]], -int(x["marte_ops_producto_propio"]), x["short_title"]))
p = write_csv("riesgos_a_mecanicas.csv", rows)

n = lambda k: sum(x["jugable_7_12_propio"] == k for x in rows)
print(f"{p.name}: {len(rows)} riesgos activos | jugable sí={n('sí')} parcial={n('parcial')} no={n('no')} | en demo={sum(x['en_demo_propio'] == 'sí' for x in rows)}")
for x in rows:
    print(f"  {x['jugable_7_12_propio']:8s} {x['short_title']:20s} Marte {x['marte_ops_LxC']:4s} LEO {x['leo_largo_ops_LxC']:14s} Luna {x['luna_sup_largo_ops_LxC']:4s} "
          f"SLP {x['marte_slp_LxC']:14s} {x['mecanica_demo_propia'][:2]:3s} {x['indicador_en_pantalla_propio']:14s} OSDR {x['osdr_estudios']}")
