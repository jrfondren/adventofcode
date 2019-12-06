#! /usr/bin/env dub
/+ dub.sdl:
    dependency "dgraph" version="~>0.0.2"
+/
/++
    In a previous year I tried to solve one of these graph problems without
    resort to a graphing library, and I ended up giving up on the star
    completely.

    Not this year.

    Even though I got the star, for the first time this year my part2 rank was
    worse than my part1 rank, due to how much time I spent on trying to figure
    out how I could put dgraph to any use.
+/
void main() {
    import std.stdio : writeln;
    import std.file : slurp;
    import std.typecons : Tuple;
    import std.algorithm : filter, minElement;
    import dgraph.graph : IndexedEdgeList;

    Tuple!(string, string)[] input = slurp!(string, string)("input.txt", "%s)%s");
    ulong[string] vert;
    ulong[] edges;
    
    foreach (pair; input) {
        foreach (x; pair)
            if (x !in vert)
                vert[x] = vert.length;
        edges ~= [vert[pair[0]], vert[pair[1]]];
    }

    auto g = new IndexedEdgeList!false;
    g.vertexCount = edges.length;
    g.addEdge(edges);

    bool[ulong] seen;
    int findsanta(ulong from, int count) {
        if (from == vert["SAN"]) {
            return count;
        } else {
            seen[from] = true;
            int[] results;
            foreach (x; g.neighborsOut(from).filter!(n => n !in seen)) {
                results ~= findsanta(x, count+1);
            }
            return results.length ? results.minElement : int.max;
        }
    }

    writeln("part2: ", findsanta(vert["YOU"], 0)-2);
}
