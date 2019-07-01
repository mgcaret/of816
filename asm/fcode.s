; FCode support
; Built-in (ROM) FTables overlap where possible to save space.
; FCode fetch is in assembly for speed.  Most of the rest of the things are to support
; the "FCode" way of doing things, and managing the tables in RAM.

.define trace_fcode 0

; FCODE->XT tables
; Initially the FCode table pointers point to the ROM tables
; the tables are copy-on-write, whereupon each table will be copied to RAM when
; new-token or set-token are called.  memory for the table will be via alloc-mem
; byte-load will also save the local fcode tables and temporarily reset the to the ROM
; tables
; end0 and end1 reset the local fcode tables to the ROM, freeing RAM used by them
; since the purpose of fcode is to be space-efficient, hopefully this results in
; space-efficiency

; Almost all of the non-reserved & non-historical FCodes from table 0 are implemented
; to some degree.  Initially, INSTANCE is not supported but can be added later.
.proc     fcrom0
          FCIMM FCEND ; 0x00
          FCIMM FERROR          ; 0x01-0x0F = prefixes for other tables
          FCIMM FERROR          ; these wont normally be executed because an fcode 
          FCIMM FERROR          ; fetch will never return one of thes
          FCIMM FERROR          ; that being said, get-token *will* return these
          FCIMM FERROR          ; entries
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM B_LIT       ; 0x10 b(lit)
          FCIMM B_TICK      ; b(')
          FCIMM B_QUOTE     ; b(")
          FCIMM BBRANCH     ; bbranch
          FCIMM BQBRANCH    ; b?branch
          FCIMM B_LOOP      ; b(loop)
          FCIMM B_PLOOP     ; b(+loop)
          FCIMM B_DO        ; b(do)
          FCIMM B_QDO       ; b(?do)
          .dword IX
          .dword JX
          FCIMM B_LEAVE     ; b(leave)
          FCIMM B_OF        ; b(of)
          .dword EXECUTE
          .dword PLUS
          .dword MINUS
          .dword MULT                   ; 0x20
          .dword DIV
          .dword MOD
          .dword LAND
          .dword LOR
          .dword LXOR
          .dword INVERT
          .dword LSHIFT
          .dword RSHIFT
          .dword ARSHIFT
          .dword DIVMOD
          .dword UDIVMOD
          .dword NEGATE
          .dword ABS
          .dword MIN
          .dword MAX
          .dword PtoR                   ; 0x30
          .dword RtoP
          .dword RCOPY
          .dword DEXIT
          .dword ZEROQ
          .dword ZERONEQ
          .dword ZEROLT
          .dword ZEROLTE
          .dword ZEROGT
          .dword ZEROGTE
          .dword SLT
          .dword SGT
          .dword EQUAL
          .dword NOTEQUAL
          .dword UGT
          .dword ULTE
          .dword ULT                    ; 0x40
          .dword UGTE
          .dword SGTE
          .dword SLTE
          .dword BETWEEN
          .dword WITHIN
          .dword DROP
          .dword DUP
          .dword OVER
          .dword SWAP
          .dword ROT
          .dword NROT
          .dword TUCK
          .dword NIP
          .dword PICK
          .dword ROLL
          .dword QDUP                   ; 0x50
          .dword DEPTH
          .dword TWODROP
          .dword TWODUP
          .dword TWOOVER
          .dword TWOSWAP
          .dword TWOROT
          .dword TWODIV
          .dword UTWODIV
          .dword TWOMULT
          .dword SCHAR
          .dword SWORD
          .dword SLONG
          .dword SCELL
          .dword CAPLUS
          .dword WAPLUS
          .dword LAPLUS                 ; 0x60
          .dword NAPLUS
          .dword CHARPLUS
          .dword WAINCR
          .dword LAINCR
          .dword CELLPLUS
          .dword CHARS
          .dword SWORDMULT
          .dword SLONGMULT
          .dword CELLS
          .dword ON
          .dword OFF
          .dword PSTORE
          .dword FETCH
          .dword LFETCH
          .dword WFETCH
          .dword WFETCHS                ; 0x70
          .dword CFETCH
          .dword STORE
          .dword LSTORE
          .dword WSTORE
          .dword CSTORE
          .dword TWOFETCH
          .dword TWOSTORE
          .dword MOVE
          .dword FILL
          .dword COMP
          .dword NOOP
          .dword LWSPLIT
          .dword WLJOIN
          .dword LBSPLIT
          .dword BLJOIN
          .dword WBFLIP                 ; 0x80
          .dword UPC
          .dword LCC
          .dword PACK
          .dword COUNT
          .dword BODYr
          .dword rBODY
          .dword FCODE_REVISION
          .dword SPAN
          .dword UNLOOP
          .dword EXPECT
          .dword ALLOC
          .dword FREE
          .dword KEYQ
          .dword KEY
          .dword EMIT
          .dword TYPE                   ; 0x90
          .dword pCR
          .dword CR
          .dword NOUT
          .dword NLINE
          .dword PHOLD
          .dword PBEGIN
          .dword PUDONE
          .dword PSIGN
          .dword PUNUM
          .dword PUNUMS
          .dword UDOT
          .dword UDOTR
          .dword DOT
          .dword DOTR
          .dword DOTS
          .dword BASE                   ; 0xA0
          FCIMM FERROR                ; historical CONVERT
          .dword dNUMBER
          .dword DIGIT
          .dword MINUSONE
          .dword ZERO
          .dword ONE
          .dword TWO
          .dword THREE
          .dword BL
          .dword BS
          .dword BELL
          .dword BOUNDS
          .dword HERE
          .dword ALIGNED
          .dword WBSPLIT
          .dword BWJOIN                 ; 0xB0
          FCIMM B_MARK      ; b(<mark)
          FCIMM B_RESOLVE   ; b(>resolve)
          FCIMM FERROR                ; obsolete set-token-table
          FCIMM FERROR                ; obsolete set-table
          .dword NEW_TOKEN
          .dword NAMED_TOKEN
          FCIMM B_COLON
          FCIMM pVALUE      ; subject to INSTANCE
          FCIMM pVARIABLE   ; subject to INSTANCE
          FCIMM B_CONSTANT  ; b(constant)
          FCIMM pCREATE     ; b(create) -> pCREATE
          FCIMM pDEFER      ; subject to INSTANCE
          FCIMM pBUFFER     ; subject to INSTANCE
          FCIMM B_FIELD     ; b(field)
          FCIMM FERROR                ; obsolete b(code) (re-use OK for native words?)
          FCIMM FERROR                ; INSTANCE    ; 0xC0
          FCIMM FERROR                ; reserved
          FCIMM SEMI        ; B_SEMI, same as SEMI for now
          FCIMM B_TO
          FCIMM B_CASE      ; b(case)
          FCIMM B_ENDCASE   ; b(endcase)
          FCIMM B_ENDOF     ; b(endof)
          .dword PNUM
          .dword PNUMS
          .dword PDONE
          .dword EXTERNAL_TOKEN
          .dword dFIND
          .dword OFFSET16
          .dword EVALUATE
          FCIMM FERROR
          FCIMM FERROR
          .dword CCOMMA                 ; 0xD0
          .dword WCOMMA
          .dword LCOMMA
          .dword COMMA
          .dword UMMULT
          .dword UMDIVMOD
          FCIMM FERROR
          FCIMM FERROR
          .dword DPLUS
          .dword DMINUS
          .dword GET_TOKEN
          .dword SET_TOKEN
          .dword STATE
          .dword COMPILECOMMA
          .dword BEHAVIOR
          FCIMM FERROR                ; 0xDF-0xEF reserved
          FCIMM FERROR                ; 0xE0
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          .dword START0                 ; 0xF0
          .dword START1
          .dword START2
          .dword START4
          FCIMM FERROR                ; 0xF4-0xFB reserved
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR                ; 0xFC explicitly FERROR
          .dword VERSION1
          FCIMM FERROR                ; obsolete 4-byte-id
          .dword FCEND                  ; 0xFF
.endproc

.proc     fcrom2
          FCIMM FERROR                ; 0x200
          FCIMM FERROR                ; device-name
          FCIMM FERROR                ; my-args
          FCIMM FERROR                ; my-self
          FCIMM FERROR                ; find-package
          FCIMM FERROR                ; open-package
          FCIMM FERROR                ; close-package
          FCIMM FERROR                ; find-method
          FCIMM FERROR                ; call-package
          FCIMM FERROR                ; $call-parent
          FCIMM FERROR                ; my-parent
          FCIMM FERROR                ; ihandle>phandle
          FCIMM FERROR                ; reserved
          FCIMM FERROR                ; my-unit
          FCIMM FERROR                ; $call-method
          FCIMM FERROR                ; $open-package
          FCIMM FERROR                ; 0x210 historical processor-type
          FCIMM FERROR                ; historical firmware-version
          FCIMM FERROR                ; historical fcode-version
          FCIMM FERROR                ; alarm
          .dword IS_USER_WORD           ; (is-user-word)
          .dword NOOP                   ; suspend-fcode, to be optionally replaced
          .dword ABORT
          .dword CATCH
          .dword THROW
          FCIMM FERROR                ; user-abort
          FCIMM FERROR                ; get-my-property
          FCIMM FERROR ; DECODE_INT
          FCIMM FERROR ; DECODE_STRING
          FCIMM FERROR                ; get-inherited-property
          FCIMM FERROR                ; delete-property
          FCIMM FERROR                ; get-package-property
          .dword CPEEK                  ; 0x220
          .dword WPEEK
          .dword LPEEK
          .dword CPOKE
          .dword WPOKE
          .dword LPOKE
          .dword WBFLIP
          .dword LBFLIP
          .dword LBFLIPS
          FCIMM FERROR                ; historical adr-mask
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          .dword dRBFETCH
          .dword dRBSTORE
          .dword dRWFETCH
          .dword dRWSTORE
          .dword dRLFETCH
          .dword dRLSTORE
          .dword WBFLIPS
          .dword LWFLIPS
          FCIMM FERROR                ; probe
          FCIMM FERROR                ; probe-virtual
          FCIMM FERROR                ; reserved
          FCIMM FERROR                ; child
          FCIMM FERROR                ; peer
          FCIMM FERROR                ; next-property
          .dword BYTE_LOAD
          FCIMM FERROR                ; set-args
          .dword LEFT_PARSE_STRING
          .repeat $aa
          FCIMM FERROR                ; remaining are reserved
          .endrepeat
          ; the last 15 XTs overlap with fcrom1 to save space
.endproc

.proc     fcrom1
          FCIMM FERROR                ; 0x100 reserved
          FCIMM FERROR                ; dma-alloc
          FCIMM FERROR                ; my-address
          FCIMM FERROR                ; my-space
          FCIMM FERROR                ; historical memmap
          FCIMM FERROR                ; free-virtual
          FCIMM FERROR                ; historical >physical
          FCIMM FERROR                ; 0x107-0x10E reserved
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR
          FCIMM FERROR                ; my-params
          FCIMM FERROR ; PROPERTY               ; 0x110
          FCIMM FERROR ; ENCODE_INT
          FCIMM FERROR ; ENCODEPLUS
          FCIMM FERROR ; ENCODE_PHYS
          FCIMM FERROR ; ENCODE_STRING
          FCIMM FERROR ; ENCODE_BYTES
          FCIMM FERROR                ; reg
          FCIMM FERROR                ; obsoluete intr
          FCIMM FERROR                ; driver
          FCIMM FERROR                ; model
          FCIMM FERROR                ; device-type
          .dword PARSE_2INT             ; 0x11b
          ; the rest are unimplemented in the ROM, need to be installed later
          ; and overlap with fcromnone
.endproc

.proc     fcromnone
          .repeat 256
          FCIMM FERROR
          .endrepeat
.endproc
fcrom3  = fcromnone                ; reserved
fcrom4  = fcromnone                ; reserved
fcrom5  = fcromnone                ; reserved
fcrom6  = fcromnone                ; vendor
fcrom7  = fcromnone                ; vendor
fcrom8  = fcromnone                ; local codes table 8-f
fcrom9  = fcromnone
fcroma  = fcromnone
fcromb  = fcromnone
fcromc  = fcromnone
fcromd  = fcromnone
fcrome  = fcromnone
fcromf  = fcromnone

.proc   fc_romtab
          FCROM fcrom0
          FCROM fcrom1
          FCROM fcrom2
          FCROM fcrom3
          FCROM fcrom4
          FCROM fcrom5
          FCROM fcrom6
          FCROM fcrom7
          FCROM fcrom8
          FCROM fcrom9
          FCROM fcroma
          FCROM fcromb
          FCROM fcromc
          FCROM fcromd
          FCROM fcrome
          FCROM fcromf
.endproc

; headerless words related to FCode evaluation

; ( -- c-addr f )
; Get the pointer to the current FCode tables, and a flag if the table is in ROM
xdword    GET_FTABLES
          ENTER
          .dword dFCODE_TABLES
dof:      .dword FETCH
          .dword DUP
          ONLIT $7FFFFFFF
          .dword LAND
          .dword SWAP
          ONLIT FC_ROMFLAG
          .dword LAND
          EXIT
exdword

; ( u -- c-addr )
; Get the address of a specific FCode table pointer
; e.g. if u is 1, get the cell containing the address of the table for $1xx
; FCodes
xdword    GET_FTABLE_PADDR
          ENTER
          ONLIT $F
          .dword LAND
          .dword GET_FTABLES
          .dword DROP
          .dword SWAP
          .dword NAPLUS
          EXIT
exdword

; ( -- )
; Copy the ROM FCode table list to RAM in preparation for it to be modified
; by set-token, new-token, etc.
xdword    SET_MUTABLE_FTABLES
          ENTER
          .dword GET_FTABLES      ; ( -- c-addr f )
          .dword _IF              ; ( c-addr f -- c-addr )
          .dword already          ; false branch if already in RAM
          ONLIT 16*4              ; ( c-addr -- c-addr u ) 16 tables, 4 bytes per pointer
          .dword DUP              ; ( c-addr u -- c-addr u1 u2 )
          .dword ALLOC            ; ( c-addr u1 u2 -- c-addr1 u1 c-addr2 )
          .dword PtoR             ; ( c-addr1 u1 c-addr2 -- c-addr1 u1 ) ( R: -- c-addr2 )
          .dword RCOPY            ; ( ... c-addr1 u1 c-addr2 )
          .dword SWAP             ; ( ... c-addr1 c-addr2 u1 )
          .dword MOVE             ; ( c-addr1 c-addr2 u1 -- )
          .dword RtoP             ; ( -- c-addr2 ) ( R: c-addr2 -- )
          .dword dFCODE_TABLES    ; ( c-addr2 -- c-addr2 c-addr3 )
          .dword STORE            ; ( c-addr2 c-addr3 -- )
          EXIT
already:  .dword DROP             ; ( c-addr -- )
          EXIT
exdword

; ( u -- a-addr f ) f = 1 if ROM table
xdword    GET_FTABLE
          ENTER
          .dword GET_FTABLE_PADDR
          JUMP GET_FTABLES::dof
exdword

; ( a-addr u -- )
; set table u address to a-addr
xdword    SET_FTABLE
          ENTER
          .dword SET_MUTABLE_FTABLES ; ( a-addr u -- a-addr u )
          .dword GET_FTABLE_PADDR    ; ( a-addr u -- a-addr1 a-addr2 )
          .dword STORE               ; ( a-addr1 a-addr2 -- )
          EXIT
exdword

; ( u -- a-addr )
; Get ROM ftable address for table u
xdword    GET_ROM_FTABLE
          ENTER
          ONLIT fc_romtab
          .dword SWAP
          .dword NAPLUS
          .dword FETCH
          EXIT
exdword

; ( u -- )
; Force table u to the ROM table without freeing the existing RAM table
xdword    FORCE_ROM_FTABLE
          ENTER
          .dword DUP              ; ( u -- u1 u2 )
          .dword GET_FTABLE       ; ( u1 u2 -- u1 a-addr f )
          .dword _IFFALSE         ; ( u1 a-addr f -- u1 a-addr )
          .dword already          ; is true, already in ROM
          .dword DROP             ; ( .. u1 ) don't need current address
          .dword DUP              ; ( u1 -- u1 u2 )
          .dword GET_ROM_FTABLE   ; ( u1 u2 -- u1 a-addr )
          .dword SWAP             ; ( u1 a-addr -- a-addr u1 )
          .dword SET_FTABLE       ; ( a-addr u1 -- )
          EXIT
already:  .dword TWODROP          ; ( u1 a-addr -- )
          EXIT
exdword

; ( u -- )
; Set table u to the ROM table, freeing existing RAM table
xdword    SET_ROM_FTABLE
          ENTER
          .dword DUP              ; ( u -- u1 u2 )
          .dword GET_FTABLE       ; ( u1 u2 -- u1 a-addr f )
          .dword _IFFALSE         ; ( u1 a-addr f -- u1 a-addr )
          .dword already          ; is true, already in ROM
          .dword ZERO             ; ( ... u1 a-addr 0 )
          .dword FREE             ; ( ... u1 ) free existing RAM
          .dword DUP              ; ( u1 -- u1 u2 )
          .dword GET_ROM_FTABLE   ; ( u1 u2 -- u1 a-addr )
          .dword SWAP             ; ( u1 a-addr -- a-addr u1 )
          .dword SET_FTABLE       ; ( a-addr u1 -- )
          EXIT
already:  .dword TWODROP          ; ( u1 a-addr -- )
          EXIT
exdword

;  ( u -- )
; Set table u to be a RAM table, allocating memory and copying the existing table
; do nothing if it is already a RAM table
xdword    SET_RAM_FTABLE
          ENTER
          .dword PtoR             ; ( u -- ) ( R: u )
          .dword RCOPY            ; ( -- u )
          .dword GET_FTABLE       ; ( u -- a-addr f )
          .dword _IF              ; ( a-addr f -- a-addr )
          .dword already
doset:    ONLIT $100*4            ; ( ... a-addr $400 )
          .dword DUP              ; ( ... a-addr $400 $400 )
          .dword ALLOC            ; ( ... a-addr1 $400 a-addr2 )
          .dword PtoR             ; ( ... a-addr1 $400 ) ( R: ... u a-addr2 )
          .dword RCOPY            ; ( ... a-addr1 $400 a-addr2 )
          .dword SWAP             ; ( ... a-addr1 a-addr2 $400 )
          .dword MOVE             ; ( a-addr1 a-addr2 $400 -- )
          .dword RtoP             ; ( -- a-addr2 )
          .dword RtoP             ; ( -- a-addr u )
          .dword SET_FTABLE       ; ( a-addr u -- )
          EXIT
already:  .dword RtoP
          .dword TWODROP          ; ( a-addr -- )
          EXIT
exdword

; ( -- )
; set tables 0-7 to ROM tables, freeing any RAM tables
xdword    SET_ROM_FTABLE_SYS
          ENTER
          ONLIT $7
set1:     .dword DUP              ; ( n -- n1 n2 )
          .dword SET_ROM_FTABLE   ; ( n1 n2 -- n1 )
          .dword QDUP             ; ( n1 -- 0 | n1 -- n1 n2 )
          .dword _IF              ; ( 0 -- | n1 n2 -- n1 )
          .dword done 
          .dword DECR             ; ( n1 -- n1' )
          JUMP set1
done:     EXIT
exdword

; ( -- )
; set tables 8-F to ROM tables, freeing any RAM tables
xdword    SET_ROM_FTABLE_PRG
          ENTER
          ONLIT $F
set1:     .dword DUP              ; ( n -- n1 n2 )
          .dword SET_ROM_FTABLE   ; ( n1 n2 -- n1 )
          .dword DUP              ; ( n1 -- n1 n2 )
          ONLIT $8                ; ( n1 n2 -- n1 n2 8 )
          .dword EQUAL            ; ( n1 n2 8 -- n1 f )
          .dword _IFFALSE         ; ( n1 f -- n1 )
          .dword done
          .dword DECR             ; ( n1 -- n1' )
          JUMP set1
done:     .dword DROP             ; ( n1 -- )
          EXIT
exdword

; ( a-addr -- )
; save tables 8-F pointers to a-addr restoring the existing table to ROM vectors
xdword    SAVE_PRG_FTABLES
          ENTER
          .dword SET_MUTABLE_FTABLES ; ( a-addr -- a-addr )
          ONLIT 8                 ; ( a-addr -- a-addr 8 )
          .dword GET_FTABLE_PADDR ; ( a-addr 8 -- a-addr1 a-addr2 )
          .dword SWAP             ; ( ... a-addr2 a-addr1 )
          ONLIT 8*4               ; ( ... a-addr2 a-addr1 )
          .dword MOVE             ; ( ... )
           ONLIT $F
set1:     .dword DUP              ; ( n -- n1 n2 )
          .dword FORCE_ROM_FTABLE ; ( n1 n2 -- n1 )
          .dword DUP              ; ( n1 -- n1 n2 )
          ONLIT  $8               ; ( n1 n2 -- n1 n2 8 )
          .dword EQUAL            ; ( n1 n2 8 -- n1 f )
          .dword _IFFALSE         ; ( n1 f -- n1 )
          .dword done
          .dword DECR             ; ( n1 -- n1' )
          JUMP set1
done:     .dword DROP             ; ( n1 -- )
          EXIT
exdword

; ( a-addr -- )
; set tables 8-F to pointers in c-addr, freeing c-addr after restoring, also freeing
; any RAM tables
xdword    RESTORE_PRG_FTABLES
          ENTER
          .dword SET_MUTABLE_FTABLES ; ( a-addr -- a-addr )
          .dword SET_ROM_FTABLE_PRG  ; ( a-addr -- a-addr )
          ONLIT 8                    ; ( a-addr -- a-addr 8 )
          .dword GET_FTABLE_PADDR    ; ( a-addr 8 -- a-addr1 a-addr2 )
          ONLIT 8*4                  ; ( a-addr1 a-addr2 -- a-addr1 a-addr2 24 )
          .dword MOVE                ; ( a-addr1 a-addr2 24 -- )
          EXIT
exdword

; save the current state of the FCode internal variables and program-defined memory
; into newly-allocated memory, return address
; ( -- a-addr )
xdword    SAVE_FCODE_STATE
          ENTER
          ; Allocate memory
          ONLIT 8*4+5*4             ; 5 variables plus program-defined table size
          .dword ALLOC
          .dword PtoR
          ; $FCODE-IP and $FCODE-END
          .dword dFCODE_IP
          .dword FETCH
          .dword dFCODE_END
          .dword FETCH
          .dword RCOPY
          .dword TWOSTORE
          ; $FCODE-SPREAD and $FCODE-OFFSET
          .dword dFCODE_SPREAD
          .dword FETCH
          .dword dFCODE_OFFSET
          .dword FETCH
          .dword RCOPY
          .dword TWO
          .dword NAPLUS
          .dword TWOSTORE
          ; $FCODE-FETCH
          .dword dFCODE_FETCH
          .dword FETCH
          .dword RCOPY
          ONLIT 4
          .dword NAPLUS
          .dword STORE
          ; Program-defined FCode tables
          .dword RCOPY
          ONLIT 5
          .dword NAPLUS
          .dword SAVE_PRG_FTABLES
          .dword RtoP
          EXIT
exdword

; ( a-addr -- )
xdword    RESTORE_FCODE_STATE
          ENTER
          ; Program-defined FCode Tables
          .dword PtoR
          .dword RCOPY
          ONLIT 5
          .dword NAPLUS
          .dword RESTORE_PRG_FTABLES
          ; $FCODE-FETCH
          .dword RCOPY
          ONLIT 4
          .dword NAPLUS
          .dword FETCH
          .dword dFCODE_FETCH
          .dword STORE
          ; $FCODE-OFFSET and $FCODE-SPREAD
          .dword RCOPY
          .dword TWO
          .dword NAPLUS
          .dword TWOFETCH
          .dword dFCODE_OFFSET
          .dword STORE
          .dword dFCODE_SPREAD
          .dword STORE
          ; $FCODE-END and $FCODE-IP
          .dword RCOPY
          .dword TWOFETCH
          .dword dFCODE_END
          .dword STORE
          .dword dFCODE_IP
          .dword STORE
          ; finally, free memory
          .dword RtoP
          .dword ZERO
          .dword FREE
          EXIT
exdword

; ( fcode# -- a-addr )
xdword    GET_TOKEN_PADDR
          ENTER
          .dword WBSPLIT          ; ( fcode# - u table# )
          .dword GET_FTABLE       ; ( u table# -- u tableaddr f )
          .dword DROP             ; ( u tableaddr f -- u tableaddr )
          .dword SWAP             ; ( u tableaddr -- tableaddr u )
          .dword NAPLUS           ; ( tableaddr u -- a-addr )
          EXIT
exdword

; ( xt f fcode# -- )
xdword    xSET_TOKEN
          ENTER
          .dword PtoR             ; ( xt f fcode# -- xt f ) ( R: fcode# )
          .dword _IF              ; ( xt f -- xt )
          .dword notimm
          ONLIT FC_IMMFLAG        ; 
          .dword LOR
notimm:   .dword SET_MUTABLE_FTABLES
          .dword RCOPY
          ONLIT 8
          .dword RSHIFT
          .dword SET_RAM_FTABLE
          .dword RtoP
          .dword GET_TOKEN_PADDR
          .dword STORE
          EXIT
exdword
xSET_TOKEN_code = xSET_TOKEN::code

.proc     lGET_TOKEN
          ldy   #SV_FCODE_TABLES+2
          lda   [SYSVARS],y       ; Copy table of tables address
          sta   WR+2              ; to WR
          dey
          dey
          lda   [SYSVARS],y
          sta   WR
          lda   STACKBASE+0,x     ; now get the table number
          xba
          and   #$0F
          asl                     ; multiply by 4 (cell size)
          asl
          tay                     ; and use for index
          lda   [WR],y            ; get table address low word
          pha                     ; save it
          iny
          iny
          lda   [WR],y            ; high word
          sta   WR+2              ; now put that in WR
          pla
          sta   WR
          lda   STACKBASE+0,x     ; get token again
          and   #$FF              ; mask in low byte
          asl                     ; multiply by 4
          asl
          tay                     ; and use for index
          lda   [WR],y            ; (y = 2) grab token low byte
          sta   STACKBASE+0,x     ; put in data stack
          iny
          iny
          lda   [WR],y
          php                     ; save for flag
          and   #$7FFF
          sta   STACKBASE+2,x
          ldy   #$0000            ; for flag
          plp
          bpl   :+
          dey
:         dex                     ; make room for flag
          dex
          dex
          dex
          sty   STACKBASE+0,x     ; and put it on stack
          sty   STACKBASE+2,x
          rtl
.endproc

; Increment FCode IP by spread
; Put FCode IP on stack
; Jump to fetch method
; The reasons we do it in this order are:
; * We need the routines that change the spread to be run before the next increment.
; * We would like the IP to point to the address with the FCode that caused an exception.
; The consequences are:
; * byte-load needs to load the address less 1 so that the first increment goes to the
;   correct address.
xdword    xFCODE_FETCH
          dex                     ; add a stack item, hope there's room!
          dex
          dex
          dex
          ldy   #SV_FCODE_SPREAD  ; get spread
          lda   [SYSVARS],y
          sta   XR                ; and hold in XR for now
          ldy   #SV_FCODE_IP      ; get IP
          lda   [SYSVARS],y       ; low byte
          clc                     ; now add spread
          adc   XR
          sta   [SYSVARS],y       ; and write back
          sta   STACKBASE+0,x     ; put on data stack
          iny                     ; go to high byte of IP
          iny
          lda   [SYSVARS],y       ; fetch it
          adc   #$0000            ; in case spread carried
          sta   [SYSVARS],y       ; write back
          sta   STACKBASE+2,x     ; put on data stack
          ldy   #SV_FCODE_FETCH   ; now get XT for fetch function
          lda   [SYSVARS],y       ; and set it up for RUN
          pha
          iny
          iny
          lda   [SYSVARS],y
          ply
          LRUN
exdword

; ( u -- ) skip u bytes of FCode
xdword    xFCODE_SKIP
          ENTER
          .dword dFCODE_SPREAD
          .dword FETCH
          .dword UMULT
          .dword dFCODE_IP
          .dword PSTORE
          EXIT
exdword

xdword    xFCODE_FETCH_TOKEN
          ENTER
          .dword xFCODE_FETCH     ; ( -- u ) fetch first byte of FCODE
          .dword DUP              ; ( ... u u' )
          .dword _IF              ; ( ... u )
          .dword one              ; if zero, one byte token
          .dword DUP              ; ( ... u u' )
          ONLIT $10               ; ( ... u u' $10 )
          .dword ULT              ; ( ... u f )
          .dword _IF              ; ( ... u )
          .dword one              ; if $10 or more, one-byte token
          .dword xFCODE_FETCH     ; ( ... u1 u2 ) otherwise fetch low byte
          .dword SWAP             ; ( ... u2 u1 ) put low byte first
          .dword BWJOIN           ; and combine into a word
one:      EXIT
exdword

xdword    xFCODE_FETCH_NUM16
          ENTER
          .dword xFCODE_FETCH     ; high byte
          .dword xFCODE_FETCH     ; low byte
          .dword SWAP
          .dword BWJOIN
          EXIT
exdword

xdword    xFCODE_FETCH_OFFSET
          ENTER
          .dword dFCODE_OFFSET
          .dword FETCH
          .dword _IF
          .dword offset8
          .dword xFCODE_FETCH_NUM16
          .dword WSX
          EXIT
offset8:  .dword xFCODE_FETCH
          .dword BSX
          EXIT
exdword

xdword    xFCODE_FETCH_NUM32
          ENTER
          .dword xFCODE_FETCH_NUM16 ; high word
          .dword xFCODE_FETCH_NUM16 ; low word
          .dword SWAP
          .dword WLJOIN
          EXIT
exdword

; Consume a string from the FCode stream and return it in a newly-allocated
; chunk from the heap.  This *must* be freed with FREE_MEM
; ( -- c-addr u )
xdword    xFCODE_FETCH_STR
          ENTER
          .dword xFCODE_FETCH     ; ( -- u ) get length of string
          .dword DUP              ; ( u -- u u' )
          .dword PtoR             ; ( u u' -- u ) ( R: u )
          .dword ALLOC            ; ( u -- c-addr ) allocate space
          .dword ZERO             ; ( c-addr -- c-addr count )
lp:       .dword DUP              ; ( c-addr count -- c-addr count count' )
          .dword RCOPY            ; ( ... c-addr count count' u )
          .dword EQUAL            ; ( ... c-addr count f )
          .dword _IFFALSE         ; ( ... c-addr count ) are we done?
          .dword done             ; true branch, yes, finished
          .dword TWODUP           ; ( ... c-addr count c-addr' count' )
          .dword PLUS             ; ( ... c-addr count c-addr2 )
          .dword xFCODE_FETCH     ; ( ... c-addr count c-addr2 char )
          .dword SWAP             ; ( ... c-addr count char c-addr2 )
          .dword CSTORE           ; ( ... c-addr count )
          .dword INCR             ; ( ... c-addr count+1 )
          JUMP lp
done:     .dword RDROP
          EXIT
exdword

; Compile or execute token based on current state and immediacy of the token
; ( fcode# -- nx... )
xdword    DO_TOKEN
          ENTER
          ;.dword DOTS
          .dword GET_TOKEN
          .dword _IF              ; is immediate word?
          .dword notimm           ; no, either compile or execute
          .dword TEMPDQ
          .dword _IF              ; check if requires temp def when interpreting         
          .dword exec             ; it doesn't, just execute
          .dword _SMART           ; true branch, see if we are interpreting
          .dword tempdef          ; we are, start temporary definition          
exec:     .dword EXECUTE          ; otherwise execute
          EXIT
notimm:   .dword _SMART
          .dword exec             ; execute if interpreting
compile:  .dword COMPILECOMMA     ; otherwise compile it
          EXIT
tempdef:  .dword PtoR             ; ( xt -- ) ( R: -- xt )
          .dword dTEMPCOLON       ; start temporary colon definition
          .dword RtoP             ; ( -- xt ) ( R: xt -- )
          .dword IMMEDQ           ; is base definition immediate?  (It usually is)
          .dword _IF
          .dword compile          ; no, compile xt
          JUMP exec               ; yes, execute xt
exdword

; FCode evaluator, assumes things were set up correctly by byte-load
xdword    xFCODE_EVALUATE
          ENTER
lp:       .dword dFCODE_END       ; ( -- a-addr )
          .dword FETCH            ; ( -- f )
          .dword _IFFALSE         ; ( f -- )
          .dword done             ; true, stop evaluating
          .if trace_fcode
          ONLIT '['
          .dword EMIT
          .dword SPACE
          .dword DEPTH
          .dword UDOT
          .endif
          .dword xFCODE_FETCH_TOKEN ; ( -- token ) not ending
          .if trace_fcode
          .dword dFCODE_IP
          .dword FETCH
          .dword UDOT
          .dword DUP
          .dword UDOT
          .endif
          ONLIT DO_TOKEN          ; ( ... token xt )
          .dword CATCH            ; ( ... xn )
          .if trace_fcode
          ONLIT ']'
          .dword EMIT
          .dword CR
          .endif
          .dword QDUP
          .dword _IF
          .dword lp               ; false ( -- ) go to loop
          .dword DUP              ; true, ( exc -- exc exc' ) save in $FCODE-END
          .dword dFCODE_END       ; ( ... exc exc' c-addr )
          .dword STORE            ; ( ... exc )
          .dword DUP              ; ( ... exc exc' )
          .dword _IF              ; ( ... exc )
          .dword :+
          SLIT " FCode error "
          .dword TYPE
          .dword DUP              ; ( ... exc exc' )
          .dword DOTD             ; ( ... exc )
          SLIT "@ "
          .dword TYPE
          .dword dFCODE_IP        ; ( ... exc addr )
          .dword FETCH            ; ( ... exc addr2 )
          .dword UDOT             ; ( ... exc )
:         ;.dword DOTS
          .dword THROW            ; ( exc -- ) and THROW
done:     EXIT
exdword

xdword    FCEND
          ENTER
          ONLIT 1
          .dword dFCODE_END
          .dword STORE
          EXIT
exdword

xdword    VERSION1
          ENTER
          .dword ONE              ; spread
          .dword ZERO             ; offset (0 = 8, nonzero = 16)
set:      .dword dFCODE_OFFSET
          .dword STORE
          .dword dFCODE_SPREAD
          .dword STORE
drophdr:  ONLIT 7
          .dword xFCODE_SKIP      ; drop the header
          EXIT
exdword

xdword    OFFSET16
          ENTER
          .dword dFCODE_OFFSET
          .dword ON
          EXIT
exdword

xdword    START4
          ENTER
          ONLIT 4
set:      .dword MINUSONE
          JUMP VERSION1::set
exdword

xdword    START2
          ENTER
          .dword TWO
          JUMP START4::set
exdword

xdword    START1
          ENTER
          .dword ONE
          JUMP START4::set
exdword

xdword    START0
          ENTER
          .dword ZERO
          JUMP START4::set
exdword

xdword    B_LIT
          ENTER
          .dword xFCODE_FETCH_NUM32
dolit:    .dword _SMART
          .dword interp
          .dword LITERAL
interp:   EXIT
exdword

xdword    B_TICK
          ENTER
          .dword xFCODE_FETCH_TOKEN
          .dword GET_TOKEN
          .dword DROP
          JUMP B_LIT::dolit
exdword

xdword    B_QUOTE
          ENTER
          .dword xFCODE_FETCH_STR ; ( -- c-addr u ) get length of string
          ;.dword DBGMEM
          .dword TWODUP           ; ( c-addr u -- c-addr u c-addr' u' )
          .dword _SMART
          .dword interp
          .dword SLITERAL         ; ( ... c-addr u )
          JUMP done
interp:   .dword dTMPSTR          ; ( ... c-addr u c-addr2 u2 )
          .dword TWOSWAP          ; ( ... c-addr2 u2 c-addr u )          
done:     .dword FREE             ; ( ... c-addr2 u2 ) | ( ... )
          ;.dword DBGMEM
          EXIT
exdword

; Defining stuff in FCode is kind of a pain because there is a preparation step
; consisting of NEW-TOKEN, NAMED-TOKEN, or EXTERNAL token that starts the definition
; followed by one of the words that defines the behavior of the definition

xdword    dMKENTRY
          jsl   _l2parm
          jsl   _lmkentry
          LPUSHNEXT               ; flags/XT
exdword

xdword    EXTERNAL_TOKEN
          ENTER
doext:    .dword xFCODE_FETCH_STR     ; ( -- str len )
          .dword TWODUP               ; ( str len -- str len str' len' )
          .dword TWOPtoR              ; ( str len str' len' -- str len) ( R: str' len' )
          .dword xFCODE_FETCH_TOKEN   ; ( str len -- str len fcode# )
          .dword NROT                 ; ( str len fcode# -- fcode# str len )
          .dword dMKENTRY             ; ( fcode# str len -- fcode# xt )
          .dword TWORtoP              ; ( fcode# xt -- fcode# xt str' len' )
          .dword FREE                 ; ( fcode# xt str' len' -- fcode# xt )
settok:   ONLIT 0                     ; ( fcode# xt -- fcode# xt f )
          .dword ROT                  ; ( fcode# xt f -- xt f fcode# )
          .dword DUP                  ; ( ... xt f fcode# fcode# )
          .dword dFCODE_LAST          ; ( ... xt f fcode# fcode# c-addr )
          .dword STORE                ; ( ... xt f fcode# )
          .dword SET_TOKEN            ; ( xt f fcode# -- )
          EXIT
exdword

xdword    NEW_TOKEN
          ENTER
          .dword xFCODE_FETCH_TOKEN   ; ( -- fcode# )
          ONLIT $80                   ; ( ... fcode# $80 ) name length is 0 for noname
          .dword CCOMMA               ; ( ... fcode# )
          .dword HERE                 ; ( ... fcode# xt ) XT/flags
          ONLIT $00                   ; ( ... fcode# xt $00 ) noname flags
          .dword CCOMMA               ; ( ... fcode# xt )
          JUMP EXTERNAL_TOKEN::settok
exdword

xdword    NAMED_TOKEN
          ENTER
          .dword dFCODE_DEBUG
          .dword FETCH
          .dword _IFFALSE
          .dword EXTERNAL_TOKEN::doext
          .dword xFCODE_FETCH_STR     ; retrieve token name
          .dword FREE                 ; immediately free it
          .dword NEW_TOKEN            ; and make headerless
          EXIT
exdword

xdword    B_COLON
          ENTER
          .dword dCOLON               ; compile ENTER
          .dword dFCODE_LAST          ; ( -- c-addr )
          .dword FETCH                ; ( c-addr -- fcode# )
          .dword GET_TOKEN            ; ( fcode# -- xt f )
          .dword DROP                 ; ( xt f -- xt )
          .dword DUP                  ; ( xt -- xt xt' )
          .dword rLINK                ; ( xt xt' -- xt c-addr|0 )
          .dword QDUP                 ; ( xt c-addr|0 -- xt c-addr c-addr' | xt 0 )
          .dword _IF                  ; ( .. xt c-addr | xt )
          .dword noname
          .dword dOLDHERE             ; ( xt c-addr -- xt c-addr c-addr2 )
          .dword STORE                ; ( xt c-addr c-addr2 -- xt )
          .dword DUP                  ; ( xt -- xt xt' )
          .dword SMUDGE               ; ( xt xt' -- xt )
          .dword STATEC               ; xt on stack for colon-sys
          EXIT
noname:   .dword STATEC               ; xt on stack for colon-sys
          EXIT
exdword

xdword    B_CONSTANT
          jsl _l1parm
          jml dVALUE::dovalue
exdword

xdword    B_FIELD
          jsl _l1parm
          jml dFIELD::dofield
exdword

xdword    DEST_ON_TOP
          ENTER
          ;.dword DOTS
          .dword ZERO 
          .dword PtoR 
b1:       .dword DUP 
          .dword FETCH
          ONLIT _CONTROL_MM
          .dword EQUAL
          .dword _IF
          .dword e1b2 
          .dword PtoR 
          JUMP b1
e1b2:     .dword RtoP
          .dword DUP 
          .dword _IF
          .dword e2 
          .dword SWAP 
          JUMP e1b2
e2:       .dword DROP
          ;.dword DOTS
          EXIT
exdword

; Branch FCode while interpreting
; ( fcode-offset -- )
xdword    IBRANCH
          ENTER
          .dword DUP
          .dword ZEROLT
          .dword _IF
          .dword pos              ; positive offset, just skip
          .dword dFCODE_SPREAD    ; negative offset, compute new IP
          .dword FETCH
          .dword UMULT
          .dword dFCODE_IP
          .dword FETCH
          .dword PLUS
          .dword dFCODE_IP
          .dword STORE
          EXIT
pos:      .dword DECR
          .dword dFCODE_OFFSET
          .dword FETCH
          .dword _IF              ; offset size
          .dword :+               ; 8, skip forward 
          .dword DECR             ; decrement again
:         .dword xFCODE_SKIP          
          EXIT
exdword

; Maybe branch FCode
xdword    BQBRANCH
          ENTER
          .dword xFCODE_FETCH_OFFSET
          .dword _SMART
          .dword interp
          .dword ZEROLT           ; is offset negative?
          .dword _IF
          .dword cpos             ; no, positive offset
          .dword UNTIL
          EXIT
cpos:     .dword IF
          ;.dword DOTS
          EXIT
interp:   .dword SWAP             ; move flag to front
          .dword _IFFALSE
          .dword nobr             ; do nothing if true
          .dword IBRANCH          ; otherwise branch
          EXIT
nobr:     .dword DROP             ; drop offset
          EXIT
exdword

xdword    BBRANCH
          ENTER
          .dword xFCODE_FETCH_OFFSET
          .dword _SMART
          .dword interp
          .dword ZEROLT
          .dword _IF
          .dword cpos
          .dword AGAIN
          EXIT
cpos:     .dword dFCODE_IP
          .dword FETCH
          .dword xFCODE_FETCH_TOKEN ; peek next token
          ONLIT $B2               ; B(>RESOLVE)
          .dword EQUAL            ; see if it's B(>RESOLVE)
          .dword _IF
          .dword ahead            ; it's not, do ahead and fix IP
          .dword DROP             ; drop saved IP
          .dword ELSE             ; do ELSE
          EXIT
ahead:    .dword AHEAD
          .dword dFCODE_IP
          .dword STORE
          EXIT
interp:   .dword IBRANCH          ; otherwise branch
          EXIT
exdword

xdword    B_MARK
          ENTER
          .dword _SMART
          .dword done ; interpreting
          .dword BEGIN
done:     EXIT
exdword

xdword    B_RESOLVE
          ENTER
          ;.dword DOTS
          .dword _SMART
          .dword done ; interpreting
          .dword THEN
done:     EXIT
exdword

xdword    B_CASE,F_IMMED|F_TEMPD
          ENTER
          .dword CASE
          EXIT
exdword

xdword    B_ENDCASE
          ENTER
          .dword ENDCASE
          EXIT
exdword

xdword    B_OF
          ENTER
          .dword xFCODE_FETCH_OFFSET
          .dword DROP
          .dword OF
          EXIT
exdword

xdword    B_ENDOF
          ENTER
          .dword xFCODE_FETCH_OFFSET
          .dword DROP
          .dword ENDOF
          EXIT
exdword

xdword    B_DO,F_IMMED|F_TEMPD
          ENTER
          .dword xFCODE_FETCH_OFFSET
          .dword DROP
          .dword DO               ; postpone DO
          EXIT
exdword

xdword    B_QDO,F_IMMED|F_TEMPD
          ENTER
          .dword xFCODE_FETCH_OFFSET
          .dword DROP
          .dword QDO
          EXIT
exdword

xdword    B_LOOP
          ENTER
          .dword xFCODE_FETCH_OFFSET
          .dword DROP
          .dword LOOP
          EXIT
exdword

xdword    B_PLOOP
          ENTER
          .dword xFCODE_FETCH_OFFSET
          .dword DROP
          .dword PLOOP
          EXIT
exdword


xdword    B_LEAVE
          ENTER
          .dword _COMP_LIT
          .dword LEAVE
          EXIT
exdword

xdword    B_TO
          ENTER
          .dword xFCODE_FETCH_TOKEN
          .dword GET_TOKEN
          .dword DROP
          JUMP TO::doto
          EXIT
exdword

xdword    FCODE_REVISION
          FCONSTANT $00030000
exdword

