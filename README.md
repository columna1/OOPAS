# OOPAS

Osu Object Parsing and Analysis Suite

## What is OOPAS

OOPAS is a set of libraries meant to make reading and analyzing certain osu files easy. These libraries will read and parse map files and replay flies. It will perform scoring/judging of the replay on the map and return useful information about what happened. This allows for easy creation of tools that can show different metrics and statistics about plays that simply isn't stored in any immediately readable form.  
This project is currently written in lua, targeting luajit (lua 5.1 with some 5.2 extensions) since lua is the language I am most comfortable with. In the future when I'm satisfied with it's accuracy I will personally port this to javascript which will probably be more useful.

Note: The goal of this lib is to create accurate results and be easy to use, it is not(yet) meant to be fast.

Libraries included in this repo:

- Beatmap reader/parser
  - includes a slider parser/path generator
  - allows you to apply mods and all values are adjusted accordingly
- Beatmap difficulty calculator
  -PP calculator (port of [oppai-ng](https://github.com/Francesco149/oppai-ng))
- Replay reader/parser
- Play scoring (the main goal of this project)
  - UR/error metrics (easy)
  - 300s/100s/50s/misses gotten and when
  - slider breaks, what/when and why
  - "realtime" scoring? (for use in situations where you only have replay data up to a certain point for ex. spectating? *hint)
- Documentation/wiki
  - DOCUMENT ALL THE THINGS
  - how judging works/numbers/formulas
  - how sliders work (omfg how they are complicated)
  - how slider paths are calculated
  - spinners ⭕
  - gotchas/edge cases (slider ends/ticks with early key presses etc.)
  - combo/score
  - difficulty values (AR/OD/etc)
    - possibly how difficulty is calculated (strains etc)
  - modifiers

## Dependencies

[lua-lzma](https://github.com/columna1/lua-lzma)

## Future plans

Stuff that has already been written, just needs to be cleaned/re-written:

- [ ] Write/design new scoring system (current spaghetti system won't cut it 😕)
- [ ] scoring
  - [x] circles/slider heads
  - [ ] spinners
  - [ ] sliders
  - [ ] combo
  - [ ] score
- [x] Slider parsing
  - [x] path generation
- [x] Beatmap parsing
  - [ ] error reporting (without error()/crashing)
- [ ] Difficulty / PP calculation

To do: (please help 🆘)

- [ ] Write/design API
- [ ] testing
- [ ] Make more accurate! please help!

## How to use

Get [luajit](http://luajit.org/). You can just download and extract the binary somewhere  
The easiest way to install would probably be [luarocks](https://luarocks.org/)  
Install luasocket (for timing, comment those lines out if you don't want to install socket)

compile custom [lua-lzma](https://github.com/columna1/lua-lzma) source and place it into the project directory  
*you may have to edit the make file

```shell
cd lua-lzma/src
make
cp lzma.so* somewhere/OOPAS/
```

run ```luajit test/test.lua```

## Related repositories

- Viewer -tbd
- Javascript port -tbd
  - browser visualizations
- [oppai-ng](https://github.com/Francesco149/oppai-ng)
- [ojsama](https://github.com/Francesco149/ojsama)
- [lua-lzma](https://github.com/rainfiel/lua-lzma)