\ W65C816SXB ROM loader.  Itself in FCode, this defines some words to bootstrap
\ any FCode and files in the SXB's flash ROM.

\ This provides two facilities:  FCode loader, and romfs.
\ romfs provides a simple filesystem of up to 32K (one bank of ROM) in the SXB for
\ files.  Basic ANSI-ish functions to open/read/close the files are provided
\ as well as include and included.  romfs was inspired by SLOF's romfs.
\ romfs may be omitted during tokenization by defining the commad-line symbol no-romfs
\ i.e. adding -d no-romfs to the toke command line, this saves more than 1K of output
\ in the tokenized FCode.

\ Note that the SXB-specific word $SXB-READROM takes a virtual address of the form
\ $bbaaaaaa where bb is the ROM bank to select, and the address is then used to read it
\ For practical purposes to read the ROM the addresses are restricted to:
\ $00008000-$0000FFFF - bank 0, $01008000-$0100FFFF - bank 1,
\ $02008000-$0200FFFF - bank 2, $03008000-$0300FFFF - bank 3.

start1 hex

." W65C816SXB ROM loader by M.G. ... "

headers

headerless

\ Stuff we need to get to that isn't supported by FCode
defer $sxb-readrom
s" $sxb-readrom" $find 0= if ." no $SXB-READROM" abort then to $sxb-readrom

[ifndef] no-romfs
defer -trailing
s" -trailing" $find drop to -trailing
defer parse-word
s" parse-word" $find drop to parse-word

: 2w@ dup w@ swap wa1+ w@ ;

\ temp vars for file I/O, headerless to save space
\ $fileno is used for susequent conditionals to compile remaining romfs code
0 value $fileno
0 value $bufsz
0 value $buffer
0 value $incbuffer
[endif]

headers

\ a $100-byte page buffer is provided to avoid slow reads of the ROM to a certain extent
fffffffff value $sxb-readrom-page
0 value $sxb-readrom-buf

[ifexist] $fileno
0 value $sxb-romfs-filebuf
0 value $sxb-romfs-files
0 value $sxb-romfs-tab
[endif]

\ fetch a page to the page buffer, allocating it if necessary, and doing nothing if
\ it's already in the page buffer
: $sxb-rom-fetchpage ( v-addr -- v-addr )
  $sxb-readrom-buf 0= if
    100 alloc-mem to $sxb-readrom-buf
    ffffffff to $sxb-readrom-page ( invalid page number )
  then
  dup 8 >> $sxb-readrom-page <> if
    dup ffffff00 and $sxb-readrom-buf 100 $sxb-readrom
    dup 8 >> to $sxb-readrom-page
  then
;

\ Byte read function for the ROM, used to execute FCode.
: $sxb-rom-rb@ ( v-addr -- byte )
  $sxb-rom-fetchpage ff and $sxb-readrom-buf + c@
;

\ Free the page buffer to return memory to the user
: $sxb-readrom-free ( -- )
  $sxb-readrom-buf if
    $sxb-readrom-buf 100 free-mem
  then
  0 to $sxb-readrom-buf
  ffffffff to $sxb-readrom-page
;

\ Magic test for FCode
: $$fcode-at? ( v-addr -- f )
  $sxb-rom-fetchpage ff and $sxb-readrom-buf + @ 4346474D =
;

[ifexist] $fileno
\ Magit test for romfs
: $$romfs-at? ( v-addr -- f )
  $sxb-rom-fetchpage ff and $sxb-readrom-buf + @ 5346474D =
;
[endif]

external

[ifexist] $fileno
\ Holds location of discovered romfs
0 value $sxb-romfs
[endif]

\ see if there is FCode in the SXB ROM at v-addr.
: $sxb-rom-fcode-at? ( v-addr -- f )
  $$fcode-at? $sxb-readrom-free
;

[ifexist] $fileno
\ see if there is romfs in the SXB ROM at v-addr.
: $sxb-rom-romfs-at? ( v-addr -- f )
  $$romfs-at? $sxb-readrom-free
;
[endif]

\ byte-load FCode in the SXB ROM.
: $sxb-rom-byte-load ( v-addr -- )
  dup $$fcode-at? if
    cell+ ['] $sxb-rom-rb@ ['] byte-load catch
    $sxb-readrom-free
    dup if
      nip nip
    then
    throw
  else
    ." no FCode at " . true abort
  then
;

headers

\ Scan a bank for FCode and execute any that is found
: $sxb-fc-boot-bank ( bank -- )
  1000000 *
  ffff 8000 do dup i + dup $$fcode-at? if
    $sxb-rom-byte-load
  else
    drop
  then
  1000 +loop
  drop
;

[ifexist] $fileno
\ scan a bank for romfs and update $sxb-romfs if found
: $romfs-find-bank ( bank -- )
  1000000 *
  ffff 8000 do dup i + dup $$romfs-at? if
    to $sxb-romfs leave
  else
    drop
  then
  1000 +loop
  drop
;

\ return address of romfs or throw exception
: $sxb-romfs? ( -- addr )
  $sxb-romfs ?dup 0= if d# -37 throw then
;

