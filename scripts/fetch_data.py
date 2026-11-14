#!/usr/bin/env python3
"""Download the hackathon datasets (standard library only, so it runs anywhere).

    python3 scripts/fetch_data.py --out data/raw small   # laptop: small sources
    python3 scripts/fetch_data.py --out data/raw big     # Ramona: multi-GB CDC tables
    python3 scripts/fetch_data.py --out data/raw all

Re-running skips files that already exist (delete a file to refresh it).
"""
import argparse, csv, html, json, re, sys, time, urllib.parse, urllib.request
from pathlib import Path

UA = {"User-Agent": "hackathon-data-fetch/1.0"}


def get(url, tries=4, timeout=120):
    for i in range(tries):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=timeout) as r:
                return r.read()
        except Exception as e:  # network hiccups / 5xx
            if i == tries - 1:
                raise
            print(f"  retry {i+1} {url[:90]}: {e}", file=sys.stderr)
            time.sleep(3 * (i + 1))


def stream(url, dest: Path):
    """Stream a large download to disk via a .part file (atomic rename at the end)."""
    part = dest.with_suffix(dest.suffix + ".part")
    with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=600) as r, open(part, "wb") as f:
        n = 0
        while chunk := r.read(1 << 20):
            f.write(chunk)
            n += len(chunk)
            if n % (200 << 20) < (1 << 20):
                print(f"  {dest.name}: {n >> 20} MB", flush=True)
    part.rename(dest)


def skip(p: Path):
    if p.exists() and p.stat().st_size > 0:
        print(f"skip (exists) {p}")
        return True
    p.parent.mkdir(parents=True, exist_ok=True)
    print(f"fetch {p}")
    return False


# ---------------------------------------------------------------- NASA

def astronauts(out):
    p = out / "nasa/astronauts_missions.csv"
    if not skip(p):
        p.write_bytes(get("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/"
                          "data/2020/2020-07-14/astronauts.csv"))


OSDR_FIELDS = ["Accession", "Study Title", "Project Title", "Project Type", "Space Program", "Flight Program",
               "Experiment Platform", "Managing NASA Center", "Study Funding Agency", "organism", "Material Type",
               "Study Assay Measurement Type", "Study Assay Technology Type", "Study Factor Name",
               "Study Public Release Date", "Mission", "Study Description", "Authoritative Source URL"]


