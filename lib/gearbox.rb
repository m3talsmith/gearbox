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
    # state receives either a symbol or an array of symbols and sends each state to an instance method that may be called. 
    #
    # -- Examples
    #
    # state :parked do
    #   transition_to :ignite if brake_pressed && clutch_pressed
    # end
    #
    # state [:first, :second, :third, :fourth] do
    #   transition_to :next_state     if clutch_pressed
    #   transition_to :previous_state if clutch_pressed
    # end  
    def state states, trigger=nil, &callback
      raise Gearbox::MissingStateBlock unless block_given?

      states = [states] unless states.respond_to?(:each)
      states.each do |state_name|
        if trigger
          @methods = <<-END
            def #{state_name}
              if instance_eval("#{trigger}")
                #{callback}.call
              else
                self.state_errors << 'Cannot trigger :#{state_name} state because conditions did not evaluate to true'
              end
            end
          END
        else
          @methods = <<-END
            def #{state_name}
              yield
            end
          END
        end
        puts @methods
        class_eval @methods
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
