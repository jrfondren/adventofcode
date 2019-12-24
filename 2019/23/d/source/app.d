import std.stdio, std.string, std.file, std.conv, std.exception;
import std.algorithm, std.array, std.range;
import std.concurrency;
import std.bigint;
import machine;

immutable BigInt[] input;
shared static this() {
    input = File("input.txt")
        .readln.chomp
        .splitter(',').map!(to!BigInt)
        .array.assumeUnique;
}

struct Message {
    int sent;
    BigInt x, y;
}

struct InProgress {
    int partial;
    BigInt dest, x;
}

struct NAT {
    BigInt x, y;
}

struct Network {
    Tid[] servers;
    int[Tid] ids;
    Message[][] queues;
    InProgress[] outqueues;
    int informed = 0;
    NAT nat;
    bool[BigInt] nathist;
    int[] stalling;
    import std.datetime : seconds, MonoTime;
    MonoTime lastcheck;

    bool stalled() {
        if (MonoTime.currTime - lastcheck < 10.seconds) return false;
        lastcheck = MonoTime.currTime;
        return queues.all!"a.length == 0"
            && outqueues.all!"a.partial == 0"
            && stalling.sum / stalling.length > 50.0;
    }

    void start(int n) {
        lastcheck = MonoTime.currTime;
        queues.length = n;
        outqueues.length = n;
        servers.length = n;
        stalling.length = n;
        foreach (i; 0 .. n) {
            spawnLinked(function(immutable BigInt[] input) {
                Machine(input, ownerTid).run;
            }, input);
        }

        try {
            while (true) {
                receive(
                    (Tid server, BigInt n) {
                        size_t i = ids[server];
                        switch (outqueues[i].partial) {
                            case 0:
                                ++outqueues[i].partial;
                                outqueues[i].dest = n;
                                break;
                            case 1:
                                ++outqueues[i].partial;
                                outqueues[i].x = n;
                                break;
                            default:
                                if (outqueues[i].dest == 255) {
                                    writeln("part1: ", n);
                                    nat = NAT(outqueues[i].x, n);
                                } else if (outqueues[i].dest > 0 && outqueues[i].dest < servers.length) {
                                    queues[outqueues[i].dest.to!int] ~= Message(0, outqueues[i].x, n);
                                }
                                outqueues[i] = InProgress.init;
                                break;
                        }
                    },
                    (Tid server) {
                        if (server !in ids) {
                            ids[server] = informed;
                            servers[informed] = server;
                            server.send(BigInt(informed));
                            ++informed;
                        } else if (stalled && !(nat.x == 0 && nat.y == 0)) {
                            writeln("natting: ", nat);
                            queues[0] ~= Message(0, nat.x, nat.y);
                            foreach (i; iota(stalling.length)) stalling[i] = 0;
                            if (nat.y in nathist) {
                                File("sols.log", "a").writeln(nat);
                                writeln("part2: ", nat.y);
                            } else
                                nathist[nat.y] = true;
                        } else {
                            size_t i = ids[server];
                            if (queues[i].length > 0) {
                                stalling[i] = 0;
                                switch (queues[i][0].sent) {
                                    case 0:
                                        ++queues[i][0].sent;
                                        server.send(queues[i][0].x);
                                        break;
                                    default:
                                        server.send(queues[i][0].y);
                                        queues[i].popFront;
                                        break;
                                }
                            } else {
                                ++stalling[i];
                                server.send(BigInt(-1));
                            }
                        }
                    }
                );
            }
        } catch (LinkTerminated e) {
        }
    }
}

void main(string[] args) {
    auto scheduler = new ThreadScheduler;
    scheduler.start({
        Network net;
        net.start(50);
    });
}
