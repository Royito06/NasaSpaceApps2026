#!/usr/bin/env python3
"""Runs ON RAMONA (stdlib). Collapse a yrbss_extract.py output into a tiny table.

usage: python3 yrbss_aggregate.py <extract.csv> <out.csv> <mode>
mode = states   -> middle school: there is NO national middle-school YRBS, so report the unweighted median across
                   participating STATES (StratificationType == State) per question x year x sex x race x grade.
mode = national -> high school: keep the national rows (LocationAbbr == XX) as published, with CI and sample size,
                   plus the same cross-state median for reference.
"""
import csv, sys, collections, statistics
src, out, mode = sys.argv[1:4]
grp = collections.defaultdict(list); nat = {}; meta = {}
with open(src, newline="") as f:
    for r in csv.DictReader(f):
        try: v = float(r["Greater_Risk_Data_Value"])
        except ValueError: continue
        k = (r["QuestionCode"], r["YEAR"], r["Sex"], r["Race"], r["Grade"])
        meta[r["QuestionCode"]] = (r["Topic"], r["ShortQuestionText"], r["Greater_Risk_Question"], r["Lesser_Risk_Question"])
        if r["StratificationType"] == "State": grp[k].append(v)
        if r["LocationAbbr"] == "XX" or r["StratificationType"] == "National":
            nat[k] = (v, r["Greater_Risk_Low_Confidence_Limit"], r["Greater_Risk_High_Confidence_Limit"], r["Sample_Size"])
def q(xs, p):
    xs = sorted(xs); k = (len(xs) - 1) * p; f = int(k); c = min(f + 1, len(xs) - 1); return xs[f] + (xs[c] - xs[f]) * (k - f)
keys = sorted(set(grp) | set(nat))
with open(out, "w", newline="") as g:
    w = csv.writer(g)
    w.writerow(["QuestionCode", "Topic", "ShortQuestionText", "Greater_Risk_Question", "Lesser_Risk_Question", "YEAR", "Sex", "Race", "Grade",
                "national_pct", "national_ci_low", "national_ci_high", "national_n", "n_states", "states_median", "states_q1", "states_q3", "states_min", "states_max"])
    for k in keys:
        if mode == "national" and k not in nat: continue
        xs = grp.get(k, []); n = nat.get(k, ("", "", "", ""))
        st = [len(xs)] + ([round(statistics.median(xs), 1), round(q(xs, .25), 1), round(q(xs, .75), 1), min(xs), max(xs)] if xs else [""] * 5)
        w.writerow([k[0], *meta[k[0]], *k[1:], *n, *st])
print("groups", len(keys))
