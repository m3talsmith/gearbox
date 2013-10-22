require 'mongoid'

module Gearbox

  def self.included(collection)
    collection.send :field, :state
    self.send :include, Gearbox::IncludedMethods
    self.send :extend,  Gearbox::ClassMethods
  end

  module IncludedMethods
    def state states
    end

    def transition options
    end
  end

  module ClassMethods
    def gearbox options
    end
  end
protected
  
  def some_support_method
    'Private methods can go here and they wont pollute the target document with irrelevant methods.'
  end

end
