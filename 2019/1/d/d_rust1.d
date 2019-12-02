import std;

Tuple!(int, int) solve(int[] input) {
    return input
        .map!(s => to!int(s) / 3 - 2)
        .fold!(function Tuple!(int, int)(Tuple!(int, int) acc, int i) {
                return tuple(
                    acc[0] + i,
                    acc[1] + i.recurrence!"a[n-1] / 3 - 2".until!"a <= 0".sum
                );
            })(tuple(0, 0));
}

void main() {
    auto results = slurp!int("input.txt", "%d").solve;
    writeln("part1: ", results[0]);
    writeln("part2: ", results[1]);
}
