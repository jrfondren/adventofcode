% https://gist.github.com/bartosz-witkowski/8154124
%---------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sw=4 et wm=0 tw=0
%---------------------------------------------------------------------------%
%
% File: zipper.m.
% Authors: Bartosz Witkowski
%
% This module defines a list zipper type which is a `one-hole-context' of
% the list data structure (vide ``The Derivative of a Regular Type is its
% Type of One-Hole Contexts'' by Conor McBride).
%
% Conceptually the zipper tracks an index (Focus) that can be moved backwards
% and forwards. Elements can be inserted before or after the focused position
% and the focused item may be deleted.
%
% Based on scalaz Zipper
%
%---------------------------------------------------------------------------%
%---------------------------------------------------------------------------%

:- module zipper.
:- interface.
:- import_module list.

%---------------------------------------------------------------------------%

:- type zipper(T)
    --->    zipper(
                       list(T), % Elements conceptually before the focus.
                                % Referred to as lefts.
                       T,       % The focused element
                       list(T)  % Elements conceptually after the focus.
                                % Referred to as rights.
            ).

%---------------------------------------------------------------------------%

:- inst zipper_skel(L, F, R) ---> zipper(list_skel(L), F, list_skel(R)).
:- inst zipper_skel(I) ---> zipper(list_skel(I), I, list_skel(I)).
:- inst zipper_skel == zipper_skel(free).

:- mode in_zipper_skel == zipper_skel >> zipper_skel.
:- mode out_zipper_skel == free >> zipper_skel.
:- mode zipper_skel_out == zipper_skel >> ground.

%---------------------------------------------------------------------------%
% Initialization and construction

    % zipper.init(Focus) <=> zipper([], Focus, []).
    % Creates a zipper focused on the initial element.
:- func init(T) = zipper(T).
:- pred init(T, zipper(T)).
:- mode init(in, out) is det.

    % zipper.at_start_from_list(List, Zipper).
    % Create a zipper focused on the first element of the list. Fails if
    % `List' = [] .The resulting zipper is such that the head of `List' is
    % the focus and the tail of the list is Rights.
:- pred at_start_from_list(list(T), zipper(T)).
:- mode at_start_from_list(in, out) is semidet.

    % zipper.at_start_from_list(List, Zipper).
    % Create a zipper focused on the last element of the list. Fails iff
    % `List = []`. The resulting zipper is such that the last element of the
    % list is the focus and the reversed rest of the list is Rights.
:- pred at_end_from_list(list(T), zipper(T)).
:- mode at_end_from_list(in, out) is semidet.

%---------------------------------------------------------------------------%
% Accessors

    % zipper.lefts(Zipper) = List.
    % Returns the lefts of the zipper - the elements conceptually before the
    % focus.
:- func lefts(zipper(T)) = list(T).
:- pred lefts(zipper(T), list(T)).
:- mode lefts(in, out) is det.
:- mode lefts(in, in)  is semidet.

    % zipper.rights(Zipper) = List.
    % Returns the `Rights` of the zipper - the elements conceptually after the
    % focus.
:- func rights(zipper(T)) = list(T).
:- pred rights(zipper(T), list(T)).
:- mode rights(in, out) is det.
:- mode rights(in, in)  is semidet.

    % zipper.rights(Zipper) = List.
    % Returns the `Focus` of the zipper - the elements currently being indexed.
:- func focus(zipper(T)) = T.
:- pred focus(zipper(T), T).
:- mode focus(in,  out) is det.
:- mode focus(in,  in)  is semidet.

%---------------------------------------------------------------------------%
% Setters

    % zipper.update(Focus, Zipper) = Updated.
    % Updates the focus of `Zipper` to `Focus` giving `Updated`.
:- func update(T,  zipper(T)) = zipper(T).
:- pred update(T,  zipper(T), zipper(T)).
:- mode update(in, in,  out) is det.
:- mode update(in, in, in) is semidet.

