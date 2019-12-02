auto solve(int[] input) @nogc pure {
    import std.range : recurrence;
    import std.algorithm : map, fold, sum, until;
    import std.conv : to;
    import std.typecons : tuple;

    return input.map!(m => m / 3 - 2)
        .fold!("a + b", function(a, b) {
            return a + b.recurrence!"a[n-1] / 3 - 2"
                .until!"a <= 0"
                .sum;
        })(tuple(0, 0));
}

void main() {
    import std.stdio : writeln;
    import std.file : slurp;

    auto results = slurp!int("input.txt", "%d").solve;
    writeln("part1: ", results[0]);
    writeln("part2: ", results[1]);
}
