class Car
  include Mongoid::Document
  include Gearbox

  attr_accessor :brake_pressed, :clutch_pressed, :running
  
  gearbox start_state: :parked do
    state :parked, callback: ->{
      def callback
        transition to: :ignite
      end
    }
    
    state :ignite, if: :safe_to_ignite?, callback: ->{
      def callback
        self.running = true
        # transition to: :idling
      end
    }
    
    state :idling, callback: ->{
      def callback
        puts 'idling'
      end
    }
    
    state :park, if: :safe_to_park?, callback: ->{
      def callback
        transition to: :parking
      end
    }
    
    state :parking, callback: ->{
      def callback
        brake
        clutch
        turn_off
        final_state :parked
      end
    }
  end
  
  def brake
    self.brake_pressed = true
  end
  
  def clutch
    self.clutch_pressed = true
  end
  
  def turn_off
    self.running = false
  end
  
  def turn_on
    brake
    clutch
    ignite
  end

  def safe_to_ignite?
    return (self.brake_pressed && self.clutch_pressed) || false
  end

  def safe_to_park?
    return self.running || false
  end

end
