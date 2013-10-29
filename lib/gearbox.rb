require 'mongoid'
#Feel free to delete this line if I forgot to do so- was doing some intense debugging. RC
require 'pry'
module Gearbox
  class << self
    def included(base)
      base.send :include, Gearbox::InstanceMethods
      base.send :field, :state

      base.class_eval %(
        class << self
          attr_accessor :state_options, :state_triggers, :state_callbacks
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

    def current_state
      self.state = start_state unless self.state
      self.state
    end
  end

  module ClassMethods
    # == Class#gearbox
    #
    # gearbox takes a hash of options, and a block with states, setting up the class and instance injection for the state machine
    #
    # -- Examples
    #
    #   class Car
    #     include Gearbox
    #
    #     gearbox start_state: :parked do
    #       state :parked do
    #         transition to: :ignite
    #       end
    #
    #       state :ignite do
    #         transition to: :idling if brake? and clutch?
    #       end
    #
    #       state :idling do
    #         return self.current_state
    #       end
    #     end
    #
    #     def turn_on
    #       brake
    #       clutch
    #       ignite
    #     end
    #   end
    #
    # -- Results
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
      yield
    end

    # == Class#state
    #
    # Takes one or multiple symbols (as symbol array) and stores the block as an intance method named after the state.
    # Takes an optional second argument of `if: method_name` where method_name is a predefined boolean instance method.
    #
    # -- Examples
    # # Second parameter is optional.
    # state :parked do
    #   transition_to :ignite, if: :safe_to_ignite?
    # end
    # 
    # # self.responds_to(:park) == true
    #
    # state [:first, :second, :third, :fourth] do
    #   5.times{ honk! }
    #   transition_to :next_state     if clutch_pressed
    #   transition_to :previous_state if clutch_pressed
    # end
    #
    # def safe_to_ignite?
    #   brake_pressed && clutch_pressed
    # end
    def state(states, triggers=nil, &callback)
      raise Gearbox::MissingStateBlock unless block_given?
      
      states = [states] unless states.respond_to?(:each)
      triggers ||= {}

      # == State triggers and callbacks
      #
      # Sets up class variables to store state triggers and callbacks ini order to call them later from an instance method which has the name of the state.
      #
      # === Examples
      #
      # gearbox do
      #   state :ignite, if: :can_ignite? do
      #     2.times {print 'Honk!'}
      #     transition to: :zoom_zoom
      #   end
      #
      #   state :zoom_zoom do
      #     puts "Heading home"
      #   end
      # end
      #
      # def can_ignite?
      #   return true
      # end
      @state_triggers  ||= {}
      @state_callbacks ||= {}

      states.each do |state_name|
        ### stores triggers and call backs for later usage in the below instance method being defined.
        @state_triggers[state_name.to_sym]  = triggers[:if]
        @state_callbacks[state_name.to_sym] = callback
        class_eval <<-OOM
          def #{state_name}
            trigger = self.class.state_triggers[:#{state_name}]
            callback = self.class.state_callbacks[:#{state_name}]

            if trigger && self.send(trigger)
              callback.call
            else
              state_errors.push('Cannot trigger :#{state_name} state because conditions did not evaluate to true')
            end
          end
        OOM
      end
    end

    # == Class#transition_to
    #
    # transition_to receives a symbol of a desired next step and updates the current_step to the the next_step. Note that separate logic may govern whether or not this method is called
    #
    # -- Examples
    #
    # 
    # def transition_to next_state
    #   self.state = next_state.to_sym
    # end
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
