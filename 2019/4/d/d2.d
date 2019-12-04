/++
    Gold star. Tried to reuse regex solution but std.regex doesn't have
    zero-width negative lookbehinds. 99% of dev time went towards getting the
    chunkBy usage right, including that the 's' in the map is not an array but
    a range (named Group) that lacks a .length method.

    Advent of Code really punishes / encourages familiarity with your tools.
+/
import std;

bool validPassword(int n) {
    if (!(n >= 100_000 && n <= 999_999)) return false;
    string s = to!string(n);
    if (!s.chunkBy!"a == b".map!(s => s.array.length).any!"a == 2") return false;
    foreach (i, c; s[1..$]) {
        if (s[i] > c) return false;
    }
    return true;
}

void main(string[] args) {
    enforce(args.length == 3, "usage: <low> <high>");
    immutable auto input = tuple(to!int(args[1]), to!int(args[2]));
    int count;
    foreach (p; input[0] .. input[1]) {
        if (validPassword(p))
            ++count;
    }
    writeln(count);
}
