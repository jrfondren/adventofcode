import machine;
import std.concurrency;
import std.bigint;
import std;
import nice.curses;

struct Coord { int x, y; }

enum Tile { Empty, Wall, Block, Paddle, Ball }

char toChar(Tile t) {
    final switch (t) {
        case Tile.Empty: return '.';
        case Tile.Wall: return '#';
        case Tile.Block: return '$';
        case Tile.Paddle: return '=';
        case Tile.Ball: return 'o';
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
    scr.timeout(10);
    scr.erase;
    scr.refresh;

    long score;
    int joystick = 0;
    int paddle_x;
    int ball_x;

    void draw(int x, int y, int tile) {
        if (x == -1 && y == 0)
            score = tile;
        else {
            auto t = to!Tile(tile);
            scr.addch(y, x, t.toChar);
            scr.refresh;
            curses.update;
            switch (t) {
                case Tile.Paddle: paddle_x = x; break;
                case Tile.Ball: ball_x = x; break;
                default: break;
            }
        }
    }

    auto tid = spawnLinked(function(immutable BigInt[] input) {
        auto m = Machine(input, ownerTid);
        m.memory[BigInt(0)] = BigInt(2);
        m.run;
    }, input);
    try {
        while (true) {
            int[] output;
            while (output.length != 3) {
                bool wantjoy;
                receive(
                    (BigInt i) { output ~= to!int(i); },
                    (int want) { wantjoy = true; },
                );
                if (wantjoy) {
                    /+import core.thread;
                    Thread.sleep(150.msecs);
                    try {
                        switch (scr.getch) {
                            case Key.left: joystick = -1; break;
                            case Key.right: joystick = 1; break;
                            case Key.down: joystick = 0; break;
                            default: break;
                        }
                    } catch (Exception e) { }+/
                    tid.send(joystick);
                }
            }
            draw(output[0], output[1], output[2]);
            if (ball_x < paddle_x) joystick = -1;
            else if (ball_x > paddle_x) joystick = 1;
            else joystick = 0;
        }
    } catch (LinkTerminated e) { }
    File("score", "a").writeln("score: ", score);
}
