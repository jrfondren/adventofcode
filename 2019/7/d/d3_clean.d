/++
    d1 & d2 rewrite, using machine.d
+/
import std.typecons : Tuple;

Tuple!(int[], "phase", int, "signal") brute(Range)(Range r, immutable int[] memory) {
    import machine : amplify;
    import std.algorithm : permutations;
    import std.range : array;

    typeof(return) result;
    result.signal = int.min;

    foreach (phase; r.permutations) {
        int res = amplify(phase.array, memory);
        if (res > result.signal) {
            result.phase = phase.array;
            result.signal = res;
        }
    }
    return result;
}

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

    auto
        p1 = brute(iota(5), input),
        p2 = brute(iota(5, 10), input);
    writeln("part1: ", p1.phase, " -> ", p1.signal);
    writeln("part2: ", p2.phase, " -> ", p2.signal);
}
