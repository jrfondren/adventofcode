#! /usr/bin/env rdmd
import std;

int fuelreq(int mass) {
    int reqsum;
    while (1) {
        int req = mass / 3 - 2;
        if (req < 1) return reqsum;
        reqsum += req;
        mass = req;
    }
}

void main() {
    enum input = import(__FILE__).splitLines.find("__EOF__").drop(1).map!(s => to!int(s.chomp)).array;
    enum part1 = input.fold!"a + b/3-2"(0);
    enum part2 = input.map!fuelreq.sum;
    writeln("part1: ", part1);
    writeln("part2: ", part2);
}

__EOF__
