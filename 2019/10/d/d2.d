import std;

struct Sighting {
    real dist, angle;
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
            angle = atan2(cast(real)(y - other.y), cast(real)(x - other.x));
        return Sighting(c, angle);
    }
}

Coord[] can_see(Coord from, const ref bool[Coord] asteroids) {
    Coord[real] can_see;
    foreach (roid; asteroids.keys) {
        if (from == roid) continue;
        auto s = from.sight(roid);
        if (s.angle in can_see) {
            auto s2 = from.sight(can_see[s.angle]);
            if (s.dist < s2.dist) {
                can_see[s.angle] = roid;
            }
        } else {
            can_see[s.angle] = roid;
        }
    }
    return can_see.values;
}

bool obscures(Coord from, Coord a, Coord b) {
    Sighting ab = from.sight(a), bb = from.sight(b);
    return ab.angle == bb.angle && ab.dist < bb.dist;
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

Nullable!Coord would_vaporize(Coord from, real angle, const ref bool[Coord] asteroids) {
    typeof(return) result;
    real dist = real.max;
    foreach (roid; asteroids.keys) {
        auto s = from.sight(roid);
        if (approxEqual(s.angle, angle) && s.dist < dist) {
            dist = s.dist;
            result = nullable(roid);
        }
    }
    return result;
}

void main() {
    auto input = slurp!string("input.txt", "%s");
    bool[Coord] asteroids;
    auto laser = Coord(17, 23);
    auto aim = PI_2;
    foreach (row; iota(cast(int) input.length)) {
        foreach (column; iota(cast(int) input[0].length)) {
            switch (input[row][column]) {
                case '.': break;
                case '#': asteroids[Coord(column, row)] = true; break;
                case 'X': laser = Coord(column, row); break;
                default: assert(0);
            }
        }
    }

    auto destroyed = 0;
    auto visible = can_see(laser, asteroids).map!(c => tuple(c, true)).assocArray;
    //assert(visible.length > 200);

    auto quadrant = 1;
    while (visible.length > 0) {
        auto v = would_vaporize(laser, aim, visible);
        if (!v.isNull) {
            writeln(quadrant, " ", visible.length, " laser destroyed ", ++destroyed, "th roid: ", v, " ", aim);
            visible.remove(v);
            if (destroyed == 200) {
                writeln("200th destruction: ", v);
                break;
            }
        }
        switch (quadrant) {
            case 1:
                aim *= 1.00001;
                if (aim > PI) {
                    aim *= -1;
                    quadrant = 2;
                }
                break;
            case 2:
                aim *= 0.99998;
                if (aim > -PI_2) {
                    //aim = -PI_4;
                    quadrant = 3;
                }
                break;
            case 3:
                aim *= 0.99998;
                if (aim.approxEqual(0.0)) {
                    aim = 0.0;
                    quadrant = 4;
                }
                break;
            case 4:
                aim += 0.00001;
                if (aim > PI_2) {
                    quadrant = 1;
                }
                break;
            default: assert(0);
        }
    }

}
