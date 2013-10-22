Gem::Specification.new do |s|
  s.name        = 'gearbox'
  s.version     = '0.0.1'
  s.summary     = 'A state machine that is made from ground up to automate state transitions'
  s.date        = '2013-10-21'
  s.description = 'A state machine that is made from ground up to automate state transitions'
  s.authors     = ['Rick Carlino', 'Brett Byler', 'Michael Cristenson']
  s.license     = 'Private Use'
  s.email       = 'webview@revspringinc.com'
  s.homepage    = 'https://github.com/RevSpringPhoenix/gearbox'
  s.files       = ['lib/gearbox.rb']

  s.add_runtime_dependency 'bson_ext'
  s.add_runtime_dependency 'mongo'
  s.add_runtime_dependency 'mongoid'

  s.add_development_dependency 'bson_ext'
  s.add_development_dependency 'mongo'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'mongoid'
  s.add_development_dependency 'sdoc'
end