%---------------------------------------------------------------------------%

    % zipper.to_list(Zipper) = List.
    % Creates the list represented by this zipper.
:- func to_list(zipper(T)) = list(T).
:- pred to_list(zipper(T), list(T)).
:- mode to_list(in, out) is det.
:- mode to_list(in, in) is semidet.

%---------------------------------------------------------------------------%
% Zipper predicates

    % zipper.at_end(Zipper).
    % True iff the zipper is at the end of the list (rights is empty).
:- pred at_end(zipper(T)::in) is semidet.

    % zipper.at_start(Zipper).
    % True iff the zipper is at the start of the list (lefts is empty).
:- pred at_start(zipper(T)::in) is semidet.

    % zipper.member(Elem, Zipper).
    % True iff `Zipper` contains `Elem`.
:- pred member(T, zipper(T)).
:- mode member(in, in) is semidet.

    % zipper.length(Zipper) = Length.
    % Returns the length of the zipper. The length of the zipper is the same as
    % the underlying list in other words
    % `length = length(Lefts) + 1 + % length(Rights)'.
:- func length(zipper(T)) = int.
:- pred length(zipper(T)::in, int::out) is det.


%---------------------------------------------------------------------------%
% Zipper movement

    % zipper.start(Zipper) = StartZipper.
    % Moves the focus of the zipper to the start of the list.
:- func start(zipper(T)) = zipper(T).
:- pred start(zipper(T), zipper(T)).
:- mode start(in, out) is det.
:- mode start(in, in) is semidet.

    % zipper.start(Zipper) = StartZipper.
    % Moves the focus of the zipper to the end of the list.
:- func end(zipper(T)) = zipper(T).
:- pred end(zipper(T), zipper(T)).
:- mode end(in, out) is det.
:- mode end(in, in) is semidet.

    % zipper.next(Zipper, NextZipper).
    % Moves the focus of the zipper to the next element. Fails iff rights is
    % empty.
:- pred next(zipper(T), zipper(T)).
:- mode next(in, out) is semidet.
:- mode next(in, in) is semidet.

    % zipper.previous(Zipper, PreviousZipper).
    % Moves the focus of the zipper to the previous element. Fails iff lefts is
    % empty.
:- pred previous(zipper(T), zipper(T)).
:- mode previous(in, out) is semidet.
:- mode previous(in, in) is semidet.

    % zipper.move(Num, Zipper, Moved).
    % Applies next or previous `Num` number of times (next for positive `Num',
    % previous for negative). Fails if the focus can't be moved `Num' times.
:- pred move(int, zipper(T), zipper(T)).
:- mode move(in, in, out) is semidet.
:- mode move(in, in, in) is semidet.

%---------------------------------------------------------------------------%
%  Insertion and deletion

    % zipper.insert_left(NewFocus, Zipper) = Inserted.
    % Inserts `NewFocus` to the left of the current focus and focuses on it.
:- func insert_left(T, zipper(T)) = zipper(T).
:- pred insert_left(T, zipper(T), zipper(T)).
:- mode insert_left(in, in, out) is det.
:- mode insert_left(in, in, in) is semidet.

    % zipper.insert_right(NewFocus, Zipper) = Inserted.
    % Inserts `NewFocus` to the right of the current focus and focuses on it.
:- func insert_right(T, zipper(T)) = zipper(T).
:- pred insert_right(T, zipper(T), zipper(T)).
:- mode insert_right(in, in, out) is det.
:- mode insert_right(in, in, in) is semidet.

    % zipper.delete_left(Zipper, Deleted).
    % Removes the current focus and moves the focus to the left if possible and
    % if not to the right. Fails if both lefts and rights is empty.
