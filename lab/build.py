import csv
from collections import defaultdict
from pathlib import Path

LAB = Path(__file__).absolute().parent
EUROSTAT = LAB / 'eurostat'
ROOT = LAB.parent
csv.register_dialect('tsv', delimiter='\t')


def read_eurostat(tsv_path, prefix, number=float):
    prefix += ','
    rv = {}
    with tsv_path.open() as f:
        table = csv.DictReader(f, dialect='tsv')
        for row in table:
            col0 = row.pop(table.fieldnames[0])
            if col0.startswith(prefix):
                rv[col0[len(prefix):]] = values = {}
                for col in row.keys():
                    txt = row[col]
                    if not txt.startswith(':'):
                        values[int(col)] = number(txt.split()[0])

    return rv


def only(table, keys):
    return {k: r for k, r in table.iteritems() if k in keys}


def pivot(table):
    rv = defaultdict(dict)
    for a in table:
        for b, v in table[a].iteritems():
            rv[b][a] = v
    return dict(rv)


def apply(table, func):
    rv = defaultdict(dict)
    for a in table:
        for b, v in table[a].iteritems():
            rv[a][b] = func(a, b, v)
    return dict(rv)


def main():
    countries = {
        code: label.decode('utf-8') for code, label in
        csv.reader((ROOT / 'countries.csv').open('rb'))
    }
    population_tsv = read_eurostat(EUROSTAT / 'population.tsv', 'JAN', int)
    gdp_mileur_tsv = read_eurostat(EUROSTAT / 'gdp_mileur.tsv', 'B1GM,MIO_EUR')
    pop_year = pivot(only(population_tsv, countries))
    gdp_year = pivot(only(gdp_mileur_tsv, countries))
    gdp_year = apply(gdp_year, (lambda a, b, v: v * 10**6))

    fields = [
        'year', 'ro', 'eu_avg',
        'eu_min_country', 'eu_min',
        'eu_max_country', 'eu_max',
    ]
    with (ROOT / 'gdp.csv').open('wb') as f:
        gdp_brackets = csv.DictWriter(f, fields)
        gdp_brackets.writeheader()
        for year in sorted(pop_year):
            pop = pop_year[year]
            if year not in gdp_year:
                continue
            gdp = gdp_year[year]
            percapita = {c: gdp[c] / pop[c] for c in pop if c in gdp}
            eu_percapita = sum(gdp.itervalues()) / sum(pop.itervalues())
            min_country = min(percapita, key=lambda c: percapita[c])
            max_country = max(percapita, key=lambda c: percapita[c])
            gdp_brackets.writerow({
                'year': year,
                'ro': int(percapita['RO']),
                'eu_avg': int(eu_percapita),
                'eu_min_country': min_country,
                'eu_min': int(percapita[min_country]),
                'eu_max_country': max_country,
                'eu_max': int(percapita[max_country]),
            })

main()
