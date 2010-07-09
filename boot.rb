require 'rubygems'
#load sinatra and add local lib folder to include path
require "sinatra"
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))