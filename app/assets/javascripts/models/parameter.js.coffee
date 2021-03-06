class Visio.Models.Parameter extends Visio.Models.Syncable

  # @param: type - This is hash of the type of data we want (Budget, Expenditure, IndicatorDatum)
  # @param: idHash - This is a hash of ids that the data should include
  # @param: year - Allows for any specified year or false which will use all years. If undefined, will fall
  # @param: filters - Any sort of FigureFilter that should be applied to data
  # back to current year
  data: (type, idHash, year, filters, opts = {}) ->
    year = Visio.manager.year() unless year?


    # Return empty collection since indicators do not have budgets or expenditures
    if (type.plural == Visio.Syncables.BUDGETS.plural or
       type.plural == Visio.Syncables.EXPENDITURES.plural) and
       @name == Visio.Parameters.INDICATORS
      return new Visio.Collections[type.className]()

    # First pass at filtering
    if @name == Visio.Parameters.STRATEGY_OBJECTIVES
      # If it's not included in any of the SOs, throw it out
      data = Visio.manager.get(type.plural).filter (d) =>
        ids = d.get "#{@name.singular}_ids"

        _.include(ids, @id) or
          (_.isEmpty(ids) and
           opts.includeExternalStrategyData and
           @id == Visio.Constants.ANY_STRATEGY_OBJECTIVE and
           idHash[@name.plural][@id])
    else
      # data must have the instance's id
      condition = {}
      condition["#{@name.singular}_id"] = @id
      data = Visio.manager.get(type.plural).where(condition)

    data = _.filter data, (d) => not filters? or not filters.isFiltered(d)

    data = _.filter data, (d) =>
      return _.every _.values(Visio.Parameters), (hash) =>

        # This check is because it has already been filtered above
        return true if @name.plural == hash.plural

        # Must be current year if we are specifying year
        return false if year != Visio.Constants.ANY_YEAR and year != d.get('year')

        # Skip indicator if it's a budget
        if (type.plural == Visio.Syncables.BUDGETS.plural or
           type.plural == Visio.Syncables.EXPENDITURES.plural) and
           hash.plural == Visio.Parameters.INDICATORS.plural
          return true


        # One of strategy objective ids must be selected
        if hash == Visio.Parameters.STRATEGY_OBJECTIVES
          ids = d.get("#{hash.singular}_ids")

          if _.isEmpty(ids) and opts.includeExternalStrategyData and idHash[hash.plural][Visio.Constants.ANY_STRATEGY_OBJECTIVE]

            return true

          return _.any ids, (id) -> idHash[hash.plural][id]


        id = d.get("#{hash.singular}_id")

        # If output_id is missing that's ok
        return true if not id? and hash == Visio.Parameters.OUTPUTS


        idHash[hash.plural][id]

    return new Visio.Collections[type.className](data)

  selectedIndicatorData: (year, filters = null) ->
    @selectedData(Visio.Syncables.INDICATOR_DATA, year, filters)

  selectedBudgetData: (year, filters = null) ->
    @selectedData(Visio.Syncables.BUDGETS, year, filters)

  selectedExpenditureData: (year, filters = null) ->
    @selectedData(Visio.Syncables.EXPENDITURES, year, filters)

  selectedData: (type, year, filters = null) ->
    opts =
      includeExternalStrategyData: Visio.manager.includeExternalStrategyData()

    @data type, Visio.manager.get('selected'), year, filters, opts

  strategyData: (type, strategy, year, filters = null) ->
    strategy or= Visio.manager.strategy()
    idHash = {}
    opts =
      includeExternalStrategyData: Visio.manager.includeExternalStrategyData()

    _.each _.values(Visio.Parameters), (hash) ->
      idHash[hash.plural] = strategy.get("#{hash.singular}_ids")

    @data type, idHash, year, filters, opts


  strategyIndicatorData: (strategy, year, filters = null) ->
    @strategyData(Visio.Syncables.INDICATOR_DATA, strategy, year, filters)

  strategyBudgetData: (strategy, year, filters = null) ->
    @strategyData(Visio.Syncables.BUDGETS, strategy, year, filters)

  strategyExpenditureData: (strategy, year, filters = null) ->
    @strategyData(Visio.Syncables.EXPENDITURES, strategy, year, filters)

  strategyExpenditure: (year, filters = null) ->
    data = @strategyExpenditureData(null, year, filters)
    data.amount()

  strategyBudget: (year, filters = null) ->
    data = @strategyBudgetData(null, year, filters)
    data.amount()

  strategySituationAnalysis: () ->
    data = @strategyIndicatorData()
    data.situationAnalysis()

  strategyAchievement: (year, filters = null) ->
    data = @strategyIndicatorData(null, year, filters)
    data.achievement()

  strategyOutputAchievement: (year, filters = null) ->
    data = @strategyIndicatorData(null, year, filters)
    data.outputAchievement()

  selectedOutputAchievement: (year, filters = null) ->
    data = @selectedIndicatorData year, filters
    data.outputAchievement()

  selectedAchievement: (year, filters = null) ->
    data = @selectedIndicatorData(year, filters)
    data.achievement()

  selectedBudget: (year, filters = null) ->
    data = @selectedBudgetData(year, filters)
    data.amount()

  selectedSituationAnalysis: (year, filters = null) ->
    data = @selectedIndicatorData(year, filters)
    data.situationAnalysis()

  selectedExpenditure: (year, filters = null) ->
    data = @selectedExpenditureData(year, filters)
    data.amount()

  selectedExpenditureRate: (year, filters = null) ->
    expenditures = @selectedExpenditureData(year, filters)
    budgets = @selectedBudgetData(year, filters)
    expenditures.amount() / budgets.amount()

  refId: ->
    @id

  search: (query) ->
    $.get("#{@url}/search", { query: query })


  include: (singular, id) ->

    id == @id or @get("#{singular}_ids")?[id]?

  selectedAmount: (year, filters = null) ->
    # Either Budget or Expenditure
    @["selected#{Visio.manager.get('amount_type').className}"](year, filters)

  highlight: ->
    return @get('highlight').name[0] if @get('highlight')
