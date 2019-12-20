import std;
import std.ascii : isUpper, isLower, isAlpha, toUpper;

enum WIDTH = 121, HEIGHT = 125;

struct Coord {
    ubyte x, y;

    this(T)(T nx, T ny) if (isIntegral!T) {
        x = cast(ubyte) nx;
        y = cast(ubyte) ny;
    }
}

class Grid {
    char[HEIGHT][WIDTH] grid;
    Coord[Coord] portals;
    Coord start, goal;

    char opIndex(Coord c) const { return grid[c.x][c.y]; }
    char opIndex(int x, int y) const { return grid[x][y]; }

    this(string map) {
        Coord pos;
        foreach (string line; map.chomp.splitter('\n')) {
            foreach (char c; line) {
                grid[pos.x][pos.y] = c;
                ++pos.x;
            }
            ++pos.y;
            pos.x = 0;
        }
        Coord[2][string] ids;
        foreach (y; 0 .. HEIGHT) {
            foreach (x; 0 .. WIDTH) {
                if (grid[x][y].isUpper) {
                    auto others = raw_neighbors!isUpper(Coord(x, y));
                    assert(others.length==1);
                    auto mazepos = raw_neighbors!"a == '.'"(Coord(x, y)) ~ raw_neighbors!"a == '.'"(others[0]);
                    assert(mazepos.length==1);
                    string id = [cast(ubyte)(grid[x][y]), cast(ubyte)(grid[others[0].x][others[0].y])]
                        .sort.map!(to!char).array.idup;
                    if (id == "AA") start = mazepos[0];
                    else if (id == "ZZ") goal = mazepos[0];
                    else if (id in ids) ids[id][1] = mazepos[0];
                    else ids.require(id)[0] = mazepos[0];
                }
            }
        }
        foreach (id; ids.keys) {
            portals[ids[id][0]] = ids[id][1];
            portals[ids[id][1]] = ids[id][0];
        }
    }

    void draw() {
        foreach (y; 0 .. HEIGHT) {
            foreach (x; 0 .. WIDTH) {
                write(grid[x][y]);
            }
            writeln;
        }
    }

    auto raw_neighbors(alias fun)(Coord p) {
        Coord[] result;
        foreach (dir; [[0, 1], [0, -1], [1, 0], [-1, 0]]) {
            auto p2 = Coord(p.x + dir[0], p.y + dir[1]);
            if (p2.x == ubyte.max || p2.y == ubyte.max || p2.x == WIDTH || p2.y == HEIGHT)
                continue;
            if (unaryFun!fun(grid[p2.x][p2.y]))
                result ~= p2;

        }
        return result;
    }

    auto neighbors(Coord pos) {
        Coord[] result = raw_neighbors!"a == '.'"(pos);
        if (pos in portals)
            result ~= portals[pos];
        return result;
    }
}

struct Search {
    enum State { Open, Checked }
    State[HEIGHT][WIDTH] state;

    bool peek(Coord from, Coord to, Grid g, ref Coord[] opens) {
        state[from.x][from.y] = State.Checked;
        foreach (pos; g.neighbors(from)) {
            if (pos == to) return true;
            else if (state[pos.x][pos.y] == State.Open)
                opens ~= pos;
        }
        return false;
    }

    int findpos(Coord from, Coord to, Grid g) {
        int dist = 1;
        Coord[] open;
        if (peek(from, to, g, open)) return dist;
        while (open) {
            Coord[] next;
            ++dist;
            foreach (pos; open) {
                if (peek(pos, to, g, next)) return dist;
            }
            open = next;
        }
        assert(0);
    }
}

void main(string[] args) {
    auto g = new Grid(readText("input.txt"));
    writeln("part1: ", Search().findpos(g.start, g.goal, g));
}
