/++
    Conversion of fast.pl to D

    ... I had some trouble with this one.

    Mainly, I forgot to +1 in nextIncreasing and so thought I had severe
    performance problems through many iterations of this that were probably
    just an infinite loop.

    Still, this is quite speedy.
+/
import std.conv : to;

class DoubleCounter(T) {
    import std.typecons : Tuple;
    import std.algorithm : canFind;
    import std.range : iota;
    char[][] doubles;
    char[][] triples;

    this() {
        foreach (n; iota('0', '9'+1)) {
            char c = cast(char) n;
            doubles ~= [c, c];
            triples ~= [c, c, c];
        }
    }

    void nextIncreasing(ref char[] digits) {
        digits = to!string(to!int(digits)+1).dup;
        foreach (i; 1 .. digits.length) {
            while (true) {
                if (digits[i] < digits[i - 1])
                    ++digits[i];
                else
                    break;
            }
        }
    }

    Tuple!(T, "part1", T, "part2") solve(char[] n, char[] end) {
        int p1, p2;
        while (n.length < end.length || n <= end) {
            bool part1;
            foreach (i; 0 .. 10) {
                if (n.canFind(doubles[i])) {
                    part1 = true;
                    if (!n.canFind(triples[i])) {
                        ++p2;
                        break;
                    }
                }
            }
            if (part1) ++p1;
            nextIncreasing(n);
        }
        return typeof(return)(p1, p2);
    }
}

void main(string[] args) {
    import std.exception : enforce;
    import std.stdio : writeln;

    enforce(args.length == 3, "usage: " ~ args[0] ~ " <start> <end>");
    auto answer = new DoubleCounter!int().solve(args[1].dup, args[2].dup);
    writeln("part 1: ", answer.part1);
    writeln("part 2: ", answer.part2);
}
