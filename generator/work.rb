#!/usr/env ruby

require 'fileutils'
require 'optparse' 
require 'rdoc/usage'

# == Synopsis
#    Copies an existing work (or the project template) to start a new work.
#
# == Examples
#    Create an artwork called flowers based on a work called leaves.svg:
#    art_project -c leaves.svg flowers.svg
#
# == Usage
#    art_work [options] work_name
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
    opts.on('-v', '--version')  { output_version ; exit 0 }
    opts.on('-h', '--help')     { output_help }
    opts.on('-c FILE', '--copy FILE')     do |source|
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
    @arguments.length == 1
    # And the argument refers to an existing file
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
  
  def make_work
    FileUtils.cp(@source_work_name, 
                 @destination_work_name)
  end
  
  def process_command
    make_work
  end
end

app = ArtWork.new(ARGV)
app.run
