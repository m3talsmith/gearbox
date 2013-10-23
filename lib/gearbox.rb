require 'mongoid'

module Gearbox
  class << self
    def included(base)
      base.extend Gearbox::ClassMethods
      base.send   :field, :state
      base.class_eval %(
        class << self
          attr_accessor :state_options
          @state_options = {}
        end
      )
    end
  end

  module ClassMethods
    def gearbox options={}
      self.state_options ||= options
    end
  end
end
