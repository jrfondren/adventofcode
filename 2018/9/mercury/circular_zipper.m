:- module circular_zipper.
:- interface.
:- import_module zipper.

:- pred circle_next(zipper(T)::in, zipper(T)::out) is det.

:- pred circle_next(int::in, zipper(T)::in, zipper(T)::out) is det.

:- pred circle_previous(zipper(T)::in, zipper(T)::out) is det.

:- pred circle_previous(int::in, zipper(T)::in, zipper(T)::out) is det.

:- pred circle_delete_right(zipper(T)::in, zipper(T)::out) is det.

:- implementation.
:- import_module int, exception.

circle_next(Z0, Z) :-
    (
        next(Z0, Z1)
    ->
        Z1 = Z
    ;
        start(Z0, Z)
    ).

circle_previous(Z0, Z) :-
    (
        previous(Z0, Z1)
    ->
        Z1 = Z
    ;
        end(Z0, Z)
    ).

circle_delete_right(Z0, Z) :-
    (
        delete_right(Z0, Z1)
    ->
        Z1 = Z
    ;
        (
            delete_left(Z0, Z2)
        ->
            start(Z2, Z)
        ;
            throw(software_error("tried to delete last element of zipper"))
        )
    ).

circle_next(N, !Z) :-
    ( N > 0 -> circle_next(!Z), circle_next(N - 1, !Z); true ).

circle_previous(N, !Z) :-
    ( N > 0 -> circle_previous(!Z), circle_previous(N - 1, !Z); true ).

