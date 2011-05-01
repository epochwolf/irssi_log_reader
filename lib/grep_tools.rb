#!/usr/bin/env ruby
# encoding: utf-8
# Grep Tools
# Contains methods to grep logs
# (Benchmarking shows this to be slightly faster than using ruby, it's certianly less code.)
require 'shell_tools'
require 'list_tools' # for path_components

#using egrep for search

def grep_multiple(folder, search)

  folder = File.expand_path(folder)
  return nil if folder.nil? || search.nil? || !File.directory?(folder)
  folder = folder[0..-2] if folder =~ %r{/$} #remove trailing slash if present
  
  data, benchmark = safe_utf8_exec(options.grep_folder, search, folder)
  
  hash = {}
  
  #convert data from 
  # file:line
  #into 
  # file => [lines]
  data.each_line do |line|
    file, str = line.split(":", 2)
    file = url_from_file(file)
    hash[file] ||= []
    hash[file] << str
  end
  
  [hash, benchmark]
end

# TODO: This isn't used, remove it.
def grep_ruby(loglist, search, options={})
  rxp = Regexp.new(search)
  hash = {}
  files = []
  case loglist
  when Logs::Server #one server
    loglist.each do |chatroom| 
      files += chatroom.to_a
    end 
  when Logs::Chatroom #one chatroom
    files = loglist.to_a #convert to an array
  when Logs::LogList #all servers
    loglist.each do |server| 
      server.each do |chatroom|
        files += chatroom.to_a
      end
    end
  when Logs::LogFile
    [loglist]
  end
  benchmark = Benchmark.measure() do
    #find file
    files.each do |file|
      data = []
      open(file) do |io|
        data = io.grep(rxp)
      end
      hash[file] = data
    end
  end
  hash
end

def grep_one(file, search)
  file = File.expand_path(file)
  return nil if file.nil? || search.nil? || !File.file?(file)
  hash = {}
  benchmark = Benchmark.measure() do
    data, _  = safe_utf8_exec(options.grep_file, search, file)
    file = url_from_file(file)
    hash[file] = data.split("\n")
  end
  [hash, benchmark]
end

def grep_one_ruby(file, search, options={})
  options = {
    :extended => true,
  }.update options

  file = File.expand_path(file)
  return nil if file.nil? || search.nil? || !File.file?(file)
  
  data = []
  hash = {}
  rxp = Regexp.new(search)
  range = 0..-2
  benchmark = Benchmark.measure() do
    open(file) do |io|
      data = io.grep(rxp)
    end  
    data.map!{|v| v.slice(range)}
    hash[file] = data
  end
  [hash, benchmark]
end