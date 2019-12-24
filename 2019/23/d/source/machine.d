module machine;

import std.typecons : Tuple;
import std.concurrency;
import std.bigint;
import std.conv : to;
import std.algorithm : map;
import std.array : array;

enum IntOp {
    Add = 1,
    Mul = 2,
    Get = 3,
    Put = 4,
    JumpIf = 5,
    JumpElse = 6,
    Lt = 7,
    Eq = 8,
    Rbo = 9,
    Hlt = 99
}

int width (IntOp op) {
    final switch (op) {
        case IntOp.Add, IntOp.Mul, IntOp.Lt, IntOp.Eq:
            return 4;
        case IntOp.Get, IntOp.Put, IntOp.Rbo:
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
    Relative = 2,
}

Tuple!(IntOp, "opcode", Mode[3], "modes") decode(BigInt bigcode) {
    int code = to!int(bigcode);
    typeof(return) result;
    result.opcode = to!IntOp(code % 100);
    code /= 100;
    foreach (i; 0 .. 3) {
        result.modes[i] = to!Mode(code % 10);
        code /= 10;
    }
    return result;
}

struct Machine {
    BigInt[BigInt] memory;
    Tid output;
    BigInt IP, RB;

    this(const int[] mem) {
        this(mem.map!(to!BigInt).array);
    }

    this(const int[] mem, Tid outp) {
        this(mem.map!(to!BigInt).array, outp);
    }

    this(const BigInt[] mem) {
        foreach (i, n; mem)
            memory[to!BigInt(i)] = n;
    }

    this(const BigInt[] mem, Tid outp) {
        this(mem);
        output = outp;
    }

    BigInt at(int param, Mode[3] modes)
        in { assert(param > 0 && param < 4); }
    body {
        BigInt get(BigInt addr) {
            if (addr !in memory)
                memory[addr] = BigInt.init;
            return memory[addr];
        }
        final switch (modes[param-1]) {
            case Mode.Position:
                return get(get(IP+param));
            case Mode.Immediate:
                return get(IP+param);
            case Mode.Relative:
                return get(RB+get(IP+param));
        }
    }
    ref BigInt write(int param, Mode[3] modes)
    in { assert(param > 0 && param < 4); }
    body {
        ref BigInt get(BigInt addr) {
            if (addr !in memory)
                memory[addr] = BigInt.init;
            return memory[addr];
        }
        final switch (modes[param-1]) {
            case Mode.Position:
            case Mode.Immediate:
                return get(get(IP+param));
            case Mode.Relative:
                return get(RB+get(IP+param));
        }
    }

    void run() {
        while (true) {
            auto opmode = decode(memory[IP]);
            auto m = opmode.modes;
            import std.stdio;
            final switch (opmode.opcode) {
                case IntOp.Add:
                    write(3, m) = at(1, m) + at(2, m);
                    break;
                case IntOp.Mul:
                    write(3, m) = at(1, m) * at(2, m);
                    break;
                case IntOp.Hlt:
                    return;
                case IntOp.Rbo:
                    RB += at(1, m);
                    break;
                case IntOp.Get:
                    import core.thread, std.datetime;
                    Thread.sleep(10.msecs);
                    send(output, thisTid);
                    receive((BigInt n) { write(1, m) = n; });
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
                    write(3, m) = at(1, m) < at(2, m) ? 1 : 0;
                    break;
                case IntOp.Eq:
                    write(3, m) = at(1, m) == at(2, m) ? 1 : 0;
                    break;
                case IntOp.Put:
                    send(output, thisTid, at(1, m));
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
        foreach (addr, n; tests[i * 2 + 1]) {
            if (m.memory[to!BigInt(addr)] != to!BigInt(n))
                return false;
        }
        return true;
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
    send(tid, BigInt("14"));
    receive((BigInt i) { assert(i == 28); });

    immutable twice = [3,9,1,9,9,9,4,9,99,0];
    spawn(function(immutable int[] mem) {
        Machine(mem.dup, ownerTid).run;
    }, twice).send(BigInt("28"));
    receive((BigInt i) { assert(i == 56); });
}

/// day 9 tests
unittest {
    Machine([109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]).run;
    Machine([1102,34915192,34915192,7,4,7,99,0]).run;
    Machine([BigInt(104),BigInt(1125899906842624),BigInt(99)]).run;
    auto tid = spawnLinked(function() {
        Machine([109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99], ownerTid).run;
    });
    BigInt[] output;
    try {
        while (true) {
            receive((BigInt i) { output ~= i; });
        }
    } catch (LinkTerminated e) { }
    assert(output == [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99].map!(to!BigInt).array);
}

BigInt amplify(int[] phase, immutable int[] mem)
in { assert(phase.length > 1); }
body {
    Tid[] machines;

    foreach (n; phase[0..$-1]) {
        auto m = spawn((immutable int[] memory) {
            Tid next;
            receive((Tid tid) { next = tid; });
            Machine(memory.dup, next).run;
        }, mem);
        send(m, to!BigInt(n)); // phase setting, not 'next' tid
        machines ~= m;
    }
    machines ~= spawnLinked((immutable int[] memory) {
        Machine(memory.dup, ownerTid).run;
    }, mem);
    machines[$-1].send(to!BigInt(phase[$-1]));

    // supply 'next' tids
    foreach (i, m; machines[0..$-1]) {
        send(m, machines[i + 1]);
    }

    machines[0].send(BigInt("0")); // start amplifying

    BigInt last;
    try {
        while (true) {
            receive((BigInt i) { last = i; machines[0].send(i); });
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

