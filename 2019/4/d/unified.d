/++
    Rewrite of d1.d and d2.d into nicer D and a single solution for both parts of the puzzle.
+/

bool mostlyValid(string pass) {
    if (pass.length != 6) return false;
    foreach (i, c; pass[1 .. $]) {
        if (pass[i] > c)
            return false;
    }
    return true;
}

bool chunklen(alias fun)(string pass) {
    import std.functional : unaryFun;
    import std.algorithm : any, chunkBy;
    import std.array : array;

    return pass.chunkBy!"a == b".any!(g => unaryFun!fun(g.array.length));
}

void main(string[] args) {
    import std.exception : enforce;
    import std.conv : to;
    import std.range : iota;
    import std.algorithm : filter, map;
    import std.stdio : writeln;

    enforce(args.length == 3, "usage: <low> <high>");
    immutable int
        low = to!int(args[1]),
        high = to!int(args[2]);
    int count1, count2;

    foreach (pass; iota(low, high).map!(n => to!string(n)).filter!mostlyValid) {
        if (chunklen!"a >= 2"(pass)) {
            ++count1;
            if (chunklen!"a == 2"(pass))
                ++count2;
        }
    }

    writeln("part1: ", count1);
    writeln("part2: ", count2);
}
