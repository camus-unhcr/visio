# Budget Summary
class Visio.Figures.BmySummary extends Visio.Figures.Bmy

  initialize: ->
    super
    @filters.get('group_by').set 'hidden', true

    @groupBy = "#{Visio.Utils.parameterByPlural(Visio.manager.get('aggregation_type')).singular}_id"

  onMouseenterVoronoi: (d) =>
    @g.selectAll(".budget-line").classed 'active', false
    line = @g.select(".budget-line-#{d.point[d.point.groupBy]}")
    line.classed 'active', true
    line.moveToFront()

    pointData = [d.point]
    points = @g.selectAll('.point').data pointData
    points.enter().append 'circle'
    points
      .attr('r', 5)
      .attr('class', (d) -> ['point', Visio.Utils.stringToCssClass(d[d.groupBy])].join(' '))
    points.transition().duration(Visio.Durations.VERY_FAST).ease('ease-in')
      .attr('cx', (d) => @x(d.year))
      .attr('cy', (d) => @y(d.amount))
    points.exit().remove()
    points.moveToFront()



    if @tooltip?
      @tooltip.year = d.point.year
      @tooltip.collection = new Backbone.Collection(pointData)
      @tooltip.model = new Backbone.Model d.point
      @tooltip.render(true)
    else
      @tooltip = new Visio.Views.BmySummaryTooltip
        figure: @
        year: d.point.year
        collection: new Backbone.Collection(pointData)
        model: new Backbone.Model(d.point)
      @tooltip.render()


