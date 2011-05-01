# encoding: utf-8
# shell_tools.rb
require "shellwords"
require 'benchmark'

def safe_utf8_exec(cmd, *args)
  str = nil
  benchmark = nil
  if args.empty?
    puts "Executing: #{cmd}"
    benchmark = Benchmark.measure() do
      str = safe_encode_utf8(`#{cmd}`)
    end
  else
    puts "Executing: #{cmd} #{args.map(&:to_s).map(&:shellescape).join(" ")}"
    benchmark = Benchmark.measure() do
      str = safe_encode_utf8(`#{cmd} #{args.map(&:to_s).map(&:shellescape).join(" ")}`)
    end
  end
  [str, benchmark]
end

# Destructive conversion to utf8
def safe_encode_utf8(text)
  text.force_encoding('ASCII-8BIT').encode("UTF-8", :invalid => :replace, :undef => :replace, :universal_newline => true)
end