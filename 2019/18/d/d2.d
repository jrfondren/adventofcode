import std;
import std.ascii : isUpper, isLower, isAlpha, toUpper;

struct Coord {
    ubyte x, y;

    this(T)(T nx, T ny) if (isIntegral!T) {
        x = cast(ubyte) nx;
        y = cast(ubyte) ny;
    }
}

class Grid {
    char[81][81] grid;
    Coord[26] keys;
    Coord[4] entrance;

    char opIndex(Coord c) const { return grid[c.x][c.y]; }
    char opIndex(int x, int y) const { return grid[x][y]; }

    this(string map) {
        Coord pos;
        int ents;
        foreach (string line; map.chomp.splitter('\n')) {
            foreach (char c; line) {
                if (c == '@') {
                    grid[pos.x][pos.y] = '.';
                    entrance[ents++] = pos;
                } else if (c.isLower) {
                    keys[c - 'a']  = pos;
                    grid[pos.x][pos.y] = c;
                } else
                    grid[pos.x][pos.y] = c;
                ++pos.x;
            }
            ++pos.y;
            pos.x = 0;
        }
        // for unit tests
        foreach (y; 0 .. 81) {
            foreach (x; 0 .. 81) {
                if (grid[x][y] == char.init)
                    grid[x][y] = '#';
            }
        }
        assert(ents == 4);
    }
}

struct Search {
    enum State { Unknown, Blocked, Open, Checked, Key }
    alias KeyDist = Tuple!(char, "key", int, "dist");

    State[81][81] state;
    KeyDist[] keys;

    void peek(Coord from, int dist, const ref Maze maze, ref Coord[] opens) {
        state[from.x][from.y] = State.Checked;
        foreach (pos; [[0, 1], [0, -1], [1, 0], [-1, 0]].map!(d =>
                    Coord(from.x + d[0], from.y + d[1]))) {
            if (state[pos.x][pos.y] != State.Unknown) continue;
            char c = maze.grid[pos];
            if (c == '.' || maze.keys.passable(c)) {
                state[pos.x][pos.y] = State.Open;
                opens ~= pos;
            } else if (c.isLower) {
                state[pos.x][pos.y] = State.Key;
                keys ~= KeyDist(c, dist);
            } else
                state[pos.x][pos.y] = State.Blocked;
        }
    }

    int findKeys(Coord from, const ref Maze maze) {
        int dist = 1;
        Coord[] open;
        peek(from, dist, maze, open);
        while (open) {
            Coord[] next;
            ++dist;
            open.each!(c => peek(c, dist, maze, next));
            open = next;
        }
        return cast(int) keys.length;
    }
}

struct Keys {
    bool[26] keys;

    void grab(char c) {
        assert(c.isLower);
        assert(keys[c - 'a']);
        keys[c - 'a'] = false;
    }

    bool opBinaryRight(string op)(char c) const if (op == "in") {
        if (c.isLower)
            return keys[c - 'a'];
        else if (c.isUpper)
            return keys[c - 'A'];
        else
            return false;
    }

    bool passable(char c) const {
        if (c.isLower)
            return !keys[c - 'a'];
        else if (c.isUpper)
            return !keys[c - 'A'];
        else
            return false;
    }
}

struct Maze {
    Grid grid;
    Coord[4] you;
    Keys keys;
    int[4] steps;

    this(Grid g) {
        grid = g;
        you[] = g.entrance;
        foreach (k; 0 .. 26) {
            if (g.keys[k] != Coord.init)
                keys.keys[k] = true;
        }
    }

    void draw(const char[] highlights = "") {
        foreach (y; 0 .. 81) {
            foreach (x; 0 .. 81) {
                if (highlights.length && you[].any!(p => p.x == x && p.y == y))
                    write("\x1b[32;1m@\x1b[0m");
                else if (you[].any!(p => p.x == x && p.y == y))
                    write('@');
                else if (grid[x, y] in keys && highlights.indexOf(grid[x, y]) != -1)
                    write("\x1b[31;1m", grid[x, y], "\x1b[0m");
                else if (grid[x, y].isAlpha && grid[x, y] !in keys)
                    write('.');
                else
                    write(grid[x, y]);
            }
            writeln;
        }
        writeln("Steps: ", steps[].sum);
    }

    void grab(int i, char key, int stepsto) {
        keys.grab(key);
        you[i] = grid.keys[key - 'a'];
        steps[i] += stepsto;
    }
}

class Plan {
    Maze maze;
    ubyte[] plan;
    bool[26] keysGrabbed;
    bool done;

