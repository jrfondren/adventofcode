/++
    Gold star.

    ... can you tell this is the first time I used std.concurrency, ever?

    Actually, I'm saving this as is--it's evidence. A terrible crime happened
    here. Someone needs to get to the bottom of it!

    Incredibly important fact: if a thread gets an exception and it was started
    with spawn(), it'll just silently exit.
+/
import std.typecons : Tuple;
import std.concurrency;

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

class Machine {
    string id;
    Tid next;
    int[] memory;
    int IP;
    bool blocked, halted;
    int lastSent;
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
                receive((int i) {
                    at(1, outm) = i;
                });
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
                lastSent = at(1, m);
                try { send(next, at(1, m)); } catch (Exception e) { } 
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

    static void start(string id, immutable int[] mem) {
        auto m = new Machine;
        m.id = id;
        m.memory = mem.dup;
        receive((Tid n) {
            m.next = n;
        });
        m.run();
    }
}

struct Amplifiers {
    int[] inputs, memory;

    this(int[] inp, int[] mem) {
        inputs = inp;
        memory = mem;
        import std.format : format;
        import std.exception : enforce;
        enforce(inp.length == 5, "invalid amplifier input: %s".format(inp));
    }

    int run() {
        import std.exception : assumeUnique;
        auto
            atid = spawn(&Machine.start, "a", memory.idup),
            btid = spawn(&Machine.start, "b", memory.idup),
            ctid = spawn(&Machine.start, "c", memory.idup),
            dtid = spawn(&Machine.start, "d", memory.idup),
            etid = spawnLinked(&Machine.start, "e", memory.idup);
        send(atid, inputs[0]);
        send(atid, 0);
        send(btid, inputs[1]);
        send(ctid, inputs[2]);
        send(dtid, inputs[3]);
        send(etid, inputs[4]);
        send(atid, btid);
        send(btid, ctid);
        send(ctid, dtid);
        send(dtid, etid);
        send(etid, thisTid);
        int last;
        try {
            while (true) {
                receive(
                    (int i) { last = i; send(atid, i); },
                );
            }
        } catch (LinkTerminated e) { }
        return last;
    }
}

unittest {
    assert(Amplifiers([9,8,7,6,5], [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]).run == 139_629_729);
    assert(Amplifiers([9,7,8,5,6], [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]).run == 18216);
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
    foreach (ampin; iota(5, 10).permutations) {
        int res = Amplifiers(ampin.array, input.dup).run;
        if (res > best) {
            bestin = ampin.array;
            best = res;
        }
    }
    writeln(bestin, " -> ", best);
}