def osdr(out):
    pj, pc = out / "nasa/osdr_studies.json", out / "nasa/osdr_studies.csv"
    if skip(pc):
        return
    hits, start, size = [], 0, 50
    while True:
        q = urllib.parse.urlencode({"type": "cgene", "from": start, "size": size})
        d = json.loads(get(f"https://osdr.nasa.gov/osdr/data/search?{q}"))
        page = [h["_source"] for h in d["hits"]["hits"]]
        hits += page
        start += size
        if not page or start >= d["hits"]["total"]:
            break
    pj.write_text(json.dumps(hits, indent=1))

    def flat(v):
        if isinstance(v, dict):
            return v.get("Name") or json.dumps(v)
        if isinstance(v, list):
            return "; ".join(flat(x) for x in v)
        return "" if v is None else str(v)

    with open(pc, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(OSDR_FIELDS + ["Mission Start", "Mission End"])
        for h in hits:
            m = h.get("Mission") if isinstance(h.get("Mission"), dict) else {}
            w.writerow([flat(h.get(k)) for k in OSDR_FIELDS] + [m.get("Start Date", ""), m.get("End Date", "")])
    print(f"  {len(hits)} OSDR studies")


def hrp(out):
    """NASA Human Research Program risks: index + full text of each risk page."""
    p = out / "nasa/hrp_risks.csv"
    if skip(p):
        return
    base = "https://humanresearchroadmap.nasa.gov/Risks/"
    idx = get(base).decode("utf-8", "replace")
    risks = {}
    for i, name in re.findall(r'href="/Risks/\?i=(\d+)"[^>]*>\s*([^<]+?)\s*<', idx):
        risks.setdefault(i, html.unescape(name))
    pages = out / "nasa/hrp_risk_pages"
    pages.mkdir(exist_ok=True)
    rows = []
    for i, name in risks.items():
        raw = get(f"{base}?i={i}").decode("utf-8", "replace")
        (pages / f"risk_{i}.html").write_text(raw)
        body = re.sub(r"(?is)<(script|style).*?</\1>", " ", raw)
        text = re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", body))).strip()
        rows.append({"risk_id": i, "risk_name": name, "url": f"{base}?i={i}", "page_text": text})
        time.sleep(0.3)
    with open(p, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    print(f"  {len(rows)} HRP risks")


# ---------------------------------------------------------------- Education / youth health

NAEP_PLAN = [  # (subject, composite scale, grades, years)
    ("mathematics", "MRPCM", [4, 8], [2000, 2003, 2005, 2007, 2009, 2011, 2013, 2015, 2017, 2019, 2022, 2024]),
    ("science", "SRPUV", [4, 8, 12], [2009, 2015, 2019, 2024]),
]
NAEP_VARS = ["TOTAL", "GENDER", "SDRACE", "SLUNCH3"]


def naep(out):
    p = out / "education/naep_national.csv"
    if skip(p):
        return
    rows = []
    for subj, scale, grades, years in NAEP_PLAN:
        for g in grades:
            for var in NAEP_VARS:
                for y in years:
                    q = urllib.parse.urlencode({"type": "data", "subject": subj, "grade": g, "subscale": scale,
                                                "variable": var, "jurisdiction": "NP", "stattype": "MN:MN", "Year": y})
                    try:
                        d = json.loads(get(f"https://www.nationsreportcard.gov/DataService/GetAdhocData.aspx?{q}", tries=2))
                    except Exception as e:
                        print(f"  naep miss {subj} g{g} {var} {y}: {e}", file=sys.stderr)
                        continue
                    for r in d.get("result", []) if isinstance(d.get("result"), list) else []:
                        rows.append({"subject": subj, "grade": g, "year": r["year"], "variable": var,
                                     "group": r.get("varValueLabel"), "mean_score": r.get("value"),
                                     "displayable": r.get("isStatDisplayable")})
    with open(p, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    print(f"  {len(rows)} NAEP rows")


def socrata_csv(dataset_id):
    return f"https://data.cdc.gov/api/views/{dataset_id}/rows.csv?accessType=DOWNLOAD"


CDC_SMALL = {  # id -> filename
    "nu3s-3dwd": "yrbss_mental_health_indicators.csv",
    "vba9-s8jp": "yrbss_nutrition_physical_activity_obesity.csv",
}
CDC_BIG = {
    "k5bc-k3g8": "yrbss_middle_school_1991_2017.csv",           # ~0.75M rows
    "q6p7-56au": "yrbss_high_school_incl_sexual_orientation.csv",  # ~13.6M rows, multi-GB
}


def cdc(out, table):
    for did, name in table.items():
        p = out / "youth_health" / name
        if not skip(p):
            stream(socrata_csv(did), p)


SMALL = [astronauts, osdr, hrp, naep, lambda o: cdc(o, CDC_SMALL)]
BIG = [lambda o: cdc(o, CDC_BIG)]

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("which", choices=["small", "big", "all"])
    ap.add_argument("--out", default="data/raw", type=Path)
    a = ap.parse_args()
    jobs = {"small": SMALL, "big": BIG, "all": SMALL + BIG}[a.which]
    failed = 0
    for job in jobs:
        try:
            job(a.out)
        except Exception as e:
            failed += 1
            print(f"FAILED {getattr(job, '__name__', job)}: {e}", file=sys.stderr)
    print("done" + (f" with {failed} failure(s)" if failed else ""))
    sys.exit(1 if failed else 0)
