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
  for row in d3.tsv.parse(read('eurostat/gdp.tsv'))
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

parseStudents = ->
  rv = {}
  for row in d3.tsv.parse(read('eurostat/students.tsv'))
    col0 = dicPop(row, 'GEO,INDIC_ED,SEX\\TIME')
    if (m = col0.match('^([^,]+),'))?
      region = m[1].toLowerCase()
      if region in ['european union (28 countries)', 'romania']
        region = if (region == 'romania') then 'ro' else 'eu28'
        rvRow = rv[region] = {}
        for year in d3.keys(row)
          data = row[year].match('^[^ ]*')[0]
          rvRow[+year] = +data
  rvEU = rv['eu28']
  rvRO = rv['ro']
  for name in d3.keys(rvEU)
    if isNaN(rvEU[name]) or isNaN(rvRO[name])
      delete rvEU[name]
      delete rvRO[name]

  return rv


compile.run = ->
  students = parseStudents()
  population = parsePopulation()
  gdp = parseGdp(population)

  writeCsv(table(students), 'students.csv')
  writeCsv(table(population), 'population.csv')
  writeCsv(table(gdp), 'gdp.csv')
