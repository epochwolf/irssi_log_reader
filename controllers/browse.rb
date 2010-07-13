require "logs"


before do
  @log_list = Logs.from_folder(options.irc_logs_path)
end

# get "/browse" doesn't load on "/browse/" unlike rails, understandable but I want it to load anyway
# solution: regex 
get %r{/browse/?$} do 
  haml :"browse/index"
end

# /browse/server
get %r{/browse/([^/]+)/?$} do |server|
  @server = @log_list[server]
  if @server.nil?
    haml :missing
  else
    haml :"browse/server"
  end
end

#need regex'd routes because sinatra hates escaped #'s in the url
# /browse/server/#chatroom
get %r{/browse/([^/]+)/([^/]+)/?$} do |server, chatroom|
  @server = @log_list[server]
  if @server
    @chatroom = @server[chatroom]
    if@chatroom
      return haml :"browse/chatroom"
    end
  end
  haml :missing
end

# /browse/server/#chatroom/date
get %r{/browse/([^/]+)/([^/]+)/([^/]+)/?$} do |server, chatroom, date|
  if @server = @log_list[server]
    if @chatroom = @server[chatroom]
      if @logfile = @chatroom[date]
        return haml :"browse/logfile"
      end
    end
  end
  haml :missing
end