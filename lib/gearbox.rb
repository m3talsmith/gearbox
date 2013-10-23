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
    def gearbox options={}
      self.state_options ||= options
    end
  end
end
