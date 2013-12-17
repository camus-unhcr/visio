require 'test_helper'

class FocusParseTest < ActiveSupport::TestCase

  TESTFILE_PATH = "#{Rails.root}/test/files/"
  TESTFILE_NAME = "PlanTest.xml"
  DELETED_TESTFILE_NAME = "DeletedPlanTest.xml"
  TESTFILE_NAME_2 = "PlanTest2.xml"
  TESTFILE_NAME_DIFFERENT = "PlanTestDifferent.xml"
  UPDATED_TESTFILE_NAME = "UpdatedPlanTest.xml"
  TESTHEADER_NAME = "HeaderTest.xml"
  PLAN_TYPES = ['ONEPLAN']

  COUNTS = {
    :plans => 1,
    :ppgs => 3,
    :goals => 3,
    :rights_groups => 8,
    :problem_objectives => 28,
    :indicators => 171,
    :outputs => 82,
    :operations => 139,
    :indicator_data => 208,
    :budgets => 403
  }
  include FocusParse
  def setup
    # Destory any fixtures or previous data
    Plan.destroy_all
    Ppg.destroy_all
    Goal.destroy_all
    RightsGroup.destroy_all
    ProblemObjective.destroy_all
    Output.destroy_all
    Indicator.destroy_all
    IndicatorDatum.destroy_all
    Operation.destroy_all
    Budget.delete_all
  end

  test "two separate plans" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)

    file = File.read(TESTFILE_PATH + TESTFILE_NAME)
    parse_plan(file)

    file2 = File.read(TESTFILE_PATH + TESTFILE_NAME_DIFFERENT)
    parse_plan(file2)

    Plan.all.each do |plan|
      o = plan.operation
      assert_equal 1, o.plans.length
    end



  end

  test "update" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)

    file = File.read(TESTFILE_PATH + TESTFILE_NAME)
    parse_plan(file)

    updated_file = File.read(TESTFILE_PATH + UPDATED_TESTFILE_NAME)
    parse_plan(updated_file)

    # Ensure counts are the same
    assert_equal COUNTS[:plans], Plan.count, "Plan count"
    assert_equal COUNTS[:ppgs], Ppg.count, "Ppg count"
    assert_equal COUNTS[:goals], Goal.count, "Goal count"
    assert_equal COUNTS[:rights_groups], RightsGroup.count, "Rights Group count"
    assert_equal COUNTS[:problem_objectives], ProblemObjective.count, "ProblemObjective count"
    assert_equal COUNTS[:outputs], Output.count, "Output count"
    assert_equal COUNTS[:operations], Operation.count, "Operation count"
    assert_equal COUNTS[:budgets], Budget.count, "Budget count"

    doc = Nokogiri::XML(file) do |config|
      config.noblanks.strict
    end
    updated_doc = Nokogiri::XML(updated_file) do |config|
      config.noblanks.strict
    end

    assert !EquivalentXml.equivalent?(doc, updated_doc, {
      :element_order => false,
      :normalize_whitespace => true })

    assert_equal 2014, Plan.first.year
    assert Goal.where(:name => 'Voluntary return Changed').first
    assert RightsGroup.where(:name => 'Basic Needs and Essential Services Changed').first
    assert ProblemObjective.where(:problem_name => 'Self reliance and livelihoods insufficient for protection and solutions Changed').first
    assert Indicator.where(:name => '# of PoC receiving production kits or inputs for agriculture/livestock/fisheries activities Changed')
  end

  test "Parse operation_header FOCUS" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)

    assert_equal COUNTS[:operations], Operation.count, "Operation count"
    Operation.all.each do |o|
      assert o.years.length >= 0
      assert o.name
      assert o.id
    end
  end

  test "basic" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)

    file = File.read(TESTFILE_PATH + TESTFILE_NAME)
    parse_plan(file)

    assert_equal COUNTS[:plans], Plan.count, "Plan count"
    Plan.all.each do |plan|
      assert_equal Ppg.count, plan.ppgs.length
    end

    plan = Plan.first
    operation = Operation.where(:name => plan.operation_name).first

    assert plan.country

    assert_equal 'COG', plan.country.iso3

    assert_equal COUNTS[:plans], operation.plans.length, "Should only have one plan"

    assert_equal COUNTS[:ppgs], Ppg.count, "Ppg count"
    assert_equal COUNTS[:ppgs], operation.ppgs.count, "Operation's Ppg count"
    assert_equal COUNTS[:ppgs], plan.ppgs.count, "Plan's Ppg count"
    Ppg.all.each do |ppg|
      assert ppg.goals.length >= 0
      assert ppg.goals.length <= Goal.count
      assert ppg.operation_name
    end

    assert_equal COUNTS[:goals], Goal.count, "Goal count"
    assert_equal COUNTS[:goals], operation.goals.count, "Operation's goals count"
    assert_equal COUNTS[:goals], plan.goals.count, "Plan's goals count"
    Goal.all.each do |goal|
      assert goal.rights_groups.length >= 0
      assert goal.rights_groups.length <= RightsGroup.count
    end

    assert_equal COUNTS[:rights_groups], RightsGroup.count, "Rights Group count"
    assert_equal COUNTS[:rights_groups], operation.rights_groups.count, "Operation's rights groups count"
    assert_equal COUNTS[:rights_groups], plan.rights_groups.count, "Plan's rights groups count"
    RightsGroup.all.each do |rights_group|
      assert rights_group.problem_objectives.length >= 0
      assert rights_group.problem_objectives.length <= ProblemObjective.count
    end

    assert_equal COUNTS[:problem_objectives], ProblemObjective.count, "ProblemObjective count"
    assert_equal COUNTS[:problem_objectives], operation.problem_objectives.count, "Operation's ProblemObjective count"
    assert_equal COUNTS[:problem_objectives], plan.problem_objectives.count, "Plan's ProblemObjective count"
    ProblemObjective.all.each do |problem_objective|
      assert problem_objective.outputs.length >= 0
      assert problem_objective.outputs.length <= Output.count
      assert problem_objective.indicators.length >= 0
      assert problem_objective.indicators.length <= Indicator.count
    end

    assert_equal COUNTS[:outputs], Output.count, "Output count"
    assert_equal COUNTS[:outputs], operation.outputs.count, "Operation's outputs count"
    assert_equal COUNTS[:outputs], plan.outputs.count, "Plan's outputs count"
    Output.all.each do |output|
      assert output.indicators.length >= 0
      assert output.indicators.length <= Indicator.count
    end

    assert_equal COUNTS[:indicators], Indicator.count, "Indicator count"
    assert_equal COUNTS[:indicators], operation.indicators.count, "Operation's indicators count"
    assert_equal COUNTS[:indicators], plan.indicators.count, "Plan's indicators count"

    assert_equal COUNTS[:indicator_data], IndicatorDatum.count, "IndicatorDatum count"
    IndicatorDatum.all.each do |d|
      assert d.plan, "Must be a plan"
      assert d.ppg, "Must be a ppg"
      assert d.goal, "Must be a goal"
      assert d.rights_group, "Must be a rights group"
      assert d.problem_objective || d.output, "Must be either a obj or output"
      assert d.indicator, "Must be an indicator"
      assert d.operation, "Must be an operation"
      assert !d.is_performance.nil?, "Must have a performance field"
      assert d.year, "Must be a year"
    end

    assert_equal COUNTS[:budgets], Budget.count, "Budget count"
    assert_equal 0, Budget.where('amount = 0').count

  end

  test "should find duplicates and not create extra entries" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)

    file = File.read(TESTFILE_PATH + TESTFILE_NAME)
    parse_plan(file)

    file = File.read(TESTFILE_PATH + TESTFILE_NAME)
    parse_plan(file)

    assert_equal COUNTS[:plans], Plan.count, "Plan count"
    Plan.all.each do |plan|
      assert_equal Ppg.count, plan.ppgs.length
    end

    plan = Plan.first
    operation = Operation.where(:name => plan.operation_name).first

    assert_equal COUNTS[:plans], operation.plans.length, "Should only have one plan"

    assert_equal COUNTS[:ppgs], Ppg.count, "Ppg count"
    assert_equal COUNTS[:ppgs], operation.ppgs.count, "Operation's Ppg count"
    assert_equal COUNTS[:ppgs], plan.ppgs.count, "Plan's Ppg count"
    Ppg.all.each do |ppg|
      assert ppg.goals.length >= 0
      assert ppg.goals.length <= Goal.count
    end

    assert_equal COUNTS[:goals], Goal.count, "Goal count"
    assert_equal COUNTS[:goals], operation.goals.count, "Operation's goals count"
    assert_equal COUNTS[:goals], plan.goals.count, "Plan's goals count"
    Goal.all.each do |goal|
      assert goal.rights_groups.length >= 0
      assert goal.rights_groups.length <= RightsGroup.count
    end

    assert_equal COUNTS[:rights_groups], RightsGroup.count, "Rights Group count"
    assert_equal COUNTS[:rights_groups], operation.rights_groups.count, "Operation's rights groups count"
    assert_equal COUNTS[:rights_groups], plan.rights_groups.count, "Plan's rights groups count"
    RightsGroup.all.each do |rights_group|
      assert rights_group.problem_objectives.length >= 0
      assert rights_group.problem_objectives.length <= ProblemObjective.count
    end

    assert_equal COUNTS[:problem_objectives], ProblemObjective.count, "ProblemObjective count"
    assert_equal COUNTS[:problem_objectives], operation.problem_objectives.count, "Operation's ProblemObjective count"
    assert_equal COUNTS[:problem_objectives], plan.problem_objectives.count, "Plan's ProblemObjective count"
    ProblemObjective.all.each do |problem_objective|
      assert problem_objective.outputs.length >= 0
      assert problem_objective.outputs.length <= Output.count
      assert problem_objective.indicators.length >= 0
      assert problem_objective.indicators.length <= Indicator.count
    end

    assert_equal COUNTS[:outputs], Output.count, "Output count"
    assert_equal COUNTS[:outputs], operation.outputs.count, "Operation's outputs count"
    assert_equal COUNTS[:outputs], plan.outputs.count, "Plan's outputs count"
    Output.all.each do |output|
      assert output.indicators.length >= 0
      assert output.indicators.length <= Indicator.count
    end

    assert_equal COUNTS[:indicators], Indicator.count, "Indicator count"
    assert_equal COUNTS[:indicators], operation.indicators.count, "Operation's indicators count"
    assert_equal COUNTS[:indicators], plan.indicators.count, "Plan's indicators count"

    assert_equal COUNTS[:indicator_data], IndicatorDatum.count, "IndicatorDatum count"
    IndicatorDatum.all.each do |d|
      assert d.plan, "Must be a plan"
      assert d.ppg, "Must be a ppg"
      assert d.goal, "Must be a goal"
      assert d.rights_group, "Must be a rights group"
      assert d.problem_objective || d.output, "Must be either a obj or output"
      assert d.indicator, "Must be an indicator"
      assert d.operation, "Must be an operation"
    end

  end

  test "Parse operation_header FOCUS duplicates" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)
    parse_header(file, PLAN_TYPES)

    assert_equal COUNTS[:operations], Operation.count, "Operation count"
    Operation.all.each do |o|
      assert o.years.length >= 0
      assert o.name
      assert o.id
    end
  end
end

