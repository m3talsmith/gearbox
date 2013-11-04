require 'mongoid'
require 'pry'
module Gearbox
  class << self
    def included(base)
      base.send :include, Gearbox::InstanceMethods

      base.class_eval %(
        class << self
          attr_accessor :state_options, :state_tree, :state_triggers, :state_callbacks
        end
      )
      base.extend Gearbox::ClassMethods
    end
  end

  module InstanceMethods
    attr_accessor :gearbox_state_errors

    def state_errors
      @gearbox_state_errors ||= []
    end

    def state_options
      self.class.state_options
    end

    def start_state
      state_options[:start_state]
    end

    def state_tree
      self.class.state_tree
    end

    def set_state state_name
      self.state = state_name
      self.save
    end

    def transition options
      self.send options[:to]
    end

    def final_state state_name
      set_state state_name
    end
  end

  module ClassMethods
    # == Class#gearbox
    #
    # gearbox takes a hash of options, and a block with states, setting up the class and instance injection for the state machine
    #
    # === Examples
    #
    #   class Car
    #     include Gearbox
    #
    #     gearbox start_state: :parked do
    #       state :parked, callback: ->{
    #         transition :ignite
    #       }
    #
    #       state :ignite, callback: ->{
    #         transition :idling if brake? and clutch?
    #       }
    #
    #       state :idling, callback: ->{
    #         return self.current_state
    #       }
    #     end
    #
    #     def turn_on
    #       brake
    #       clutch
    #       ignite
    #     end
    #   end
    #
    # === Results
    #
    #   Car.state_options
    #   # => {start_state: :parked}
    #
    #   car = Car.new
    #
    #   car.current_state
    #   # => :parked
    #
    #   car.next_state
    #   # => :ignite
    #
    #   car.turn_on
    #   # => :idling
    #
    #   car.current_state
    #   # => :idling
    #
    #   car.previous_state
    #   # => :ignite
    def gearbox options={}
      raise Gearbox::MissingStates unless block_given?
      self.state_options ||= options
      self.send :field, :state, default: options[:start_state]
      yield
    end

    # == Class#state
    #
    # Takes one or multiple symbols (as symbol array) and stores the block as an intance method named after the state.
    # Takes an optional second argument of `if: method_name` where method_name is a predefined boolean instance method.
    #
    # === Examples
    # # Second parameter is optional.
    # state :parked, callback: ->{
    #   def callback
    #     transition_to :ignite, if: :safe_to_ignite?
    #   end
    # }
    # 
    # # self.responds_to(:park) == true
    #
    # state [:first, :second, :third, :fourth], callback: ->{
    #   def callback
    #     5.times{ honk! }
    #     transition to: :next_state     if clutch_pressed
    #     transition to: :previous_state if clutch_pressed
    #   end
    # }
    #
    # def safe_to_ignite?
    #   brake_pressed && clutch_pressed
    # end
    def state(states, options={})
      raise Gearbox::MissingStateBlock unless options[:callback]
      
      states   = [states] unless states.respond_to?(:each)
      callback = options[:callback]

      # == State triggers and callbacks
      #
      # Sets up class variables to store state triggers and callbacks ini order to call them later from an instance method which has the name of the state.
      #
      # === Examples
      #
      # gearbox do
      #   state :ignite, if: :can_ignite?, callback: ->{
      #     2.times {print 'Honk!'}
      #     transition :zoom_zoom
      #   }
      #
      #   state :zoom_zoom, callback: ->{
      #     puts "Heading home"
      #   }
      # end
      #
      # def can_ignite?
      #   return true
      # end
      @state_tree      ||= {}
      @state_triggers  ||= {}
      @state_callbacks ||= {}

      states.each do |state_name|
        ### Stores triggers and call backs for later usage in the below instance method being defined.
        @state_tree[state_name.to_sym]      = state_name
        @state_triggers[state_name.to_sym]  = options[:if]
        @state_callbacks[state_name.to_sym] = callback
        class_eval <<-OOM
          def #{state_name}
            trigger       = self.class.state_triggers[:#{state_name}]
            callback      = self.class.state_callbacks[:#{state_name}]
            error_message = 'Cannot trigger :#{state_name} state because conditions did not evaluate to true'

            if trigger
              if self.send(trigger)
                state_errors.delete(error_message)
                set_state :#{state_name}
                callback.call
                self.callback
              else
                state_errors.push(error_message)
              end
            else
              state_errors.delete(error_message)
              set_state :#{state_name}
              callback.call
              self.callback
            end
          end
        OOM
      end
    end

  end

  class MissingStates < Exception
    def message
      @gearbox_state_errors << "gearbox requires at least one state"
    end
  end

  class MissingStateBlock < Exception
    def message
      @gearbox_state_errors << "state requires at least one state_name and a block"
    end
  end

  class FailedCondition < Exception
    def message
      @gearbox_state_errors << "Cannot transition to the #{self.states} state from the #{self.current_state} state"
    end
  end
end
