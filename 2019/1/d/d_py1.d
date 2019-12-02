import std;

void main() {
    int[]
        a = slurp!int("input.txt", "%d").array,
        b = [];
    while (a.any!(n => n > 0)) {
        a = a.map!(n => n/3-2 > 0 ? n/3-2 : 0).array;
        b ~= a.sum;
    }
    writeln("part1: ", b[0], " part2: ", b.sum);
}
