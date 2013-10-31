class Car
  include Mongoid::Document
  include Gearbox

  attr_accessor :brake_pressed, :clutch_pressed
  
  gearbox start_state: :parked do
    state :parked, callback: ->{
      def callback
        transition to: :ignite
      end
    }
    
    state :ignite, if: :safe_to_ignite?, callback: ->{
      def callback
        puts "safe_to_ignite?: #{safe_to_ignite?}"
        transition to: :idling
      end
    }
    
    state :idling, callback: ->{
      def callback
        puts 'idling'
        # transition :first_gear
      end
    }

    # state [:first, :second, :third, :fourth], callback: ->{
    # }
    # 
    # state :park, callback: ->{
    #   transition to: :parking
    # }
    # 
    # state :parking, callback: ->{
    #   brake
    #   clutch
    #   turn_off
    #   transition to: :parked
    # }
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
    puts "[in_instance] state: #{self.state}"
    return (self.brake_pressed && self.clutch_pressed) || false
  end

end
