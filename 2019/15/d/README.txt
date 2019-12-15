--- Day 15, part 1 & 2 ---

Fun day! Since I'm not at all comfortable with pathfinding, I
resolved to spend ages on this, and just started by making a
playable game out of it with the nice-curses job from day 13.

Turns out pathfinding was never required: the shortest path to
the oxygen is also the only path to it, so the very simple
Dir[] moves handling that I put in as a placeholder actually
answered part1 (I didn't trust it until getting the same number
from dozens of randomized walkers).

Part2 was just flooding the space with oygen, and should've
been trivial, but I made the mistake of mutating the maze
during the selection of the tiles to spread oxygen to. This
spread oxygen too fast, which was obvious with a higher
Thread.sleep in the oxygenation loop.

The output for this one is entertaining to watch, and it's
possible (and I did this in an earlier version) to switch to
manual control of the robot mid-way.
