#!/usr/bin/env python3
"""Verifica que cada cifra de eda/tables/mexico_ensanut.csv aparezca, junto con su intervalo de confianza, en el texto del PDF del INSP del que se tomó."""
# Uso, desde la carpeta del proyecto:
#     python3 eda/06_ensanut_verificar.py               usa los PDF o textos que ya estén en data/raw/mexico/ensanut/
#     python3 eda/06_ensanut_verificar.py --descargar   baja antes los PDF que falten, desde la URL de cada renglón
#
# Qué comprueba: para cada renglón con cifra, que el valor y los dos límites del intervalo de confianza estén en una
# misma línea del texto del PDF. En el suplemento de resultados estatales busca sólo dentro de la tabla de la región
# del renglón (Nacional o Sonora), y en el artículo de sobrepeso y obesidad exige que la región esté en esa misma línea.
# Qué no comprueba: que el sexo, la edad o el nombre del indicador sean los correctos; eso se revisó a la vista.
#
# Los PDF no se guardan en el repositorio (ver data/raw/mexico/ensanut/FUENTES.md). El texto se saca con `pdftotext -layout`
# (paquete poppler-utils). Fuera de eso sólo usa la biblioteca estándar de Python.
import csv
import hashlib
import re
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
TABLA = RAIZ / "eda" / "tables" / "mexico_ensanut.csv"
CRUDOS = RAIZ / "data" / "raw" / "mexico" / "ensanut"
TEXTOS = CRUDOS / "txt"
PENDIENTE = "[DATO PENDIENTE]"

# Parte distintiva de cada URL -> nombre del archivo local (los mismos nombres que en FUENTES.md y SHA256SUMS)
ARCHIVO = {
    "17311-": "ensanut2020-2024_17311_sobrepeso_obesidad_escolares_adolescentes_nacional_estatal",
    "17642-": "ensanut2020-2024_17642_resultados_estatales",
    "16955-": "ensanut2018-2024_16955_actividad_fisica_sedentarismo_sueno_adolescentes",
    "15787-": "ensanut2023_15787_promocion_actividad_fisica_escolares_adolescentes",
    "33-Movimiento": "ensanut2022_14754_comportamientos_del_movimiento",
    "ensanut_23_112024": "ensanut2023_informe_resultados_nacionales",
    "16-Sintomatologia": "ensanut2022_14827_sintomatologia_depresiva_adolescentes_adultos",
    "15842-": "ensanut2020-2023_15842_sobrepeso_obesidad_escolares_adolescentes",
}
ESTATAL = ARCHIVO["17642-"]        # suplemento con una tabla por estado: se busca dentro de la tabla de la región
ART_PESO = ARCHIVO["17311-"]       # en sus cuadros la región va en la misma línea que la cifra
CABECERA = re.compile(r"^\s*(\S.*?) \| Resultados Ensanut Continua 2020-2024\s*$")


def nombre_local(url):
    for clave, nombre in ARCHIVO.items():
        if clave in url:
            return nombre
    raise SystemExit(f"No sé a qué archivo corresponde esta URL: {url}")


def huellas():
    """SHA-256 esperado de cada PDF, según data/raw/mexico/ensanut/SHA256SUMS (si existe)."""
    p = CRUDOS / "SHA256SUMS"
    if not p.exists():
        return {}
    return {l.split()[1]: l.split()[0] for l in p.read_text(encoding="utf-8").splitlines() if l.strip()}


def descargar(url, pdf):
    print(f"  bajando {pdf.name} ...", flush=True)
    CRUDOS.mkdir(parents=True, exist_ok=True)
    tmp = pdf.with_name(pdf.name + ".part")
    pedido = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(pedido, timeout=120) as r, open(tmp, "wb") as f:
        shutil.copyfileobj(r, f)
    datos = tmp.read_bytes()
    if not datos.startswith(b"%PDF-"):
        tmp.unlink()
        raise SystemExit(f"La URL no devolvió un PDF: {url}")
    esperado = huellas().get(pdf.name)
    if esperado and hashlib.sha256(datos).hexdigest() != esperado:
        print(f"  AVISO: {pdf.name} no coincide con SHA256SUMS; el INSP pudo haber sustituido el archivo.")
    tmp.rename(pdf)


