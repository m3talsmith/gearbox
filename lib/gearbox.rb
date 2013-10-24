require 'mongoid'

module Gearbox
  class << self
    def included(base)
      base.extend         Gearbox::ClassMethods
      base.send :include, Gearbox::InstanceMethods
      base.send :field, :state
      base.class_eval %(
        class << self
          attr_accessor :state_options
          @state_options = {}
        end
      )
    end
  end

  module InstanceMethods
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
      self.state_options ||= options
      if !block_given?
        raise Gearbox::MissingStates
      end
      # yield
    end
  end

  class MissingStates < Exception
    def message
      "gearbox requires at least one state"
    end
  end
end
