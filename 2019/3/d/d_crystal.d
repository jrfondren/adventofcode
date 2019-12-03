/++
    D transliteration of crystal.cr
+/
import std;

int indexOf(int[][] haystack, int[] needle) {
    int index;
    foreach (hay; haystack) {
        if (hay == needle)
            return index;
        ++index;
    }
    assert(0);
}

void main() {
    int[][][] points, sorted;
    ubyte[][2] input = slurp!string("input.txt", "%s")
        .map!(line => line.splitter(',')
                .map!(move => repeat(cast(ubyte) move[0], to!int(move[1..$])).array)
                .joiner
                .array)
        .array;

    foreach (line; input) {
        int x, y;
        points ~= line.map!(delegate(ubyte c) {
            switch (c) {
                case 'R': ++x; break;
                case 'L': --x; break;
                case 'D': ++y; break;
                case 'U': --y; break;
                default: assert(0);
            }
            return [x, y];
        }).array;
    }
    sorted = [points[0].dup, points[1].dup];
    sorted[0].sort;
    sorted[1].sort;

    int part1() {
        return setIntersection(sorted[0], sorted[1])
            .map!(c => (c[0] - 0).abs + (c[1] - 0).abs)
            .minElement;
    }

    int part2() {
        return setIntersection(sorted[0], sorted[1])
            .map!(c => 2 + points[0].indexOf(c) + points[1].indexOf(c))
            .minElement;
    }

    writeln("part 1: ", part1);
    writeln("part 1: ", part2);
}
