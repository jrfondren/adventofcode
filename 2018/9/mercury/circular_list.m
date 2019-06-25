:- module circular_list.
:- interface.

:- type circle.

%:- inst circle == unique. :(
:- inst circle == ground.
:- mode circle_in == in(circle).
:- mode circle_di == di(circle).
:- mode circle_uo == out(circle).

    % Create a new circular list containing a single element.
:- func init(int) = circle.
:- mode init(in) = (circle_uo) is det.

:- pred next(circle, circle).
:- mode next(circle_di, circle_uo) is det.

:- pred next(int, circle, circle).
:- mode next(in, circle_di, circle_uo) is det.

:- pred previous(circle, circle).
:- mode previous(circle_di, circle_uo) is det.

:- pred previous(int, circle, circle).
:- mode previous(in, circle_di, circle_uo) is det.

    % Delete current cell and change 'current' to point to the next cell.
:- pred delete(circle, circle).
:- mode delete(circle_di, circle_uo) is det.

    % Insert a new cell after the current one, and change 'current' to point
    % to the new cell.
:- pred insert(int, circle, circle).
:- mode insert(in, circle_di, circle_uo) is det.

:- pred get(circle, int).
:- mode get(circle_in, out) is det.

:- implementation.
:- import_module int.

:- pragma foreign_decl("C", "
#include <stdlib.h>

struct DLL_cons {
    int car;
    struct DLL_cons *next;
    struct DLL_cons *prev;
};
").

:- pragma foreign_type("C", circle, "struct DLL_cons *").

:- pragma foreign_proc("C",
    init(X::in) = (Circle::circle_uo),
    [promise_pure],
"
    Circle = malloc(sizeof (struct DLL_cons));
    Circle->car = X;
    Circle->next = Circle;
    Circle->prev = Circle;
").

:- pragma foreign_proc("C",
    next(Circle0::circle_di, Circle::circle_uo),
    [promise_pure],
"
    Circle = Circle0->next;
").

next(N, !C) :-
    ( N = 0 -> true; next(!C), next(N - 1, !C) ).

:- pragma foreign_proc("C",
    previous(Circle0::circle_di, Circle::circle_uo),
    [promise_pure],
"
    Circle = Circle0->prev;
").

previous(N, !C) :-
    ( N = 0 -> true; previous(!C), previous(N - 1, !C) ).

:- pragma foreign_proc("C",
    delete(Circle0::circle_di, Circle::circle_uo),
    [promise_pure],
"
    Circle0->next->prev = Circle0->prev;
    Circle0->prev->next = Circle0->next;
    Circle = Circle0->next;
    free(Circle0);
").


:- pragma foreign_proc("C",
    insert(X::in, Circle0::circle_di, Circle::circle_uo),
    [promise_pure],
"
    Circle = malloc(sizeof (struct DLL_cons));
    Circle->car = X;
    Circle->prev = Circle0;
    Circle->next = Circle0->next;
    Circle0->next = Circle;
    Circle->next->prev = Circle;
").

:- pragma foreign_proc("C",
    get(Circle::circle_in, X::out),
    [promise_pure],
"
    X = Circle->car;
").


:- interface.

    % this is very limited code that's only intended for circle_test2
:- func to_string(circle::circle_in) = (string::out) is det.
:- implementation.

:- pragma foreign_proc("C",
    to_string(Circle::circle_in) = (X::out),
    [promise_pure],
"
    MR_String Temp;
    MR_allocate_aligned_string_msg(Temp, 4096, MR_ALLOC_ID);
    MR_allocate_aligned_string_msg(X, 4096, MR_ALLOC_ID);

    sprintf(X, ""[%d"", Circle->car);

    struct DLL_cons *p = Circle;
    while (p->next != Circle) {
        sprintf(Temp, "", %d"", p->next->car);
        strcat(X, Temp);
        p = p->next;
    }

    sprintf(Temp, ""]"");
    strcat(X, Temp);
").
