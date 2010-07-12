#!/usr/bin/env ruby
# encoding: utf-8
# List Tools
# Contains methods to extract hash represenation of a folder
require 'shell_tools'
require "shellwords" #ruby 1.9 module including String#shellescape

# Convert "/path/to/file/" into ["path", "to", "file"].
# If relative_to is "/path/", the resulting output is ["to", "file"].
#
# WARNING: Will not handle an escaped forward slash either parameter
def path_components(path, relative_to = nil)
  #convert to relative path if requested
  path = path[relative_to.length..-1] if relative_to
  #convert /path/to/file/ to ["path", "to", "file"]
  path.split('/').select{|v| v != ''} 
end

# Reads directory structure from the harddrive into a hash 
#     {
#       '.' => ['list', 'of', 'files'], #root level
#       'folder' => {
#         '.' => ['list', 'of', 'files'], #folder's files
#         'subfolder' => {
#           '.' => ['list', 'of', 'files'], #subfolder's files
#           'empty_folder' => {'.' => [], },
#         }
#       },
#       'empty_folder' => {'.' => [], },
#     }
# <tt>folder</tt> must be a string, and can optionally have a trailing slash
def extract_filelist(folder)
  folder = File.expand_path(folder)
  return nil if folder.nil? || !File.directory?(folder)
  folder = folder[0..-2] if folder =~ %r{/$} #remove trailing slash if present
  
  # using a *nix system call because Dir.glob may not be thread safe
  
  str = safe_utf8_exec("ls -1ARp", folder)
  file_list = {'.' => []}
  
  #the first block contains toplevel folders.
  first_block, *blocks = str.split(/\n\n/) 
  
  first_block.split(/\n/).each do |item|
    if item =~ %r{/$} #if dir
      #strip the trailing slash on item
      file_list[item[0..-2]] ||= {'.' => []}
    else
      file_list['.'] << item
    end
  end
  
  blocks.each do |block|
    first_item, *items = block.split(/\n/)
    items = [items].flatten
    
    #temp var to store the section of the file_list we are working on
    hsh = file_list
    
    cwd = first_item[0..-2] #remove trailing ':'
    cwd = path_components(cwd, folder)
    #isolate the subfolder we want
    cwd.each do |d| 
      hsh = hsh[d] ||= {'.' => []} 
    end
    
    if !items.nil?
      items.each do |item|
        if item =~ %r{/$}
          hsh[item[0..-2]] ||= {'.' => []}
        elsif !item.nil?
          hsh['.'] << item
        end
      end 
    end
  end #end blocks.each
  
  file_list
end #def extract_files

# Convert a filelist hash into a loglist hash
#     {
#       'server' => {
#         '#chatroom' => ['log', 'files'], #log files
#         '#chatroom' => ['log', 'files'], #log files
#         '#chatroom' => ['log', 'files'], #log files
#       },
#       'server' => {
#         '#chatroom' => ['log', 'files'], #log files
#         '#chatroom' => ['log', 'files'], #log files
#         '#chatroom' => ['log', 'files'], #log files
#       },
#     }
# <tt>hash</tt> must be in the same format as the output from <tt>extract_filelist</tt>
# This method relies on the log folder processed by <tt>extract_filelist</tt>
# conforming to the settings listed in the readme.
def filelist_to_loglist(hash)
  loglist = {}
  hash.select{|v| v != '.'}.each do |server, chatrooms|
    loglist[server] = {}
    chatrooms.select{|v| v != '.'}.each do |room, logs|
      loglist[server][room] = logs['.'].map do |filename|
        filename.gsub(%r{.*?(\d{8})\.log}, '\\1')
      end
    end
  end
  loglist.each do |server, chatrooms|
    chatrooms.reject!{ |room, logs| logs.empty? } unless chatrooms.empty?
  end
  loglist.select{|server, chatrooms| !chatrooms.empty? }
end


# Accepts a loglist and removes items according a hash matching the format 
#     {
#       'server' => ['chatroom', 'private_chat'],
#       'FreeNode' => ['#slicehost', '#rubyonrails'],
#     }
def filter_loglist(hash, filter={})
  hash # TODO: Add filtering.
end


#rolled my own testing because I'm away from my ruby book and the internet :'(
if __FILE__ == $0
  
  puts "Running test for extract_filelist"
  begin
    expected = (
      {
        '.' => ['4', '5', '6'],
        '1' => {
          '.' => ['7', '8'],
          '10' => {
            '.' => ['11', '12'],
          },
        },
        '2' => {
          '.' => ['9'],
        },
        '3' => {
          '.' => [],
        },
      }
    )
    actual = extract_filelist(File.expand_path("../tests/data/", File.dirname(__FILE__)))
    if actual != expected
      puts "Fail!"
      puts "Expected"
      puts expected
      puts "Actual"
      puts actual
    else
      puts "Pass"
    end
  end
  
  puts "Running test for filelist_to_loglist"
  begin
    data = (
      {
        '.' => ['4', '5', '6'],
        '1' => {
          '.' => ['7', '8'],
          '10' => {
            '.' => ['nickserv_20100602.log', 'nickserv_20100603.log', 'nickserv_20100604.log'],
          },
        },
        '2' => {
          '.' => ['9'],
          '11' => {
            '.' => [],
          }
        },
        '3' => {
          '.' => [],
        },
      }
    )
    expected = (
      {
        '1' => {
          '10' => ['20100602', '20100603', '20100604'],
        },
      }
    )
    actual = filelist_to_loglist(data)
    if actual != expected
      puts "Fail!"
      puts "Expected"
      puts expected
      puts "Actual"
      puts actual
    else
      puts "Pass"
    end
  end
end