---
---

class Graph

  constructor: (options) ->
    @svg = options.svg
    @width = 700
    @height = 200
    @margin = {t: 50, b: 50, l: 75, r: 25}
    @seriesNames = ['eu28', 'ro']

    @space = @svg
        .attr('width', @width + @margin.l + @margin.r)
        .attr('height', @height + @margin.t + @margin.b)
      .append('g')
        .attr('transform', "translate(#{@margin.l}, #{@margin.t})")

  data: (@rows) ->
    @x = d3.scale.linear()
      .domain(d3.extent(@rows, (r) => +r.year))
      .range([0, @width])

    @y = d3.scale.linear()
      .domain([0, d3.max(@rows, (r) => d3.max(@seriesNames, (s) -> +r[s]))])
      .range([@height, 0])

    @xAxis = d3.svg.axis()
        .scale(@x)
        .tickFormat((d) => +d)

    @yAxis = d3.svg.axis()
        .scale(@y)
        .orient('left')

    @render()

  render: ->
    pluck = (rows, n) =>
        rv = []
        for r in rows
            if r[n]?
                rv.push([@x(r.year), @y(r[n])])
        return rv

    @space.append('g')
        .attr('class', 'axis axis-x')
        .attr('transform', "translate(0, #{@height})")
        .call(@xAxis)

    @space.append('g')
        .attr('class', 'axis axis-y')
        .call(@yAxis)

    @space.selectAll('.series')
        .data(@seriesNames)
      .enter().append('path')
        .attr('class', (n) => "series series-#{n}")
        .attr('d', (n) => d3.svg.line()(pluck(@rows, n)))


d3.csv('data/gdp.csv').get (err, rows) ->
    new Graph(svg: d3.select('body').append('svg')).data(rows)
