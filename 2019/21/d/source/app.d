import std.stdio, std.string, std.file, std.conv, std.exception;
import std.algorithm, std.array;
import std.concurrency;
import std.bigint;
import machine;

immutable BigInt[] input;
shared static this() {
    input = File("input.txt")
        .readln.chomp
        .splitter(',').map!(to!BigInt)
        .array.assumeUnique;
}

void program(Tid tid, string code) {
    foreach (c; code)
        tid.send(cast(int) c);
}

void main(string[] args) {
    auto tid = spawnLinked(function(immutable BigInt[] input) {
        auto bot = Machine(input, ownerTid);
        bot.run;
    }, input);
    enforce(args.length == 2 && (args[1] == "1" || args[1] == "2"),
            "usage: " ~ args[0] ~ " <1|2>");
    BigInt last;
    try {
        bool ready, sent;
        while (true) {
            receive(
                (BigInt i) {
                    last = i;
                    if (!(i > 0 && i < 256)) return;
                    char c = to!char(i);
                    write(c);
                    if (c == ':' || c == '?') ready = true;
                    else if (c == '\n' && ready && !sent) {
                        tid.program(readText(args[1] == "1" ? "part1.txt" : "part2.txt"));
                        sent = true;
                    }
                }
            );
        }
    } catch (LinkTerminated e) { }
    writeln("hull damage: ", last);
}
