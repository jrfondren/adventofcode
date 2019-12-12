import std;

struct Moon {
    int[3] loc;
    int[3] vel;

    void gravity(Moon other) {
        foreach (dim; 0 .. 3) {
            if (loc[dim] > other.loc[dim]) {
                --vel[dim];
                ++other.vel[dim];
            } else if (loc[dim] < other.loc[dim]) {
                ++vel[dim];
                --other.vel[dim];
            }
        }
    }

    void velocity() {
        loc[] += vel[];
    }

    int potential() {
        return loc[].map!"abs(a)".sum;
    }

    int kinetic() {
        return vel[].map!"abs(a)".sum;
    }

    int energy() {
        return potential() * kinetic();
    }
}

void step(ref Moon[] input) {
    foreach (i; iota(input.length)) {
        foreach (j; iota(input.length).filter!(n => n != i)) {
            input[i].gravity(input[j]);
        }
    }
    input.each!"a.velocity";
}

void part1(Moon[] input) {
    foreach (i; 0 .. 1000) step(input);
    writeln("part1: ", input.map!"a.energy".sum);
}

ulong cycle(Moon[] input, int dim) {
    int[] slice() {
        return input.map!(m => [m.loc[dim], m.vel[dim]]).joiner.array;
    }
    const start = slice;
    ulong steps = 1;
    step(input);
    while (slice != start) {
        ++steps;
        step(input);
    }
    return steps;
}

void main(string[] args) {
    enforce(args.length == 2, "usage: <file>");
    auto input = slurp!(int, int, int)(args[1], "<x=%d, y=%d, z=%d>")
        .map!(p => Moon([p[0], p[1], p[2]])).array;

    part1(input.dup);

    writeln("part2:");
    enum dims = "xyz";
    foreach (dim; 0 .. 3) {
        writeln(dims[dim], " cycle length: ", cycle(input.dup, dim));
    }
}

