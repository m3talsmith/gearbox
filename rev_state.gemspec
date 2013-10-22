Gem::Specification.new do |s|
  s.name        = 'rev_state'
  s.version     = '1.0.0'
  s.summary     = 'A state machine for Mongoid by the nice folks at RevSpring Inc.'
  s.date        = '2013-10-21'
  s.description = 'Mixin that provides state machine support for Mongoid documents'
  s.authors     = ['Rick Carlino', 'Brett Byler', 'Michael Cristenson']
  s.license     = 'Private Use'
  s.email       = 'webview@revspringinc.com'
  s.homepage    = 'https://github.com/RevSpringPhoenix/revstate'
  s.files       = ['lib/rev_state.rb']

  s.add_runtime_dependency 'bson_ext'
  s.add_runtime_dependency 'mongo'
  s.add_runtime_dependency 'mongoid'
  s.add_runtime_dependency 'active_support/time'

  s.add_development_dependency 'bson_ext'
  s.add_development_dependency 'mongo'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'mongoid'
  s.add_development_dependency 'sdoc'
end