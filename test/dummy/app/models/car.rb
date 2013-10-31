class Car
  include Mongoid::Document
  include Gearbox

  attr_accessor :brake_pressed, :clutch_pressed
  
  gearbox start_state: :parked do
    state :parked do
      transition :ignite
    end
    
    state :ignite, if: :safe_to_ignite? do
      binding.pry
      transition :idling
    end
    
    state :idling do
      transition :first_gear
    end
    
    state [:first, :second, :third, :fourth] do
      transition next_state
      transition previous_state
    end
    
    state :park do
      transition :parking
    end
    
    state :parking do
      brake
      clutch
      turn_off
      transition :parked
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
