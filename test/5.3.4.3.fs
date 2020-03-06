testing 5.3.4.3 Get local arguments

: s= ( str len str len )
  2 pick over = if
    drop swap comp 0=
  else
    2drop 2drop false
  then
;

t{ s" foo bar" bl left-parse-string s" foo" s= >r s" bar" s= r> -> true true }t
t{ s" foo/bar" ascii / left-parse-string s" foo" s= >r s" bar" s= r> -> true true }t

hex
t{ s" a5,f0" parse-2int -> f0 a5 }t
t{ s" babe,cafe" parse-2int -> cafe babe }t
