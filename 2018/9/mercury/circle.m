:- module circle.
:- interface.
:- import_module array.

:- type cons(T)
    --->    nil
    ;       cons(
                prev :: int,
                this :: T,
                next :: int
            ).

:- type circle(T)
    --->    circle(
                cells :: array(cons(T)),
                fill :: int,
                current :: int
            ).

:- inst circle for circle/1
    == bound(circle(array, ground, ground)).
:- mode circle_in == in(circle).
:- mode circle_di == di(circle).
:- mode circle_uo == out(circle).

    % Create a new circular list containing a single element.
    % The second parameter is the initial size of the backing array,
    % which doubles in length as necessary.
:- func init(T, int) = circle(T).
:- mode init(in, in) = (circle_uo) is det.

:- pred next(circle(T), circle(T)).
:- mode next(circle_di, circle_uo) is det.

:- pred next(int, circle(T), circle(T)).
:- mode next(in, circle_di, circle_uo) is det.

:- pred previous(circle(T), circle(T)).
:- mode previous(circle_di, circle_uo) is det.

:- pred previous(int, circle(T), circle(T)).
:- mode previous(in, circle_di, circle_uo) is det.

    % Delete current cell and change 'current' to point to the next cell.
:- pred delete(circle(T), circle(T)).
:- mode delete(circle_di, circle_uo) is det.

    % Insert a new cell after the current one, and change 'current' to point
    % to the new cell.
:- pred insert(T, circle(T), circle(T)).
:- mode insert(in, circle_di, circle_uo) is det.

:- pred get(circle(T), T).
:- mode get(circle_in, out) is det.

:- implementation.
:- import_module exception, int.

init(X, Size) = circle(A, 1, 0) :-
    array.init(Size, nil, A0),
    unsafe_set(0, cons(0, X, 0), A0, A).

next(circle(A, F, C), circle(A, F, N)) :-
    getcons(C, A, _, _, N).

next(N, !C) :-
    ( N = 0 -> true; next(!C), next(N - 1, !C) ).

previous(circle(A, F, C), circle(A, F, P)) :-
    getcons(C, A, P, _, _).

previous(N, !C) :-
    ( N = 0 -> true; previous(!C), previous(N - 1, !C) ).

:- pred error_deletelast(int::in, int::in, int::in) is det.
error_deletelast(P, C, N) :-
    (
        not P = C, not C = N
    ->
        true
    ;
        throw(software_error("can't delete last member of circular list"))
    ).

delete(circle(A0, F, C), circle(A, F, Nc)) :-
    getcons(C, A0, Pc, _, Nc),
    error_deletelast(Pc, C, Nc),
    (
        Pc = Nc
    ->
        getcons(Pc, A0, _, Xp, _),
        set(C, nil, A0, A1),
        set(Pc, cons(Pc, Xp, Pc), A1, A)
    ;
        getcons(Pc, A0, P, Xp, _),
        getcons(Nc, A0, _, Xn, N),

        set(C, nil, A0, A1),
        set(Pc, cons(P, Xp, Nc), A1, A2),
        set(Nc, cons(Pc, Xn, N), A2, A)
    ).


:- pred getcons(int, array(cons(T)), int, T, int).
:- mode getcons(in, array_ui, out, out, out) is det.
getcons(I, A, P, X, N) :-
    lookup(A, I, Cell),
    (
        Cell = nil,
        throw(software_error("invalid circle"))
    ;
        Cell = cons(P, X, N)
    ).

:- pred add(cons(T), int, array(cons(T)), array(cons(T))).
:- mode add(in, in, array_di, array_uo) is det.
add(New, I, A0, A) :-
    (
        I >= size(A0)
    ->
        resize(size(A0) * 2, nil, A0, A1)
    ;
        A0 = A1
    ),
    unsafe_set(I, New, A1, A).

insert(X, circle(A0, I, C), circle(A, F, I)) :-
    I + 1 = F,
    getcons(C, A0, Pc, Xc, Nc),
    (
        not C = Nc, not C = Pc
    ->
        getcons(Nc, A0, _, Xn, Nn),
        New = cons(C, X, Nc),
        NewC = cons(Pc, Xc, I),
        NewN = cons(I, Xn, Nn),
        unsafe_set(Nc, NewN, A0, A1),
        unsafe_set(C, NewC, A1, A2),
        add(New, I, A2, A)
    ;
        add(cons(C, X, C), I, A0, A1),
        unsafe_set(C, cons(I, Xc, I), A1, A)
    ).

get(circle(A, _, C), X) :-
    getcons(C, A, _, X, _).
