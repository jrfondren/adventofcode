import std;

auto pattern(int nth) {
    enum base = [0, 1, 0, -1];
    return base.map!(n => n.repeat(nth)).joiner.repeat.joiner.drop(1);
}

int[] apply(int[] ns) {
    return ns.length.to!int.iota.map!(i => zip(ns, pattern(i+1)).map!"a[0] * a[1]".sum.abs % 10).array;
}

unittest {
    assert(apply([1,2,3,4,5,6,7,8]) == [4, 8, 2, 2, 6, 1, 5, 8]);
}

int[] phases(int n, int[] ns) {
    foreach (i; 0 .. n) ns = ns.apply;
    return ns;
}

int[] split(int n) pure {
    return to!string(n).split;
}

int[] split(string s) pure {
    return s.chunks(1).map!(to!int).array;
}

string join(int[] ns) pure {
    return ns.map!(to!string).joiner.array.to!(char[]).idup;
}

unittest {
    assert(phases(4, [1,2,3,4,5,6,7,8]) == [0, 1, 0, 2, 9, 4, 9, 8]);
    assert(phases(4, split(12345678)).join == "01029498");
    assert(phases(100, "80871224585914546619083218645595".split).join.take(8).array == "24176176");
    assert(phases(100, "19617804207202209144916044189917".split).join.take(8).array == "73745418");
    assert(phases(100, "69317163492948606335995924319873".split).join.take(8).array == "52432133");
}

void runtotaldig(const int[] ns, ref int[] result) {
    result[0] = ns[0];
    foreach (i; iota(1, ns.length)) {
        result[i] = ns[i] + result[i - 1];
    }
    foreach (i; iota(ns.length)) {
        result[i] = result[i] % 10;
    }
}

string part2(int[] input) {
    auto latter = input.repeat(10000).joiner.array.drop(input.take(7).join.to!int).array;
    reverse(latter);
    int[] copy;
    copy.length = latter.length;
    foreach (i; 0 .. 100) {
        runtotaldig(latter, copy);
        auto t = copy;
        copy = latter;
        latter = t;
    }
    reverse(latter);
    return latter.take(8).map!"a % 10".array.join;
}

unittest {
    assert(part2("03036732577212944063491565474664".split) == "84462026");
    assert(part2("02935109699940807407585447034323".split) == "78725270");
    assert(part2("03081770884921959731165446850517".split) == "53553731");
}

void main(string[] args) {
    enforce(args.length == 2, "usage: <file>");
    int[] input = File(args[1]).readln.chomp.chunks(1).map!(to!int).array;
    writeln("part1: ", phases(100, input).take(8).join);
    writeln("part2: ", part2(input));
}
