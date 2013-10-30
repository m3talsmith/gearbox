class Car
  include Mongoid::Document
  include Gearbox

  attr_accessor :brake_pressed, :clutch_pressed
  
  gearbox start_state: :parked do
    state :parked do
      can_transition_to :ignite
    end
    
    state :ignite, if: :safe_to_ignite? do
      binding.pry
      can_transition_to :idling
    end
    
    state :idling do
      can_transition_to :first_gear
    end
    
    state [:first, :second, :third, :fourth] do
      can_transition_to next_state
      can_transition_to previous_state
    end
    
    state :park do
      can_transition_to :parking
    end
    
    state :parking do
      brake
      clutch
      turn_off
      can_transition_to :parked
    end
  end
  
  def brake
    self.brake_pressed = true
    return true
  end
  
  def clutch
    self.clutch_pressed = true
    return true
  end
  
  def turn_off
    # turn off the engine
    return true
  end
  
  def turn_on
    brake
    clutch
    ignite
  end

  def safe_to_ignite?
    self.brake_pressed && self.clutch_pressed
  end

end
