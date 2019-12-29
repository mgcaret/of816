testing 7.3.2.4 Data type conversion

t{ 01020304 lbsplit -> 04 03 02 01 }t
t{ 01020304 lwsplit -> 0304 0102 }t
t{ 0102 wbsplit -> 02 01 }t
t{ 04 03 02 01 bljoin -> 01020304 }t
t{ 02 01 bwjoin -> 0102 }t
t{ 0304 0102 wljoin -> 01020304 }t
t{ 0102 wbflip -> 0201 }t
t{ 01020304 lbflip -> 04030201 }t
t{ 01020304 lwflip -> 03040102 }t
