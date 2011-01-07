#!/usr/bin/env ruby
require 'rubygems'
#load sinatra and add local lib folder to include path
require "sinatra"
require "haml"
require 'date'

Encoding.default_external = "ASCII-8BIT" #irc logs tend to have invalid data
Encoding.default_internal = "UTF-8"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

configure do
  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, "public") }
  set :views, Proc.new { File.join(root, "templates") }
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