:- pred delete_left(zipper(T), zipper(T)).
:- mode delete_left(in, out) is semidet.
:- mode delete_left(in, in) is semidet.

    % zipper.delete_right(Zipper, Deleted).
    % Removes the current focus and moves the focus to the right if possible
    % and if not to the left. Fails if both lefts and rights is empty.
:- pred delete_right(zipper(T), zipper(T)).
:- mode delete_right(in, out) is semidet.
:- mode delete_right(in, in) is semidet.

    % zipper.delete_others(Zipper) = Deleted.
    % Removes all elements from the current zipper except the focus.
:- func delete_others(zipper(T)) = zipper(T).
:- pred delete_others(zipper(T), zipper(T)).
:- mode delete_others(in, out) is det.
%-----------------------------------------------------------------------------%
% Higher order predicates

    % zipper.map(T, L, M). uses the closure T
    % to transform the elements of L into the elements of M.
:- pred map(pred(X, Y), zipper(X), zipper(Y)).
:- mode map(pred(in, out) is det, in, out) is det.
:- mode map(pred(in, out) is cc_multi, in, out) is cc_multi.
:- mode map(pred(in, out) is semidet, in, out) is semidet.
:- mode map(pred(in, out) is multi, in, out) is multi.
:- mode map(pred(in, out) is nondet, in, out) is nondet.
:- mode map(pred(in, in) is semidet, in, in) is semidet.

:- func map(func(X) = Y, zipper(X)) = zipper(Y).


    % zipper.foldl(Pred, Zipper, Start, End) calls Pred with each
    % element of Zipper (working left-to-right) and an accumulator
    % (with the initial value of Start), and returns the final
    % value in End.
    %
:- pred foldl(pred(T, A, A), zipper(T), A, A).
:- mode foldl(pred(in, in, out) is det, in, in, out) is det.
:- mode foldl(pred(in, mdi, muo) is det, in, mdi, muo) is det.
:- mode foldl(pred(in, di, uo) is det, in, di, uo) is det.
:- mode foldl(pred(in, in, out) is semidet, in, in, out) is semidet.
:- mode foldl(pred(in, mdi, muo) is semidet, in, mdi, muo) is semidet.
:- mode foldl(pred(in, di, uo) is semidet, in, di, uo) is semidet.
:- mode foldl(pred(in, in, out) is multi, in, in, out) is multi.
:- mode foldl(pred(in, in, out) is nondet, in, in, out) is nondet.
:- mode foldl(pred(in, mdi, muo) is nondet, in, mdi, muo) is nondet.
:- mode foldl(pred(in, in, out) is cc_multi, in, in, out) is cc_multi.
:- mode foldl(pred(in, di, uo) is cc_multi, in, di, uo) is cc_multi.

:- func foldl(func(T, A) = A, zipper(T), A) = A.

    % zipper.foldr(Pred, Ziper, Start, End) calls Pred with each
    % element of List (working right-to-left) and an accumulator
    % (with the initial value of Start), and returns the final
    % value in End.
    %
:- pred foldr(pred(T, A, A), zipper(T), A, A).
:- mode foldr(pred(in, in, out) is det, in, in, out) is det.
:- mode foldr(pred(in, mdi, muo) is det, in, mdi, muo) is det.
:- mode foldr(pred(in, di, uo) is det, in, di, uo) is det.
:- mode foldr(pred(in, in, out) is semidet, in, in, out) is semidet.
:- mode foldr(pred(in, mdi, muo) is semidet, in, mdi, muo) is semidet.
:- mode foldr(pred(in, di, uo) is semidet, in, di, uo) is semidet.
:- mode foldr(pred(in, in, out) is multi, in, in, out) is multi.
:- mode foldr(pred(in, in, out) is nondet, in, in, out) is nondet.
:- mode foldr(pred(in, mdi, muo) is nondet, in, mdi, muo) is nondet.
:- mode foldr(pred(in, in, out) is cc_multi, in, in, out) is cc_multi.
:- mode foldr(pred(in, di, uo) is cc_multi, in, di, uo) is cc_multi.

