#!/usr/bin/env python3
"""Construye eda/tables/osdr_hallazgos.csv: hallazgos de salud en vuelo espacial de tres estudios del repositorio OSDR de la NASA, cada uno con la frase del artículo de donde salió su cifra."""
# Uso, desde la carpeta del proyecto (sólo usa la biblioteca estándar):
#     python3 eda/07_osdr_hallazgos.py               escribe la tabla
#     python3 eda/07_osdr_hallazgos.py --verificar   además comprueba cada renglón contra OSDR y contra el artículo
#
# Qué comprueba --verificar: 1) que OSDR tenga un estudio con ese número, ese título y ese artículo ligado;
# 2) que la cita textual de cada renglón esté en el texto completo del artículo (PubMed Central);
# 3) que la cifra del renglón esté dentro de esa cita.
# Usa los archivos de data/raw/nasa/osdr_hallazgos/ y baja de las dos API públicas los que falten.
# Qué no comprueba: que la frase en español diga lo mismo que la cita en inglés; eso se revisó a mano.
import csv
import json
import re
import sys
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
TABLA = RAIZ / "eda" / "tables" / "osdr_hallazgos.csv"
CRUDOS = RAIZ / "data" / "raw" / "nasa" / "osdr_hallazgos"
API_OSDR = "https://osdr.nasa.gov/osdr/data/osd/meta/{n}"
API_PMC = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id={n}&rettype=xml"

ESTUDIOS = {
    "OSD-342": {
        "titulo": "Targeting myostatin/activin A protects against skeletal muscle and bone loss during spaceflight [plasma proteomics]",
        "organismo": "Ratón (Mus musculus)",
        "mision": "SpaceX-19 a la Estación Espacial Internacional; 33 días en microgravedad (dic 2019 a ene 2020)",
        "pmcid": "PMC7519220", "doi": "10.1073/pnas.2014716117",
        "cita": "Lee S-J y col. Proc Natl Acad Sci USA 2020;117(38):23942-23951. doi:10.1073/pnas.2014716117",
    },
    "OSD-714": {
        "titulo": "Lunar gravity prevents skeletal muscle atrophy but not myofiber type shift in mice",
        "organismo": "Ratón (Mus musculus)",
        "mision": "SpaceX-9, SpaceX-17 y SpaceX-20 a la Estación Espacial Internacional (misiones MHU-1, MHU-4 y MHU-5 de JAXA); cerca de un mes cada una",
        "pmcid": "PMC10121599", "doi": "10.1038/s42003-023-04769-3",
        "cita": "Hayashi T y col. Commun Biol 2023;6:424. doi:10.1038/s42003-023-04769-3",
    },
    "OSD-540": {
        "titulo": "Ten-day human unilateral lower limb suspension and active recovery in young healthy men",
        "organismo": "Humano (Homo sapiens): 11 hombres jóvenes sanos",
        "mision": "Estudio en Tierra, sin vuelo (financiado por la Agencia Espacial Italiana)",
        "pmcid": "PMC9828768", "doi": "10.1113/JP283381",
        "cita": "Sarto F y col. J Physiol 2022;600(21):4731-4751. doi:10.1113/JP283381",
    },
}

# accession, frase en español, frase en inglés, valor, unidad, citas textuales del artículo (la cifra debe estar en alguna)
HALLAZGOS = [
    ("OSD-342",
     "Ratones que pasaron 33 días en la Estación Espacial regresaron con 18% menos de un músculo de la pantorrilla (el sóleo) que los ratones que se quedaron en la Tierra.",
     "Mice that spent 33 days on the Space Station came back with 18% less of a calf muscle (the soleus) than mice that stayed on Earth.",
     "18", "% menos de peso del músculo sóleo que en ratones en Tierra, tras 33 días en microgravedad",
     ["Exposure of wild type mice to microgravity for 33 d led to significant muscle loss, with lean body mass being lower by 9% and weights of pectoralis, triceps, quadriceps, gastrocnemius/plantaris, and soleus muscles being lower by 8%, 8%, 15%, 14%, and 18%, respectively, compared to wild type mice maintained on Earth"]),
    ("OSD-342",
     "En 22 días en órbita, los huesos de esos ratones perdieron 8% de su densidad mineral, comparados con los de ratones en la Tierra.",
     "In 22 days in orbit, those mice's bones lost 8% of their mineral density compared with mice on Earth.",
     "8", "% menos de densidad mineral ósea de todo el cuerpo que en ratones en Tierra, en 22 días de microgravedad",
     ["Exposure of wild type mice to these 22 d of microgravity led to significant reductions in bone mineral density (BMD) of the whole body, left femur, and right femur by 8%, 11%, and 8%, respectively, compared to mice maintained on Earth"]),
    ("OSD-714",
     "En cerca de un mes en la Estación Espacial, los ratones en microgravedad perdieron 17% de un músculo de la pantorrilla (el sóleo), comparados con ratones en la Tierra.",
     "In about a month on the Space Station, mice in microgravity lost 17% of a calf muscle (the soleus) compared with mice on Earth.",
     "17", "% menos de peso del músculo sóleo (relativo al peso corporal) que en ratones en Tierra, tras cerca de un mes en microgravedad",
     ["male C57BL/6 J mice (8 or 9 weeks old) were maintained on the ISS for approximately one month",
      "The wet weight of the Sol muscle, normalized to the body weight, was 17% lower in the MG group than in the GC group but was similar between the GC and PG groups of MHU-4 and MHU-5"]),
    ("OSD-714",
     "Con una gravedad como la de la Luna (un sexto de la terrestre), creada con una centrífuga en la Estación, los ratones conservaron ese músculo, aunque sus fibras sí cambiaron de tipo.",
     "With Moon-like gravity (one sixth of Earth's), made by a centrifuge on the Station, the mice kept that muscle, although its fibers still changed type.",
     "0.167", "g: gravedad artificial con la que el peso del sóleo fue similar al de ratones en Tierra",
     ["gravity was set to 1/6 g (0.167 g), to mimic the gravity of the moon",
      "We observed that microgravity-induced soleus muscle atrophy was prevented by lunar gravity. However, lunar gravity failed to prevent the slow-to-fast myofiber transition in the soleus muscle in space."]),
    ("OSD-540",
     "Once hombres jóvenes mantuvieron una pierna sin apoyar durante 10 días y el músculo del muslo de esa pierna se achicó 4.5%.",
     "Eleven young men kept one leg off the ground for 10 days, and that leg's thigh muscle shrank by 4.5%.",
     "4.5", "% menos de tamaño (área transversal) del cuádriceps tras 10 días sin apoyar la pierna",
     ["Eleven healthy males underwent a 10-day unilateral lower limb suspension (ULLS) period, followed by 21-day AR based on resistance exercise",
      "These functional impairments were accompanied by a 4.5% loss in quadriceps size"]),
    ("OSD-540",
     "Después hicieron ejercicio de fuerza: a los 10 días todavía no recuperaban su fuerza y a los 21 días ya la habían recuperado toda.",
     "Then they did strength exercise: after 10 days their strength was not yet back, and after 21 days it had fully returned.",
     "21", "días de ejercicio de fuerza para recuperar la fuerza perdida en 10 días sin apoyar la pierna",
     ["total recovery in muscle function (i.e. MVC) was achieved after 21 days of AR, while after 10 days, muscle strength was not yet restored"]),
]


