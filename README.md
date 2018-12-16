# OOPAS

Osu Object Parsing and Analysis Suite

## What is OOPAS

OOPAS is a set of libraries meant to make reading and analyzing certain osu files easy. These libraries will read and parse map files and replay flies. It will perform scoring/judging of the replay on the map and return useful information about what happened. This allows for easy creation of tools that can show different metrics and statistics about plays that simply isn't stored in any immediately readable form.  
This project is currently written in lua, targeting luajit (lua 5.1 with some 5.2 extensions) since lua is the language I am most comfortable with. In the future when I'm satisfied with it's accuracy I will personally port this to javascript which will probably be more useful.

Libraries included in this repo:

- Beatmap reader/parser
  - includes a slider parser/path generator
  - allows you to apply mods and all values are adjusted accordingly
- Beatmap difficulty calculator
  -PP calculator (port of [oppai-ng](https://github.com/Francesco149/oppai-ng))
- Replay reader/parser
- Play scoring (the star of this repo)
  - UR/error metrics (easy)
  - 300s/100s/50s/misses gotten and when
  - slider breaks, what/when and why

## Future plans

Stuff that has already been written, just needs to be cleaned/re-written:

- [ ] Write/design scoring system (current spaghetti system won't cut it 😕)
- [ ] Slider parsing
- [ ] Beatmap parsing
- [ ] Difficulty / PP calculation

To do: (please help 🆘)

- [ ] Write/design API
- [ ] Make more accurate! please help!

## How to use

--tbd

## Related repositories

- Viewer -tbd
- Javascript port -tbd
  - browser visualizations
- [oppai-ng](https://github.com/Francesco149/oppai-ng)
- [ojsama](https://github.com/Francesco149/ojsama)