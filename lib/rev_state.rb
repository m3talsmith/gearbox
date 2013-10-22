require 'mongoid'
require 'active_support/time'

module RevState

  def self.included(collection)
    collection.send :field, :some_field_name
  end

  self.config = {
    #Put library configs here. Or not.
  }

  def some_mixin_method
    'The document will inherit this'
  end

protected
  
  def some_support_method
    'Private methods can go here and they wont pollute the target document with irrelevant methods.'
  end

end