:- func foldr(func(T, A) = A, zipper(T), A) = A.


    % zipper.find_by(Traverse, Pred, Zipper, Found) using the general traversal
    % predicate `Traverse' find the first element that satisfies `Pred'
    % in the given zipper `Zipper'. If the predicate succeeds the resulting
    % zipper `Found' will have the found element as the focus. Fails when the
    % given traversal predicate fails.
:- pred find_by(pred(zipper(T), zipper(T)), pred(T), zipper(T), zipper(T)).
:- mode find_by(pred(in, out) is semidet,
    pred(in) is semidet, in, out) is semidet.
:- mode find_by(pred(in, out) is semidet,
    pred(in) is semidet, in, in) is semidet.

    % zipper.find_next(Pred, Zipper, Found) finds the first element that
    % satisfies the given predicate `Pred' in the given zipper `Zipper'
    % applying `next' until the element is found or failure. If the predicate
    % succeeds the resulting zipper `Found' will have the found element as the
    % focus. Fails when the
    % zipper cannot be moved forward.
:- pred find_next(pred(T), zipper(T), zipper(T)).
:- mode find_next(pred(in) is semidet, in, out) is semidet.
:- mode find_next(pred(in) is semidet, in, in) is semidet.

    % zipper.find_previous(Pred, Zipper, Found) finds the first element that
    % satisfies the given predicate `Pred' in the given zipper `Zipper'
    % applying `previous' until the element is found or failure. If the
    % predicate succeeds the resulting zipper `Found' will have the found
    % element as the focus. Fails when the zipper cannot be moved backward.
:- pred find_previous(pred(T), zipper(T), zipper(T)).
:- mode find_previous(pred(in) is semidet, in, out) is semidet.
:- mode find_previous(pred(in) is semidet, in, in) is semidet.

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

:- implementation.

:- import_module int.

init(T) = R :- init(T, R).
init(T, zipper([], T, [])).

at_start_from_list(List, Zipper) :-
    List = [H|T],
    Zipper = zipper([], H, T).

at_end_from_list(List, Zipper) :-
    list.reverse(List) = [H|T],
    Zipper = zipper(T, H, []).

lefts(Z) = L :- lefts(Z, L).
lefts(zipper(Lefts, _, _ ), Lefts).

rights(Z) = L :- rights(Z, L).
rights(zipper(_, _, Rights ), Rights).

focus(Z) = T :- focus(Z, T).
focus(zipper(_, Focus, _ ), Focus).

to_list(Z) = T :- to_list(Z, T).
to_list(zipper(Lefts, Focus, Rights), list.reverse(Lefts) ++ [Focus] ++ Rights).

update(NewFocus, Zipper) = Updated :- update(NewFocus, Zipper, Updated).
update(NewFocus, zipper(Lefts, _OldFocus, Rights), zipper(Lefts, NewFocus, Rights)).

at_start(zipper([], _, _)).
at_end(zipper(_, _, [])).

start(Zipper0) = Zipper1 :- start(Zipper0, Zipper1).
start(zipper(Lefts, Focus, Rights), ZipperOut) :-
    List = list.reverse(Lefts) ++ [Focus] ++ Rights,
    H = list.det_head(List),
    T = list.det_tail(List),
    ZipperOut = zipper([], H, T).

end(Zipper0) = Zipper1 :- start(Zipper0, Zipper1).
end(zipper(Lefts, Focus, Rights), ZipperOut) :-
    List = list.reverse(Rights) ++ [Focus] ++ Lefts,
    H = list.det_head(List),
    T = list.det_tail(List),
    ZipperOut = zipper(T, H, []).

next(zipper(Lefts, Focus, [R|Rs]), zipper([Focus|Lefts], R, Rs)).

previous(zipper([L|Ls], Focus, Rights), zipper(Ls, L, [Focus|Rights])).

