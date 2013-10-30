require 'spec_helper'

class GearboxTest < Test::Unit::TestCase
  
  def setup
    @f1 = Car.new
  end

  def teardown
    Car.destroy_all
  end

  def test_gearbox_raises_exception_without_block
    #REMINDER: You can't define a class in a block or method. This is how we get around that.
    class_def = %(
      class Car2
        include Mongoid::Document
        include Gearbox
        
        gearbox
      end
    )

    assert_raise Gearbox::MissingStates do
      eval(class_def)
    end
  end

  def test_gearbox_raises_exception_without_params
    #REMINDER: You can't define a class in a block or method. This is how we get around that.
    class_def = %(
      class Car3
        include Mongoid::Document
        include Gearbox
        
        gearbox do
          state :start
        end
      end
    )

    assert_raise Gearbox::MissingStateBlock do
      eval(class_def)
    end
  end

  def test_car_has_state_options
    assert_not_nil Car.state_options
  end

  def test_car_has_start_state_of_parked
    assert_equal :parked, Car.state_options[:start_state]
  end

  def test_car_parked
    assert_equal :parked, @f1.current_state
  end

  def test_car_brake_pressed
    assert_nil @f1.brake_pressed
    @f1.brake
    assert_equal true, @f1.brake_pressed
  end

  def test_car_clutch_pressed
    assert_nil @f1.clutch_pressed
    @f1.clutch
    assert_equal true, @f1.clutch_pressed
  end

  def test_turn_on_car
    error_message = 'Cannot trigger :ignite state because conditions did not evaluate to true'
    @f1.ignite
    assert_send [@f1.state_errors, :include?, error_message]
    @f1.turn_on
    # Turn_on is there, but it doesn't get out of park...
    #I think the ignite method is not modifying the state.
    # binding.pry
    assert_equal :ignite, @f1.state
    assert_not_send [@f1.state_errors, :include?, error_message]
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
