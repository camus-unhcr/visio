class Visio.Views.BmyShowView extends Visio.Views.AccordionShowView

  template: HAML['modules/bmy_show']

  className: 'bmy-container accordion-show-container'

  events:
    'click .js-parameter': 'onClickParameter'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'

  initialize: (options) ->
    @config =
      margin:
        top: 10
        bottom: 80
        left: 120
        right: 40
      width: 650
      height: 450

    @figure = new Visio.Figures.Bmy @config
    @filterBy = new Visio.Views.FilterBy({ figure: @figure, })

  render: (isRerender) ->

    unless isRerender
      @$el.html @template( parameter: @model, figureId: @figure.figureId() )
      @$el.find('.bmy-figure').html @figure.el
      @$el.find('.header-buttons').append @filterBy.render().el

    if @model.selectedBudgetData(Visio.Constants.ANY_YEAR).length == 0
      @$el.addClass 'disabled'
      @shrink()
    else
      @$el.removeClass 'disabled'
    @


  drawFigures: ->
    @figure.collectionFn @model.selectedBudgetData(Visio.Constants.ANY_YEAR)
    @figure.render()

  removeInstances: =>
    @filterBy.close()
    @figure.unsubscribe()
