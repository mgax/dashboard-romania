fs = require('fs')
d3 = require('d3')

compile = module.exports = {}


dicPop = (dic, key) ->
    value = dic[key]
    delete dic[key]
    return value


readEurostatGDP = ->
  pop_tsv = fs.readFileSync(__dirname + '/eurostat/population.tsv', 'utf8')
  pop_table = d3.tsv.parse(pop_tsv)

  col0_pop = 'indic_de,geo\\time'
  popByRegion = {}

  for row in pop_table
    region = dicPop(row, col0_pop).match('JAN,([^,]+)$')[1].toLowerCase()
    if region in ['eu28', 'ro']
      popRow = popByRegion[region] = {}
      for year in d3.keys(row)
        popRow[+year] = +(row[year].match('^[^ ]*')[0])

  gdp_tsv = fs.readFileSync(__dirname + '/eurostat/gdp_mileur.tsv', 'utf8')
  gdp_table = d3.tsv.parse(gdp_tsv)

  col0_gdp = 'indic_na,unit,geo\\time'
  gdpByYear = {}

  for row in gdp_table
    if (m = dicPop(row, col0_gdp).match('B1GM,MIO_EUR,([^,]+)$'))?
      region = m[1].toLowerCase()
      if region in ['eu28', 'ro']
        for year in d3.keys(row)
          pop = popByRegion[region][+year]
          if pop?
            yearRow = gdpByYear[+year] or (gdpByYear[+year] = {year: +year})
            yearRow[region] = +row[year] * 1e6 / pop

  return d3.values(gdpByYear).sort((a, b) -> d3.ascending(+a.year, +b.year))


compile.run = ->
  fs.writeFileSync(__dirname + '/../gdp.csv', d3.csv.format(readEurostatGDP()))