def lineas_de(nombre, url, bajar):
    """Líneas del texto del PDF; convierte (y si se pide, descarga) lo que falte. None si no se puede."""
    txt, pdf = TEXTOS / f"{nombre}.txt", CRUDOS / f"{nombre}.pdf"
    if not txt.exists():
        if not pdf.exists():
            if not bajar:
                return None
            descargar(url, pdf)
        TEXTOS.mkdir(parents=True, exist_ok=True)
        try:
            subprocess.run(["pdftotext", "-layout", str(pdf), str(txt)], check=True)
        except FileNotFoundError:
            raise SystemExit("Falta el programa pdftotext (paquete poppler-utils).")
    return txt.read_text(encoding="utf-8", errors="replace").split("\n")


def lineas_de_region(lineas, region):
    """Índices de las líneas de la tabla de `region` en el suplemento de resultados estatales."""
    actual, dentro = None, []
    for i, linea in enumerate(lineas):
        m = CABECERA.match(linea)
        if m:
            actual = m.group(1).strip()
        if actual == region:
            dentro.append(i)
    return dentro


def main():
    bajar = "--descargar" in sys.argv[1:]
    with open(TABLA, newline="", encoding="utf-8") as f:
        renglones = [r for r in csv.DictReader(f)]
    con_cifra = [(n, r) for n, r in enumerate(renglones, 2) if r["valor"] != PENDIENTE]
    print(f"{TABLA.relative_to(RAIZ)}: {len(renglones)} renglones, {len(con_cifra)} con cifra, "
          f"{len(renglones) - len(con_cifra)} marcados {PENDIENTE} (no se verifican)")

    textos, faltan, fallas, bien = {}, {}, [], {}
    for n, r in con_cifra:
        nombre = nombre_local(r["url"])
        if nombre not in textos:
            textos[nombre] = lineas_de(nombre, r["url"], bajar)
        lineas = textos[nombre]
        if lineas is None:
            faltan[nombre] = r["url"]
            continue
        buscados = [r["valor"]] + (r["ic95"].split("-") if r["ic95"] else [])
        donde = lineas_de_region(lineas, r["region"]) if nombre == ESTATAL else range(len(lineas))
        hallado = False
        for i in donde:
            if all(b in re.findall(r"\d+\.\d+", lineas[i]) for b in buscados):
                if nombre != ART_PESO or r["region"] in lineas[i]:
                    hallado = True
                    break
        if hallado:
            bien[nombre] = bien.get(nombre, 0) + 1
        else:
            fallas.append((n, r, buscados, nombre))

    for nombre in sorted(bien):
        print(f"  {bien[nombre]:3d} renglones confirmados en {nombre}.pdf")
    for n, r, buscados, nombre in fallas:
        print(f"  NO ENCONTRADO, línea {n} del CSV: {r['indicador'][:50]} | {r['grupo_edad']} | {r['sexo']} | {r['region']} "
              f"| {' '.join(buscados)} | {nombre}.pdf")
    for nombre, url in sorted(faltan.items()):
        print(f"  FALTA {nombre}.pdf\n        {url}")
    if faltan:
        print("Faltan PDF de origen. Vuelve a correr con --descargar, o bájalos a data/raw/mexico/ensanut/ con los nombres de FUENTES.md.")

    total = sum(bien.values())
    print(f"Resultado: {total} de {len(con_cifra)} renglones con cifra confirmados en el texto de su fuente; "
          f"{len(fallas)} no encontrados; {len(con_cifra) - total - len(fallas)} sin poder revisar.")
    sys.exit(0 if total == len(con_cifra) else 1)


if __name__ == "__main__":
    main()
