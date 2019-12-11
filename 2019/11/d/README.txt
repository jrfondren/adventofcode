--- Day 11, part 1 & 2 ---

Another IntCode day. The big mistake here that resulted in some uglification of
the code was leaving a "send 2" from day 9's copied machine-runner. Didn't
notice that until having the machine temporarily log all its inputs. Maybe
dynamic contracts would help with that...

    auto m = Machine(input, ownerTid);
    m.inputRestriction = nullable(i => assert(i == 0 || i == 1));
    m.run;

I bet this robot is going to show up again.

Incidentally the exact stable version of dmd that I had was unable to compile
one of the attempts. ldc2, an older version of dmd, and the nightly were able
to compile it fine. So not a big deal, but also not a pleasant encounter when
under time pressure.
