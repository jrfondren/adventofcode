:- module day9.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.
:- implementation.
:- import_module marble_mania, string, list.

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    (
        Args = [PlayerStr, LastMarbleStr],
        to_int(PlayerStr, Players),
        to_int(LastMarbleStr, LastMarble)
    ->
        io.format("%d players; last marble of %d points -> high score of %d\n",
            [i(Players), i(LastMarble), i(HighScore)], !IO),
        HighScore = play_until(Players, LastMarble)
    ;
        io.progname("day9", Name, !IO),
        io.format(io.stderr_stream, "%s <player count> <last marble>\n",
            [s(Name)], !IO)
    ).
