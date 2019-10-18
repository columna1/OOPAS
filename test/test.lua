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
--local replay = replayReader(io.open("test/columna1 - Nekomata Master - Far east nightbird (kors k Remix) [RLC's Extra] (2016-05-27) Osu.osr","rb"):read("*a"))
--local replay = replayReader(io.open("/mnt/e/osu!/Replays/nathan on osu - Aimiya Zero - -ERROR [Drowning] (2019-03-23) Osu.osr","rb"):read("*a"))
--local replay = replayReader(io.open("/mnt/e/osu!/Replays/columna1 - Demetori - Kourou ~ Eastern Dream [Bygone Dream] (2018-09-21) Osu.osr","rb"):read("*a"))
local replay = replayReader(io.open("/mnt/e/osu!/Replays/columna1 - ETIA. - Lost Love [Last Eve] (2017-10-22) Osu.osr","rb"):read("*a"))
print(replay.player)
print("https://osu.ppy.sh/web/osu-getreplay.php?c="..replay.onlineID.."&m=0")
print(replay.combo)
print(replay.threehundreds.."x300 "..replay.onehundreds.."x100 "..replay.fifties.."x50 "..replay.misses.."xmiss")
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
--local b = io.open("test/358273.osu","r")
--local b = io.open("/mnt/e/osu!/songs/426602 Aimiya Zero - -ERROR/Aimiya Zero - -ERROR (Yusomi) [Drowning].osu","r")
--local b = io.open("/mnt/e/osu!/songs/837842 Demetori - Kourou ~ Eastern Dream/Demetori - Kourou ~ Eastern Dream (tokiko) [Bygone Dream].osu","r")
local b = io.open("/mnt/e/osu!/songs/341933 ETIA - Lost Love/ETIA. - Lost Love (JJburstOwO) [Last Eve].osu","r")
map:parse(b)
print("map")
print(map.Artist.." - "..map.Title.." ["..map.Version.."]")
print(map.Artist)
print(map.Title)
print(map.Version)
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

