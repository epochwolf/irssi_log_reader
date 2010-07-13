require "grep_tools"

post "/" do 
  @files = grep_multiple(options.irc_logs_path, params[:grep])
  haml :"grep/index"
end

post "/browse/?" do 
  @files = grep_multiple(options.irc_logs_path, params[:grep])
  haml :"grep/index"
end


# /browse/server
post %r{/browse/([^/]+)/?$} do |server|
  @server = @log_list[server]
  if @server.nil?
    haml :missing
  else
    path = File.join(options.irc_logs_path, server)
    @files = grep_multiple(path, params[:grep])
    haml :"grep/server"
  end
end

#need regex'd routes because sinatra hates escaped #'s in the url
# /browse/server/#chatroom
post %r{/browse/([^/]+)/([^/]+)/?$} do |server, chatroom|
  @server = @log_list[server]
  if @server
    @chatroom = @server[chatroom]
    if@chatroom
      path = File.join(options.irc_logs_path, server, chatroom)
      @files = grep_multiple(path, params[:grep])
      return haml :"grep/chatroom"
    end
  end
  haml :missing
end

# /browse/server/#chatroom/date
post %r{/browse/([^/]+)/([^/]+)/([^/]+)/?$} do |server, chatroom, date|
  if @server = @log_list[server]
    if @chatroom = @server[chatroom]
      if @logfile = @chatroom[date]
        @files = grep_one(@logfile.path, params[:grep])
        return haml :"grep/logfile"
      end
    end
  end
  haml :missing
end