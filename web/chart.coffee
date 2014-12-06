---
---

class Graph

    constructor: (options) ->
        @svg = options.svg
        @width = 700
        @height = 200
        @margin = {t: 50, b: 50, l: 75, r: 25}

        @seriesNames = options.names
        @color = d3.scale.ordinal()
          .range(options.colors).domain(@seriesNames);

        @space = @svg
            .attr('width', @width + @margin.l + @margin.r)
            .attr('height', @height + @margin.t + @margin.b)
          .append('g')
            .attr('transform', "translate(#{@margin.l}, #{@margin.t})")

        @legend = @space
            .append('g')
            .attr('transform', "translate(" + (@width - 100) + ", -30)");

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
            .attr('stroke', (d) => console.log(@color(d)); @color(d))
            .attr('class', (n) -> "series")
            .attr('d', (n) => d3.svg.line()(pluck(@rows, n)))

        #Legend
        @legendItems = @legend.selectAll('.legend')
            .data(@color.domain())
            .enter()
            .append('g')
            .attr('class', 'legend')
            .attr('transform', (d, i) => return 'translate(' + 15 + ', ' + 15 * i + ')')

        @legendItems.append('rect')
            .attr('width',  12)
            .attr('height', 10)
            .attr('fill', (d, i) => @color(d))

        @legendItems.append('text')
            .attr('x', 17)
            .attr('y', 10)
            .text((d) => console.log(d); d)

populationGraph = new Graph(svg: d3.select('body').append('svg'),
                            names: ['ro'],
                            colors: ['steelblue'])
gdpGraph = new Graph(svg: d3.select('body').append('svg'),
                     names: ['ro', 'eu28'],
                     colors: ['steelblue', '#aaa'])

d3.csv('data/population.csv').get (err, rows) ->
    populationGraph.seriesNames = ['ro']
    populationGraph.data(rows)

d3.csv('data/gdp.csv').get (err, rows) ->
    gdpGraph.data(rows)