def construir():
    campos = ["accession", "titulo", "organismo", "mision", "hallazgo", "hallazgo_en", "valor", "unidad",
              "url_osdr", "osdr_abierta", "url_publicacion", "publicacion_abierta", "cita", "cita_textual"]
    with open(TABLA, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(campos)
        for acc, es, en, valor, unidad, citas in HALLAZGOS:
            e = ESTUDIOS[acc]
            w.writerow([acc, e["titulo"], e["organismo"], e["mision"], es, en, valor, unidad,
                        f"https://osdr.nasa.gov/bio/repo/data/studies/{acc}", "sí",
                        f"https://pmc.ncbi.nlm.nih.gov/articles/{e['pmcid']}/", "sí", e["cita"], " [...] ".join(citas)])
    print(f"{len(HALLAZGOS)} hallazgos de {len(ESTUDIOS)} estudios -> eda/tables/{TABLA.name}")


def traer(nombre, url):
    """Devuelve los bytes del archivo local; si no está, lo baja de la API pública y lo guarda."""
    p = CRUDOS / nombre
    if not p.exists():
        print(f"  bajando {nombre} ...", flush=True)
        CRUDOS.mkdir(parents=True, exist_ok=True)
        with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"}), timeout=120) as r:
            p.write_bytes(r.read())
    return p.read_bytes()


def plano(s):
    """Texto comparable: guiones y espacios raros normalizados, espacios seguidos reducidos a uno."""
    s = re.sub("[‐‑‒–—−]", "-", s)
    return re.sub(r"\s+", " ", s.replace(" ", " ").replace(" ", " ").replace(" ", " ")).strip()


def verificar():
    fallas = 0
    textos = {}
    for acc, e in ESTUDIOS.items():
        n = acc.split("-")[1]
        meta = json.loads(traer(f"osdr_meta_{acc}.json", API_OSDR.format(n=n)))
        estudio = meta["study"][acc]["studies"][0]
        dois = [(pub.get("doi") or "").lower() for pub in estudio.get("publications", [])]
        ok = plano(estudio.get("title", "")) == plano(e["titulo"]) and e["doi"].lower() in dois
        fallas += not ok
        print(f"  {'OK   ' if ok else 'FALLA'} {acc}: OSDR tiene el estudio con ese título y liga el artículo doi:{e['doi']}")
        xml = traer(f"ncbi_pmc_{acc}_{e['pmcid']}.xml", API_PMC.format(n=e["pmcid"][3:]))
        textos[acc] = plano("".join(ET.fromstring(xml).itertext()))
    for i, (acc, es, en, valor, unidad, citas) in enumerate(HALLAZGOS, 1):
        presentes = all(plano(c) in textos[acc] for c in citas)
        cifra = any(re.search(rf"(?<![\d.]){re.escape(valor)}(?![\d.]|\.\d)", c) for c in citas)
        ok = presentes and cifra
        fallas += not ok
        print(f"  {'OK   ' if ok else 'FALLA'} hallazgo {i} ({acc}, {valor}): cita en el artículo {'sí' if presentes else 'NO'}; cifra en la cita {'sí' if cifra else 'NO'}")
    print(f"Resultado: {len(ESTUDIOS) + len(HALLAZGOS) - fallas} de {len(ESTUDIOS) + len(HALLAZGOS)} comprobaciones correctas.")
    return fallas


if __name__ == "__main__":
    construir()
    if "--verificar" in sys.argv[1:]:
        sys.exit(1 if verificar() else 0)
