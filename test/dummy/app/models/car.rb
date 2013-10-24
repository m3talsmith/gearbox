class Car
  include Mongoid::Document
  include Gearbox

  attr_accessor :brake_pressed, :clutch_pressed
  
  gearbox start_state: :parked do
    state :parked do
      transition to: :ignite
    end
    
    state :ignite, 'self.brake_pressed && self.clutch_pressed' do
      transition to: :idling
    end
    
    state :idling do
      transition to: :first_gear
    end
    
    state [:first, :second, :third, :fourth] do
      transition to: next_state
      transition to: previous_state
    end
    
    state :park do
      transition to: :parking
    end
    
    state :parking do
      brake
      clutch
      turn_off
      transition to: :parked
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
    # turn of the key
    return true
  end
  
  def turn_on
    brake
    clutch
    ignite
  end
end
