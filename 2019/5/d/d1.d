/++
    Code as use for part1 & part2 (after modifications).

    to run part1: echo 1 | dmd -run d1
    to run part2: echo 5 | dmd -run d1

    Lost a full minute due to copy&paste error.

    Most of the time was wasted on taking '1' input as an 49 instead of 1
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
    int[] memory;
    int IP;
    bool halted;
    ref int noun() { return memory[1]; }
    ref int verb() { return memory[2]; }
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

    this(int[] mem) {
        memory = mem;
    }

    this(int[] mem, int n, int v) {
        memory = mem;
        //noun = n;
        //verb = v;
    }

    void tick() {
        import std.conv : to;
        import std.stdio : readf, write;

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
                char c;
                readf!"%c"(c);
                at(1, outm) = c - '0';
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
                write(to!string(at(1, m)));
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
    
    Machine(input.dup, 12, 2).run;
    writeln;
}
