get '/' do
  'Hello World'
end

get %r{/debug?} do
  testing
end