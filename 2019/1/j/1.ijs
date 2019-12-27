#! /usr/bin/env j
mods =: ". 'm' freads 'input.txt'

fuel =: monad : '(<.y%3) - 2'

part1 =: +/ fuel mods

fuelplus =: monad define"0
r =. 0
a =. fuel y
while.  a > 0
do.     r =. r + a
        a =. fuel a
end.
r
)

part2 =: +/ fuelplus mods
