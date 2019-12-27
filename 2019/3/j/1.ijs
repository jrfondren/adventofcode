#! /usr/bin/env j
chars =: a. e. 'LRUD0123456789'
lex =: 1 2 2     $ 0 0 , 1 1
lex =: lex , 2 2 $ 0 3 , 1 0
lexer =: 0 ; lex ; chars

wires =: lexer&;:"1 'm' freads 'input.txt'

coord =: 0 2 $ 0
at =: 0 0

todir =: (_1 0 , 1 0 , 0 _1 ,: 0 1) {~ 'LRUD' i. ]

move =: monad define
dir =. todir {.y
n =. ". }.y
while. n > 0 do.
  at =: at + dir
  coord =: coord , at
  n =. n - 1
end.
)

NB. follow first wire, reset, follow second wire
move&.> {.wires
other =: coord
coord =: 0 2 $ 0
at =: 0 0
move&.> {:wires

intersections =: (((other&i. coord) < #other) # (other&i. coord)) { other

part1 =: /:~ +/"1 |intersections

steps =: coord&i. + other&i.

part2 =: 2 + /:~ steps intersections
