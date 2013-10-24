class Car
  include Mongoid::Document
  include Gearbox
  
  gearbox start_state: :parked do
    state :parked do
      transition to: :ignite if brake? && clutch?
    end
    
    state :ignite do
      transition to: :idling
    end
    
    state :idling do
      transition to: :first_gear if clutch?
    end
    
    state [:first, :second, :third, :fourth] do
      transition to: next_state     if clutch?
      transition to: previous_state if clutch?
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
    # press down brake
    return true
  end
  
  def clutch
    # press down clutch
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
