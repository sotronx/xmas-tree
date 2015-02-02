require_relative './expression'
require_relative './matcher'
require_relative './parser'

#
# Hanjis
#
_TSHINN = HanjiExpression.new("青")
_TSHINN.romanizations = %w[tshinn tshīnn]
_TSHINN.statements = ["document.write('leaf'.fontcolor('green'));", \
"document.write('leaf'.fontcolor('olive'));", \
"document.write('leaf'.fontcolor('lime'));"]

_ANG = HanjiExpression.new("紅")
_ANG.romanizations = %w[âng āng]
_ANG.statements = ["document.write('ball'.fontcolor('red'));", \
"document.write('ball'.fontcolor('crimson'));", \
"document.write('ball'.fontcolor('tomato'));", \
"document.write('ball'.fontcolor('pink'));"]


_KIM = HanjiExpression.new("金")
_KIM.romanizations = %w[kim kīm]
_KIM.statements = ["document.write('flake'.fontcolor('gold'));"]

_GIN = HanjiExpression.new("銀")
_GIN.romanizations = %w[gîn gīn]
_GIN.statements = ["document.write('star'.fontcolor('gray'));", \
"document.write('star'.fontcolor('darkgray'));", 
"document.write('star'.fontcolor('lightgray'));"]

_PEH = HanjiExpression.new("八")
_PEH.romanizations = %w[peh pé]
_PEH.statements = ["for (var counter = 0; counter < 8; counter = counter + 1)", \
"for (var counter = 18; counter < 28; counter = counter + 1)"]

_SIA = HanjiExpression.new("寫")
_SIA.romanizations = %w[siá sia]
_SIA.statements = ["function write() {}"]


#
# Matcher returning MatchData which is an array of nodes
#
puts '-' * 40
puts 'Matcher'
puts '-' * 40
matchdata = Matcher.new("sia | kīm & gīn & tshīnn & âng").match([_SIA, _KIM, _GIN, _TSHINN, _ANG])


#
# Context
#
ctx = Set.new
ctx.add([_PEH, _GIN, 2])

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