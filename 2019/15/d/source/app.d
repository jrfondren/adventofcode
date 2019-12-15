import machine;
import std.concurrency;
import std.bigint;
import std;
import nice.curses;
import core.thread : Thread;

struct Coord {
    BigInt x, y;

    Coord look(const Dir dir) const {
        Coord pos = this;
        pos.move(dir);
        return pos;
    }

    void move(const Dir dir) {
        final switch (dir) {
            case Dir.North: --y; break;
            case Dir.South: ++y; break;
            case Dir.East: ++x; break;
            case Dir.West: --x; break;
        }
    }
}

enum Dir { North = 1, South = 2, West = 3, East = 4 }

enum Status { Wall = 0, Moved = 1, Oxygen = 2 }

enum Tile { Unknown, Empty, Wall, Oxygen }

char toChar(const Tile t) {
    final switch (t) {
        case Tile.Unknown: return ' ';
        case Tile.Empty: return '.';
        case Tile.Wall: return '#';
        case Tile.Oxygen: return '$';
    }
}

bool backtracked(Dir a, Dir b) {
    final switch (a) {
        case Dir.North: return b == Dir.South;
        case Dir.South: return b == Dir.North;
        case Dir.West: return b == Dir.East;
        case Dir.East: return b == Dir.West;
    }
}

struct Maze {
    Tile[Coord] maze;
    Coord pos;
    Dir[] moves;
    enum width = 25;
    bool found;
    uint minutes;

    void move(const Dir dir, Tile tile) {
        pos.move(dir);
        maze[pos] = tile;
        if (moves.length > 0 && dir.backtracked(moves[$ - 1]))
            --moves.length;
        else
            moves ~= dir;
    }

    void moved(const Dir dir, const Status stat) {
        final switch (stat) {
            case Status.Wall: maze[pos.look(dir)] = Tile.Wall; break;
            case Status.Moved: move(dir, Tile.Empty); break;
            case Status.Oxygen: move(dir, Tile.Oxygen); found = true; break;
        }
    }

    void draw(Window scr) {
        int adjx = 0 - (to!int(pos.x) - width), adjy = 0 - (to!int(pos.y) - width);
        foreach (y; iota(pos.y - width, pos.y + width)) {
            foreach (x; iota(pos.x - width, pos.x + width)) {
                auto
                    c = Coord(x, y),
                    t = (x == 0 && y == 0) ? 'X' : c == pos ? 'D' : c in maze ? maze[c].toChar : ' ';
                scr.addch(to!int(y) + adjy, to!int(x) + adjx, t);
            }
        }
    }

    void dump() {
        auto
            f = File("maze.out", "w"),
            top = maze.keys.map!"a.y".minElement,
            left = maze.keys.map!"a.x".minElement,
            right = maze.keys.map!"a.x".maxElement,
            bottom = maze.keys.map!"a.y".maxElement;
        foreach (y; iota(top, bottom + 1)) {
            foreach (x; iota(left, right + 1)) {
                if (x == 0 && y == 0)
                    f.write('X');
                else {
                    auto
                        c = Coord(x, y),
                        t = c == pos ? 'D' : c in maze ? maze[c].toChar : ' ';
                    f.write(t);
                }
            }
            f.writeln;
        }
    }

    void dump_moves() {
        File("moves.log", "a").writeln(moves.length);
    }

    bool filled() {
        foreach (loc; maze.keys.filter!(p => maze[p] == Tile.Empty)) {
            foreach (dir; [Dir.North, Dir.South, Dir.West, Dir.East]) {
                if (maze.require(loc.look(dir)) == Tile.Unknown)
                    return false;
            }
        }
        return true;
    }

    bool can_oxygen(Coord loc) {
        if (maze[loc] != Tile.Empty) return false;
        static foreach (dir; [Dir.North, Dir.South, Dir.West, Dir.East]) {
            if (maze.require(loc.look(dir)) == Tile.Oxygen)
                return true;
        }
        return false;
    }

    bool oxygen() {
        auto next_oxygen = maze.keys.filter!(p => this.can_oxygen(p)).array;
        if (next_oxygen.length == 0) return false;
        ++minutes;
        next_oxygen.each!(p => maze[p] = Tile.Oxygen);
        return true;
    }
}

interface Player {
    Dir move(ref Maze);
}

class Random : Player {
    Dir move(ref Maze m) {
        return choice([Dir.North, Dir.South, Dir.East, Dir.West]);
    }
}

class Searching : Player {
    ulong[Coord] seen;

    Dir move(ref Maze m) {
        Tuple!(Dir, Coord, ulong)[] moves;
        foreach (dir; [Dir.North, Dir.South, Dir.East, Dir.West]) {
            Coord next = m.pos.look(dir);
            if (next !in m.maze) {
                ++seen[next];
                return dir;
            } else if (m.maze[next] == Tile.Wall)
                continue;
            else
                moves ~= tuple(dir, next, seen.require(next));
        }
        auto move = moves.sort!"a[2] < b[2]".front;
        ++seen[move[1]];
        return move[0];
    }
}

class Manual : Player {
    Window scr;

    this(Window scr) {
        this.scr = scr;
    }

    Dir move(ref Maze m) {
        while (true) {
            switch (scr.getch) {
                case Key.left: return Dir.West;
                case Key.right: return Dir.East;
                case Key.down: return Dir.South;
                case Key.up: return Dir.North;
                default: break;
            }
        }
    }
}

void main() {
    immutable BigInt[] input = File("input.txt")
        .readln.chomp
        .splitter(',').map!(to!BigInt)
        .array.assumeUnique;
    auto curses = new Curses;
    auto scr = curses.stdscr;
    curses.setCursor(0);
    scr.erase;
    Maze m;
    m.draw(scr);
    scr.refresh;
    curses.update;
    //Player p = new Random();
    //Player p = new Manual(scr);
    Player p = new Searching();

    auto tid = spawnLinked(function(immutable BigInt[] input) {
        Machine(input, ownerTid).run;
    }, input);
    try {
        while (!m.found || !m.filled) {
            Dir move = p.move(m);
            tid.send(to!int(move));
            receive(
                (BigInt i) { m.moved(move, to!Status(to!int(i))); }
            );
            m.draw(scr);
            scr.refresh;
            curses.update;
        }
        m.dump_moves;
        tid.send(666);
    } catch (LinkTerminated e) { }
    m.dump;
    while (m.oxygen) {
        scr.addstr(42, 0, to!string(m.minutes));
        m.draw(scr);
        scr.refresh;
        curses.update;
        Thread.sleep(50.msecs);
    }
    File("minutes.out", "w").writeln(m.minutes);
    m.dump;
}
