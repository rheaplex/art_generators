Gem::Specification.new do |s|
   s.name = %q{art_generators}
   s.version = "0.0.1"
   s.authors = ["Rob Myers"]
   s.email = %q{rob@robmyers.org}
   s.summary = %q{art_generators provides rails-style generators for managing a digital art project.}
   s.homepage = %q{http://www.robmyers.org/}
   s.description = %q{art_generators provides rails-style generators for managing a digital art project.}
   s.files = [ "README", "Changelog", "COPYING", "bin/art_project", 
   	       "generator/project.rb", "generator/release.rb", 
	       "generator/web.rb", "generator/work.rb",
	       "templates/template.svg"]
   s.executables = ['art_project']
end 