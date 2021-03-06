class Visio.Views.IsyShowView extends Visio.Views.AccordionShowView

  template: HAML['modules/isy_show']

  className: 'isy-container accordion-show-container'

  events:
    'click .js-parameter': 'onClickParameter'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'

  initialize: (options) ->
    @config =
      margin:
        top: 35
        bottom: 18
        left: 40
        right: 30
      width: 800
      height: 260

    @isyFigure = new Visio.Figures.Isy @config
    @filterBy = new Visio.Views.FilterBy({ figure: @isyFigure, })
    @queryBy = new Visio.Views.QueryBy figure: @isyFigure, placeholder: 'Search for an indicator'
    @sortBy = new Visio.Views.Dropdown
      title: 'Sort By'
      data: [
          { label: 'Baseline to MYR', value: Visio.ProgressTypes.BASELINE_MYR.value, checked: true },
          { label: 'Baseline to YER', value: Visio.ProgressTypes.BASELINE_YER.value },
          { label: 'MYR to YER', value: Visio.ProgressTypes.MYR_YER.value },
        ]
      callback: (value, data) =>
        progress = _.findWhere _.values(Visio.ProgressTypes), { value: value }
        @isyFigure.sortAttribute = progress
        @isyFigure.render()

    $.subscribe "hover.#{@isyFigure.cid}.figure", (e, idxOrDatum) =>
      if idxOrDatum instanceof Visio.Models.IndicatorDatum
        value = @isyFigure.findBoxByDatum(idxOrDatum).idx
      else
        value = idxOrDatum

      @$el.find('.slider').slider 'value', value
      @$el.find('.slider .ui-slider-handle').attr 'data-value', value + 1
    $.subscribe "drawFigures.#{@isyFigure.cid}.figure", @drawFigures

  render: (isRerender) ->
    situationAnalysis = @model.selectedSituationAnalysis()

    if !isRerender
      @$el.html @template({ parameter: @model, figureId: @isyFigure.figureId() })

      @$el.find('.indicator-bar-graph').html @isyFigure.el
      @$el.find('.header-buttons').append @filterBy.render().el
      @$el.find('.header-buttons').append @sortBy.render().el
      @$el.find('.header-buttons').append @queryBy.render().el

      @$el.find('.slider').slider
        animate: true
        slide: @onSlide
        stop: @onStop
        min: 0


    category = if situationAnalysis.total == 0 then 'white' else situationAnalysis.category

    # Remove any previous category class from pin
    @$el.find('.pin').removeClass () ->
      classes = _.values(Visio.Algorithms.ALGO_RESULTS).map (result) -> 'pin-' + result
      classes.join ' '

    # Add recomputed category class
    @$el.find('.pin').addClass "pin-#{category}"

    if @model.selectedIndicatorData().length == 0
      @$el.addClass 'disabled'
      @shrink()
    else
      @$el.removeClass 'disabled'

    @drawFigures() if @isOpen()
    @

  onStop: (e, ui) =>
    $.publish "mouseout.#{@isyFigure.cid}.figure", ui.value

  onSlide: (e, ui) =>
    $.publish "hover.#{@isyFigure.cid}.figure", ui.value
    @$el.find('.slider .ui-slider-handle').attr 'data-value', ui.value + 1

  drawFigures: =>
    @isyFigure.collectionFn @model.selectedIndicatorData()
    max = @isyFigure.filtered(@isyFigure.collection).length

    @isyFigure.render()

    # Make sure something is there
    unless @isyFigure.tooltip.hasRendered()
      $.publish "hover.#{@isyFigure.cid}.figure", 0

    @$el.find('.slider').slider 'option', 'max', max - 1
    @$el.find('.slider').attr('data-max', max)

  removeInstances: =>
    $.unsubscribe "drawFigures.#{@isyFigure.cid}.figure"
    $.unsubscribe "hover.#{@isyFigure.cid}.figure"
    @isyFigure.close()
