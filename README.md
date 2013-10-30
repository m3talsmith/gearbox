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
        can_transition_to :ignite if brake? && clutch?
      end
      
      state :ignite do
        can_transition_to :idling
      end
      
      state :idling do
        can_transition_to :first_gear if clutch?
      end
      
      state [:first, :second, :third, :fourth] do
        can_transition_to next_state     if clutch?
        can_transition_to previous_state if clutch?
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