insert_right(NewFocus, Zipper1) = Zipper0 :-
    insert_right(NewFocus, Zipper1, Zipper0).
insert_right(NewFocus, zipper(Lefts, Focus, Rights),
    zipper([Focus|Lefts], NewFocus, Rights)).

insert_left(NewFocus, Zipper1) = Zipper0 :-
    insert_left(NewFocus, Zipper1, Zipper0).
insert_left(NewFocus, zipper(Lefts, Focus, Rights),
    zipper(Lefts, NewFocus, [Focus|Rights])).

delete_left(zipper(Lefts, _, Rights), ZipperOut) :-
    ( [R|Rs] = Rights ->
        ZipperOut = zipper(Lefts, R, Rs)
    ;
        [L|Ls] = Lefts,
        ZipperOut = zipper(Ls, L, [])
    ).


delete_right(zipper(Lefts, _, Rights), ZipperOut) :-
    ( [R|Rs] = Rights ->
        ZipperOut = zipper(Lefts, R, Rs)
    ;
        [L|Ls] = Lefts,
        ZipperOut = zipper(Ls, L, [])
    ).

delete_others(Zipper0) = Zipper1 :- delete_others(Zipper0, Zipper1).
delete_others(zipper(_, Focus, _), zipper([], Focus, [])).

length(Zipper) = Length :- length(Zipper, Length).
length(zipper(Lefts, _, Rights), Length) :-
    Length is list.length(Lefts) + 1 + list.length(Rights).

member(T, zipper(Lefts, Focus, Rights)) :-
    T = Focus ; list.member(T, Lefts) ; list.member(T, Rights).

map(Pred, zipper(LeftsX, X, RightsX), zipper(LeftsY, Y, RightsY)) :-
    list.map(Pred, LeftsX, LeftsY),
    Pred(X, Y),
    list.map(Pred, RightsX, RightsY).

map(F, zipper(Lefts, T, Rights)) =
    zipper(list.map(F, Lefts), F(T), list.map(F, Rights)).

foldl(Pred, zipper(Lefts, Focus, Rights), Acc0, Out) :-
    list.foldr(Pred, [Focus | Rights], Acc0, Acc1),
    list.foldl(Pred, Lefts, Acc1, Out).

foldl(F, zipper(Lefts, Focus, Rights), Acc0) = Out :-
    Acc1 = list.foldr(F, [Focus | Rights], Acc0),
    Out = list.foldl(F, Lefts, Acc1).

foldr(F, zipper(Lefts, Focus, Rights), Acc0) = Out :-
    Acc1 = list.foldl(F, [Focus | Rights], Acc0),
    Out = list.foldr(F, Lefts, Acc1).

foldr(Pred, zipper(Lefts, Focus, Rights), Acc0, Out) :-
    list.foldl(Pred, [Focus | Rights], Acc0, Acc1),
    list.foldr(Pred, Lefts, Acc1, Out).

move(N, Zipper0, Zipper1) :-
    ( N = 0 ->
        Zipper0 = Zipper1
    ; N > 0 ->
        next(Zipper0, Z),
        move(N - 1, Z, Zipper1)
    ;
        previous(Zipper0, Z),
        move(N + 1, Z, Zipper1)
    ).

find_by(Traverse, Pred, Zipper0 @ zipper(_, F, _), Zipper1) :-
    ( Pred(F) ->
        Zipper0 = Zipper1
    ;
        Traverse(Zipper0, Z),
        find_by(Traverse, Pred, Z, Zipper1)
    ).

find_next(Pred, !Zipper) :-
    find_by(
        (pred(Zin::in, Zout::out) is semidet :- next(Zin, Zout)),
        Pred,
        !Zipper).

find_previous(Pred, !Zipper) :-
    find_by(
        (pred(Zin::in, Zout::out) is semidet :- previous(Zin, Zout)),
        Pred,
        !Zipper).
