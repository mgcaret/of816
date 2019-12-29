testing 7.3.2.5 Address arithmetic

t{ /c -> 1 }t
t{ /w -> 2 }t
t{ /l -> 4 }t
t{ /n -> 4 }t \ OF816 is hardcoded to this

t{ 0 2 ca+ -> 2 /c * }t
t{ 0 2 wa+ -> 2 /w * }t
t{ 0 2 la+ -> 2 /l * }t
t{ 0 2 na+ -> 2 /n * }t

t{ 0 ca1+ -> /c }t
t{ 0 wa1+ -> /w }t
t{ 0 la1+ -> /l }t
t{ 0 na1+ -> /n }t

t{ 2 /c* -> 2 /c * }t
t{ 2 /w* -> 2 /w * }t
t{ 2 /l* -> 2 /l * }t
t{ 2 /n* -> 2 /n * }t

\ no alignment restrictions on the 816
t{ 0 aligned -> 0 }t
t{ 1 aligned -> 1 }t
t{ 2 aligned -> 2 }t
t{ 3 aligned -> 3 }t

t{ 0 char+ -> /c }t
t{ 0 cell+ -> /n }t

t{ 2 chars -> 2 /c * }t
t{ 2 cells -> 2 /n * }t
