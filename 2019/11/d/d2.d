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
    bot.hull[Coord(BigInt(0), BigInt(0))] = true;
    try {
        while (true) {
            send(tid, bot.atop ? BigInt(1) : BigInt(0));
            bool color, turnright;
            receive((BigInt i) { if (i > 0) color = true; });
            receive((BigInt i) { if (i > 0) turnright = true; });
            bot.paint(color, turnright);
        }
    } catch (LinkTerminated e) { }
    writeln("part2:");
    auto top = bot.painted.keys.map!(c => c.y).minElement;
    auto left = bot.painted.keys.map!(c => c.x).minElement;
    auto bottom = bot.painted.keys.map!(c => c.y).maxElement;
    auto right = bot.painted.keys.map!(c => c.x).maxElement;
    assert([top, left, bottom, right] == [0, 0, 5, 42]);
    foreach (y; 0 .. 5 + 1) {
        foreach (x; 0 .. 42+1) {
            auto c = Coord(BigInt(x), BigInt(y));
            if (c in bot.hull) {
                if (bot.hull[c]) write('#');
                else write(' ');
            } else write(' ');
        }
        writeln;
    }
}
