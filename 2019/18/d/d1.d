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
    Coord entrance;

    char opIndex(Coord c) const { return grid[c.x][c.y]; }
    char opIndex(int x, int y) const { return grid[x][y]; }

    this(string map) {
        Coord pos;
        foreach (string line; map.chomp.splitter('\n')) {
            foreach (char c; line) {
                if (c == '@') {
                    grid[pos.x][pos.y] = '.';
                    entrance = pos;
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
    Coord you;
    Keys keys;
    int steps;

    this(Grid g) {
        grid = g;
        you = g.entrance;
        foreach (k; 0 .. 26) {
            if (g.keys[k] != Coord.init)
                keys.keys[k] = true;
        }
    }

    void draw(const char[] highlights = "") {
        foreach (y; 0 .. 81) {
            foreach (x; 0 .. 81) {
                if (highlights.length && y == you.y && x == you.x)
                    write("\x1b[32;1m@\x1b[0m");
                else if (y == you.y && x == you.x)
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
        writeln("Steps: ", steps);
    }

    /// expensive, for simple tests
    void grab(char key) {
        scope search = new Search();
        search.findKeys(you, this);
        grab(key, search.keys.find!(t => t.key == key).front.dist);
    }

    void grab(char key, int stepsto) {
        keys.grab(key);
        you = grid.keys[key - 'a'];
        steps += stepsto;
    }
}

unittest {
    enum map = q"map
#########
#b.A.@.a#
#########
map";
    auto g = Maze(new Grid(map));
    g.grab('a');
    g.grab('b');
    assert(g.steps == 8);
}

unittest {
    enum map = q"map
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################
map";
    Maze g1 = Maze(new Grid(map));
    Maze g2 = g1;
    foreach (key; "abcdef")
        g1.grab(key);
    assert(g1.steps == 86);
    foreach (key; "abcedf")
        g2.grab(key);
    assert(g2.steps == 114);
}

class Plan {
    Maze maze;
    ubyte[] plan;
    bool[26] keysGrabbed;
    bool done;

    void grab(char key, int dist, int limit) {
        maze.grab(key, dist);
        if (maze.steps > limit)
            done = true;
        else {
            plan ~= key;
            keysGrabbed[key - 'a'] = true;
        }
    }

    this(Plan other) {
        maze = other.maze;
        plan = other.plan.dup;
        keysGrabbed = other.keysGrabbed;
    }

    this(Maze m) {
        maze = m;
    }
}

alias PlayResult = Tuple!(int, "steps", char[], "plan");

void advance(Plan p, ref Plan[] plans, ref PlayResult result) {
    scope search = new Search();
    switch (search.findKeys(p.maze.you, p.maze)) {
        case 0:
            p.done = true;
            if (p.maze.steps < result.steps) {
                result.steps = p.maze.steps;
                result.plan = cast(char[]) p.plan;
                writeln("new best: ", result);
            }
            break;
        default:
            foreach (keydist; search.keys.drop(1)) {
                if (p.maze.steps + keydist.dist < result.steps) {
                    plans ~= new Plan(p);
                    plans[$ - 1].grab(keydist.key, keydist.dist, result.steps);
                }
            }
            auto keydist = search.keys[0];
            p.grab(keydist.key, keydist.dist, result.steps);
            break;
    }
}

void join(Plan p, size_t pi, ref Plan[] plans) {
    ubyte last = p.plan[$ - 1];
    int steps = p.maze.steps;
    foreach (i; 0 .. plans.length) {
        if (i == pi) continue;
        if (steps != plans[i].maze.steps) continue;
        if (last != plans[i].plan[$ - 1]) continue;
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
#########
#b.A.@.a#
#########
map";
    auto g = Maze(new Grid(map));
    auto res = play(g, 10);
    assert(res.steps == 8);
    assert(res.plan == "ab");
}

unittest {
    enum map = q"map
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################
map";
    auto g = Maze(new Grid(map));
    auto res = play(g, 90);
    assert(res.steps == 86);
    assert(res.plan == "abcdef");
}

unittest {
    enum map = q"map
########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################
map";
    auto g = Maze(new Grid(map));
    auto res = play(g, 135);
    assert(res.steps == 132);
    assert(res.plan == "bacdfeg");
}

unittest {
    enum map = q"map
#################
#i.G..c...e..H.p#
########.########
#j.A..b...f..D.o#
########@########
#k.E..a...g..B.n#
########.########
#l.F..d...h..C.m#
#################
map";
    auto g = Maze(new Grid(map));
    auto res = play(g, 140);
    assert(res.steps == 136);
    writeln(res.plan);
    assert(res.plan == "afbjgnhdloepcikm" || res.plan == "cefdlhmakobjgnip" || res.plan == "dhgciepakbjfonml" || res.plan == "bfceakdlhmgnjoip");
}

unittest {
    enum map = q"map
########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################
map";
    auto g = Maze(new Grid(map));
    auto res = play(g, 85);
    assert(res.steps == 81);
    assert(res.plan == "acfidgbeh" || res.plan == "acdgfibeh");
}

void main(string[] args) {
    auto g = Maze(new Grid(readText("input.txt")));
    g.draw;
    auto res = play(g, 3348);
    File("sols.log", "a").writeln(res.steps, " ", res.plan);
    writeln(res);
}
