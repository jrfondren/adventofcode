module machine;

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

struct Machine {
    int[] memory;
    Tid output;
    int IP;

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

    void run() {
        import std.conv : to;

        while (true) {
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
                    return;
                case IntOp.Get:
                    receive((int i) { at(1, outm) = i; });
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
                    send(output, at(1, m));
                    break;
            }
            IP += width(opmode.opcode);
        }
    }
}

/// day 2 tests
unittest {
    auto tests = [
        [1,0,0,0,99],                       [2,0,0,0,99],
        [2,3,0,3,99],                       [2,3,0,6,99],
        [2,4,4,5,99,0],                     [2,4,4,5,99,9801],
        [1,1,1,4,99,5,6,0,99],              [30,1,1,4,2,5,6,0,99],
        [1,9,10,3,2,3,11,0,99,30,40,50],    [3500,9,10,70,2,3,11,0,99,30,40,50],
    ];
    bool test(int i) {
        auto m = Machine(tests[i * 2]);
        m.run;
        return m.memory == tests[i * 2 + 1];
    }
    assert(test(0));
    assert(test(1));
    assert(test(2));
    assert(test(3));
    assert(test(4));
}

/// day 5 tests
unittest {
    auto tid = spawn(function() {
        Machine([3,9,1,9,9,9,4,9,99,0], ownerTid).run;
    });
    send(tid, 14);
    receive((int i) { assert(i == 28); });

    immutable twice = [3,9,1,9,9,9,4,9,99,0];
    spawn(function(immutable int[] mem) {
        Machine(mem.dup, ownerTid).run;
    }, twice).send(28);
    receive((int i) { assert(i == 56); });
}

int amplify(int[] phase, immutable int[] mem) in (phase.length > 1) {
    Tid[] machines;

    foreach (n; phase[0..$-1]) {
        auto m = spawn((immutable int[] memory) {
            Tid next;
            receive((Tid tid) { next = tid; });
            Machine(memory.dup, next).run;
        }, mem);
        send(m, n); // phase setting, not 'next' tid
        machines ~= m;
    }
    machines ~= spawnLinked((immutable int[] memory) {
        Machine(memory.dup, ownerTid).run;
    }, mem);
    machines[$-1].send(phase[$-1]);

    // supply 'next' tids
    foreach (i, m; machines[0..$-1]) {
        send(m, machines[i + 1]);
    }

    machines[0].send(0); // start amplifying

    int last;
    try {
        while (true) {
            receive((int i) { last = i; machines[0].send(i); });
        }
    } catch (LinkTerminated e) { }
    return last;
}

/// day 7 tests
unittest {
    assert(amplify([4,3,2,1,0], [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]) == 43210);
    assert(amplify([0,1,2,3,4], [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]) == 54321);
    assert(amplify([1,0,4,3,2], [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]) == 65210);

    assert(amplify([9,8,7,6,5], [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]) == 139_629_729);
    assert(amplify([9,7,8,5,6], [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]) == 18216);
}
