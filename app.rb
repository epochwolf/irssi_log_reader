#!/usr/bin/env ruby
require "bundler/setup"
#load sinatra and add local lib folder to include path
require "haml" #avoid race condition
require "sinatra"
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

Encoding.default_external = "ASCII-8BIT" #irc logs tend to have invalid data
Encoding.default_internal = "UTF-8"

configure do
  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, "public") }
  set :views, Proc.new { File.join(root, "templates") }
  set :haml, :format => :html5, :ugly => true
  #shell commands
  set :grep_folder, "/usr/bin/env egrep -r" #folder
  set :grep_file, "/usr/bin/env egrep " #file
  #absolute path to irc logs
  set :irc_logs_path, "/Users/marquis/programming/test_data/irclogs/"
  set :show_private_chats, false # TODO: get this working for browse and grep
end

helpers do
  include Rack::Utils
  
  def h(text)
    escape_html(text)
  end
end

load "controllers/grep.rb"
load "controllers/browse.rb"
