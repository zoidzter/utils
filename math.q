/fib
fib:{x#0,last {x,sum -2#x}\[x;1 1]};
/factorial
fac:{$[x<2;1;*/[1;1 +til x]]};
/pascal's triangle
pas:{{(+)prior x,0}\[x;1]};