    void grab(int i, char key, int dist, int limit) {
        maze.grab(i, key, dist);
        if (maze.steps[].sum > limit)
            done = true;
        else {
            plan ~= key;
            keysGrabbed[key - 'a'] = true;
        }
    }

    this(Plan other) {
        maze = other.maze;
        plan = other.plan.dup;
        keysGrabbed[] = other.keysGrabbed;
    }

    this(Maze m) {
        maze = m;
    }
}

alias PlayResult = Tuple!(int, "steps", char[], "plan");

void advance(Plan p, ref Plan[] plans, ref PlayResult result) {
    scope Search*[] ps = [
        new Search(), new Search(),
        new Search(), new Search()
    ];
    switch (iota(4).map!(i => ps[i].findKeys(p.maze.you[i], p.maze)).sum) {
        case 0:
            p.done = true;
            writeln(p.maze.steps[].sum);
            if (p.maze.steps[].sum < result.steps) {
                result.steps = p.maze.steps[].sum;
                result.plan = cast(char[]) p.plan;
                writeln("new best: ", result);
            }
            break;
        /+case 1:
            auto keydist = ps.find!"a.keys.length > 0".front.keys[0];
            auto i = iota(4).find!(n => ps[n].keys.length > 0).front;
            p.grab(i, keydist.key, keydist.dist, result.steps);
            break;+/
        default:
            foreach (i; iota(4).filter!(n => ps[n].keys.length > 0)) {
                foreach (keydist; ps[i].keys.drop(1)) {
                    if (p.maze.steps[].sum + keydist.dist < result.steps) {
                        plans ~= new Plan(p);
                        plans[$ - 1].grab(i, keydist.key, keydist.dist, result.steps);
                    }
                }
                auto keydist = ps[i].keys[0];
                plans ~= new Plan(p);
                plans[$ - 1].grab(i, keydist.key, keydist.dist, result.steps);
            }
            p.done = true;
    }
}

void join(Plan p, size_t pi, ref Plan[] plans) {
    ubyte last = p.plan[$ - 1];
    int steps = p.maze.steps[].sum;
    foreach (i; 0 .. plans.length) {
        if (i == pi) continue;
        if (steps != plans[i].maze.steps[].sum) continue;
        if (last != plans[i].plan[$ - 1]) continue;
        if (p.maze.you != plans[i].maze.you) continue;
        if (p.keysGrabbed != plans[i].keysGrabbed) continue;
        plans[i].done = true;
    }
}

PlayResult play(Maze maze, int target) {
    Plan[] plans = [new Plan(maze)];
    typeof(return) best;
    best.steps = target;
    advance(plans[0], plans, best);
    while (plans.length) {
        writeln(plans.length, " ", cast(char[]) plans[0].plan);
        foreach (i; 0 .. plans.length) {
            if (plans[i].done) continue;
            join(plans[i], i, plans);
            advance(plans[i], plans, best);
        }
        plans = plans.filter!"!(a.done)".array;
    }
    return best;
}

unittest {
    enum map = q"map
#######
#a.#Cd#
##@#@##
#######
##@#@##
#cB#Ab#
#######
map";
    auto g = Maze(new Grid(map));
    auto res = play(g, 10);
    writeln(res);
    assert(res.steps == 8);
}

unittest {
    enum map = q"map
###############
#d.ABC.#.....a#
######@#@######
###############
######@#@######
#b.....#.....c#
###############
map";
    auto g = Maze(new Grid(map));
    auto res = play(g, 30);
    writeln(res);
    assert(res.steps == 24);
}

unittest {
    enum map = q"map
#############
#DcBa.#.GhKl#
#.###@#@#I###
#e#d#####j#k#
###C#@#@###J#
#fEbA.#.FgHi#
#############
map";
    auto g = Maze(new Grid(map));
    auto res = play(g, 100);
    writeln(res);
    assert(res.steps == 32);
}

unittest {
    enum map = q"map
#############
#g#f.D#..h#l#
#F###e#E###.#
#dCba@#@BcIJ#
#############
#nK.L@#@G...#
#M###N#H###.#
#o#m..#i#jk.#
#############
map";
    auto g = Maze(new Grid(map));
    auto res = play(g, 100);
    writeln(res);
    assert(res.steps == 72);
}

void main(string[] args) {
    auto g = Maze(new Grid(readText("input.txt")));
    auto res = play(g, 2000); // 1700 too high
    File("sols.log", "a").writeln(res.steps, " ", res.plan);
    writeln(res);
}
