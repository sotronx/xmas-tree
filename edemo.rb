require_relative './expression'
require_relative './matcher'
require_relative './parser'

#
# ideograms
#
_GREEN = IdeogramExpression.new("青")
_GREEN.romanizations = %w[green greener greenest greenish greenly greenness greenery]
_GREEN.statements = ["document.write('leaf'.fontcolor('green'));", \
"document.write('leaf'.fontcolor('olive'));", \
"document.write('leaf'.fontcolor('lime'));"]

_RED = HanjiExpression.new("紅")
_RED.romanizations = %w[red redder reddest red reddish reddy redly redness redden]
_RED.statements = ["document.write('ball'.fontcolor('red'));", \
"document.write('ball'.fontcolor('crimson'));", \
"document.write('ball'.fontcolor('tomato'));", \
"document.write('ball'.fontcolor('pink'));"]

_EIGHT = HanjiExpression.new("八")
_EIGHT.romanizations = %w[eight eighteen eighty]
_EIGHT.statements = ["for (var counter = 0; counter < 8; counter = counter + 1)", \
"for (var counter = 18; counter < 80; counter = counter + 1)"]

_WRITE = HanjiExpression.new("寫")
_WRITE.romanizations = %w[write writes wrote written]
_WRITE.statements = ["function write() {}"]


#
# Matcher returning MatchData which is an array of nodes
#
puts '-' * 40
puts 'Matcher'
puts '-' * 40
matchdata = Matcher.new("writes | eighteen & red").match([_WRITE, _EIGHT, _RED])


#
# Context
#
ctx = Set.new
ctx.add([_GREEN, _RED, 2])

#
# Parser
#
puts '-' * 40
puts 'Parser'
puts '-' * 40
p = Parser.new(matchdata)
s = p.to_ast

lines = s.to_javascript(ctx)
lines.each do |ln|
  puts ln
end

puts '-' * 40

f = File.new('./color.html', "w")
f.puts '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8" /><title>Test</title></head><body><script>'
lines.each do |ln|
  f.puts ln
end
f.puts "write();</script></body></html>"