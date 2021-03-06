module 'ABSY Figure',
  setup: ->
    Visio.manager = new Visio.Models.Manager()
    @figure = new Visio.Figures.Absy(
      margin:
        left: 0
        right: 0
        top: 0
        bottom: 0
      width: 100
      height: 100
      )
    @d = new Visio.Models.Output({ id: 1, name: 'abc' })
    sinon.stub @d, 'selectedBudget', -> 10
    sinon.stub @d, 'selectedExpenditureRate', -> .5
    sinon.stub @d, 'selectedAchievement', -> { result: 10 }

  teardown: ->
    @figure.unsubscribe()
    @d.selectedBudget.restore()
    @d.selectedExpenditureRate.restore()
    @d.selectedAchievement.restore()

test 'render', ->
  @figure.collectionFn new Visio.Collections.Output([@d])
  @figure.render()

  ok d3.select(@figure.el).selectAll('.point').size(), 1
  strictEqual @figure.x.domain()[0], 0
  strictEqual @figure.x.domain()[1], 10

  @figure.collectionFn new Visio.Collections.Output([])
  @figure.render()
  strictEqual d3.select(@figure.el).selectAll('.point').size(), 0, 'Collection is not 0'

  @figure.collectionFn new Visio.Collections.Output([@d])
  @figure.render()
  strictEqual d3.select(@figure.el).selectAll('.point').size(), 1

  @d.selectedBudget.restore()
  sinon.stub @d, 'selectedBudget', -> 0

  @figure.render()
  strictEqual d3.select(@figure.el).selectAll('.point').size(), 0

  @figure.algorithm = 'selectedExpenditureRate'
  @figure.render()
  strictEqual d3.select(@figure.el).selectAll('.point').size(), 1

test 'filtered', ->

  collection = new Visio.Collections.Output([@d])

  strictEqual @figure.filtered(collection).length, 1, 'Should not be filtered'

  @d.selectedBudget.restore()
  sinon.stub @d, 'selectedBudget', -> 0
  ok not @figure.filtered(collection).length, 'Should be filtered'

  @d.selectedBudget.restore()
  @d.selectedAchievement.restore()
  sinon.stub @d, 'selectedBudget', -> 10
  sinon.stub @d, 'selectedAchievement', -> { result: undefined }
  ok not @figure.filtered(collection).length, 'Should be filtered'


test 'select', ->
  @figure.collectionFn new Visio.Collections.Output([@d])
  @figure.render()

  ok d3.select(@figure.el).selectAll('.active').empty(), 'Should have no active point'

  $.publish("select.#{@figure.figureId()}.figure", [@d, 0])

  ok not @figure.isExport, 'Should not be export'
  ok d3.select(@figure.el).selectAll('.active').empty(), 'Should not have active point since it is not export'

  @figure.subscribe()
  $.publish("select.#{@figure.figureId()}.figure", [@d, 0])
  strictEqual d3.select(@figure.el).selectAll('.active').size(), 1, 'Should have one active point'

test 'el', ->
  @figure.collectionFn new Visio.Collections.Output([@d])
  @figure.render()

  ok @figure.el.innerHTML != '', 'Figure should have something in it'

  $(@figure.el).html ''

  strictEqual @figure.el.innerHTML, '', 'Figure should be empty'

test 'query', ->
  collection = new Visio.Collections.Output([@d])

  @figure.query = 'a'
  @figure.collectionFn collection
  @figure.render()
  strictEqual @figure.$el.find('.queried').length, 1, 'Should be queried'

  @figure.query = ''
  @figure.render()
  strictEqual @figure.$el.find('.queried').length, 0, 'Should not be queried'

  @figure.query = 'e'
  @figure.render()
  strictEqual @figure.$el.find('.queried').length, 0, 'Should not be queried'
