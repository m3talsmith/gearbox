require 'spec_helper'

class GearboxTest < Test::Unit::TestCase
  
  def setup
    @f1 = Car.new
  end

  def teardown
    Car.destroy_all
  end

  def test_car_parked
    assert_equal :parked, @f1.state
  end

  def test_turn_on_car
    error_message = 'Cannot transition to the :ignite state from the :parked state'
    @f1.ignite
    assert @f1.state_errors.include(error_message)
    @f1.turn_on
    assert_equal false, @f1.state_errors.include(error_message)
    assert_equal :ignite, @f1.state
  end

  def test_park_car
  end

  def test_shift_to_first_gear
  end

  def test_shift_to_next_gear
  end

  def test_shift_to_previous_gear
  end

  def test_cannot_skip_gears
  end

  def test_cannot_shift_without_clutch
  end

  def test_cannot_ignite_without_brake_and_clutch
  end
end
