\ CompactFlash test code
vocabulary cflash
also cflash definitions

7F60 value card-base
E0000000 value lba-select \ drive 0, LBA mode
200 value block-size

struct
1 field card>data
0 field card>features
1 field card>error
1 field card>s-count
4 field card>lba
0 field card>command
1 field card>status
drop

: ?."
  ascii " parse
  [: rot if type cr else 2drop then ;]
  state @ if
    -rot postpone sliteral compile,
  else
    execute
  then
; immediate

: send-cmd
  card-base card>command c!
;

defer init-card

: cferror ( fatal? -- f | <abort> )
  card-base card>status c@ 1 and 0= if drop false exit then
  card-base card>error c@ ?dup 0= if drop false exit then
  ." CF error: " .
  03 send-cmd card-base card>error c@
  ." ; sense code: " . cr
  if abort else true then
;


\ wait for busy (b7) to become unset
: busy-wait
  card-base card>status
  begin
    dup c@
    dup 80 and 0= if 2drop exit then
    1 and if ." (!BUSY) " true cferror drop then
  again
;

\ wait for drq (b3) to be asserted
: drq-wait
  card-base card>status
  begin
    dup c@
    dup 08 and if 2drop exit then
    1 and if ." (DRQ) " true cferror drop then
  again
;

: init-card
  \ set up 8-bit mode
  busy-wait 1 card-base card>features c!
  busy-wait ef send-cmd
  0 set-lba
;


: set-lba ( lba -- )
  busy-wait
  0FFFFFFF and lba-select or card-base card>lba !
;

: (read-blk-data) ( addr -- )
  busy-wait drq-wait
  block-size 0 do
    card-base card>data c@
    over i + c!
  loop
  drop
;

: read-block ( lba addr -- )
  busy-wait
  1 card-base card>s-count c!
  swap set-lba
  20 send-cmd (read-blk-data)
  true cferror drop
;

: (identify-drive) ( addr - )
  busy-wait
  EC send-cmd (read-blk-data)
;

: identify-drive
  init-card 200 alloc-mem >r r@ (identify-drive)
  false cferror if r> free-mem ." Error identifying" cr then
  r@ a + w@ 0240 <> if r> free-mem ." Unable to identify" cr exit then
  r@ 36 + 28 -trailing type ."  rev. " r@
  r@ 2e + 8 -trailing type cr
  r@ 78 + @ . ." LBAs"
  r> free-mem
;
  
previous definitions
