import std;
import std.ascii : isUpper, isLower, isAlpha, toUpper;

enum WIDTH = 121, HEIGHT = 125;

struct Coord {
    int x, y, depth;

    bool outer() {
        return x < 3 || y < 3 || x >= WIDTH - 3 || y >= HEIGHT - 3;
    }

    int manhattan_distance(Coord other) {
        return abs(other.x - x) + abs(other.y - y);
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
                    if (1 == Coord(x, y).manhattan_distance(mazepos[0])) {
                        string id = [cast(ubyte)(grid[x][y]), cast(ubyte)(grid[others[0].x][others[0].y])]
                            .sort.map!(to!char).array.idup;
                        if (id == "AA") start = mazepos[0];
                        else if (id == "ZZ") goal = mazepos[0];
                        else if (id in ids) ids[id][1] = mazepos[0];
                        else ids.require(id)[0] = mazepos[0];
                    }
                }
            }
        }
        foreach (d; 0 .. 128) {
            foreach (id; ids.keys) {
                auto from = ids[id][0], to = ids[id][1];
                from.depth = d;
                if (from.outer) {
                    if (d != 0) {
                        to.depth = d - 1;
                        portals[from] = to;
                        portals[to] = from;
                    }
                } else {
                    to.depth = d + 1;
                    portals[from] = to;
                    portals[to] = from;
                }
            }
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

    auto raw_neighbors(alias fun)(Coord pos) {
        Coord[] result;
        foreach (dir; [[0, 1], [0, -1], [1, 0], [-1, 0]]) {
            auto p2 = Coord(pos.x + dir[0], pos.y + dir[1], pos.depth);
            if (p2.x < 0 || p2.y < 0 || p2.x == WIDTH || p2.y == HEIGHT)
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

class Search {
    enum State { Open, Checked }
    State[128][HEIGHT][WIDTH] state;

    bool peek(Coord from, Coord to, Grid g, ref Coord[] opens) {
        state[from.x][from.y][from.depth] = State.Checked;
        foreach (pos; g.neighbors(from)) {
            if (pos == to) return true;
            else if (state[pos.x][pos.y][pos.depth] == State.Open)
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
    writeln("part2: ", new Search().findpos(g.start, g.goal, g));
}
