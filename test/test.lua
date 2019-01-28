local vec2 = require("vec2")
local bin = require("binRead")
local replayReader = require("readreplay")
local mapReader = require("readmap")
local score = require("score")
local stream = require("replaystream")
--dbg = require("debugger")

local socket = require("socket")

--vec2 tests

--file read tests
print(os.clock())
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
local f = socket.gettime()
local ff = socket.gettime()
local replay = replayReader(io.open("test/columna1 - Nekomata Master - Far east nightbird (kors k Remix) [RLC's Extra] (2016-05-27) Osu.osr","rb"):read("*a"))
print(replay.player)
print("https://osu.ppy.sh/web/osu-getreplay.php?c="..replay.onlineID.."&m=0")
print(replay.combo)
local s = socket.gettime()
print(math.floor((s-f)*1000).."ms to read replay")
--print(replay.uncompressedData)

--replay stream test
local f = socket.gettime()
local rpstream = stream.wrap(replay)
local s = socket.gettime()
print(math.floor((s-f)*1000).."ms to wrap/parse replay")


--map parsing test
local f = socket.gettime()
map = mapReader.new()
local b = io.open("test/358273.osu","r")
map:parse(b)
local s = socket.gettime()
print(math.floor((s-f)*1000).."ms to read/parse map")
--print(socket.gettime())

--scoring
local f = socket.gettime()
local sc = score.new(map,replay)
print(sc.map.Title)
sc:judgeAll()
local s = socket.gettime()
print(math.floor((s-f)*1000).."ms to score map")
print(math.floor((s-ff)*1000).."ms total")