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

require 'fileutils'
require 'optparse' 
require 'rdoc/usage'

# == Synopsis
#    Moves an existing work (or the project template) to another folder in the
#    project, changing its status, and inform the version control system of the
#    change if using one.
#
# == Examples
#    Move an artwork called flowers.svg to the final folder:
#    move --final flowers.svg
#
# == Usage
#    move [options] work_name
#
#    For help use: art_work -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display version number
#   -d, --discard       Move to the discard directory
#   -f, --final         Move to the final directory (default)
#   -p, --preparatory   Move to the preparatory directory
#
# == Author
#    Rob Myers <rob@robmyers.org>
#
# == Copyright
#    Copyright (C) 2008 Rob Myers. Licensed under the GNU GPL 3 or later.
#    http://www.gnu.org/licenses/gpl-3.0.html

class Move
  VERSION = "0.0.1"
  
  def initialize(arguments)    
    @arguments = arguments
    
    # Here __FILE__ is the path to the symbolic link to the script
    @project_dir = $project_dir
    @project_name = File.basename(@project_dir)
    @status = "final"
    @work = nil
    @destination = nil
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
    opts.on('-d', '--discard')          { @status = 'discard' }
    opts.on('-f', '--final')          { @status = 'final' }
    opts.on('-p', '--preparatory')    { @status = 'preparatory' }
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
    @arguments.length == 1
    # And the argument refers to an existing file
  end
  
  def file_of_status file, status
    "#{status}/#{File.basename(file)}"
  end
    
  def file_path_in_project name
    # Default to preparatory if no directory provided
    if name.index('/') == nil
      "preparatory/" + name
    else
      name
    end
  end
  
  def process_arguments
    @work = file_path_in_project @arguments[0]
    @destination = file_of_status @work, @status
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
  
  def change_work_status
    FileUtils.mv(@work, 
                 @destination)
  end
   
  def using_git?
    File.exists?("#{@project_path}/.git")
  end
   
  def using_svn?
      File.exists?("#{@project_path}/.svn")
  end

  def move_work_in_version_control
    Kernel.system("git mv #{@work} #{@destination}") if using_git?
    Kernel.system("svn mv #{@work} #{@destination}") if using_svn?
  end

  def process_command
    if File.exists? @destination
      puts "File already exists #{@destination}"
      exit 1
    end
    change_work_status
    move_work_in_version_control
  end
end

app = Move.new(ARGV)
app.run
