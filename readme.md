# crownquake

crownquake is a source-maintained continuation of QUESS 1.34, the Quake chess mod originally by the IMPACT TEAM with v1.34a work by Ralgha.

The mod keeps the original chess mode and adds a `checkers` cvar for standard American checkers on the same 8x8 board maps. Internal `chess_*` classnames are intentionally preserved so existing QUESS chessboard maps continue to load.

## Layout

- `src/` - QuakeC source and `progs.src`
- `pak0.pak` - original game data archive
- `readme.txt` - crownquake-facing game docs

## Build

From the repo root:

```sh
/home/woods/codedev/CRMod7/fteqcc64 -src src
```

The compiler writes `src/progs.dat`. For local play, copy or package that `progs.dat` into the crownquake game directory so it overrides the original progs in `pak0.pak`.

## Launch

Place this directory under Quake as `crownquake`, then launch:

```text
quake -game crownquake +teamplay 0
```

Chess is the default mode. Enable checkers before the match starts:

```text
quake -game crownquake +teamplay 0 +checkers 1
```

Checkers uses 12 men per side on dark squares. Men move and capture forward diagonally, kings move and capture one square diagonally in either direction, captures are mandatory, multi-jumps continue with the same piece, passing is disabled, and a side loses when it has no pieces or no legal move.

Turns are untimed when `timelimit` is `0` or omitted. Set `timelimit` to a positive number of seconds to use a per-turn clock, for example `+timelimit 60`.
