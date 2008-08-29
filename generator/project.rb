#!/usr/env ruby

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

# == Synopsis
#    Creates a directory structure for an SVG-based art project
#    and populates it with useful resources and scripts.
#
# == Examples
#    Create a project called flowers:
#    art_project flowers
#
# == Usage
#    art_project [options] project_name
#
#    For help use: art_project -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display version number
#   -a, --artist        Your name
#   -l, --license       Set the Creative Commons license URL for the project
#   -g, --git           Use the git version control system for the project
#   -d, --date          The year(s) for the copyright message
#
#
# == Author
#    Rob Myers <rob@robmyers.org>
#
# == Copyright
#    Copyright (C) 2008 Rob Myers. Licensed under the GNU GPL 3 or later.
#    http://www.gnu.org/licenses/gpl-3.0.html


require 'fileutils'
require 'optparse' 
require 'ostruct'
require 'rdoc/usage'
#require 'liblicense'

class ArtProject
  VERSION = "0.0.1"
  
  def initialize (arguments)    
    @arguments = arguments

    # Here __FILE__ is the absolute path to the installed script
    @generator_dir = File.dirname(__FILE__) 
    @source_dir = File.dirname(@generator_dir)
    @template_dir = @source_dir + '/templates'
    
    initialize_project_details
  end
  
  def run
    if parsed_options? && arguments_valid? 
      process_arguments            
      process_command
    else
      output_usage
    end
  end
  
  protected
  
  def initialize_project_details
    @project = OpenStruct.new
    @project.name = ''
    @project.license_id = ''
    @project.license_metadata = ''
    @project.license_full_text = ''
    @project.dir = ''
    @project.artist = ''
    @project.use_git = false
    @project.use_svn = false
  end
  
  def parsed_options?
    opts = OptionParser.new       
    opts.on('-v', '--version')  { output_version ; exit 0 }
    opts.on('-h', '--help')     { output_help }
    opts.on("-g", "--git")      {|git| @project.use_git << git}
    #opts.on("-s", "--svn")     {|svn| @project.use_svn << svn}
    #opts.on('-l LICENSE', '--license LICENSE')  do |license|
    #  @project.license_id << license
    #end 
    opts.on('-a', '--artist')  { |artist| @project.artist << artist }
    opts.on("-d DATE", "--date DATE") {|date| @project.date << date}
    # This consumes matched arguments from @arguments
    opts.parse!(@arguments) rescue return false
    process_options
    true      
  end
  
  def process_options
  end
  
  def output_options
    puts "Options:\\n"
    @options.marshal_dump.each do |name, val|        
      puts "  #{name} = #{val}"
    end
  end
  
  def arguments_valid?
    if @arguments[0] == nil
      return false
    end
    #if @project.git && @project.svn
    #  puts "Both git and svn specified. Please one or the other, not both."
    #  return false
    #end
    #TODO Check the licence id is valid
    true
  end
  
  def process_arguments
    @project.name = @arguments[0] # nil if unsupplied
    @project.dir = Dir.pwd + "/" + @project.name
  end
  
  def output_help
    output_version
    RDoc::usage() # exits application
  end
  
  def output_usage
    RDoc::usage('usage')
  end
  
  def output_version
    puts "#{File.basename(__FILE__)} version #{VERSION}"
  end
  
  def get_license_details
    #TODO Get the RDF metadata
    #TODO Get the full text of the license (or the non-web text?)
  end
  
  def make_directories
    if File.exists? @project.dir
      die "Cannot create project. Directory named {@project.dir} already exists. Please rename or move the existing directory."
    end
    FileUtils.mkdir_p @project.dir
    FileUtils.mkdir_p @project.dir + "/discard"
    FileUtils.mkdir_p @project.dir + "/final"
    FileUtils.mkdir_p @project.dir + "/preparatory"
    FileUtils.mkdir_p @project.dir + "/releases"
    FileUtils.mkdir_p @project.dir + "/resources"
    FileUtils.mkdir_p @project.dir + "/script"
  end
  
  def make_script_link(name)
    script=@project.dir + "/script/" + name
    File.open(script, 'w') {|f| 
      f.puts("#!/usr/bin/env ruby")
      f.puts("$project_dir=File.dirname(File.dirname(File.expand_path(__FILE__)))")
      f.puts("require '" + @generator_dir + "/" + name + ".rb'")
      File.chmod(0700, script)}
  end
  
  def make_script_links
    make_script_link("release")
    make_script_link("web")
    make_script_link("work")
  end
  
  def make_files
    File.open(@project.dir + "/resources/license.xml", 'w') {|f| 
      f.write(@project.license_metadata) }
    File.open(@project.dir + "/COPYING", 'w') {|f| 
      f.write(@project.license_full_text) }
    File.open(@project.dir + "/README", 'w') {|f| 
      f.write(@project.name + " by " + @project.artist +
              ".\nSee COPYING for license.\n") }
    FileUtils.cp(@template_dir + "/template.svg", @project.dir + "/resources")
  end
  
  def initialize_version_control
    Kernel.system('git-init') if @project.use_git
    #Kernel.system('svn-init') if @project.use_svn
  end
  
  def process_command
    #get_license_details
    make_directories
    make_script_links
    make_files
    initialize_version_control
  end
end

app = ArtProject.new(ARGV)
app.run
