require 'test/unit'
require 'mongo'
require 'mongoid'
require 'pry'

#Make a simple document for test cases.
require_relative '../lib/state_machine.rb'
Mongoid.load!('test/database.yml', :test)

class StateCollection
  include Mongoid::Document
  include RevState

end
