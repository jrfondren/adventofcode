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
    immutable int[] input = slurp!int("input.txt", "%d").assumeUnique;
    writeln("part1: ", input.fold!"a + b/3-2"(0));
    writeln("part2: ", input.map!fuelreq.sum);
}
