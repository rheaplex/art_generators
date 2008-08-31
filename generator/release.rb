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

require 'date'
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
#    release [options]
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
    @tag = "release_#{Date::today.to_s}"
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
    opt.on('-t TAG', '--tag TAG') do |tag|
      @tag = tag
    end
    # This consumes matched arguments from @arguments
    opts.parse!(@arguments) rescue return false
    process_options
    true      
  end
  
  def process_options
    if ! (@archive_file.index(".tar.gz") != nil) ||
          (@archive_file.index(".tgz") != nil)
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

  def using_git?
    File.exists("#{@project.project_path}/.git")
  end
   
  def using_svn?
    File.exists("#{@project.project_path}/.svn")
  end
  
  def tag_release_version
    Kernel.system("git' 'tag' @tag) if @project.git
    #Kernel.system("svn tag #{tag}") if @project.svn
  end
  
  def process_command
    tag_release_version
    make_archive
  end
end

app = ArtRelease.new(ARGV)
app.run
