#! /usr/bin/env rdmd
/++ Translation of d1.d with:
    - unit tests
    - local imports instead of "import std"
+/

int fuelreq(int mass) {
    return mass / 3 - 2;
}

unittest {
    assert(fuelreq(12) == 2);
    assert(fuelreq(14) == 2);
    assert(fuelreq(1969) == 654);
    assert(fuelreq(100756) == 33583);
}

int fuelreqrec(int mass) {
    int reqsum;
    while (1) {
        int req = fuelreq(mass);
        if (req < 1)
            return reqsum;
        reqsum += req;
        mass = req;
    }
}

unittest {
    assert(fuelreqrec(14) == 2);
    assert(fuelreqrec(1969) == 966);
    assert(fuelreqrec(100756) == 50346);
}

void main() {
    import std.file : slurp;
    import std.algorithm : map, sum;
    import std.stdio : writeln;

    const int[] input = slurp!int("input.txt", "%d");

    writeln("part1: ", input.map!fuelreq.sum);
    writeln("part2: ", input.map!fuelreqrec.sum);
}

