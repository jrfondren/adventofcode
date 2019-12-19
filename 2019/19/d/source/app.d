import machine;
import std.concurrency;
import std.bigint;
import std;
import nice.curses;
import core.thread : Thread;

immutable BigInt[] input;
shared static this() {
    input = File("input.txt")
        .readln.chomp
        .splitter(',').map!(to!BigInt)
        .array.assumeUnique;
}

bool tractored(int x, int y) {
    auto tid = spawn(function(immutable BigInt[] input) {
        Machine(input, ownerTid).run;
    }, input);
    tid.send(x);
    tid.send(y);
    int r;
    receive(
        (BigInt i) {
            r = to!int(i);
        }
    );
    assert(r == 1 || r == 0);
    return r == 1;
}

alias memotractor = memoize!tractored;

bool fits(int blx, int bly) {
    foreach (x; blx .. blx + 100) {
        foreach (y; bly - 99 .. bly + 1) {
            if (!memotractor(x, y)) return false;
        }
    }
    return true;
}

void draw(int startx, int starty, int size) {
    foreach (y; starty .. starty + 20) {
        foreach (x; startx .. startx + size) {
            write(memotractor(x, y) ? '#' : '.');
        }
        writeln;
    }
}

int startx(int x, int y) {
    foreach (x2; x .. x + 50) {
        if (memotractor(x2, y))
            return x2;
    }
    return x;
}

void main(string[] args) {
    int x = 1052;
    foreach (y; 1263 .. 5000) {
        if (!memotractor(x, y)) x = startx(x, y);
        if (fits(x, y)) {
            File("sols.log", "a").writeln(x, " ", y - 99, " ", x * 10_000 + y - 99);
            writeln(x, " ", y - 99, " ", x * 10_000 + y - 99);
            return;
        } else {
            writeln(x, " ", y);
            ++y;
        }
    }
    //writeln(width(x, y + 19, size));
}
