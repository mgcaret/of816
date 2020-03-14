testing 5.3.7.6 Start and end

hex

\ ferror token validated in 5.3.3.x, now let's test
t{ ' ferror catch >r clear r> 0= -> false }t

\ Fcode: version1 true end0
: test-fcode " "(fd 08 00 a4 00 00 00 0a a4 00)" ;

\ covers: $byte-exec
t{ test-fcode drop 1 byte-load -> true }t
