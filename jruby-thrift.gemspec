# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jruby-thrift}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Evan Dowling"]
  s.date = %q{2011-02-20}
  s.description = %q{jruby-thrift is a gemified thrift binding what uses the java Thrift classes rather than a pure
                     ruby implementation.  It was developed to support the hyper_record gem and as such is not as 
                     thoroughly tested as it should be. Caveat Emptor}
  s.email = %q{dowling.evan@gmail.com}
  s.extra_rdoc_files = []
  s.files = ["README", "Rakefile", "LICENSE.txt", "lib/client.rb", "lib/core_ext.rb",
             "lib/data_structures.rb","lib/deserializer.rb","lib/serializer.rb","lib/exceptions.rb", 
             "lib/processor.rb","lib/protocols.rb","lib/serializer.rb","lib/servers.rb", 
             "lib/thrift.rb","lib/transports.rb","lib/types.rb", 
             "lib/libthrift.jar", "lib/slf4j-api-1.6.1.jar", "lib/slf4j-simple-1.6.1.jar"]
  s.homepage = %q{http://github.com/evandowling/jruby-trhift}
  s.rdoc_options = ["--main", "README.txt", "-SHN", "-f", "darkfish"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{jruby-extras}
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{Thrift binding for jruby using the Java thrift bindings in place of native extensions.}

end