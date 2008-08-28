#!/usr/env ruby

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
#
# == Author
#    Rob Myers <rob@robmyers.org>
#
# == Copyright
#    Copyright (C) 2008 Rob Myers. Licensed under the GNU GPL 3 or later.
#    http://www.gnu.org/licenses/gpl-3.0.html


require 'fileutils'
require 'optparse' 
require 'rdoc/usage'


class ArtProject
  VERSION = "0.0.1"
  
  def initialize (arguments)    
    @arguments = arguments

    # Here __FILE__ is the absolute path to the installed script
    @generator_dir = File.dirname(__FILE__) 
    @source_dir = File.dirname(@generator_dir)
    @template_dir = @source_dir + '/templates'
    
    @project_name = ''
    @project_license_id = ''
    @project_license_metadata = ''
    @project_license_full_text = ''
    @project_dir = ''
    @project_artist = ''
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
  
  def parsed_options?
    opts = OptionParser.new       
    opts.on('-v', '--version')  { output_version ; exit 0 }
    opts.on('-h', '--help')     { output_help }
    opts.on('-l', '--license')  do |license|
      @project_license_id << license || ''
    end       
    opts.on('-a', '--artist')  do |artist|
      @project_artist << artist || ''
    end       
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
    #TODO Check the licence id is valid
    true
  end
  
  def process_arguments
    @project_name = @arguments[0] # nil if unsupplied
    @project_dir = Dir.pwd + "/" + @project_name
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
    FileUtils.mkdir_p @project_dir
    FileUtils.mkdir_p @project_dir + "/discard"
    FileUtils.mkdir_p @project_dir + "/final"
    FileUtils.mkdir_p @project_dir + "/preparatory"
    FileUtils.mkdir_p @project_dir + "/releases"
    FileUtils.mkdir_p @project_dir + "/resources"
    FileUtils.mkdir_p @project_dir + "/script"
  end
  
  def make_script_link(name)
    script=@project_dir + "/script/" + name
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
    File.open(@project_dir + "/resources/license.xml", 'w') {|f| 
      f.write(@project_license_metadata) }
    File.open(@project_dir + "/COPYING", 'w') {|f| 
      f.write(@project_license_full_text) }
    File.open(@project_dir + "/README", 'w') {|f| 
      f.write(@project_name + " by " + @project_artist +
              ".\nSee COPYING for license.\n") }
    FileUtils.cp(@template_dir + "/template.svg", @project_dir + "/resources")
  end
  
  def process_command
    #get_license_details
    make_directories
    make_script_links
    make_files
  end
end

app = ArtProject.new(ARGV)
app.run
