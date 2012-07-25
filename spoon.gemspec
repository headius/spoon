Gem::Specification.new do |s|
  s.name = "spoon"
  s.version = "0.0.2"
  s.authors = ["Charles Oliver Nutter"]
  s.date = "2012-04-20"
  s.description = s.summary = "Spoon is an FFI binding of the posix_spawn function (and Windows equivalent), providing fork+exec functionality in a single shot."
  s.files = "lib/spoon.rb"
  s.require_paths = ["lib"]
  s.add_dependency('ffi') unless defined?(JRUBY_VERSION) # JRuby includes ffi
end
