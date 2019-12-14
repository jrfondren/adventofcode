import std;

struct Chemical {
    int amount;
    string name;
}

struct Reaction {
    Chemical[] from, to;

    void simplify() {
        import std.numeric : gcd;
        auto b = chain(from, to).map!"a.amount".reduce!((a, b) => gcd(a, b));
        if (b == 1) return;
        foreach (ref chem; chain(from, to)) {
            chem.amount /= b;
        }
    }
}

Chemical[] chemicals(string str) {
    Chemical[] result;
    foreach (string part; str.splitter(", ").map!chomp) {
        auto parts = part.splitter(' ').array.filter!(p => p.length > 0).array;
        assert(parts.length == 2);
        result ~= Chemical(to!int(parts[0]), parts[1]);
    }
    return result;
}

struct Analysis {
    Reaction[] reactions;
    int[string] outputs; // index into reactions
    ulong[string] ranks;

    ulong cost(long[string] needs) {
        while (needs.keys.any!(c => c != "ORE" && needs[c] > 0)) {
            foreach (reqname; needs.keys.filter!(c => c != "ORE" && needs[c] > 0)) {
                foreach (chem; reactions[outputs[reqname]].from) {
                    needs[chem.name] += chem.amount;
                }
                needs[reqname] -= reactions[outputs[reqname]].to[0].amount;
            }
        }
        return needs["ORE"];
    }
    void recost(real target) {
        long[string] needs = ["FUEL": 0];
        long count, last;
        while (true) {
            ++count;
            ++needs["FUEL"];
            while (needs.keys.any!(c => c != "ORE" && needs[c] > 0)) {
                foreach (reqname; needs.keys.filter!(c => c != "ORE" && needs[c] > 0)) {
                    foreach (chem; reactions[outputs[reqname]].from) {
                        needs[chem.name] += chem.amount;
                    }
                    needs[reqname] -= reactions[outputs[reqname]].to[0].amount;
                }
            }
            auto ore = needs["ORE"];
            writefln("%d -> %d (+%d) (%.2f)", count, ore, ore - last, target / cast(real) ore);
            last = ore;
            if (ore > target) return;
        }
    }
}

Analysis analyze(Reaction[] input) {
    typeof(return) result;
    result.reactions = input;
    foreach (i; iota(cast(int) input.length)) {
        result.outputs[input[i].to[0].name] = i;
    }
    /+foreach (outp, i; result.outputs) {
        result.ranks[outp] = result.cost([tuple(outp, cast(long) result.reactions[i].to[0].amount)].assocArray);
    }+/
    return result;
}

void main(string[] args) {
    enforce(args.length == 2);
    Reaction[] input;
    foreach (string line; File(args[1]).lines) {
        auto parts = line.splitter("=>").array;
        assert(parts.length == 2);
        auto react = Reaction(parts[0].chemicals, parts[1].chemicals);
        assert(react.to.length == 1);
        input ~= react;
    }
    auto results = analyze(input);
    //writeln(results.cost(["FUEL": 1]));
    results.recost(1000000000000.0);
    //writeln(results.cost(["FUEL": 1000000000000]));
}
