--- Day 9, part 1 & 2 ---

Silver and Gold solution (with different parameters to send())

This is super rough but I've got a long Monday.

s/int/BigInt/ was easy.
s/array of memory/table of memory/ was easy.

Actually most things were easy and this was a good day for getting punished
for not thinking too deeply about the problem, vs. the problem of other
days which was unfamiliarity with what D had to offer.

The single disappointment: no tracebacks for exceptions in other threads.
Luckily I could debug by getting the exception to happen in the main
thread, but this is what the weird Tid.init test is about in machine.d

--- Files ---
d1.d : part2 solution
machine.d : intcode machine
