/++
    Written after second star, unifying d1 and d2.
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
    import std.typecons : Tuple, tuple;
    import std.algorithm : map, sort, sum, all;
    import std.range : drop;
    import std.math : abs;

    int[Coord][] tracks;

    void plot(Move[] wire) {
        int[Coord] track;
        int steps;
        auto at = Coord(0, 0);
        track[at] = 0;
        foreach (move; wire) {
            foreach (i; 0 .. move.dist) {
                at.move(move.dir, 1);
                track[at] = ++steps;
            }
        }
        tracks ~= track;
    }

    bool intersecting(Coord c) {
        return tracks.all!(track => c in track);
    }

    int sumsteps(Coord c) {
        return tracks.map!(m => m[c]).sum;
    }

    alias Answer = Tuple!(int, "part1", int, "part2");
    Answer solve() {
        int[Coord] dists;
        int[Coord] steps;
        foreach (k, v; tracks[0]) {
            if (intersecting(k)) {
                dists[k] = k.x.abs + k.y.abs;
                steps[k] = sumsteps(k);
            }
        }
        return Answer(
                dists.values.sort.drop(1).front,
                steps.values.sort.drop(1).front);
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
    grid.plot(input[0]);
    grid.plot(input[1]);

    auto answer = grid.solve;
    writeln("part1: ", answer.part1);
    writeln("part2: ", answer.part2);
}
