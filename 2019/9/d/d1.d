/++
    Silver and Gold solution (with different parameters to send())

    This is super rough but I've got a long Monday.

    s/int/BigInt/ was easy.
    s/array of memory/table of memory/ was easy.

    Actually most things were easy and this was a good day for getting punished
    for not thinking too deeply about the problem, vs. the problem of other
    days which was unfamiliarity with what D had to offer.

    The single disappointment: no tracebacks for exceptions in other threads.
    Luckily I could debug by getting the exception to happen in the main
    thread, but this is what the weird Tid.init test is about in machine.d
+/
import machine;
import std.concurrency;
import std.bigint;

void main() {
    import std.algorithm : map, splitter;
    import std.stdio : writeln, File;
    import std.conv : to;
    import std.string : chomp;
    import std.range : iota, array;
    import std.exception : assumeUnique;

    immutable int[] input = File("input.txt")
        .readln.chomp
        .splitter(',').map!(to!int)
        .array.assumeUnique;

    auto tid = spawnLinked(function(immutable int[] input) {
        Machine(input, ownerTid).run;
    }, input);
    send(tid, BigInt("2"));
    BigInt[] output;
    try {
        while (true) {
            receive((BigInt i) { output ~= i; });
        }
    } catch (LinkTerminated e) { }
    writeln(output);
}
