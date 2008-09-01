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
#    Copies an existing work (or the project template) to start a new work.
#
# == Examples
#    Create an artwork called flowers based on a work called leaves.svg:
#    art_project -c leaves.svg flowers.svg
#
# == Usage
#    work [options] work_name
#
#    For help use: art_work -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display version number
#   -c, --copy        Base on this work
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

class ArtWork
  VERSION = "0.0.1"
  
  def initialize(arguments)    
    @arguments = arguments
    
    # Here __FILE__ is the path to the symbolic link to the script
    @project_dir = $project_dir
    @project_name = File.basename(@project_dir)
    @work_dir = "#{@project_dir}/preparatory"
    @resource_dir = "#{@project_dir}/resources"
    @source_work_name = "#{@resource_dir}/template.svg"
    @destination_work_name = nil
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
    opts.on('-v', '--version')        { output_version ; exit 0 }
    opts.on('-h', '--help')           { output_help }
    opts.on('-c FILE', '--copy FILE') do |source|
      @source_work_name = "#{@work_dir}/#{source}" || 
        "#{@resource_dir}/template.svg"
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
    if @arguments.length != 1
      puts "No work file name specified."
      return false
    end
    # And the argument refers to an existing file
    return true
  end
  
  def process_arguments
    @destination_work_name = "#{@work_dir}/#{@arguments[0]}"
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
  
  def make_work_file
    FileUtils.cp(@source_work_name, 
                 @destination_work_name)
  end
   
  def using_git?
    File.exists?("#{@project_path}/.git")
  end
   
  def using_svn?
      File.exists?("#{@project_path}/.svn")
  end

  def add_work_to_version_control
    Kernel.system("git", "add", "#{@destination_work_name}") if using_git?
    Kernel.system("svn", "add", "#{@destination_work_name}") if using_svn?
  end

  def process_command
    if ! File.exists?(@source_work_name)
      puts "File doesn't exist #{@source_work_name}"
      exit 1
    end
    if File.exists?(@destination_work_name)
      puts "File already exists #{@destination_work_name}"
      exit 1
    end
    make_work_file
    add_work_to_version_control
  end
end

app = ArtWork.new(ARGV)
app.run
