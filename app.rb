#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'boot')

configure do
  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, "public") }
  set :views, Proc.new { File.join(root, "templates") }
  #path to irc logs
  set :irc_logs_path, "~/programming/test_data/irclogs/"
  #do you want private messages in logs to be available?
  set :show_private_chats, false
end

def testing
  "<pre>#{$:}</pre>" 
end

load "controllers/home.rb"
load "controllers/search.rb"
load "controllers/browse.rb"
