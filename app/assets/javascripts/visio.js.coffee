window.Visio =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Utils: {}
  Graphs: {}
  AchievementTypes:
    TARGET: 'comp_target'
    STANDARD: 'standard'
  Scenarios:
    OL: 'Operating Level'
    AOL: 'Above Operating Level'
  Budgets:
    ADMIN: 'ADMIN'
    PARTNER: 'PARTNER'
    PROJECT: 'PROJECT'
    STAFF: 'STAFF'
  Durations:
    FAST: 500
    MEDIUM: 1000
  Formats:
    SI: d3.format('0.3s')
    PERCENT: d3.format(".0%")
  Constants:
    DB_NAME: 'visio'
  Stores:
    MAP: 'map'
    SYNC: 'sync_date'
  ParameterClass:
    PLANS: 'Plan'
    PPGS: 'Ppg'
    GOALS: 'Goal'
    OUTPUTS: 'Output'
    PROBLEM_OBJECTIVES: 'ProblemObjective'
    INDICATORS: 'Indicator'
    INDICATOR_DATA: 'IndicatorDatum'
    BUDGETS: 'Budget'
  Parameters:
    PLANS: 'plans'
    PPGS: 'ppgs'
    GOALS: 'goals'
    OUTPUTS: 'outputs'
    PROBLEM_OBJECTIVES: 'problem_objectives'
    INDICATORS: 'indicators'
    INDICATOR_DATA: 'indicator_data'
    BUDGETS: 'budgets'
  Algorithms:
    SUCCESS_THRESHOLD: 0.66
    OK_THRESHOLD: 0.33
    HIGH_THRESHOLD: 0.8
    MEDIUM_THRESHOLD: 0.6
    ALGO_RESULTS:
      success: 'success'
      ok: 'ok'
      fail: 'fail'
      missing: 'missing'
      high: 'high'
      medium: 'medium'
      low: 'low'

    REPORTED_VALUES:
      myr: 'myr'
      yer: 'yer'
      baseline: 'baseline'

    GOAL_TYPES:
      standard: 'standard'
      target: 'comp_target'

Visio.ProgressTypes =
  BASELINE_MYR:
    "#{Visio.Algorithms.REPORTED_VALUES.baseline}-#{Visio.Algorithms.REPORTED_VALUES.myr}"
  BASELINE_YER:
    "#{Visio.Algorithms.REPORTED_VALUES.baseline}-#{Visio.Algorithms.REPORTED_VALUES.yer}"
  MYR_YER:
    "#{Visio.Algorithms.REPORTED_VALUES.myr}-#{Visio.Algorithms.REPORTED_VALUES.yer}"
Visio.Types = [
    Visio.Parameters.PLANS,
    Visio.Parameters.PPGS,
    Visio.Parameters.GOALS,
    Visio.Parameters.OUTPUTS,
    Visio.Parameters.PROBLEM_OBJECTIVES,
    Visio.Parameters.INDICATORS,
  ]

Visio.AggregationTypes = [
    Visio.Parameters.PLANS,
    Visio.Parameters.PPGS,
    Visio.Parameters.GOALS,
    Visio.Parameters.OUTPUTS,
    Visio.Parameters.PROBLEM_OBJECTIVES,
  ]

Visio.Schema =
    stores: []

_.each _.values(Visio.Parameters), (parameter) ->
  Visio.Schema.stores.push {
    name: parameter + '_store'
    keyPath: 'id'
    autoIncrement: false
  }

Visio.Schema.stores.push {
    name: Visio.Stores.MAP
    autoIncrement: false
  }

Visio.Schema.stores.push {
    name: Visio.Stores.SYNC
    autoIncrement: false
  }
