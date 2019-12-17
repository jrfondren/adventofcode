import machine;
import std.concurrency;
import std.bigint;
import std;
import nice.curses;
import core.thread : Thread;

struct Coord { int x, y; }

struct Maze {
    char[Coord] maze;

    bool look_scaffold(int x, int y) {
        auto p = Coord(x, y) in maze;
        if (!p) return false;
        return *p == '#';
    }

    ulong part1() {
        ulong result;
        foreach (pos; maze.keys) {
            if (look_scaffold(pos.x - 1, pos.y)
                    && look_scaffold(pos.x + 1, pos.y)
                    && look_scaffold(pos.x, pos.y - 1)
                    && look_scaffold(pos.x, pos.y + 1)) {
                result += pos.x * pos.y;
            }
        }
        return result;
    }
}

void program(Tid tid, string p) {
    foreach (c; p)
        tid.send(cast(int) c);
    tid.send(cast(int) '\n');
}

void main() {
    immutable BigInt[] input = File("input.txt")
        .readln.chomp
        .splitter(',').map!(to!BigInt)
        .array.assumeUnique;
    auto m = Maze();

    auto tid = spawnLinked(function(immutable BigInt[] input) {
        auto bot = Machine(input, ownerTid);
        bot.memory[BigInt(0)] = 2;
        bot.run;
    }, input);
    string[] programs = [
        "A,B,B,A,C,A,C,A,C,B",
        "R,6,R,6,R,8,L,10,L,4",
        "R,6,L,10,R,8",
        "L,4,L,12,R,6,L,10",
        "n"
    ];
    BigInt last;
    try {
        Coord pos;
        bool ready;
        while (true) {
            receive(
                (BigInt i) {
                    last = i;
                    auto c = to!char(i);
                    write(c);
                    if (c == ':' || c == '?') ready = true;
                    else if (c == '\n') {
                        if (ready) {
                            tid.program(programs.front);
                            programs.popFront;
                            ready = false;
                        }
                        pos.x = 0;
                        ++pos.y;
                    } else {
                        m.maze[pos] = c;
                        ++pos.x;
                    }
                }
            );
        }
    } catch (LinkTerminated e) { }
    catch (ConvOverflowException e) { }
    writeln("part1: ", m.part1);
    writeln("part2: ", last);
}
