#!/usr/bin/env ruby
require "shellwords"
require "active_support"

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
  return {'.' => []} if folder.nil?
  folder = File.expand_path(folder)
  folder = folder[0..-2] if folder =~ %r{/$}
  
  # using a *nix system call because Dir.glob may not be thread safe
  str = `ls -1ARp #{folder.shellescape}`
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
    #convert /test/test/test into ['test', 'test', 'test']
    cwd = first_item[folder.length..-2].split('/').select{|v| v != ''} 
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
#         'chatroom' => ['log', 'files'], #log files
#         'chatroom' => ['log', 'files'], #log files
#         'chatroom' => ['log', 'files'], #log files
#       },
#       'server' => {
#         'chatroom' => ['log', 'files'], #log files
#         'chatroom' => ['log', 'files'], #log files
#         'chatroom' => ['log', 'files'], #log files
#       },
#     }
# <tt>hash</tt> must be in the same format as the output from <tt>extract_filelist</tt>
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

#rolled my own testing because I'm away from my ruby book and the internet :'(
if __FILE__ == $0
  puts "Running test for extract_filelist"
  expected = ({
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
  })
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
  
  puts "Running test for filelist_to_loglist"
  data = ({
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
  })
  expected = ({
    '1' => {
      '10' => ['20100602', '20100603', '20100604'],
    },
  })
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