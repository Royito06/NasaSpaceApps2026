#!/usr/bin/env python3
"""Runs ON RAMONA (stdlib). The laptop link is ~5 KB/s, so the raw "small" sources stay on Ramona
(data/raw en el servidor del equipo) and this script writes slim versions to eda/out/slim/ that are
copied to the laptop (eda/tables/ramona/). No numbers are altered: rows are filtered and long text is cut.
"""
import csv, re, collections, os, statistics
csv.field_size_limit(10**9)
RAW, OUT = "data/raw", "eda/out/slim"
os.makedirs(OUT, exist_ok=True)

def rd(p):
    with open(p, newline="", encoding="utf-8", errors="replace") as f:
        r = csv.DictReader(f); r.fieldnames = [c.strip() for c in r.fieldnames]
        yield from r

def wr(name, rows, fields):
    with open(f"{OUT}/{name}", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore"); w.writeheader(); w.writerows(rows)
    print(name, len(rows))

# ---- HRP risks: header fields, DRM rating table (raw text), risk statement --------------------
rows = []
for x in rd(f"{RAW}/nasa/hrp_risks.csv"):
    t = x["page_text"]
    def g(pat, n=1):
        m = re.search(pat, t, re.S); return m.group(n).strip() if m else ""
    rows.append({"risk_id": x["risk_id"], "risk_name": x["risk_name"], "url": x["url"],
                 "short_title": g(r"Short Title:\s*(.*?)\s*Last Published"), "last_published": g(r"Last Published:\s*(\S+)"),
                 "element": g(r"Element:\s*(.*?)\s*Evidence:"), "status": g(r"HRP Risk Status:\s*(.*?)\s*(?:Risk Ratings|Inactive Rationale)"),
                 "drm_table_raw": g(r"LxC Risk Disposition \* LxC Risk Disposition \*\s*(.*?)\s*Note: LxC"),
                 "hsrb_approved": g(r"last approved by the Human System Risk Board in\s*([0-9/]+)"),
                 "risk_statement": g(r"Risk Statement\s*(.*?)\s*(?:HSRB State of Knowledge|Context|Risk Overview)")[:900],
                 "n_gaps_mentions": len(re.findall(r"\bGap\b", t)), "page_chars": len(t)})
wr("hrp_risks_slim.csv", rows, list(rows[0]))

# ---- OSDR: drop long description, add keyword topic flags (title + description + factors) -----
TOPICS = {"hueso": r"\bbone|osteo|skelet|femur|tibia|calvari", "musculo": r"muscle|soleus|gastrocnemius|quadriceps|myo(?!card)|sarcopenia|atroph",
          "inmune": r"immun|lymph|spleen|thymus|t[- ]cell|cytokine|inflammat", "cardiovascular": r"heart|cardi|vascul|aort|endotheli",
          "ojo_SANS": r"\beye|retina|ocular|optic|\bSANS\b|visual", "cerebro_conducta": r"brain|neuro|cognit|behavio|hippocamp|cortex|stress|anxiety|depress",
          "sueno_circadiano": r"sleep|circadian|clock gene", "radiacion": r"radiat|irradiat|\bHZE\b|proton|heavy ion|gamma|cosmic ray",
          "microbioma": r"microbiom|microbiota|gut|metagenom|16S", "higado_metabolismo": r"liver|hepat|metabol|lipid|insulin|glucose",
          "piel": r"\bskin|dermal|hair follicle", "rinon": r"kidney|renal", "nutricion_dieta": r"\bdiet|nutri|food|vitamin",
          "ejercicio_contramedida": r"exercise|countermeasure|centrifug|artificial gravity|resistive|treadmill|running wheel",
          "aislamiento_confinamiento": r"isolation|confine|\bHERA\b|Mars[- ]?500|\bSIRIUS\b|antarctic|bed ?rest|head[- ]down|analog",
          "plantas": r"plant|arabidopsis|seedling|root|leaf|lettuce|tomato|wheat|crop", "astronautas_humanos": r"astronaut|crew ?member|twin|inspiration4|\bJAXA\b.*human|cosmonaut"}
rows = []
for x in rd(f"{RAW}/nasa/osdr_studies.csv"):
    txt = " ".join(x.get(c, "") for c in ("Study Title", "Project Title", "Study Description", "Study Factor Name", "Material Type"))
    d = {k: x.get(k, "") for k in ("Accession", "Project Type", "Space Program", "Flight Program", "Experiment Platform", "Managing NASA Center",
                                   "organism", "Material Type", "Study Assay Measurement Type", "Study Factor Name", "Study Public Release Date",
                                   "Mission", "Mission Start", "Mission End")}
    for k in ("organism", "Material Type", "Study Assay Measurement Type", "Study Factor Name"):
        d[k] = re.sub(r"\s{2,}", "; ", d[k])[:160]
    d["Study Title"] = x["Study Title"][:140]
    d["desc_chars"] = len(x.get("Study Description", ""))
    for k, pat in TOPICS.items(): d["t_" + k] = int(bool(re.search(pat, txt, re.I)))
    rows.append(d)
wr("osdr_slim.csv", rows, list(rows[0]))

# ---- NAEP: tiny, keep everything ---------------------------------------------------------------
rows = list(rd(f"{RAW}/education/naep_national.csv")); wr("naep_national.csv", rows, list(rows[0]))

# ---- CDC mental health indicators (2019-2023): Total/Sex/Hispanic rows, short question codes ---
QS = {}
rows = []
for x in rd(f"{RAW}/youth_health/yrbss_mental_health_indicators.csv"):
    if x["Demographics_Value"] not in ("Total", "Female", "Male", "Hispanic"): continue
    q = QS.setdefault(x["Question"], f"MH{len(QS)+1}")
    rows.append({"Year": x["Year"], "q": q, "Area": x["Area"], "Area_abbr": x["Area_abbr"], "dtype": x["Demographics_Type"],
                 "dval": x["Demographics_Value"], "pct": x["Percent"], "lo": x["Low_Confidence_Interval"], "hi": x["High_Confidence_Interval"]})
wr("cdc_mental_health_slim.csv", rows, list(rows[0]))
wr("cdc_mental_health_questions.csv", [{"q": v, "Question": k} for k, v in QS.items()], ["q", "Question"])

# ---- CDC nutrition / physical activity / obesity: national rows (US), all strata ---------------
rows = [{"Year": x["YearStart"], "Question": x["Question"], "QuestionID": x["QuestionID"], "strat_cat": x["StratificationCategory1"],
         "strat": x["Stratification1"], "pct": x["Data_Value"], "lo": x["Low_Confidence_Limit"], "hi": x["High_Confidence_Limit"],
         "n": x["Sample_Size"], "footnote": x["Data_Value_Footnote"][:60]}
        for x in rd(f"{RAW}/youth_health/yrbss_nutrition_physical_activity_obesity.csv") if x["LocationAbbr"] == "US"]
wr("cdc_npao_us.csv", rows, list(rows[0]))
# cross-state spread for the same questions (Total stratum), to show variation
grp = collections.defaultdict(list)
for x in rd(f"{RAW}/youth_health/yrbss_nutrition_physical_activity_obesity.csv"):
    if x["LocationAbbr"] != "US" and x["Stratification1"] == "Total" and x["Data_Value"]:
        grp[(x["YearStart"], x["QuestionID"])].append((float(x["Data_Value"]), x["LocationAbbr"]))
rows = []
for (y, q), v in sorted(grp.items()):
    v.sort(); vals = [a for a, _ in v]
    rows.append({"Year": y, "QuestionID": q, "n_locs": len(v), "median": statistics.median(vals), "min": vals[0], "min_loc": v[0][1], "max": vals[-1], "max_loc": v[-1][1]})
wr("cdc_npao_states_spread.csv", rows, list(rows[0]))

# ---- YRBSS high school (from yrbss_extract.py output): question list + national series ---------
p = "eda/out/hs_extract.csv"
if os.path.exists(p):
    PAT = re.compile(r"physical|sport|\bPE\b|television|computer|screen|video|sleep|sad|hopeless|suicid|bull|mental|obes|overweight|breakfast|soda|fruit|vegetable|concussion|water|muscle|safe|weight", re.I)
    qs = {}; rows = []; yrs = collections.defaultdict(set); grp = collections.defaultdict(list)
    for x in rd(p):
        c = x["QuestionCode"]
        qs.setdefault(c, {"QuestionCode": c, "Topic": x["Topic"], "Subtopic": x["Subtopic"], "Short": x["ShortQuestionText"],
                          "Greater_Risk_Question": x["Greater_Risk_Question"], "Lesser_Risk_Question": x["Lesser_Risk_Question"]})
        if not PAT.search(x["ShortQuestionText"] + " " + x["Greater_Risk_Question"] + " " + x["Topic"]): continue
        if x["LocationAbbr"] == "XX":
            yrs[c].add(x["YEAR"])
            rows.append({"c": c, "y": x["YEAR"], "sex": x["Sex"], "race": x["Race"], "grade": x["Grade"], "pct": x["Greater_Risk_Data_Value"],
                         "lo": x["Greater_Risk_Low_Confidence_Limit"], "hi": x["Greater_Risk_High_Confidence_Limit"], "n": x["Sample_Size"]})
        elif x["StratificationType"] == "State" and x["Sex"] == "Total" and x["Race"] == "Total" and x["Grade"] == "Total":
            grp[(c, x["YEAR"])].append(float(x["Greater_Risk_Data_Value"]))
    for c in qs: qs[c]["national_years"] = " ".join(sorted(yrs.get(c, [])))
    wr("yrbss_hs_questions.csv", sorted(qs.values(), key=lambda d: (d["Topic"], d["QuestionCode"])), list(next(iter(qs.values()))))
    wr("yrbss_hs_national.csv", rows, list(rows[0]))
    wr("yrbss_hs_states_median.csv", [{"c": c, "y": y, "n_states": len(v), "median": statistics.median(v), "min": min(v), "max": max(v)} for (c, y), v in sorted(grp.items())],
       ["c", "y", "n_states", "median", "min", "max"])
else:
    print("hs_extract.csv not ready")
