/++
    Silver star. Had to look up regex usage from my own code.
    Fumbled the foreach-with-index by checking i-1.

    Original version hard-coded the input, otherwise this is it.
+/

import std;

bool validPassword(int n) {
    if (!(n >= 100_000 && n <= 999_999)) return false;
    string s = to!string(n);
    static auto re = ctRegex!(`([0-9])\1`);
    if (!s.match(re)) return false;
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
