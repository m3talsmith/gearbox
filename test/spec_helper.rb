require 'test/unit'
require 'mongo'
require 'mongoid'

#Make a simple document for test cases.
require_relative '../lib/gearbox.rb'
Mongoid.load!('test/dummy/config/database.yml', :test)
Dir['./test/dummy/app/models/**/*.rb'].each { |f| require f }
