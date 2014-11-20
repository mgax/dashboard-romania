---
---

class Graph

  constructor: (options) ->
    @width = 700
    @height = 200
    @margin = {t: 50, b: 50, l: 75, r: 25}
    @seriesNames = ['eu28', 'ro']

    d3.csv(options.file).get (err, rows) =>
      @data(rows)

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

    @svg = d3.select('body').append('svg')
        .attr('width', @width + @margin.l + @margin.r)
        .attr('height', @height + @margin.t + @margin.b)
      .append('g')
        .attr('transform', "translate(#{@margin.l}, #{@margin.t})")

    @svg.append('g')
        .attr('class', 'axis axis-x')
        .attr('transform', "translate(0, #{@height})")
        .call(@xAxis)

    @svg.append('g')
        .attr('class', 'axis axis-y')
        .call(@yAxis)

    @svg.selectAll('.series')
        .data(@seriesNames)
      .enter().append('path')
        .attr('class', (n) => "series series-#{n}")
        .attr('d', (n) => d3.svg.line()(pluck(@rows, n)))


new Graph(file: 'data/gdp.csv')
