                  -----------------------------
                         C R O W N Q U A K E
                  -----------------------------

INTRODUCTION

  crownquake is a source-maintained continuation of QUESS 1.34, the
  Quake chess mod originally by the IMPACT TEAM with v1.34a work by
  Ralgha.

  The original chess game remains playable. crownquake also adds a
  checkers mode that uses the same 8x8 board maps and Quake monster
  presentation.

INSTALLATION

  Put this directory under your Quake directory as "crownquake".
  The expected launch directory is:

    quake/crownquake

QUICK START

  Chess, single-PC alternating turns:

    quake -game crownquake +teamplay 0

  Checkers, single-PC alternating turns:

    quake -game crownquake +teamplay 0 +checkers 1

  Chess is the default. Set the "checkers" cvar before the match starts
  to use checkers mode.

  Turns are untimed when "timelimit" is 0 or omitted. Set timelimit to a
  positive number of seconds to use a per-turn clock, for example:

    quake -game crownquake +teamplay 0 +checkers 1 +timelimit 60

CONTROLS

    Normal Quake controls are used for looking around.
    Shift       - move forward
    RMB/Return  - move backward
    LMB/Space   - select a piece or move it
    C           - toggle camera between flying and walking
    M           - save current camera marker
    1-8         - go to camera marker
    P           - pass turn in chess mode
    H           - help
    W           - toggle mouse in window mode
    F1          - display the board in text

CHESS MODE

  Chess mode follows the original QUESS rules and presentation. Pieces
  keep their internal chess_* classnames so existing QUESS board maps
  remain compatible.

CHECKERS MODE

  Checkers mode is standard American checkers:

    - 12 men per side spawn on dark squares.
    - Men move one diagonal square forward.
    - Men capture by jumping a forward diagonal enemy to an empty square.
    - Kings move and capture one diagonal square in any direction.
    - Captures are mandatory.
    - Multi-jumps continue with the same piece until no jump remains.
    - Passing is disabled.
    - Men are crowned when they reach the far rank.
    - A side loses when it has no pieces or no legal moves.

ATTRIBUTION

  Original QUESS by the IMPACT TEAM.
  QUESS v1.34a modifications by Ralgha.
