#!/usr/bin/env python3
"""Runs ON RAMONA (stdlib only, streaming, one pass, low RAM). Keep only the rows we need from a YRBSS
Socrata export and write a small CSV that is copied back to the laptop.

usage: python3 yrbss_extract.py <src.csv> <out.csv> <QCODE,QCODE,...|ALL>
Filters: QuestionCode in list; Race in {Total, Hispanic or Latino}; Grade == Total (plus single grades when
Race == Total and Sex == Total); sexual-identity columns (if present) == Total; value not empty.
"""
import csv, sys
src, out, codes = sys.argv[1], sys.argv[2], sys.argv[3]
codes = None if codes == "ALL" else set(codes.split(","))
KEEP = ["YEAR", "LocationAbbr", "LocationDesc", "StratificationType", "Topic", "Subtopic", "QuestionCode", "ShortQuestionText",
        "Greater_Risk_Question", "Lesser_Risk_Question", "Greater_Risk_Data_Value", "Greater_Risk_Low_Confidence_Limit",
        "Greater_Risk_High_Confidence_Limit", "Lesser_Risk_Data_Value", "Sample_Size", "Sex", "Race", "Grade",
        "SexualIdentity", "SexOfSexualContacts"]
n = k = 0
with open(src, newline="", encoding="utf-8", errors="replace") as f, open(out, "w", newline="") as g:
    r = csv.DictReader(f)
    r.fieldnames = [c.strip() for c in r.fieldnames]  # the high-school export has trailing spaces in the header
    keep = [c for c in KEEP if c in r.fieldnames]
    w = csv.DictWriter(g, fieldnames=keep, extrasaction="ignore")
    w.writeheader()
    for row in r:
        n += 1
        if codes is not None and row["QuestionCode"] not in codes: continue
        if not row["Greater_Risk_Data_Value"]: continue
        if row.get("SexualIdentity", "Total") not in ("Total", ""): continue
        if row.get("SexOfSexualContacts", "Total") not in ("Total", ""): continue
        race, grade, sex = row["Race"], row["Grade"], row["Sex"]
        if race not in ("Total", "Hispanic or Latino"): continue
        if grade != "Total" and not (race == "Total" and sex == "Total"): continue
        w.writerow(row); k += 1
print(f"read {n} rows, kept {k}")
