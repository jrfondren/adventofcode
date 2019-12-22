import std;

struct Deal {
    enum Type { Incr, Cut, NewStack }
    Type type;
    int n;
}

T fromString(T)(char[] str) if (is(T == Deal)) {
    if (str == "deal into new stack") return Deal(Deal.Type.NewStack);
    auto res = str.matchFirst(regex(`^deal with increment (\d+)$`));
    if (res[1]) return Deal(Deal.Type.Incr, to!int(res[1]));
    res = str.matchFirst(regex(`^cut (-?\d+)$`));
    if (res[1]) return Deal(Deal.Type.Cut, to!int(res[1]));
    assert(0);
}

void cut(int n, ref int[] cards) {
    if (n > 0) {
        cards = cards.drop(n) ~ cards.take(n);
    } else if (n < 0) {
        cards = cards.drop(cards.length - abs(n)) ~ cards.take(cards.length - abs(n));
    }
}

void inc(int n, ref int[] cards) {
    int[] result;
    result.length = cards.length;
    int i = 0;
    foreach (card; cards) {
        assert(result[i] == 0);
        result[i] = card;
        i += n;
        i %= cards.length;
    }
    cards[] = result[];
}

unittest {
    int[] deck = iota(10).array;
    inc(3, deck);
    assert(deck == [0, 7, 4, 1, 8, 5, 2, 9, 6, 3]);
}

int[] shuffle(int[] cards, Deal[] strategy) {
    foreach (deal; strategy) {
        final switch (deal.type) {
            case Deal.Type.NewStack: cards = reverse(cards); break;
            case Deal.Type.Cut: cut(deal.n, cards); break;
            case Deal.Type.Incr: inc(deal.n, cards); break;
        }
    }
    return cards;
}

unittest {
    int[] deck = iota(5).array;
    assert(shuffle(deck, [Deal(Deal.Type.NewStack)]) == [4, 3, 2, 1, 0]);
    int[] deck2 = iota(5).array;
    assert(shuffle(deck2, [Deal(Deal.Type.Cut, 2)]) == [2, 3, 4, 0, 1]);
    int[] deck3 = iota(5).array;
    assert(shuffle(deck2, [Deal(Deal.Type.Cut, -2)]) == [3, 4, 0, 1, 2]);
    int[] deck4 = iota(10).array;
    assert(shuffle(deck4, [Deal(Deal.Type.Incr, 3)]) == [0, 7, 4, 1, 8, 5, 2, 9, 6, 3]);
}

void main(string[] args) {
    enforce(args.length == 2, "usage: <file>");
    Deal[] input = File(args[1]).byLine.map!(fromString!Deal).array;
    int[] cards = iota(10_007).array;
    cards = shuffle(cards, input);
    writeln("part1: ", cards.countUntil(2019));
}
