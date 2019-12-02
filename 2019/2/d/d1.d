enum IntOp {
    Add = 1,
    Mul = 2,
    Hlt = 99
}

struct Machine {
    int[] memory;
    int IP;
    bool halted;
    ref int noun() { return memory[1]; }
    ref int verb() { return memory[2]; }
    int output() { return memory[0]; }
    ref int at(int delta) { return memory[memory[IP+delta]]; }

    this(int[] mem) {
        memory = mem;
    }

    this(int[] mem, int n, int v) {
        memory = mem;
        noun = n;
        verb = v;
    }

    void tick() {
        import std.conv : to;

        final switch (to!IntOp(memory[IP])) {
            case IntOp.Add:
                at(3) = at(1) + at(2);
                break;
            case IntOp.Mul:
                at(3) = at(1) * at(2);
                break;
            case IntOp.Hlt:
                halted = true;
                break;
        }
        IP += 4;
    }

    int run() {
        while (!halted) {
            tick();
        }
        return output;
    }
}

unittest {
    auto
        a = Machine([1,0,0,0,99]),
        b = Machine([2,3,0,3,99]),
        c = Machine([2,4,4,5,99,0]),
        d = Machine([1,1,1,4,99,5,6,0,99]);
    a.run;
    b.run;
    c.run;
    d.run;
    assert(a.memory == [2,0,0,0,99]);
    assert(b.memory == [2,3,0,6,99]);
    assert(c.memory == [2,4,4,5,99,9801]);
    assert(d.memory == [30,1,1,4,2,5,6,0,99]);
}

void main() {
    import std.algorithm : map, splitter;
    import std.stdio : writeln, File;
    import std.conv : to;
    import std.string : chomp;
    import std.range : array;

    const int[] input = File("input.txt").readln.chomp.splitter(',').map!(s => to!int(s)).array;
    
    writeln("part1: ", Machine(input.dup, 12, 2).run);

    foreach (noun; 0 .. 100) {
        foreach (verb; 0 .. 100) {
            if (Machine(input.dup, noun, verb).run == 19690720) {
                writeln("part2: ", 100 * noun + verb);
                return;
            }
        }
    }
    assert(0);
}
