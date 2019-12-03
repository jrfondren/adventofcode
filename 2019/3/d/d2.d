/++
    Actual Day 3 part 2 code, used to get the answer.

    d1.d didn't set me up very well for part 2, and I came close to having a
    part2 rank that was lower than my part1 rank as as result.

    The Steps struct is pure flailing--the problem was somewhere else.
+/
import std;

enum Dir { Up, Down, Left, Right };

struct Move {
    Dir dir;
    uint dist;

    this(string desc) {
        switch (desc[0]) {
            case 'U':
                dir = Dir.Up;
                break;
            case 'D':
                dir = Dir.Down;
                break;
            case 'L':
                dir = Dir.Left;
                break;
            case 'R':
                dir = Dir.Right;
                break;
            default:
                assert(0);
        }
        dist = to!int(desc[1..$]);
    }
}

struct Steps {
    int[2] steps;
}

struct Grid {
    Steps[Coord] grid;
    int[2] steps;

    void plot(Move[] wire, int id) {
        auto at = Coord(0, 0);
        if (at !in grid) grid[at] = Steps();
        foreach (move; wire) {
            foreach (i; 0 .. move.dist) {
                at.move(move.dir, 1);
                if (at !in grid) grid[at] = Steps();
                grid[at].steps[id] = ++steps[id];
            }
        }
    }

    int part2() {
        int[Coord] intersections;
        auto start = Coord(0, 0);
        foreach (k, v; grid) {
            if (v.steps[0] > 0 && v.steps[1] > 0) {
                intersections[k] = v.steps[0] + v.steps[1];
            }
        }
        int[] sumstep = intersections.values.sort.array;
        return sumstep[0];
    }
}

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

int manhattan_distance(Coord a, Coord b) {
    return abs(b.x - a.x) + abs(b.y - a.y);
}

void main() {
    Move[][2] input =
        slurp!string("input.txt", "%s")
        .map!(line => line.splitter(',').map!Move.array)
        .array;

    Grid grid;
    grid.plot(input[0], 0);
    grid.plot(input[1], 1);
    writeln(grid.part2);
}
