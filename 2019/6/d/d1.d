import std;

void main() {
    Tuple!(string, string)[] input = slurp!(string, string)("input.txt", "%s)%s");
    string[string] orbitals;
    
    foreach (pair; input) {
        orbitals[pair[1]] = pair[0];
    }

    ulong totalOrbit;
    foreach (sat; orbitals.keys) {
        ++totalOrbit;
        while (orbitals[sat] in orbitals) {
            sat = orbitals[sat];
            ++totalOrbit;
        }
    }
    writeln("part1: ", totalOrbit);
}
