--- Day 13, part 1 & 2 ---

Part1:

  Weird, I keep getting a blank screen for some reason. Add
  logging to the machine, grep -c the log, part1 done.

Part2:

  Ages pass ("\x1b" escapes get replaced with nice-curses,
  various workarounds and logging methods enter and exit the
  code) until I realize that I'm essentially using an
  uninitialized value and this is why I only ever draw a blank
  screen.

  Turns out that D's auto-initialization doesn't save you from
  all imagineable errors, huh. At least it was the case that
  the game kept saying "THERE IS SOMETHING WRONG WITH YOUR
  TILE-HANDLING, FRIEND" and I kept not hearing this message.

  If I'd left in the logging from part1, I might've noticed
  faster...

Fun day. This is messy as hell. There will 100% be some
follow-up work for today's solution.
