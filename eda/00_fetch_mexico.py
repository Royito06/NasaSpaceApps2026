#!/usr/bin/env python3
"""Fetch small public international tables that include Mexico (stdlib only) into data/raw/mexico/.

Sources (public APIs, no key):
  * WHO Global Health Observatory OData API  https://ghoapi.azureedge.net/api/<INDICATOR>
  * World Bank API v2                         https://api.worldbank.org/v2/country/all/indicator/<CODE>
Re-running skips files that already exist. Raw JSON is saved exactly as returned.
"""
import json, sys, time, urllib.parse, urllib.request
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "data" / "raw" / "mexico"
OUT.mkdir(parents=True, exist_ok=True)
UA = {"User-Agent": "hackathon-data-fetch/1.0"}


def get(url, tries=3, timeout=90):
    for i in range(tries):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=timeout) as r:
                return r.read()
        except Exception as e:
            print(f"  retry {i+1} {url[:100]}: {e}", file=sys.stderr)
            time.sleep(2 * (i + 1))
    return None


def save(name, url):
    p = OUT / name
    if p.exists() and p.stat().st_size > 0:
        print("skip", name); return
    b = get(url)
    if b is None:
        print("FAILED", name, url); return
    p.write_bytes(b); print("ok", name, len(b))


GHO = "https://ghoapi.azureedge.net/api/"
# WHO: obesity / overweight in children and adolescents (BMI > +2 SD / > +1 SD), insufficient physical activity 11-17
for code in ("NCD_BMI_PLUS2C", "NCD_BMI_PLUS1C", "NCD_PAC_ADO"):
    f1 = urllib.parse.quote("SpatialDim eq 'MEX' or SpatialDim eq 'USA' or SpatialDim eq 'GLOBAL' or SpatialDim eq 'AMR'")
    save(f"who_{code}_mex_usa.json", f"{GHO}{code}?$filter={f1}")
for code, yr in (("NCD_BMI_PLUS2C", 2022), ("NCD_PAC_ADO", 2016)):
    f2 = urllib.parse.quote(f"TimeDim eq {yr} and SpatialDimType eq 'COUNTRY'")
    save(f"who_{code}_{yr}_all_countries.json", f"{GHO}{code}?$filter={f2}")
save("who_indicator_list_bmi_pa.json", GHO + "Indicator?$filter=" + urllib.parse.quote("contains(IndicatorName,'adolescents')"))

# World Bank: PISA means (EdStats, source 12) and female share of STEM tertiary graduates (WDI/Gender)
WB = "https://api.worldbank.org/v2/country/all/indicator/"
for code in ("LO.PISA.MAT", "LO.PISA.MAT.FE", "LO.PISA.MAT.MA", "LO.PISA.SCI", "LO.PISA.SCI.FE", "LO.PISA.SCI.MA"):
    save(f"wb_{code}.json", f"{WB}{code}?source=12&format=json&per_page=20000&date=2000:2023")
for code in ("SE.TER.GRAD.FE.SI.ZS",):
    save(f"wb_{code}.json", f"{WB}{code}?format=json&per_page=20000&date=2000:2023")

# Our World in Data grapher CSV (secondary source; original: OECD PISA 2022 database, cited by OWID as "OECD (2023)").
# Used because the World Bank EdStats API stops at PISA 2018.
for slug in ("pisa-test-score-mean-performance-on-the-mathematics-scale", "pisa-test-score-mean-performance-on-the-reading-scale"):
    save(f"owid_{slug}.csv", f"https://ourworldindata.org/grapher/{slug}.csv?v=1&csvType=full&useColumnShortNames=true")
save("owid_pisa_math.metadata.json", "https://ourworldindata.org/grapher/pisa-test-score-mean-performance-on-the-mathematics-scale.metadata.json")
