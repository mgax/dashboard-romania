fs = require('fs')
d3 = require('d3')

compile = module.exports = {}

dicPop = (dic, key) ->
    value = dic[key]
    delete dic[key]
    return value

read = (fileName) -> fs.readFileSync(__dirname + '/' + fileName, 'utf8')

sort = (array, key) -> array.sort((a, b) -> d3.ascending(key(a), key(b)))


parsePopulation = ->
  rv = {}
  for row in d3.tsv.parse(read('eurostat/population.tsv'))
    col0 = dicPop(row, 'indic_de,geo\\time')
    region = col0.match('JAN,([^,]+)$')[1].toLowerCase()
    if region in ['eu28', 'ro']
      popRow = rv[region] = {}
      for year in d3.keys(row)
        popRow[+year] = +(row[year].match('^[^ ]*')[0])

  return rv


readEurostatGDP = ->
  popByRegion = parsePopulation()

  gdpByYear = {}
  for row in d3.tsv.parse(read('eurostat/gdp_mileur.tsv'))
    col0 = dicPop(row, 'indic_na,unit,geo\\time')
    if (m = col0.match('B1GM,MIO_EUR,([^,]+)$'))?
      region = m[1].toLowerCase()
      if region in ['eu28', 'ro']
        for year in d3.keys(row)
          pop = popByRegion[region][+year]
          if pop?
            yearRow = gdpByYear[+year] or (gdpByYear[+year] = {year: +year})
            yearRow[region] = +row[year] * 1e6 / pop

  return sort(d3.values(gdpByYear), (d) -> +d.year)


compile.run = ->
  fs.writeFileSync(__dirname + '/../data/gdp.csv', d3.csv.format(readEurostatGDP()))
