require 'test_helper'

class PlanTest < ActiveSupport::TestCase

  test "get impact indicators" do
    p = plans(:one)
    p.indicators << [indicators(:one), indicators(:two)]
    p.save

    i = p.impact_indicators

    assert_equal 1, i.length
    assert_equal false, i[0].is_performance

  end

  test "synced models no date" do
    models = Plan.synced_models

    assert_equal 0, models[:deleted].count
    assert_equal 0, models[:updated].count
    assert_equal 2, models[:new].count
  end

  test "synced model with date" do
    p = [plans(:one), plans(:two), plans(:deleted)]

    # Updated
    p[1].created_at = Time.now - 1.week

    p.map(&:save)

    models = Plan.synced_models(Time.now - 3.days)

    assert_equal 1, models[:new].count
    assert_equal 1, models[:updated].count
    assert_equal 1, models[:deleted].count

    assert_equal p[0].operation_name, models[:new][0].operation_name
    assert_equal p[1].operation_name, models[:updated][0].operation_name
    assert_equal p[2].operation_name, models[:deleted][0].operation_name
  end

  test "models with join_ids" do
    i = [plans(:one), plans(:two), plans(:deleted)]
    s = strategies(:one)

    i[1].strategies << s

    i.map(&:save)

    models = Plan.models({ :strategy_id => s.id })

    assert_equal 1, models.count
    assert_equal i[1].name, models[0].name
  end

  test "synced models with join_ids" do
    i = [plans(:one), plans(:two), plans(:deleted)]
    s = strategies(:one)

    i[1].strategies << s

    i.map(&:save)

    models = Plan.synced_models(Time.now - 3.days, { :strategy_id => s.id })

    assert_equal 1, models[:new].count
    assert_equal i[1].name, models[:new][0].name

    i[0].strategies << s
    i[1].created_at = Time.now - 1.week
    i.map(&:save)

    models = Plan.synced_models(Time.now - 3.days, { :strategy_id => s.id })

    assert_equal 1, models[:new].count
    assert_equal i[0].name, models[:new][0].name
    assert_equal 1, models[:updated].count
    assert_equal i[1].name, models[:updated][0].name
  end

  test "synced models with multiple join_ids" do
    i = [plans(:one), plans(:two), plans(:deleted)]
    s = strategies(:one)
    s2 = strategies(:two)

    i[0].strategies << s
    i[1].strategies << s2

    i.map(&:save)

    models = Plan.synced_models(Time.now - 3.days, { :strategy_id => [s.id, s2.id] })

    assert_equal 2, models[:new].count
  end
end
