import std;

struct Sighting {
    real dist, angle;
    bool up, down;

    Bearing bears() {
        return Bearing(angle, up, down);
    }
}

struct Bearing {
    real angle;
    bool up, down;
}

struct Coord {
    int x, y;
    int manhattan_distance(Coord other) {
        return abs(other.x - x) + abs(other.y - y);
    }
    Sighting sight(Coord other) {
        auto
            a = cast(real) abs(other.x - x),
            b = cast(real) abs(other.y - y),
            c = sqrt(a*a + b*b),
            angle = atan(cast(real)(other.x - x) / cast(real)(other.y - y));
        if (angle == 0.0) {
            assert(this.x == other.x);
            assert(this.y != other.y);
            if (other.y > y) {
                return Sighting(c, 0.0, false, true);
            } else {
                return Sighting(c, 0.0, true);
            }
        }
        else {
            return Sighting(c, angle, this.y < other.y, this.y > other.y);
        }
    }
}

int can_see(Coord from, const ref bool[Coord] asteroids) {
    real[Bearing] can_see;
    foreach (roid; asteroids.keys) {
        if (from == roid) continue;
        auto s = from.sight(roid);
        if (s.bears !in can_see || s.dist < can_see[s.bears])
            can_see[s.bears] = s.dist;
    }
    return cast(int) can_see.length;
}

void cant_see(Coord from, const ref bool[Coord] asteroids) {
    real[Bearing] can_see;
    Coord[Bearing] seeing;
    foreach (roid; asteroids.keys) {
        if (from == roid) continue;
        auto s = from.sight(roid);
        if (s.bears !in can_see || s.dist < can_see[s.bears]) {
            can_see[s.bears] = s.dist;
            seeing[s.bears] = roid;
        }
    }
    foreach (roid; asteroids.keys) {
        if (from == roid) continue;
        auto s = from.sight(roid);
        if (s.bears !in can_see) assert(0);
        if (seeing[s.bears] != roid)
            writeln(roid, " obscured from ", from, "'s vision by ", seeing[s.bears]);
    }
}

bool obscures(Coord from, Coord a, Coord b) {
    Sighting ab = from.sight(a), bb = from.sight(b);
    return ab.bears == bb.bears && ab.dist < bb.dist;
}

unittest {
    auto
        From = Coord(0, 0),
        A = Coord(3, 1),
        B = Coord(3, 2),
        C = Coord(3, 3),
        D = Coord(2, 3),
        E = Coord(1, 3),
        F = Coord(2, 4),
        G = Coord(4, 3);
    assert(obscures(From, A, Coord(6, 2)));
    assert(obscures(From, A, Coord(9, 3)));
    assert(obscures(From, B, Coord(6, 4)));
    assert(obscures(From, B, Coord(9, 6)));
    assert(obscures(From, C, Coord(4, 4)));
    assert(obscures(From, C, Coord(5, 5)));
    assert(obscures(From, C, Coord(6, 6)));
    assert(obscures(From, C, Coord(7, 7)));
    assert(obscures(From, C, Coord(8, 8)));
    assert(obscures(From, C, Coord(9, 9)));
    assert(obscures(From, D, Coord(4, 6)));
    assert(obscures(From, D, Coord(6, 9)));
    assert(obscures(From, E, Coord(2, 6)));
    assert(obscures(From, E, Coord(3, 9)));
    assert(obscures(From, F, Coord(3, 6)));
    assert(obscures(From, F, Coord(4, 8)));
    assert(obscures(From, G, Coord(8, 6)));
    assert(!obscures(From, G, Coord(9, 7)));
    assert(!obscures(From, G, Coord(7, 6)));
}

unittest {
    assert(obscures(Coord(3, 4), Coord(2, 2), Coord(1, 0)));
}

void survey(Coord from, const ref bool[Coord] asteroids) {
    foreach (roid; asteroids.keys) {
        if (from == roid) continue;
        writefln("sighting from %s to %s: %s", from, roid, from.sight(roid));
    }
}

void main() {
    auto input = slurp!string("input.txt", "%s");
    bool[Coord] asteroids;
    foreach (row; iota(cast(int) input.length)) {
        foreach (column; iota(cast(int) input[0].length)) {
            if (input[row][column] == '#')
                asteroids[Coord(column, row)] = true;
        }
    }

    auto best = Coord(0, 0), best_sees = int.min;
    foreach (roid; asteroids.keys) {
        auto sees = roid.can_see(asteroids);
        if (sees > best_sees) {
            best = roid;
            best_sees = sees;
        }
    }
    writeln(asteroids.length);
    writeln("part1: ", best, " sees ", best_sees, " asteroids");

    writeln(can_see(Coord(5, 8), asteroids));

    //survey(Coord(5, 8), asteroids);
    writeln(obscures(Coord(5, 8), Coord(4, 7), Coord(3, 6)));
    cant_see(Coord(5, 8), asteroids);

    writeln(obscures(Coord(5, 8), Coord(6, 9), Coord(3, 6)));
    writeln(Coord(5, 8).sight(Coord(3, 6)));
    writeln(Coord(5, 8).sight(Coord(6, 9)));
}
