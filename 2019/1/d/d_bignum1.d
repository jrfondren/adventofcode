import std;

T fuelreq(T)(T mass) {
    return mass / 3 - 2;
}

T fuelreqrec(T)(T mass) {
    T reqsum;
    while (1) {
        T req = mass / 3 - 2;
        if (req < 1) return reqsum;
        reqsum += req;
        mass = req;
    }
}

void main() {
    BigInt[] input = slurp!string("biginput.txt", "%s").map!BigInt.array;
    writeln("part2: ", input.map!fuelreq.sum);
    writeln("part2: ", input.map!fuelreqrec.sum);
}
