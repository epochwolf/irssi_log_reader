# encoding: utf-8
require "grep_tools"
require "cgi"


module Logs
  def self.from_folder(folder)
    return nil unless filelist = read_folder_from_filesystem(folder)
    
    build_objects(folder, filelist)
  end
  
  class LogList < Array
    attr_accessor :name,:grep_string, :grep_results, :path
    
    def [](*args)
      if args.first.is_a? String
        self.find {|v| v.name == args.first }
      else
        super(*args)
      end
    end
    
    protected
    def with_cache(search, reload=false)
      if reload || search != @grep_string
        @grep_string = search
        @grep_results = yield
      end
      @grep_results
    end
  end
  
  class Server < LogList # array of <Chatroom>
    def initialize(folder, server_name, *args)
      @name = server_name
      @path = File.join(folder, server_name)
      @grep_results = nil
      super(*args)
    end
    
    def grep(search)
      with_cache(search) do
        reject{|chatroom| chatroom.grep(search).empty? }
      end
    end
    
    def to_url
      "/#{CGI.escape @server_name}"
    end
  end
  
  class Chatroom < LogList # array of <LogFile>
    attr_reader :server_name
    def initialize(folder, server_name, chatroom_name, *args)
      @server_name = server_name
      @name = chatroom_name
      @path = File.join(folder, server_name, chatroom_name)
      super(*args)
    end
    
    def grep(search)
      with_cache(search) do
        reject{|logfile| logfile.grep(search).empty? }
      end
    end

    def to_url
      "/#{CGI.escape @server_name}/#{CGI.escape @name}"
    end
    
    def private?
      !(name =~ /^#/)
    end
  end
  
  class LogFile #proxy to file object with lazy loading
    attr_reader :name, :path, :date, :grep_string, :grep_results, :server_name, :chatroom_name
    def initialize(folder, server_name, chatroom_name, filename, path_with_filename)
      @server_name = server_name
      @chatroom_name = chatroom_name
      @name = filename
      @path = path_with_filename
      @date = begin
        date = filename_to_date(@name)
        Time.new(date[0..3], date[4..5], date[6..8])
      end
    end
    
    def grep(search)
      with_cache(search) do
        open(self.path) {|file| file.grep(Regexp.new(search)) }
      end
    end
    
    def to_url
      "/#{CGI.escape @server_name}/#{CGI.escape @chatroom_name}/#{CGI.escape @name}"
    end
    
    def safe_read(charset="UTF-8")
      to_file.read.encode(charset, :invalid => :replace, :undef => :replace, :universal_newline => true)
    end
    
    def to_file
      @file ||= File.open(@path).set_encoding("ASCII-8BIT")
    end
    
    def method_missing(*args)
      to_file.send(*args)
    end
    
    protected
    def with_cache(search, reload=false)
      if reload || search != @grep_string
        @grep_string = search
        @grep_results = yield
      end
      @grep_results
    end
  end
  
  
  private
  def self.read_folder_from_filesystem(folder)
    extract_filelist(folder)
  end
  
  def self.build_objects(folder, filelist)
    arr = LogList.new
    filelist.select{|v| v != '.'}.each do |server, chatrooms|
      srv = Server.new(folder, server) # TYPEERROR HERE
      
      chatrooms.select{|v| v != '.'}.each do |chatroom, logs|
        cht = Chatroom.new(folder, server, chatroom)
        
        logs['.'].each do |filename|
          name = filename.gsub(%r{.*?(\d{8})\.log}, '\\1')
          cht << LogFile.new(folder, server, chatroom, name, File.join(folder, server, chatroom, filename))
        end
        
        srv << cht unless cht.empty?
      end #chatrooms
      
      arr << srv
    end #filelist
    arr
  end
end