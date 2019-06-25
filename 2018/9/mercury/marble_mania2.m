:- module marble_mania2.
:- interface.
:- import_module circular_list, array.

:- type game
    ---> game(
        next_marble :: int,
        scores :: array(int),
        board :: circle
    ).

:- inst game for game/0
    == bound(game(ground, ground, circle)).
:- mode game_in == in(game).
:- mode game_di == in(game). % :(
:- mode game_uo == out(game).

    % start(PlayerCount) = Game
:- func start(int) = game.
:- mode start(in) = game_uo is det.

    % play(Player, !Game)
:- pred play(int, game, game).
:- mode play(in, game_in, game_uo) is det.

    % play(Players, Last_marble) = Highest_Score
:- func play_until(int, int) = int.

    % succeeds if the next round would be a scoring round
:- pred scoring(game::game_in) is semidet.

:- implementation.
:- import_module int.

start(N) = game(1, array.init(N, 0), circular_list.init(0)).

scoring(G) :- G^next_marble mod 23 = 0.

:- pred previous(int::in, game::game_di, game::game_uo) is det.
previous(N, game(R, S, !.B), game(R, S, !:B)) :- previous(N, !B).

:- pred next(game::game_di, game::game_uo) is det.
next(game(R, S, !.B), game(R, S, !:B)) :- next(!B).

:- pred insert(game::game_di, game::game_uo) is det.
insert(game(R, S, !.B), game(R, S, !:B)) :-
    insert(R, !B).

:- pred delete(game::game_di, game::game_uo) is det.
delete(game(R, S, !.B), game(R, S, !:B)) :- delete(!B).

:- func get(game) = int.
get(game(_, _, B)) = R :- get(B, R).

:- pred addscore(int, int, game, game).
:- mode addscore(in, in, game_di, game_uo) is det.
addscore(P, Marble, !G) :-
    Score = lookup(!.G^scores, P) + Marble,
    !:G = !.G^scores := set(!.G^scores, P, Score).

play(P, !G) :-
    (
        scoring(!.G)
    ->
        addscore(P, !.G^next_marble, !G),
        previous(7, !G),
        addscore(P, get(!.G), !G),
        delete(!G)
    ;
        next(!G),
        insert(!G)
    ),
    !:G = !.G^next_marble := !.G^next_marble + 1.

play_until(Players, Last_Marble) = WinScore :-
    G0 = start(Players),
    play_until(0, Players, Last_Marble, G0, G),
    foldl((func(N, Max) = (N > Max -> N; Max)), G^scores, -1) = WinScore.

:- pred play_until(int, int, int, game, game).
:- mode play_until(in, in, in, game_di, game_uo) is det.
play_until(Player, Players, Last_Marble, !G) :-
    (
        get(!.G) = Last_Marble
    ->
        true
    ;
        play(Player, !G),
        Next = (Player + 1 = Players -> 0 ; Player + 1),
        play_until(Next, Players, Last_Marble, !G)
    ).
