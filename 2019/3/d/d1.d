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

struct Grid {
    int[Coord] grid;

    void plot(Move[] wire, int id) {
        auto at = Coord(0, 0);
        grid[at] |= id;
        foreach (move; wire) {
            foreach (i; 0 .. move.dist) {
                at.move(move.dir, 1);
                grid[at] |= id;
            }
        }
    }

    int part1(int id) {
        int[Coord] intersections;
        auto start = Coord(0, 0);
        foreach (k, v; grid) {
            if (v == id) {
                intersections[k] = manhattan_distance(k, start);
            }
        }
        int[] dists = intersections.values.sort.array;
        return dists[1];
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
    grid.plot(input[0], 1);
    grid.plot(input[1], 2);
    writeln(grid.part1(1|2));
}
