fs = require('fs')
d3 = require('d3')

compile = module.exports = {}

dicPop = (dic, key) ->
    value = dic[key]
    delete dic[key]
    return value

read = (fileName) -> fs.readFileSync(__dirname + '/' + fileName, 'utf8')

sort = (array, key) -> array.sort((a, b) -> d3.ascending(key(a), key(b)))

table = (series) ->
  out = {}
  for name in d3.keys(series)
    data = series[name]
    for year in d3.keys(data)
      row = out[year] or (out[year] = {year: year})
      row[name] = data[year]
  return sort(d3.values(out), (d) -> +d.year)

writeCsv = (table, name) ->
  fs.writeFileSync(__dirname + '/../data/' + name, d3.csv.format(table))


parsePopulation = ->
  rv = {}
  for row in d3.tsv.parse(read('eurostat/population.tsv'))
    col0 = dicPop(row, 'indic_de,geo\\time')
    region = col0.match('JAN,([^,]+)$')[1].toLowerCase()
    if region in ['eu28', 'ro']
      rvRow = rv[region] = {}
      for year in d3.keys(row)
        rvRow[+year] = +(row[year].match('^[^ ]*')[0])

  return rv


parseGdp = (population) ->
  rv = {}
  for row in d3.tsv.parse(read('eurostat/gdp_mileur.tsv'))
    col0 = dicPop(row, 'indic_na,unit,geo\\time')
    if (m = col0.match('B1GM,MIO_EUR,([^,]+)$'))?
      region = m[1].toLowerCase()
      if region in ['eu28', 'ro']
        rvRow = rv[region] = {}
        for year in d3.keys(row)
          pop = population[region][+year]
          if pop?
            rvRow[+year] = +row[year] * 1e6 / pop

  return rv


compile.run = ->
  population = parsePopulation()
  gdp = parseGdp(population)

  writeCsv(table(gdp), 'gdp.csv')
