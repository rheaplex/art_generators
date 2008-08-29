#    art_generators - create and manage digital art project directory structures
#    Copyright (C) 2008 Rob Myers
# 
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
# 
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#    GNU General Public License for more details.
# 
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.

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