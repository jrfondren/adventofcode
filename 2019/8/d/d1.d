/++
    Day 8, both stars.

    The comment pretty much tells the story of how this day went.
+/
import std;

void main() {
    dchar[][] input = File("input.txt").readln.chomp.array.chunks(6 * 25).array;
    auto minzero = input
        .dup // 7-Dec-2019 NEVER FORGET: sort mutates.
        .sort!(function(a, b) { return a.count('0') < b.count('0'); })
        .front;
    auto part1 = minzero.count('1') * minzero.count('2');
    writeln("part1: ", part1);

    auto visible = input[0];
    foreach (layer; input[1..$]) {
        foreach (i, c; layer) {
            if (visible[i] == '2')
                visible[i] = c;
        }
    }

    writeln("part2:");
    visible.translate([
        '0': ' ',
        '1': '*',
        '2': '.',
    ]).chunks(25).each!writeln;
}