\ Normalize file ID and make sure it is valid
: romfs-file? ( u1 -- u2 / u2 = normalized file ID )
  ffff and dup $sxb-romfs-files u>= if d# -38 throw then
;

\ Get file name of file in romfs
: romfs-file ( u -- c-addr u2 )
  romfs-file? $sxb-romfs?
  $sxb-rom-fetchpage drop $sxb-readrom-buf cell+ char+ swap 4 << + c -trailing
;

\ Return info about a romfs file
: romfs-finfo ( -- offset length )
  romfs-file drop c + 2w@
;

\ Find a file in the romfs, return file number if we find it
: romfs-ffind ( c-addr u -- u2 true | false )
  -1 -rot $sxb-romfs-files 0 ?do
    2dup i romfs-file 2 pick = if
      \ lengths equal
      swap comp 0= if
        i -rot >r >r swap drop r> r>
      then
    else
      \ lengths unequal
      3drop
    then
  loop
  2drop
  dup 0< if
    drop false
  else
    true
  then
;

\ Get ROMfs table entry for file number
: $romfs-t# ( file# -- addr )
  2* cells $sxb-romfs-tab +
;

\ "open" a romfs file
\ Set up table entry for the file with current (start) and end addresses.
: $romfs-open ( u -- )
  >r r@ romfs-finfo over + $sxb-romfs + swap $sxb-romfs + swap r> $romfs-t# 2!
;

\ "close" a romfs file.  Set current address to end address
: $romfs-close ( u -- )
  $romfs-t# >r r@ 2@ swap drop dup r> 2!
  $sxb-readrom-free
;

\ Check if we hit EOF in open romfs file
: $romfs-eof? ( u -- f )
  $romfs-t# 2@ u>= 
;

\ Byte read routine for romfs
: $romfs-rb@ ( u -- byte )
  $romfs-t# dup >r @ dup 1+ r> ! $sxb-rom-rb@
;

\ See if we hit a line-ending char
: is-eol?
  case
    0d of true endof \ CR
    0a of true endof \ LF
    >r false r>
  endcase
;

\ Locate a romfs in the SXB ROM, updating $sxb-romfs and $sxb-romfs-files if found
\ and allocating the access table
: $romfs-find ( -- )
  4 1 do $sxb-romfs if leave else i $romfs-find-bank then loop
  $sxb-romfs if
    $sxb-romfs $sxb-rom-fetchpage drop $sxb-readrom-buf cell+ c@ dup to $sxb-romfs-files
    2* cells dup alloc-mem dup to $sxb-romfs-tab swap erase
  then
  $sxb-readrom-free
;
[endif]

external

\ Find and execute all FCode in ROM at $1000-aligned addresses
: $sxb-fc-boot
  4 1 do i $sxb-fc-boot-bank loop
  $sxb-readrom-free
;

[ifexist] $fileno
\ List files in romfs
: romfs-list
  $sxb-romfs-files 0 ?do 
    i romfs-file type cr
  loop
  $sxb-readrom-free
;

\ open file in romfs
: open-file ( c-addr u fam -- fileid 0 )
  drop
  romfs-ffind if
    dup 10000 or swap $romfs-open 0
  else
    d# -69 throw
  endif
;

\ report position in open file
: file-position ( fid -- u )
  romfs-file? $romfs-t# 2@ swap -
;

\ close romfs file
: close-file ( fileid -- 0 )
  romfs-file? $romfs-close 0
  $sxb-readrom-free
;

\ read open romfs file
: read-file ( c-addr u fileid - u2 0 )
  romfs-file? to $fileno to $bufsz to $buffer
  0
  $bufsz 0 ?do
    $fileno $romfs-eof? if leave then
    $fileno $romfs-rb@
    over $buffer + c! 1+
  loop
  0
;

\ read a line from open romfs file
: read-line ( c-addr u fileid - u2 f 0 )
  romfs-file? to $fileno to $bufsz to $buffer
  0
  $bufsz 0 ?do
    $fileno $romfs-eof? if leave then
    $fileno $romfs-rb@
    dup is-eol? if drop leave then
    over $buffer + c! 1+
  loop
  $fileno $romfs-eof? 0= 0
;

headers

\ read and evaluate each line of file in romfs describe in incbuf
\ incbuf is a buffer 1 cell+80 bytes long, with the file id in the cell
: $inc ( incbuf -- ) 
  $incbuffer ?dup 0= if d# -9 throw then
  begin
    >r r@ cell+ 80 r@ @
    read-line 2drop
    r@ cell+ swap eval
    r> dup @ romfs-file?
  $romfs-eof? until
  drop   
; 

external

\ allocate a buffer and evaulate the given file
: included ( c-addr u -- )
  0 open-file drop
  $incbuffer >r 80 cell+ alloc-mem dup to $incbuffer !
  ['] $inc catch r> swap >r $incbuffer swap to $incbuffer
  dup @ close-file drop 80 cell+ free-mem
  r> throw
;

\ parse name and perform the function of included
: include ( " name " -- )
  parse-word included
;

$romfs-find
[endif]

." loaded!" cr

[ifexist] $fileno
$sxb-romfs ?dup if ." ROMfs at " u. cr then
[endif]

fcode-end
