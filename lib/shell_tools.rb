# encoding: utf-8
# shell_tools.rb
require "shellwords"

def safe_utf8_exec(cmd, *args)
  if args.empty?
    safe_encode_utf8(`#{cmd}`)
  else
    safe_encode_utf8(`#{cmd} #{args.map(&:to_s).map(&:shellescape).join(" ")}`)
  end
end

def safe_encode_utf8(text)
  text.force_encoding('ASCII-8BIT').encode("UTF-8", :invalid => :replace, :undef => :replace, :universal_newline => true)
end