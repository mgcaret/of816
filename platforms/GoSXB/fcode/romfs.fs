\ GoSXB ROM Filesystem
\ Since the GoSXB has the ability to have unbanked ROM, this is much easier than a stock
\ WDC board

\ This ROMfs supports:
\ * up to 255 files
\ * name lengths up to 255 bytes,
\ * include/included for forth text
\ * load/loaded for FCode
\ * AUTOSTART file automatically executed

\ future: optionally have file access words such as open-file, read-file, and friends

start1 hex

." GoSXB ROMfs by M.G. ... "

s" vocabulary ROMfs also ROMfs definitions" eval

headerless

\ header structure
struct
4 field >magic
1 field >nentries
0 field >catalog
drop \ no need for struct size, catalog is variable

\ file entry structure
struct
4 field >offset \ relative to >magic, if 0: no more and rest of struct invalid
4 field >size
1 field >namelen
0 field >name
constant $entry-hdr-size

defer parse-word
s" parse-word" $find drop to parse-word

headers

\ romfs location
0 value $$romfs-addr
[ifdef] file-access-words
0 value $$romfs-tab
[endif]

\ temp vars for file I/O and such
0 value $curentry

: $romfs-first
  $$romfs-addr >catalog to $curentry
;

: $romfs-next
  $curentry dup >namelen c@ $entry-hdr-size + + to $curentry
;

: $romfs-entname ( -- addr len )
  $curentry >name $curentry >namelen c@
;

: $romfs-nfiles ( -- count )
  $$romfs-addr dup if
    >nentries c@
  then
;

\ scan a 65816 bank for ROMfs, every $1000 bytes
: $romfs-find-bank ( bank -- )
  d# 16 << \ convert bank addr to upper byte
  ffff 0 do dup i + \ address to probe (middle byte)
  dup @ 5346474D = \ compare with magic
  if to $$romfs-addr leave else drop then
  1000 +loop
  drop
;

\ scan banks $20-$2F for ROMfs
: $romfs-find ( -- )
  30 20 do $$romfs-addr if leave else i $romfs-find-bank then loop
  [ifdef] file-access-words
  $$romfs-addr if
    $romfs-nfiles 2* cells dup alloc-mem dup to $$romfs-tab swap erase
  then
  [endif]
;

[ifdef] file-access-words
\ return address or throw exception
: $romfs-addr ( -- addr )
  $$romfs-addr ?dup 0= if d# -37 throw then
;
[endif]

external

: romfs-list ( -- )
  $romfs-nfiles dup if
    $romfs-first
    0 do
      $romfs-entname type cr
      $romfs-next
    loop
  else
    drop
  then
;

: romfs-lookup ( addr len -- addr2 len2 | false )
  $romfs-nfiles dup if
    >r true -rot r>
    $romfs-first
    0 do
      dup $curentry >namelen c@ = if
        2dup $curentry >name swap comp
        0= if
          2drop drop false
          $curentry >offset @ $$romfs-addr +
          $curentry >size @
          leave
        then
      then
      $romfs-next
    loop
    rot if
      \ either
      \ 2drop
      \ or
      type ."  not found!" cr
      false
    then
  else
    nip nip
  then
;

external

\ See if file exists, if so, eval as text or load as FCode depending on first
\ byte
: ?romfs-run ( addr u -- ... )
  romfs-lookup
  dup if
    over 1+ c@ 8 = if
      \ is probably FCode
      drop 1 1 byte-load
    else
      \ is hopefully text
      eval
    then
  else
    drop \ hope it wasn't zero bytes long...
  then 
;

: included ( c-addr u -- ... )
  romfs-lookup dup if
    eval
  else
    d# -69 throw
  then
;

: include ( "< >name" -- ...)
  parse-word included
;

: fc-loaded ( c-addr u -- ... )
  romfs-lookup dup if
    drop 1 byte-load
  else
    d# -69 throw
  then
;

: fc-load ( "< >name" -- ... )
  parse-word fc-loaded
;

headers

$romfs-find

s" previous definitions" eval

." loaded!" cr

$$romfs-addr ?dup if ." ROMfs at " u. cr then
s" AUTOEXEC" ?romfs-run

fcode-end
