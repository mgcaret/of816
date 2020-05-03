base @ decimal
: message ( n -- 0|n )
  dup case
    -3  of s" Stack o/f" endof
    -9  of s" Invalid address" endof
    -11 of s" Numeric o/f" endof
    -12 of s" Argument type m/m" endof
    -14 of s" Compile-only word" endof
    -18 of s" String o/f" endof
    -21 of s" Unsupported operation" endof
    -22 of s" Control structure m/m" endof
    -24 of s" Invalid numeric arg" endof
    -31 of s" Can't >BODY" endof
    -37 of s" I/O error" endof
    -38 of s" File not found" endof
    -49 of s" Search-order o/f" endof
    -50 of s" Search-order u/f" endof
    -59 of s" Can't ALLOC-MEM" endof
    -60 of s" Can't FREE-MEM" endof
    -69 of s" Can't open file" endof
    -256 of s" Undefined Fcode#" endof
    >r 0 0 r>
  endcase
  ?dup if type drop 0 else drop then
;
base !
