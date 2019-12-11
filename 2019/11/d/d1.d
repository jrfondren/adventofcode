import machine;
import std.concurrency;
import std.bigint;
import std;

enum Dir { Up, Down, Left, Right }
struct Coord { immutable BigInt x, y; }

struct Robot {
    Dir dir;
    BigInt x, y;
    bool[Coord] hull;
    bool[Coord] painted;

    void paint(bool white, bool turnright) {
        writeln("bot at ", x, ",", y, " painting ", (white ? "white" : "black"), " and then turning ", (turnright ? "right" : "left"));
        painted[Coord(x, y)] = true;
        hull[Coord(x, y)] = white;
        if (turnright) {
            final switch (dir) {
                case Dir.Up: dir = Dir.Right; break;
                case Dir.Down: dir = Dir.Left; break;
                case Dir.Left: dir = Dir.Up; break;
                case Dir.Right: dir = Dir.Down; break;
            }
        } else {
            final switch (dir) {
                case Dir.Up: dir = Dir.Left; break;
                case Dir.Down: dir = Dir.Right; break;
                case Dir.Left: dir = Dir.Down; break;
                case Dir.Right: dir = Dir.Up; break;
            }
        }
        final switch (dir) {
            case Dir.Up: --y; break;
            case Dir.Down: ++y; break;
            case Dir.Left: --x; break;
            case Dir.Right: ++x; break;
        }
    }
    bool atop() {
        if (Coord(x, y) !in hull) hull[Coord(x, y)] = false;
        return hull[Coord(x, y)];
    }
}

unittest {
    auto bot = Robot(Dir.Up, BigInt(0), BigInt(0));
    bot.paint(true, false);
    bot.paint(false, false);
    bot.paint(true, false);
    bot.paint(true, false);
    bot.paint(false, true);
    bot.paint(true, false);
    bot.paint(true, false);
    assert(bot.painted.length == 6);
    assert(bot.x == BigInt(0) && bot.y == BigInt(-1));
}

void main() {
    immutable BigInt[] input = File("input.txt")
        .readln.chomp
        .splitter(',').map!(to!BigInt)
        .array.assumeUnique;

    auto tid = spawnLinked(function(immutable BigInt[] input) {
        Machine(input, ownerTid).run;
    }, input);
    BigInt[] output;
    auto bot = Robot(Dir.Up, BigInt(0), BigInt(0));
    immutable w = BigInt(1), b = BigInt(0);
    writeln("starting");
    try {
        while (true) {
            send(tid, bot.atop ? BigInt(1) : BigInt(0));
            bool color, turnright;
            receive((BigInt i) { if (i > 0) color = true; });
            receive((BigInt i) { if (i > 0) turnright = true; });
            bot.paint(color, turnright);
        }
    } catch (LinkTerminated e) { }
    writeln("part1 ", bot.painted.length);
}
