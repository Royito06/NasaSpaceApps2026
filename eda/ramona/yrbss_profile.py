#!/usr/bin/env python3
"""Runs ON RAMONA (stdlib only, streaming). Profile a YRBSS Socrata CSV:
distinct Topic/Subtopic/QuestionCode/ShortQuestionText with row counts and non-null counts,
plus distinct years, location types, strat values.
usage: python3 yrbss_profile.py <csv> <outdir> <prefix>"""
import csv, sys, collections, os
src, outdir, prefix = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(outdir, exist_ok=True)
q = collections.Counter(); qn = collections.Counter()
years = collections.Counter(); loc = collections.Counter(); strat = collections.Counter()
with open(src, newline='', encoding='utf-8', errors='replace') as f:
    r = csv.DictReader(f)
    r.fieldnames = [c.strip() for c in r.fieldnames]  # the high-school export has trailing spaces in the header
    cols = r.fieldnames
    for row in r:
        k = (row.get('Topic'), row.get('Subtopic'), row.get('QuestionCode'), row.get('ShortQuestionText'), row.get('Greater_Risk_Question'))
        q[k] += 1
        if row.get('Greater_Risk_Data_Value'):
            qn[k] += 1
        years[row.get('YEAR')] += 1
        loc[(row.get('StratificationType'), row.get('LocationAbbr'))] += 1
        strat[(row.get('Sex'), row.get('Race'), row.get('Grade'), row.get('SexualIdentity',''), row.get('SexOfSexualContacts',''))] += 1
with open(f'{outdir}/{prefix}_questions.csv', 'w', newline='') as f:
    w = csv.writer(f); w.writerow(['Topic','Subtopic','QuestionCode','ShortQuestionText','Greater_Risk_Question','rows','rows_with_value'])
    for k, n in sorted(q.items()): w.writerow(list(k) + [n, qn[k]])
with open(f'{outdir}/{prefix}_meta.txt', 'w') as f:
    f.write('COLUMNS: ' + ','.join(cols) + '\n')
    f.write('YEARS: ' + repr(sorted(years.items())) + '\n')
    f.write('LOC: ' + repr(sorted(loc.items(), key=lambda x: str(x))) + '\n')
    f.write('STRAT: ' + repr(sorted(strat.items(), key=lambda x: -x[1])[:80]) + '\n')
print('done', sum(q.values()))
