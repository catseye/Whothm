-- LUA_PATH="?.lua" lua sanity.lua

r = require "whothm"

local t = TruthTable.new()
print(t.to_s())
t.map_to_true("FF")
print(t.to_s())
print(t.apply(false, false))
print(t.apply(false, true))

local r = Rectangle.new(5, 1, 6, 10)
print(r.to_s())

local b = BitMap.new(40, 20)
local t = TruthTable.new()
t.map_to_true("FT")
t.map_to_true("TF")
r.draw(b, t)
print(b.render_to_text())

local source = [[
r := (0, 0, 1, 2);
s := (0, 0, 1, 2);
XOR := TF/FT;

begin
r.x += r.w;
r.x += -1;
r.w += 1;
r.h += 1;
draw r, XOR;
s.x += s.w;
s.x += -1;
s.w += 1;
s.h += 2;
draw s, XOR;
end
]]
local s = Scanner.new(source)
print(s.scan())
