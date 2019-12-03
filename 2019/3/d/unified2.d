/++
    Instead of looping over all the plotted points, track intersections as
    they're found. This is an incredibly marginal improvement over unified.d
    but I think the Grid.plot template is pretty cool.
+/

enum Dir { Up, Down, Left, Right }

struct Coord {
    int x, y;

    void move(Dir dir, uint dist) {
        final switch (dir) {
            case Dir.Up: y -= dist; break;
            case Dir.Down: y += dist; break;
            case Dir.Left: x -= dist; break;
            case Dir.Right: x += dist; break;
        }
    }
}

struct Move {
    Dir dir;
    uint dist;

    this(string desc) {
        import std.conv : to;

        switch (desc[0]) {
            case 'U': dir = Dir.Up; break;
            case 'D': dir = Dir.Down; break;
            case 'L': dir = Dir.Left; break;
            case 'R': dir = Dir.Right; break;
            default: assert(0);
        }
        dist = to!int(desc[1 .. $]);
    }
}

struct Grid {
    import std.typecons : Tuple;
    import std.algorithm : minElement;
    import std.math : abs;

    int[Coord][2] grid;
    int[Coord] xdists;
    int[Coord] xsteps;

    void plot(int id)(Move[] wire) if (id == 0 || id == 1) {
        int steps;
        auto at = Coord(0, 0);
        grid[id][at] = 0;
        foreach (move; wire) {
            foreach (i; 0 .. move.dist) {
                at.move(move.dir, 1);
                grid[id][at] = ++steps;
                static if (id == 1) {
                    if (at in grid[0] && at !in xdists) {
                        xdists[at] = at.x.abs + at.y.abs; 
                        xsteps[at] = steps + grid[0][at];
                    }
                }
            }
        }
    }

    alias Answer = Tuple!(int, "part1", int, "part2");
    Answer solve() {
        return Answer(
                xdists.values.minElement,
                xsteps.values.minElement);
    }
}

void main() {
    import std.stdio : writeln;
    import std.algorithm : map, splitter;
    import std.array : array;
    import std.file : slurp;

    Move[][2] input =
        slurp!string("input.txt", "%s")
        .map!(line => line.splitter(',').map!Move.array)
        .array;

    Grid grid;
    grid.plot!0(input[0]);
    grid.plot!1(input[1]);

    auto answer = grid.solve;
    writeln("part1: ", answer.part1);
    writeln("part2: ", answer.part2);
}
