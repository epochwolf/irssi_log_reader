require "grep_tools"

get %r{/grep/?$} do 
  haml :"grep/index"
end

post %r{/grep/?$} do 
  @files = grep_multiple(options.irc_logs_path, params[:grep])
  haml :"grep/index"
end