import std.stdio, std.string, std.file, std.conv, std.exception;
import std.algorithm, std.array, std.range;
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

void main(string[] args) {
    auto tid = spawnLinked(function(immutable BigInt[] input) {
        Machine(input, ownerTid).run;
    }, input);
    try {
        int command;
        while (true) {
            char output;
            receive((BigInt i) { output = to!char(i); });
            write(output);
            if ("Command?"[command] == output) {
                ++command;
                if (output == '?') {
                    foreach (c; readln)
                        tid.send(cast(int) c);
                    command = 0;
                }
            } else {
                command = 0;
            }
        }
    } catch (LinkTerminated e) { }
}
