/++
    Silver star, very lightly adapted from day 5.

    Pretty straightforward.
+/
import std.typecons : Tuple;

enum IntOp {
    Add = 1,
    Mul = 2,
    Get = 3,
    Put = 4,
    JumpIf = 5,
    JumpElse = 6,
    Lt = 7,
    Eq = 8,
    Hlt = 99
}

int width (IntOp op) {
    final switch (op) {
        case IntOp.Add, IntOp.Mul, IntOp.Lt, IntOp.Eq:
            return 4;
        case IntOp.Get, IntOp.Put:
            return 2;
        case IntOp.JumpIf, IntOp.JumpElse:
            return 3;
        case IntOp.Hlt:
            return 1;
    }
}

enum Mode {
    Position = 0,
    Immediate = 1,
}

Tuple!(IntOp, "opcode", Mode[3], "modes") decode(int code) {
    import std.conv : to;
    typeof(return) result;
    result.opcode = to!IntOp(code % 100);
    code /= 100;
    static foreach (i; 0 .. 3) {
        result.modes[i] = to!Mode(code % 10);
        code /= 10;
    }
    return result;
}

struct Machine {
    int[] inputs, memory, outputs;
    int IP;
    bool halted;
    int output() { return memory[0]; }
    ref int at(int param, Mode[3] modes) in (param > 0 && param < 4) {
        final switch (modes[param-1]) {
            case Mode.Position:
                return memory[memory[IP+param]];
                break;
            case Mode.Immediate:
                return memory[IP+param];
                break;
        }
    }

    void tick() {
        import std.conv : to;
        import std.stdio : readf, write;
        import std.range : front, popFront;

        auto opmode = decode(memory[IP]);
        auto m = opmode.modes;
        enum outm = [Mode.Position, Mode.Position, Mode.Position];
        final switch (opmode.opcode) {
            case IntOp.Add:
                at(3, outm) = at(1, m) + at(2, m);
                break;
            case IntOp.Mul:
                at(3, outm) = at(1, m) * at(2, m);
                break;
            case IntOp.Hlt:
                halted = true;
                break;
            case IntOp.Get:
                at(1, outm) = inputs.front;
                inputs.popFront;
                break;
            case IntOp.JumpIf:
                if (at(1, m))
                    IP = at(2, m) - width(opmode.opcode);
                break;
            case IntOp.JumpElse:
                if (!at(1, m))
                    IP = at(2, m) - width(opmode.opcode);
                break;
            case IntOp.Lt:
                at(3, outm) = at(1, m) < at(2, m) ? 1 : 0;
                break;
            case IntOp.Eq:
                at(3, outm) = at(1, m) == at(2, m) ? 1 : 0;
                break;
            case IntOp.Put:
                outputs ~= at(1, m);
                break;
        }
        IP += width(opmode.opcode);
    }

    int run() {
        while (!halted) {
            tick();
        }
        return output;
    }
}

struct Amplifiers {
    Machine a, b, c, d, e;

    this(int[] inp, int[] mem) {
        import std.format : format;
        import std.exception : enforce;
        enforce(inp.length == 5, "invalid amplifier input: %s".format(inp));
        static foreach (i, amp; "abcde") {
            mixin("%c.inputs ~= inp[%d];".format(amp, i));
            mixin("%c.memory = mem;".format(amp));
        }
    }

    int run() {
        a.inputs ~= 0;
        a.run;
        b.inputs ~= a.outputs[0];
        b.run;
        c.inputs ~= b.outputs[0];
        c.run;
        d.inputs ~= c.outputs[0];
        d.run;
        e.inputs ~= d.outputs[0];
        e.run;
        return e.outputs[0];
    }
}

unittest {
    assert(Amplifiers([4,3,2,1,0], [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]).run == 43210);
    assert(Amplifiers([0,1,2,3,4], [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]).run == 54321);
    assert(Amplifiers([1,0,4,3,2], [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]).run == 65210);
}

void main() {
    import std.algorithm : map, splitter, permutations;
    import std.stdio : writeln, File;
    import std.conv : to;
    import std.string : chomp;
    import std.range : array, iota;

    const int[] input = File("input.txt").readln.chomp.splitter(',').map!(s => to!int(s)).array;

    int[] bestin;
    int best = int.min;
    foreach (ampin; iota(5).permutations) {
        int res = Amplifiers(ampin.array, input.dup).run;
        if (res > best) {
            bestin = ampin.array;
            best = res;
        }
    }
    writeln(bestin, " -> ", best);
}
