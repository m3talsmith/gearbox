Gearbox
===

A state machine that's made from ground up to automate state transitions.


Examples:
---
```ruby

  class F1 < Car
    include Mongoid::Document
    include Gearbox
    
    gearbox start_state: :parked do
      state :parked do
        transition :ignite if brake? && clutch?
      end
      
      state :ignite do
        transition :idling
      end
      
      state :idling do
        transition :first_gear if clutch?
      end
      
      state [:first, :second, :third, :fourth] do
        transition next_state     if clutch?
        transition previous_state if clutch?
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
      # press down brake
    end
    
    def clutch
      # press down clutch
    end
    
    def turn_off
      # turn of the key
    end
    
    def turn_on
      brake
      clutch
      ignite
    end
  end
```