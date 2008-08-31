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
#   -g, --git URL       Use the git version control system for the project
#   -s, --svn URL       Use the svn version control system for the project
#   -d, --date          The year(s) for the copyright message
#
# == Author
#    Rob Myers <rob@robmyers.org>
#
# == Copyright
#    Copyright (C) 2008 Rob Myers. Licensed under the GNU GPL 3 or later.
#    http://www.gnu.org/licenses/gpl-3.0.html


require 'fileutils'
#require 'liblicense'
require 'optparse' 
require 'ostruct'
require 'rdoc/usage'
require 'yaml'

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
    @project.unix_name = ''
    @project.artist = ''
    @project.remote_repository = nil
    @project.use_git = false
    @project.use_svn = false
    @project.license_uri = ''
    
    # Don't save to the yaml in case the directory is moved by the user
    @project_dir = ''
    @version_control_dir = ''
  end
  
  def parsed_options?
    opts = OptionParser.new       
    opts.on('-v', '--version')  { output_version ; exit 0 }
    opts.on('-h', '--help')     { output_help }
    opts.on("-g", "--git URI")  do |uri| 
      @project.use_git = true
      @project.remote_repository = uri
    end
    opts.on("-s", "--svn URI")  do |uri| 
      @project.use_svn = true
      @project.remote_repository = uri
    end 
    #opts.on('-l LICENSE', '--license URI')  do |license|
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
    if @arguments.length != 1
      puts "No project name specified."
      return false
    end
    if @project.use_git && @project.use_svn
      puts "Both git and svn specified. Please one or the other, not both."
      return false
    end
    if @project.use_git
      if @project.remote_repository.rindex('.git') == nil
        puts "git uri must be of the format: ssh://git.com/var/git/project.git"
        return false
      end
    end
    if @project.use_svn
      if @project.remote_repository.rindex(@project.unix_name) == nil
        puts "svn uri must end with project name"
        return false
      end
    end
    #TODO Check the licence id is valid
    true
  end
  
  def process_arguments
    @project.name = @arguments[0] # nil if unsupplied
    # Make a safe UNIX filename
    #TODO: Improve this
    @project.unix_name = @project.name.downcase.gsub(/ \//, '_')        
    @version_control_dir = Dir.pwd + '/' + @project.unix_name
    @project_dir = @version_control_dir
    if @project.use_svn
      @project_dir += '/trunk'
    end  
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
    if File.exists? @project_dir
      puts "Cannot create project. Directory named #{@project_dir} already exists. Please rename or move the existing directory."
      exit 1
    end
    
    FileUtils.mkdir_p @project_dir
    
    if @project.use_svn
      FileUtils.mkdir_p @version_control_dir + '/branches'
      FileUtils.mkdir_p @version_control_dir + '/tags'
    end
    
    
    FileUtils.mkdir_p @project_dir + "/discard"
    FileUtils.mkdir_p @project_dir + "/final"
    FileUtils.mkdir_p @project_dir + "/preparatory"
    FileUtils.mkdir_p @project_dir + "/releases"
    FileUtils.mkdir_p @project_dir + "/resources"
    FileUtils.mkdir_p @project_dir + "/script"
  end
  
  def make_script_link(name)
    script="#{@project_dir}/script/#{name}"
    File.open(script, 'w') {|f| 
      f.puts("#!/usr/bin/env ruby")
      f.puts("$project_dir=File.dirname(File.dirname(File.expand_path(__FILE__)))")
      f.puts("require '#{@generator_dir}/#{name}.rb'")
      File.chmod(0700, script)}
  end
  
  def make_script_links
    make_script_link("move")
    make_script_link("release")
    make_script_link("web")
    make_script_link("work")
  end
  
  def make_files
    #File.open("#{@project_dir}/resources/license.xml", 'w') {|f| 
    #  f.write(@project.license_metadata) }
    File.open("#{@project_dir}/COPYING", 'w') do |f| 
      f.write("See: ")
      f.write(@project.license_uri)
    end
    File.open("#{@project_dir}/README", 'w') do |f| 
      f.write("#{@project.name}")
      if @project.artist != ''
        f.write("by #{@project.artist}\name")
      end
      f.write("\nSee COPYING for license.\n")
    end
    FileUtils.cp("#{@template_dir}/template.svg", "#{@project_dir}/resources")
    File.open("#{@project_dir}/resources/configuration.yaml", 'w') do |f|
      f.write(@project.marshal_dump.to_yaml)
    end
  end
  
  def initialize_version_control
    if @project.use_git
      # Need to make sure we cd .. if something fails
      File.cd(@version_Control_dir)
      Kernel.system('git', 'init')
      Kernel.system('git', 'add', '.')
      Kernel.system('git', 'commit')
      Kernel.system('git', 'remote', 'add', 'origin', 
                    @project.remote_repository)
      Kernel.system('git', 'push', 'origin', 'master')
      file.cd('..')
   end
     if @project.use_svn
       Kernel.system('svn', 'import', @version_control_dir, 
                     @project.remote_repository,
                     "-m", "Checkin of generated directory structure.")
       FileUtils.remove_entry_secure(@version_control_dir)
       Kernel.system('svn', 'checkout', @project.remote_repository,
                     @project.name)
     end
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
