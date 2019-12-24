import std;

enum Tile { Empty, Bug }

struct Eris {
    Tile[5][5] area;

    Eris read(string[] lines) {
        int x, y;
        foreach (line; lines) {
            foreach (c; line.chomp) {
                switch (c) {
                    case '#': area[x++][y] = Tile.Bug; break;
                    case '.': area[x++][y] = Tile.Empty; break;
                    default: assert(0);
                }
            }
            x = 0;
            ++y;
        }
        return this;
    }

    void draw() {
        foreach (y; 0 .. 5) {
            foreach (x; 0 .. 5) {
                final switch (area[x][y]) {
                    case Tile.Empty: write('.'); break;
                    case Tile.Bug: write('#'); break;
                }
            }
            writeln;
        }
    }

    int bugs_near(int cx, int cy) {
        int result;
        if (cx > 0 && area[cx - 1][cy] == Tile.Bug) ++result;
        if (cx < 4 && area[cx + 1][cy] == Tile.Bug) ++result;
        if (cy > 0 && area[cx][cy - 1] == Tile.Bug) ++result;
        if (cy < 4 && area[cx][cy + 1] == Tile.Bug) ++result;
        return result;
    }

    void tick() {
        Tile[5][5] next;
        foreach (y; 0 .. 5) {
            foreach (x; 0 .. 5) {
                final switch (area[x][y]) {
                    case Tile.Bug:
                        switch (bugs_near(x, y)) {
                            case 1: next[x][y] = Tile.Bug; break;
                            default: next[x][y] = Tile.Empty; break;
                        }
                        break;
                    case Tile.Empty:
                        switch (bugs_near(x, y)) {
                            case 1: next[x][y] = Tile.Bug; break;
                            case 2: next[x][y] = Tile.Bug; break;
                            default: next[x][y] = Tile.Empty; break;
                        }
                        break;
                }
            }
        }
        area = next;
    }

    ulong biodiversity() {
        ulong result;
        int factor = 1;
        foreach (xy; 0 .. 25) {
            result += factor * (area[xy % 5][xy / 5] == Tile.Bug);
            factor *= 2;
        }
        return result;
    }
}

unittest {
    assert(2129920 == Eris().read(q"state
.....
.....
.....
#....
.#...
state".splitter('\n').array).biodiversity);
}

unittest {
    string[] states = [
        q"state
....#
#..#.
#..##
..#..
#....
state",
        q"state
#..#.
####.
###.#
##.##
.##..
state",
        q"state
#####
....#
....#
...#.
#.###
state",
        q"state
#....
####.
...##
#.##.
.##.#
state",
        q"state
####.
....#
##..#
.....
##...
state"
    ];
    Eris[] games = states.map!(s => Eris().read(s.splitter('\n').array)).array;
    games[0].tick;
    assert(games[0] == games[1]);
    games[1].tick;
    assert(games[1] == games[2]);
    games[2].tick;
    assert(games[2] == games[3]);
    games[3].tick;
    assert(games[3] == games[4]);
}

void main(string[] args) {
    enforce(args.length == 2, "usage: <file>");
    Eris game;
    game.read(File(args[1]).byLineCopy.array);
    game.draw;
    writeln;

    bool[immutable Tile[5][5]] history;
    while (true) {
        if (game.area in history) {
            game.draw;
            writeln("part1: ", game.biodiversity);
            return;
        }
        history[game.area] = true;
        game.tick;
    }
}
