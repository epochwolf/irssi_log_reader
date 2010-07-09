#!/usr/bin/env ruby
require "shellwords"
require "active_support"

#dirty parser for output.
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

=begin
Format: (see man page for ls)
--
marquis@shiny:~$ ls -1ARp /Users/marquis/programming/test_data/irclogs|head
FreeNode/
SFF/

/Users/marquis/programming/test_data/irclogs/FreeNode:
##elite/
##jswolfbot/
##uno-nightd/
##uno-nights/
#cloudservers/
#couchdb/
--

Want to parse this into 
{
  :folder => {
    :subfolder => {
      :subsubfolder =>{
        :"." => [array of filenames]
      },
      :subsubfolder =>{
        :"." => [array of filenames]
      },
      :"." => [array of filenames]
    },
    :subfolder => {
      :"." => [array of filenames]
    }
    :"." => [array of filenames]
  }
  :folder => {
    :"." => [array of filenames]
  }
  :"." => [array of filenames]
}

<irc_log_path>
path: POSIX path
cwd: <path>:\n
item:
  file: <path>\n
  -or-
  folder: <path>/\n 
seperator: \n
block:
  <cwd>?<item>*<seperator>
data:
  <block>*

Parse into <block> by spliting by /\n\n/
  First <block> omits <cwd>, handle as special case
  Parse each <block> into <root> and <items> by spliting by /\n/
    Parse root into elements by [1]
    
    
[1] 
# I've looked through ruby's library for a safe version of this, no luck
# this is a bit hackish, I don't like it.
ruby-1.9.1-p378 > two = "/Users/marquis/programming/test_data/irclogs"
 => "/Users/marquis/programming/test_data/irclogs"
ruby-1.9.1-p378 > one = "/Users/marquis/programming/test_data/irclogs/FreeNode/two"
 => "/Users/marquis/programming/test_data/irclogs/FreeNode/two"
ruby-1.9.1-p378 > one[two.length..-1]
 => "/FreeNode/two" 
#if there is a / at the front we can do [1..-1] to remote it.
ruby-1.9.1-p378 > one[two.length..-1][1..-1]
 => "FreeNode/two" 



=end

#rolled my own testing because I'm away from my ruby book and the internet :'(
if __FILE__ == $0
  puts "Running test"
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
    puts expected
    puts actual
  else
    puts "Pass"
  end
end