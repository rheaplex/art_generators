#!/usr/env ruby

require 'optparse' 
require 'rdoc/usage'

# == Synopsis
#    Creates a tar.gz archive of the files that will be publicly released.
#
# == Examples
#    Create an archive:
#    art_release
#
# == Usage
#    art_release [options]
#
#    For help use: art_project -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display version number
#   -f, --file          Set the release file name (.tar.gz suffix optional)
#
# == Author
#    Rob Myers <rob@robmyers.org>
#
# == Copyright
#    Copyright (C) 2008 Rob Myers. Licensed under the GNU GPL 3 or later.
#    http://www.gnu.org/licenses/gpl-3.0.html

class ArtRelease
  VERSION = "0.0.1"
  
  def initialize (arguments)    
    @arguments = arguments

    
    @script_dir = File.dirname(File.expand_path(__FILE__))
    @project_dir = File.dirname(@script_dir)
    @project_name = File.basename(@project_dir)
    @archive_dir = @project_dir + "/archives"
    @archive_file = ''
  end
  
  def run
    if parsed_options?           
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
    opts.on('-f FILENAME', '--file FILENAME')     do |file|
      @archive_file << @archive_dir + file || "#(@archive_dir)/#(@project_name)"
    end       
    # This consumes matched arguments from @arguments
    opts.parse!(@arguments) rescue return false
    process_options
    true      
  end
  
  def process_options
    if ! (@archive_file.ends_with ".tar.gz" ||
          @archive_file.ends_with ".tgz")
    @archive_file += "tar.gz"
    end
  end
  
  def output_options
    puts "Options:\\n"
    @options.marshal_dump.each do |name, val|        
      puts "  #{name} = #{val}"
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
  
  def make_archive
    dir = "../../#(@project_name)".
    result = Kernel.system ("tar -zcvf \"#(@archive_file)\" \"#(dir)/README \"#(dir)/COPYING\" \"#(dir)/discard\" \"#(dir)/final\" \"#(dir)/preparatory\"")
    if ! result
      die "Failed to create archive."
    end
  end
  
  def process_command
    make_archive
  end
end

app = ArtRelease.new(ARGV)
app.run
