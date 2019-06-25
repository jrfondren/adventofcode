:- module circle_test2.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.
:- implementation.
:- import_module circular_list.

main(!IO) :-
    io.write_string("C1: ", !IO), io.print(to_string(C1), !IO), io.nl(!IO),
    io.write_string("C2: ", !IO), io.print(to_string(C2), !IO), io.nl(!IO),
    io.write_string("C3: ", !IO), io.print(to_string(C3), !IO), io.nl(!IO),
    io.write_string("C4: ", !IO), io.print(to_string(C4), !IO), io.nl(!IO),
    io.write_string("C5: ", !IO), io.print(to_string(C5), !IO), io.nl(!IO),
    io.write_string("C6: ", !IO), io.print(to_string(C6), !IO), io.nl(!IO),
    io.write_string("C7: ", !IO), io.print(to_string(C7), !IO), io.nl(!IO),
    io.write_string(" X: ", !IO), io.print(X,  !IO), io.nl(!IO),
    io.write_string("C8: ", !IO), io.print(to_string(C8), !IO), io.nl(!IO),

    C1 = circular_list.init(42),
    next(C1, C2),
    insert(43, C2, C3),
    next(C3, C4),
    insert(0, C4, C5),
    delete(C5, C6),
    delete(C6, C7),
    get(C7, X),
    insert(0, C7, C8).
