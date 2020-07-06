/ maths based functions

/ define in .m namespace
\d .m

/fib
fib:{x#0,last {x,sum -2#x}\[x;1 1]};

/factorial
fac:{$[x<2;1;*/[1;1 +til x]]};

/pascal's triangle
pas:{{(+)prior x,0}\[x;1]};

/ is x a prime number
isPrime:{not 0 in x mod 2_til 1+ceiling sqrt x};
/ returns the primes in a list
primes:{o where isPrime each o:{x where x mod 2} x };

/ factors
factors:{distinct asc b,x div/:b:a where 0=x mod/:a:1 +til ceiling sqrt x}

/ two combinations functions versions
comb:{[N;l]$[N=1;l;raze .z.s[N-1;l]{x,/:y where y>max x}\:l]};
comb:{{raze x{x,/:y where y>max x}\:y}[;y]/[x-1;y]};

/ permutations
perm:{{raze x{x,/:y except x}\:y}[;y]/[x-1;y]};
