require "log_tools"

get '/browse' do 
  extract_filelist(options.irc_logs_path).gsub(/\n/, "<br/>")
end