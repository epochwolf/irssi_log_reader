#!/usr/bin/env ruby
# encoding: utf-8
# Grep Tools
# Contains methods to grep logs
require 'shell_tools'
require 'list_tools' # for path_components

#using egrep for search

def grep_multiple(folder, search, options={})
  options = {
    :extended => true,
  }.update options

  folder = File.expand_path(folder)
  return nil if folder.nil? || search.nil? || !File.directory?(folder)
  folder = folder[0..-2] if folder =~ %r{/$} #remove trailing slash if present
  
  data, benchmark = safe_utf8_exec("egrep -r", search, folder)
  
  hash = {}
  
  #convert data from 
  # file:line
  #into 
  # file => [lines]
  data.each_line do |line|
    file, str = line.split(":", 2)
    hash[file] ||= []
    hash[file] << str
  end
  
  [hash, benchmark]
end

def grep_one(file, search, options={})
  options = {
    :extended => true,
  }.update options

  file = File.expand_path(file)
  return nil if file.nil? || search.nil? || !File.file?(file)
  
  data = safe_utf8_exec("egrep ", search, file)
  
  hash = {file => data.split("\n")}
end