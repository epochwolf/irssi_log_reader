require "logs" unless defined?(LogFile)


post "/" do 
  haml :"grep/index"
end


# /browse/server
post %r{^/browse/([^/]+)/?$} do |server|
  @server = @log_list[server]
  if @server.nil?
    haml :missing
  else
    @server.grep(params[:grep])
    @results = grep_multiple(@server.path, params[:grep])
    haml :"grep/server"
  end
end

#need regex'd routes because sinatra hates escaped #'s in the url
# /browse/server/#chatroom
post %r{^/browse/([^/]+)/([^/]+)/?$} do |server, chatroom|
  @server = @log_list[server]
  if @server
    @chatroom = @server[chatroom]
    if @chatroom
      @results = grep_multiple(@chatroom.path, params[:grep])
      return haml :"grep/chatroom"
    end
  end
  haml :missing
end

# /browse/server/#chatroom/date
post %r{^/browse/([^/]+)/([^/]+)/([^/]+)/?$} do |server, chatroom, date|
  if @server = @log_list[server]
    if @chatroom = @server[chatroom]
      if @logfile = @chatroom[date]
        @results = grep_one(@logfile.path, params[:grep])
        return haml :"grep/logfile"
      end
    end
  end
  haml :missing
end