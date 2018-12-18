local vec2 = require("vec2")
local bin = require("binRead")
local replayReader = require("readReplay")

--vec2 tests

--file read tests
local f1 = bin.new("one")
print(f1.file)
local f2 = bin.new("sentence")
print(f1.file)
print(f2.file)
print(f2:readBytes(2))
print(f2:readBytes(3))
print(f2:readBytes(2))
print(f2:readBytes(1))
print(f2:readBytes(1))
local f3,err = bin.new(io.open("test/testfile","r"))
if err then error(err) end
print(f3:readBytes(100))
print(f3:readBytes(1))

--replay read test
local replay = replayReader(io.open("test/columna1 - Nekomata Master - Far east nightbird (kors k Remix) [RLC's Extra] (2016-05-27) Osu.osr","rb"):read("*a"))
print(replay.player)
print("https://osu.ppy.sh/web/osu-getreplay.php?c="..replay.onlineID.."&m=0")
print(replay.combo)