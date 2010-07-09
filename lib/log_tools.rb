require "shellwords"

#dirty parser for output.
def extract_filelist(folder)
  folder = File.expand_path(folder)
  # using a *nix system call because Dir.glob may not be thread safe
  str = `ls -1ARp #{folder.shellescape}`
  file_list = {}
  
  
  #the first block contains toplevel folders.
  first_block, blocks = str.split(/\n\n/) 
  blocks.each do |block|
    first_item, items = block.split(/\n/)
  end
end

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
root: <path>:\n
item:
  file: <path>\n
  -or-
  folder: <path>/\n 
seperator: \n
block:
  <root>?<item>*<seperator>
data:
  <block>*

Parse into <block> by spliting by /\n\n/
  First <block> omits <root>, handle as special case
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