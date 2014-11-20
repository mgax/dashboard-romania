---
---

d3.csv('data/gdp.csv').get (err, rows) ->
    x = d3.scale.linear()
      .domain(d3.extent(rows, (r) -> +r.year))
      .range([0, 700])

    y = d3.scale.linear()
      .domain([0, d3.max(rows, (r) -> d3.max([+r.eu28, +r.ro]))])
      .range([200, 0])

    pluck = (rows, n) ->
        rv = []
        for r in rows
            if r[n]?
                rv.push([x(r.year), y(r[n])])
        return rv

    xAxis = d3.svg.axis()
        .scale(x)
        .tickFormat((d) -> +d)

    yAxis = d3.svg.axis()
        .scale(y)
        .orient('left')

    svg = d3.select('body').append('svg')
        .attr('width', 800)
        .attr('height', 300)
      .append('g')
        .attr('transform', 'translate(75, 50)')

    svg.append('g')
        .attr('class', 'axis axis-x')
        .attr('transform', 'translate(0, 200)')
        .call(xAxis)

    svg.append('g')
        .attr('class', 'axis axis-y')
        .call(yAxis)

    svg.selectAll('.series')
        .data(['eu28', 'ro'])
      .enter().append('path')
        .attr('class', (n) -> "series series-#{n}")
        .attr('d', (n) -> d3.svg.line()(pluck(rows, n)))
