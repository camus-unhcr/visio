require 'test_helper'

class IndicatorDataControllerTest < ActionController::TestCase
  def setup

    @s = strategies(:one)

    @plans = [plans(:one)]
    @ppgs = [ppgs(:one)]
    @rights_groups = [rights_groups(:one)]
    @goals = [goals(:one)]
    @pos = [problem_objectives(:one)]
    @outputs = [outputs(:one)]
    @indicators = [indicators(:one)]

    @s.plans << @plans
    @s.ppgs << @ppgs
    @s.rights_groups << @rights_groups
    @s.goals << @goals
    @s.problem_objectives << @pos
    @s.outputs << @outputs
    @s.indicators << @indicators

  end

  test "should get no indicator data" do
    get :index

    assert_response :success

    r = JSON.parse(response.body)

    assert_equal 0, r["new"].length
    assert_equal 0, r["updated"].length
    assert_equal 0, r["deleted"].length
  end

  test "should get one new indicator data" do
    datum = IndicatorDatum.new()
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.indicator = indicators(:one)
    datum.save

    get :index, { :strategy_id => @s.id }

    assert_response :success

    r = JSON.parse(response.body)

    assert_equal 1, r["new"].length
    assert_equal 0, r["updated"].length
    assert_equal 0, r["deleted"].length
  end
end