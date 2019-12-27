#! /usr/bin/env j
NB. turning input into a list of extended-precision numbers
chars =: 256 $ 0
chars =: 1 (a. i. '0123456789-') } chars
lex =: 1 2 2     $ 0 0 , 1 1
lex =: lex , 2 2 $ 0 3 , 1 0
lexer =: 0 ; lex ; chars

parse =: > @: ((". @: ,&'x') &. >)

input =: parse lexer ;: {. 'm' freads 'input.txt'

NB. intcode machine
memory =: input
IP =: 0
halted =: 0
get =: monad : '((IP + y) { memory) { memory'
set =: dyad : 'memory =: x ((IP + y) { memory) } memory'

op =: monad define
select. y
case.   1 do. NB. add
  3 set~ (get 1) + get 2
  IP =: IP + 4
case.   2 do. NB. mul
  3 set~ (get 1) * get 2
  IP =: IP + 4
case.   99 do. NB. hlt
  halted =: 1
end.
)

run =: monad define
while. 0 = halted do.
  op IP { memory
end.
)

NB. part 1
memory =: (12) 1 } memory
memory =: (2) 2 } memory
run ''
part1 =: {. memory

NB. part 2
try =: dyad define
memory =: input
IP =: 0
halted =: 0
memory =: x 1 } memory
memory =: y 2 } memory
run ''
{. memory
)

part2 =: monad define
noun =. 0
verb =. 0
answer =. 0
while. noun < 100 do.
  while. verb < 100 do.
    if. y = noun try verb do.
      answer =. verb + noun * 100
    end.
    verb =. >: verb
  end.
  verb =. 0
  noun =. >: noun
end.
answer
)
