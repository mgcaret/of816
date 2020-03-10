
; Forth Built-in Dictionary

; Note that no primitive words should start with a JSL as the body-modifying words
; such as TO, DEFER!, etc. will assume that they can write to the cell immediately
; following the JSL.  This would be bad if they are not supposed to do so.
; of course, this caution doesn't apply to words in ROM that can't be altered

; comments starting with H: define help text to be used for documentation generation
; including if I ever ship a help command

dstart "forth"

.if max_search_order > 0
; ( u -- wid ) search order word list entry by number
hword     WLNUM,"WL#"
          ENTER
          .dword dORDER
          .dword SWAP
          .dword DUP
          ONLIT max_search_order
          .dword ULT
          .dword _IF
          .dword bad
          .dword INCR
          .dword NAPLUS
          EXIT
bad:      ONLIT -49
          .dword THROW
eword

; H: ( widn ... wid1 n -- ) Set dictionary search order.
dword     SET_ORDER,"SET-ORDER"
          ENTER
          .dword DUP
          .dword _IF
          .dword empty
          .dword DUP              ; ( ... widn ... wid1 n n' )
          ONLIT 0                 ; ( ... widn ... wid1 n n' 1 )
          .dword SLT              ; ( ... widn ... wid1 n f )
          .dword _IF              ; ( ... widn ... wid1 n )
          .dword dolist
          .dword DROP             ; ( n -- )
          .dword FORTH_WORDLIST   ; ( -- wid )
          ONLIT 1                 ; ( ... wid 1 )
dolist:   .dword DUP              ; ( ... widn ... wid1 u u' )
          ONLIT max_search_order  ; ( ... widn ... wid1 u u' u2 )
          .dword ULTE             ; ( ... widn ... wid1 u f )
          .dword _IF              ; ( ... widn ... wid1 u )
          .dword bad
          .dword DUP              ; ( ... widn ... wid1 u u' )
          .dword dORDER           ; ( ... widn ... wid1 u u' c-addr )
          .dword STORE            ; ( ... widn ... wid1 u )
          .dword DECR
          ONLIT 0                 ; ( ... widn ... wid1 u' 0 )
          .dword SWAP             ; ( ... widn ... wid1 0 u' )
          .dword _DO              ; ( ... widn ... wid1 )
          JUMP lpdone
lp:       .dword IX               ; ( ... widn ... wid1 u' )
          .dword WLNUM            ; ( ... widn ... wid1 c-addr )   
          .dword STORE
          ONLIT -1
          .dword _PLOOP
          .dword lp
lpdone:   .dword UNLOOP
          EXIT
bad:      ONLIT -49
          .dword THROW
empty:    .dword dORDER
          .dword STORE
          EXIT
eword

.endif

.if max_search_order > 0
; H: ( -- wid ) Return the WID of the wordlist containing system words.
dword     FORTH_WORDLIST,"FORTH-WORDLIST"
.else
hword     FORTH_WORDLIST,"FORTH-WORDLIST"
.endif
          SYSVAR SV_FORTH_WL
eword

; H: ( -- ) Set the first wordlist in the search order to the system words
dword     FORTH,"FORTH"
.if max_search_order > 0
          ENTER
          .dword FORTH_WORDLIST
          .dword TOP_OF_ORDER
          EXIT
.else
          ; no-op if no search-ordering allowed
          NEXT
.endif
eword

.if max_search_order > 0
; H: ( -- wid ) Return the WID of the wordlist for environmental queries.
dword     dENVQ_WL,"$ENV?-WL"
.else
hword     dENVQ_WL,"$ENV?-WL"
.endif
          SYSVAR SV_ENV_WL
eword

; The prior was the absolute minimum search order that is possible, but we will
; not use it directly, "FORTH" will be the minimum.  However this will be the root
; of all additional wordlists so that the system can be brought into a usable state
; via FORTH.

; ( -- a-addr ) variable containing location of search order
hword     ddORDER,"$$ORDER"
          SYSVAR SV_dORDER
eword

; ( -- a-addr ) location of search order stack
hword     dORDER,"$ORDER"
          ENTER
          .dword ddORDER
          .dword FETCH
          EXIT
eword

; ( -- a-addr ) Variable containing current compiler wordlist.
hword     dCURRENT,"$CURRENT"
          SYSVAR SV_CURRENT
eword

.if max_search_order > 0
; H: ( -- wid ) Return first wordlist in search order.
dword     CONTEXT,"CONTEXT"
.else
hword     CONTEXT,"CONTEXT"
.endif
          ENTER
.if max_search_order > 0
          .dword dORDER
          .dword FETCH
          .dword QDUP
          .dword _IF
          .dword empty
          .dword DECR
          .dword WLNUM
          .dword FETCH
          EXIT
.endif
empty:    .dword dCURRENT
          .dword FETCH
          EXIT
eword

.if max_search_order > 0
; H: ( -- wid ) Get WID current compiler wordlist.
dword     GET_CURRENT,"GET-CURRENT"
.else
hword     GET_CURRENT,"GET-CURRENT"
.endif
          ENTER
          .dword dCURRENT
          .dword FETCH
          EXIT
eword

.if max_search_order > 0
; H: ( -- widn ... wid1 u ) Get dictionary search order.
dword     GET_ORDER,"GET-ORDER"
          ENTER
          .dword dORDER
          .dword FETCH
          ONLIT 0
          .dword _QDO
          JUMP lpdone
lp:       .dword IX
          .dword WLNUM
          .dword FETCH
          ONLIT 1
          .dword _PLOOP
          .dword lp
lpdone:   .dword UNLOOP
          .dword dORDER
          .dword FETCH
          EXIT
eword

; ( wid -- ) Set the first wordlist in the search order.
hword     TOP_OF_ORDER,"TOP-OF-ORDER"
          ENTER
          .dword PtoR
          .dword GET_ORDER
          .dword QDUP
          .dword _IF
          .dword default
          .dword NIP
          .dword RtoP
          .dword SWAP
          .dword SET_ORDER
          EXIT
default:  .dword RtoP
          ONLIT 1
          .dword SET_ORDER
          EXIT
eword

; H: ( -- ) Duplicate the first wordlist in the search order.
dword     ALSO,"ALSO"
          ENTER
          .dword GET_ORDER
          .dword QDUP
          .dword _IFFALSE
          .dword :+
          .dword GET_CURRENT
          .dword ONE
:         .dword INCR
          .dword OVER
          .dword SWAP
          .dword SET_ORDER
          EXIT
eword

; H: ( -- ) Remove the first wordlist in the search order.
dword     PREVIOUS,"PREVIOUS"
          ENTER
          .dword GET_ORDER
          .dword QDUP
          .dword _IF
          .dword noorder
          .dword NIP
          .dword DECR
          .dword SET_ORDER
          EXIT
noorder:  ONLIT -50
          .dword THROW
eword

; H: ( wid -- ) Set the compiler wordlist.
dword     SET_CURRENT,"SET-CURRENT"
          ENTER
          .dword dCURRENT
          .dword STORE
          EXIT
eword

; H: ( -- ) Set the search order to contain only the system wordlist.
dword     ONLY,"ONLY"
          ENTER
          .dword FORTH_WORDLIST
          ONLIT 1
          .dword SET_ORDER
          EXIT
eword

; H: ( -- ) Set the search order to contain only the current top of the order.
dword     SEAL,"SEAL"
          ENTER
          .dword CONTEXT
          .dword ONE
          .dword SET_ORDER
          EXIT
eword

; H: ( wid -- addr u ) Return the name of a wordlist, or ^address if no name.
hword     WL_NAME,"WL-NAME"
          ENTER
          .dword DUP
          .dword CELLPLUS
          .dword FETCH
          .dword QDUP
          .dword _IF
          .dword noname
          .dword NIP
          .dword rNAME
          EXIT
noname:   JUMP rNAME_noname1
          EXIT
eword

; H: ( -- ) Display the current search order and compiler wordlist.
dword     ORDER,"ORDER"
          ENTER
          SLIT "Compiling to: "
          .dword TYPE
          .dword GET_CURRENT
          .dword WL_NAME
          .dword TYPE
          .dword CR
          SLIT "Search order:"
          .dword TYPE
          .dword CR
          .dword GET_ORDER
          ONLIT 0
          .dword _QDO
          JUMP lpdone
lp:       .dword WL_NAME
          .dword TYPE
          .dword CR
          ONLIT 1
          .dword _PLOOP
          .dword lp
lpdone:   .dword UNLOOP
          EXIT
eword

; H: ( -- ) Set the compiler wordlist to the first wordlist in the search order.
dword     DEFINITIONS,"DEFINITIONS"
          ENTER
          .dword CONTEXT
          .dword SET_CURRENT
          EXIT
eword
.endif

; ( -- cell ) read literal cell from instruction stream, place it on the stack
hword     _LIT,"_LIT"
          jsr   _fetch_ip_cell
          PUSHNEXT
eword

; ( -- word ) read literal word from instruction stream, place it on the stack
hword     _WLIT,"_WLIT"
          jsr   _fetch_ip_word
          tay
          lda   #$0000
          PUSHNEXT
eword

; ( -- char ) read literal char from instruction stream, place it on the stack
hword     _CLIT,"_CLIT"
          jsr   _fetch_ip_byte
          tay
          lda   #$0000
          PUSHNEXT
eword

; ( -- c-addr u ) skip string in instruction stream, place address and len on stack
; read cell-sized <length> from instruction stream, place it on the stack
; place the address of the next cell on the stack
; skip <length> bytes in the instruction stream
hword     _SLIT,"_SLIT"
          jsr   _fetch_ip_cell
          sty   WR
          sta   WR+2
          jsr   _pushay
          ldy   IP
          lda   IP+2
          iny
          bne   :+
          inc   a
:         jsr   _pushay
          jsr   _swap
          lda   IP
          clc
          adc   WR
          sta   IP
          lda   IP+2
          adc   WR+2
          sta   IP+2
          NEXT
eword


; ( -- ) Directly compile a cell literal from IP to [HERE]
; read next cell from instruction stream, compile it into the dictionary
hword     _COMP_LIT,"_COMP_LIT"
          jsr   _fetch_ip_cell
          jsr   _ccellay
          NEXT
eword

; ( -- ) Directly compile a character literal from IP to [HERE]
; read char from instruction stream, compile it into the dictionary
hword     _COMP_CLIT,"_COMP_LIT"
          jsr   _fetch_ip_byte
          jsr   _cbytea
          NEXT
eword

; ( -- ) System initialization
hword     ddSYSINIT,"$$SYSINIT"
          ENTER
          .dword FORTH_WORDLIST   ; make sure current wordlist is the Forth wordlist
          .dword dCURRENT
          .dword STORE
          .dword HERE             ; set up minimal search order stuff
          .dword ddORDER
          .dword STORE
          ONLIT 0                 ; for # of items in order
          .dword COMMA
.if max_search_order > 0
          ONLIT max_search_order  ; now allocate the storage for the search order
          .dword CELLS
          .dword ALLOT
.endif ; max_search_order
          .dword dMEMTOP          ; set $HIMEM to $MEMTOP for dynamic allocation
          .dword FETCH
          .dword dHIMEM
          .dword STORE
          ONLIT tib_size
          .dword ALLOC            ; TODO: catch exception
          .dword dTIB
          .dword STORE
          .if include_fcode
          ONLIT SI_GET_FCODE      ; See if system wants us to evaluate FCode
          .dword dSYSIF
          .dword QDUP
          .dword _IF
          .dword no_fcode         ; apparently not
lp:       .dword PtoR
          .dword RCOPY
          .dword FETCH
          .dword QDUP
          .dword _IF
          .dword dn_fcode
          .dword ONE
          .dword BYTE_LOAD
          .dword RtoP
          .dword CELLPLUS
          JUMP lp
dn_fcode: .dword RDROP
no_fcode:
          .endif
          NLIT NOOP               ; set up STATUS defer.
          SLIT "STATUS"
          .dword dDEFER
          .dword PROTECTED        ; make sure it can't be FORGETted
          .dword CR               ; and say hello
          SLIT "OF816 by M.G."
          .dword TYPE
          .dword CR
          EXIT
eword

; ( xt base -- ) execute xt with temporary number base
hword     TMPBASE,"TMPBASE"
          ENTER
          .dword BASE
          .dword DUP
          .dword FETCH
          .dword PtoR
          .dword STORE
          .dword CATCH
          .dword RtoP
          .dword BASE
          .dword STORE
          .dword THROW
          EXIT
eword

; H: ( -- ) Display version information.
dword     DOTVERSION,".VERSION"
          ENTER
          SLIT .concat("OF816 v",VERSION,"/")
          .dword TYPE
          ONLIT .time
          ONLIT UDOT
          ONLIT 16
          .dword TMPBASE
          .if .strlen(PLATFORM) > 0
          SLIT .concat("for ", PLATFORM, ", CA65 ", .sprintf("%d.%d",.hibyte(.version),(.version & $F0)/$10))
          .else
          SLIT ", CA65"
          .endif
          .dword TYPE
          .dword CR
          .if include_fcode
          SLIT "FCode enabled"
          .dword TYPE
          .dword CR
          .endif
          EXIT
eword

; H: ( -- ) Reset the system.
dword     RESET_ALL,"RESET-ALL"
          lda   #SI_RESET_ALL
          jsl   _call_sysif
          bcc   :+
          jmp   _throway
:         NEXT
eword

; H: ( -- ) Restore system stack pointer and exit Forth.
dword     BYE,"BYE"
          lda   SYS_RSTK
          tcs
          rtl
eword

; ( n -- ) display exception message
; Display a message associated with exception # n.  It first looks to see if there
; is a MESSAGE ( n -- n|0 ) word in the current search order.  If there is, it calls it and
; if n2 is nonzero, assumes no message was displayed and proceeds, otherwise we are done.
hword     _MESSAGE,"_MESSAGE"
          ENTER
          SLIT "MESSAGE"
          .dword dFIND
          .dword _IF
          .dword notfound
          .dword CATCH
          .dword _IFFALSE
          .dword exc
          .dword QDUP
          .dword _IFFALSE
          .dword nomsg
          EXIT
notfound: .dword TWODROP
nomsg:    ONLIT -4
          .dword _IFEQUAL
          .dword :+
          SLIT "Stack u/f"
          JUMP dotype
:         ONLIT -13
          .dword _IFEQUAL
          .dword :+
          SLIT "Def not found"
          JUMP dotype
:         ONLIT -10
          .dword _IFEQUAL
          .dword :+
          SLIT "Div by 0"
          JUMP dotype
:         SLIT "Exception #"
          .dword TYPE
          .dword DOTD
          EXIT
exc:      SLIT "Exc. in MESSAGE!"
dotype:   .dword TYPE
          .dword DROP
          EXIT
eword

; H: ( xt -- xi ... xj n|0 ) Call xt, trap exception, and return it in n.
; catch return stack frame is:
; IP (4), old RSTK_SAVE (2), data SP (2, first out)
dword     CATCH,"CATCH"
          jsr   _popwr            ; remove xt for now, throw exception if none given
          inc   CATCHFLAG
          lda   IP+2              ; put catch frame on stack
          pha                     ; starting with IP
          lda   IP
          pha
          lda   RSTK_SAVE         ; old saved return stack pointer
          pha
          phx                     ; data stack pointer
          tsc
          sta   RSTK_SAVE         ; save return stack for later restoration
          ldy   WR
          lda   WR+2
          jsr   _pushay           ; push xt back on stack
          ENTER
          .dword EXECUTE          ; execute framed xt
          CODE
          ; no exception if we got here
          lda   #$0000
          sta   WR                ; exit code will be zero
          sta   WR+2
          pla                     ; drop old data SP
fixup:    pla                     ; get old RSTK_SAVE
          sta   RSTK_SAVE
          pla
          sta   IP                ; restore previous IP (after catch)
          pla
          sta   IP+2
          dec   CATCHFLAG
          ldy   WR
          lda   WR+2
          PUSHNEXT
eword

; H: ( n -- ) Throw exception n if n is nonzero.
dword     THROW,"THROW"
          jsr   _popay            ; get exception # from stack
throway:  .if trace
          wdm $90
          wdm $8f
          .endif
          cmp   #$0000            ; is it zero?
          bne   :+
          cpy   #$0000
          bne   :+
          NEXT                    ; if zero, do nothing
:         sty   WR                ; if not zero, save it
          sta   WR+2
          lda   CATCHFLAG         ; CATCH active?
          beq   uncaught          ; nope, go handle it
          lda   RSTK_SAVE         ; restore stack pointer to catch frame
          tcs
          plx                     ; restore data stack pointer
          bra   CATCH::fixup      ; "return" from CATCH
uncaught: lda   #$FFFF            ; is negative?
          cmp   WR+2
          bne   :+                ; nope, don't check for specifics
          lda   WR
          cmp   #.loword(-1)      ; ABORT
          beq   abort
          cmp   #.loword(-2)      ; ABORT"
          beq   abort
:         jsr   _stackroom        ; make room on data stack if needed
          ldy   WR
          lda   WR+2
          jsr   _pushay           ; push exception # back on stack
          ENTER                   ; short routine to display error message
          .dword SPACE
          .dword _MESSAGE
          CODE
          jmp   __doquit          ; and restart with QUIT
abort:    ldx   STK_TOP           ; empty data stack per standard for ABORT
          jmp   __doquit          ; and restart with QUIT
eword
_throway  = THROW::throway

; ( -- f ) return true if a CATCH is active
hword     CATCHQ,"CATCH?"
          ldy   CATCHFLAG
          lda   #$00
          PUSHNEXT
eword

; ( f c-addr u -- ) word compiled or executed by ABORT"
; if f is true display c-addr u and execute -2 THROW, otherwise continue execution
hword     _ABORTQ,"_ABORT'"
          ENTER
          .dword ROT
          .dword _IF
          .dword noabort
          .dword CATCHQ
          .dword _IF
          .dword dotype
          .dword TWODROP
          .dword _SKIP
dotype:   .dword TYPE
          ;.dword CLEAR
          ONLIT -2
          .dword THROW
noabort:  .dword TWODROP
          EXIT          
eword

; H: Compilation/Interpretation: ( [text<">] -- )
; H: Execution: ( f -- )
; H: If f is true, display text and execute -2 THROW.
dwordq    ABORTQ,"ABORT'",F_IMMED
          ENTER
          .dword SQ
          .dword _SMART
          .dword interp
          .dword _COMP_LIT
interp:   .dword _ABORTQ
          EXIT
eword

; H: ( -- ) Execute -1 THROW.
dword     ABORT,"ABORT"
          ENTER
          ONLIT -1
          .dword THROW
          EXIT
eword

; H: ( -- addr ) addr = address of the CPU direct page
dword     dDIRECT,"$DIRECT"
          tdc
          tay
          lda   #$00
          PUSHNEXT
eword

; H: ( -- addr ) addr = top of usable data space
dword     dMEMTOP,"$MEMTOP"
          ENTER
          .dword dDIRECT
          ONLIT MEM_TOP
          .dword PLUS
          EXIT
eword

; H: ( -- u ) u = unused data space accounting for PAD and dynamic allocations
dword     UNUSED,"UNUSED"
          ENTER
          .dword dHIMEM
          .dword FETCH
          .dword HERE
          .dword MINUS
          ONLIT 16
          .dword MINUS
          ONLIT word_buf_size
          .dword MINUS
.if pad_size > 0
          ONLIT pad_size
          .dword MINUS
.endif
          EXIT
eword

; H: ( -- ) Do nothing.
dword     NOOP,"NOOP"
          NEXT
eword

; H: ( -- u ) u = size of char in bytes.
dword     SCHAR,"/C"
          FCONSTANT 1
eword

; H: ( -- u ) u = size of word in bytes.
dword     SWORD,"/W"
          FCONSTANT 2
eword

; H: ( -- u ) u = size of long in bytes.
dword     SLONG,"/L"
          FCONSTANT 4
eword

; H: ( -- u ) u = size of cell in bytes.
dword     SCELL,"/N"
          FCONSTANT 4
eword

; H: ( u1 n -- u2 ) u2 = u1 + n * size of char in bytes.
dword     CAPLUS,"CA+"
          ENTER
          .dword SCHAR
domath:   .dword UMULT
          .dword PLUS
          EXIT
eword

; H: ( u1 n -- u2 ) u2 = u1 + n * size of word in bytes.
dword     WAPLUS,"WA+"
          ENTER
          .dword SWORD
          JUMP CAPLUS::domath
eword

; H: ( u1 n -- u2 ) u2 = u1 + n * size of long in bytes.
dword     LAPLUS,"LA+"
          ENTER
          .dword SLONG
          JUMP CAPLUS::domath
eword

; H: ( u1 n -- u2 ) u2 = u1 + n * size of cell in bytes.
dword     NAPLUS,"NA+"
          ENTER
          .dword SCELL
          JUMP CAPLUS::domath
eword

; H: ( u1 -- u2 ) u2 = u1 + size of char in bytes.
dword     CHARPLUS,"CHAR+"
          ENTER
          .dword SCHAR
          .dword PLUS
          EXIT
eword

; H: ( u1 -- u2 ) u2 = u1 + size of cell in bytes.
dword     CELLPLUS,"CELL+"
          ENTER
          .dword SCELL
          .dword PLUS
          EXIT
eword

; H: ( n1 -- n2 ) n2 = n1 * size of char.
dword     CHARS,"CHARS"
          ENTER
          .dword SCHAR
          .dword UMULT
          EXIT
eword

; H: ( n1 -- n2 ) n2 = n1 * size of cell.
dword     CELLS,"CELLS"
          ENTER
          .dword SCELL
          .dword UMULT
          EXIT
eword

; H: ( u1 -- u2 ) u2 = next aligned address after u1.
dword     ALIGNED,"ALIGNED"
          NEXT
eword

; H: ( n1 -- n2 ) n2 = n1 + size of char.
dword     CAINCR,"CA1+"
          jmp   CHARPLUS::code
eword

; H: ( n1 -- n2 ) n2 = n1 + size of word.
dword     WAINCR,"WA1+"
          ENTER
          .dword SWORD
          .dword PLUS
          EXIT          
eword

; H: ( n1 -- n2 ) n2 = n1 + size of long.
dword     LAINCR,"LA1+"
          ENTER
          .dword SLONG
          .dword PLUS
          EXIT          
eword

; H: ( n1 -- n2 ) n2 = n1 + size of cell.
dword     NAINCR,"NA1+"
          jmp   CELLPLUS::code
eword

; H: ( n1 -- n2 ) n2 = n1 * size of char.
dword     SCHARMULT,"/C*"
          jmp CHARS::code
eword

; H: ( n1 -- n2 ) n2 = n1 * size of word.
dword     SWORDMULT,"/W*"
          ENTER
          .dword SWORD
          .dword UMULT
          EXIT
eword

; H: ( n1 -- n2 ) n2 = n1 * size of long.
dword     SLONGMULT,"/L*"
          ENTER
          .dword SLONG
          .dword UMULT
          EXIT
eword

; H: ( n1 -- n2 ) n2 = n1 * size of cell.
dword     SCELLMULT,"/N*"
          jmp CELLS::code
eword

; H: ( u -- u1 ... u4 ) u1 ... u4 = bytes of u.
dword     LBSPLIT,"LBSPLIT"
          jsr   _1parm
          lda   STACKBASE+0,x
          ldy   STACKBASE+2,x
          pha
          and   #$FF
          sta   STACKBASE+0,x
          stz   STACKBASE+2,x
          pla
          xba
          and   #$FF
          jsr   _pusha
          tya
          and   #$FF
          jsr   _pusha
          tya
          xba
          and   #$FF
          tay
          lda   #$0000
          PUSHNEXT
eword

; H: ( u -- u1 ... u2 ) u1 ... u2 = words of u.
dword     LWSPLIT,"LWSPLIT"
          jsr   _1parm
          ldy   STACKBASE+2,x
          stz   STACKBASE+2,x
          lda   #$0000
          PUSHNEXT
eword

; H: ( u -- u1 .. u2 ) u1 .. u2 = bytes of word u.
dword     WBSPLIT,"WBSPLIT"
          jsr   _1parm
          stz   STACKBASE+2,x
          lda   STACKBASE+0,x
          pha
          and   #$FF
          sta   STACKBASE+0,x
          pla
          xba
          and   #$FF
          tay
          lda   #$00
          PUSHNEXT
eword

; H: ( b.l b2 b3 b.h -- q ) Join bytes into quad.
dword     BLJOIN,"BLJOIN"
          jsr   _4parm
          lda   STACKBASE+12,x
          and   #$FF
          sta   STACKBASE+12,x
          lda   STACKBASE+8,x
          and   #$FF
          xba
          ora   STACKBASE+12,x
          sta   STACKBASE+12,x
          lda   STACKBASE+4,x
          and   #$FF
          sta   STACKBASE+14,x
          lda   STACKBASE+0,x
          and   #$FF
          xba
          ora   STACKBASE+14,x
          sta   STACKBASE+14,x
_3drop:   inx
          inx
          inx
          inx
_2drop:   inx
          inx
          inx
          inx
_1drop:   inx
          inx
          inx
          inx
          NEXT
eword

; H: ( b.l b.h -- w ) Join bytes into word.
dword     BWJOIN,"BWJOIN"
          jsr   _2parm
          stz   STACKBASE+6,x
          lda   STACKBASE+4,x
          and   #$FF
          sta   STACKBASE+4,x
          lda   STACKBASE+0,x
          and   #$FF
          xba
          ora   STACKBASE+4,x
          sta   STACKBASE+4,x
          bra   BLJOIN::_1drop
eword

; H: ( w.l w.h -- q ) Join words into quad.
dword     WLJOIN,"WLJOIN"
          jsr   _2parm
          lda   STACKBASE+0,x
          sta   STACKBASE+6,x
          bra   BLJOIN::_1drop
eword

; H: ( w -- w' ) Flip the byte order of w.
dword     WBFLIP,"WBFLIP"
          jsr   _1parm
          lda   STACKBASE+0,x
          xba
          sta   STACKBASE+0,x
          lda   STACKBASE+2,x
          xba
          sta   STACKBASE+2,x
          NEXT
eword

; H: ( q -- q' ) Flip the byte order of quad.
dword     LBFLIP,"LBFLIP"
          jsr   _1parm
          ldy   STACKBASE+0,x
          lda   STACKBASE+2,x
          xba
          sta   STACKBASE+0,x
          tya
          xba
          sta   STACKBASE+2,x
          NEXT
eword

; H: ( q -- q ) Flip the word order of quad.
dword     LWFLIP,"LWFLIP"
          jsr   _1parm
          ldy   STACKBASE+0,x
          lda   STACKBASE+2,x
          sta   STACKBASE+0,x
          sty   STACKBASE+2,x
          NEXT
eword

; H: ( word -- sign-extended )
dword     WSX,"WSX"
          jsr   _1parm
          ldy   #$0000
          lda   STACKBASE+0,x
          and   #$8000
          beq   :+
          dey
:         sty   STACKBASE+2,x
          NEXT
eword

; H: ( byte -- sign-extended )
dword     BSX,"BSX"
          jsr   _1parm
          ldy   #$0000
          lda   STACKBASE+0,x
          and   #$80
          beq   :+
          dey
:         sty   STACKBASE+2,x
          tya
          and   #$FF00
          ora   STACKBASE+0,x
          sta   STACKBASE+0,x
          NEXT
eword

; ( -- addr ) variable containing address of top of data space
hword     dHIMEM,"$HIMEM"
          SYSVAR SV_HIMEM
eword

; H: ( u -- c-addr ) Allocate memory from heap.
dword     ALLOC,"ALLOC-MEM"
          jsr   _popxr            ; size into XR
          jsr   _alloc
          bcs   :+
          ldy   #.loword(-59)
          lda   #.hiword(-59)
          jmp   _throway
:         PUSHNEXT
eword

; H: ( c-addr u -- ) Release memory to heap, u is currently ignored.
dword     FREE,"FREE-MEM"
          jsr   _stackincr        ; we should really check this (len)
          jsr   _popwr
          jsr   _free
          bcs   :+
          ldy   #.loword(-60)
          lda   #.hiword(-60)
          jmp   _throway
:         NEXT
eword

; H: ( -- ) Display heap and temporary string information.
dword     DBGMEM,"DEBUG-MEM"
          ENTER
          .dword CR
          SLIT "$CSBUF:"
          .dword TYPE
          .dword dCSBUF
          .dword FETCH
          .dword UDOT
          SLIT "$SBUF0:"
          .dword TYPE
          .dword dSBUF0
          .dword FETCH
          .dword UDOT
          SLIT "$SBUF1:"
          .dword TYPE
          .dword dSBUF1
          .dword FETCH
          .dword UDOT
          .dword dHIMEM           ; ( -- $himem )
loop:     .dword CR
          .dword FETCH            ; ( $himem -- u )
          .dword DUP              ; ( u -- u1 u2 )
          .dword dMEMTOP          ; ( u1 u2 -- u1 u2 $memtop )
          .dword FETCH            ; ( u1 u2 $memtop -- u1 u2 u3 )
          .dword EQUAL            ; ( u1 u2 u3 -- u1 f )
          .dword _IFFALSE         ; ( u1 f -- u1 )
          .dword eom
          .dword DUP
          ONLIT HDR_SIZE
          .dword PLUS
          .dword UDOT             ; output address
          .dword DUP              ; ( u1 -- u1 u2 )
          .dword DUP              ; ( ... -- u1 u2 u3 )
          .dword FETCH            ; ( u1 u2 u3 -- u1 u2 u3' )
          .dword SWAP             ; ( u1 u2 u3' -- u1 u3' u2 )
          .dword MINUS            ; ( u1 u2 u3' -- u1 u4 )
          ONLIT HDR_SIZE          ; ( u1 u4 -- u1 u4 u5 )
          .dword MINUS            ; ( u1 u4 u5 -- u1 u6 )
          .dword UDOT             ; ( u1 u6 -- u1 ) output size          
          .dword DUP
          ONLIT 4
          .dword PLUS
          .dword WFETCH
          ONLIT $8000
          .dword LAND
          .dword _IF
          .dword free
          SLIT "used "
          JUMP :+
free:     SLIT "free "
:         .dword TYPE
          ONLIT '@'
          .dword EMIT
          .dword DUP
          .dword UDOT             ; write header address
          ONLIT '>'
          .dword EMIT
          .dword DUP
          .dword FETCH
          .dword UDOT
          JUMP loop
eom:      .dword UDOT
          SLIT "$MEMTOP"
          .dword TYPE
          .dword CR        
          EXIT
eword

; H: ( -- addr ) Variable, zero if interpreting, nonzero if compiling.
dword     STATE,"STATE"
          SYSVAR SV_STATE
eword

; ( -- u ) Variable containing depth of control-flow stack.
hword     dCSDEPTH,"$CSDEPTH"
          SYSVAR SV_dCSDEPTH        ; Control-flow stack depth for temporary definitions
eword

; ( -- addr ) Variable to store HERE during temporary definition creation.
hword     dSAVEHERE,"$SAVEHERE"
          SYSVAR SV_dSAVEHERE       ; saved HERE for temporary definitions
eword

; ( -- addr ) Variable pointing to memory allocated for temporary definition.
hword     dTMPDEF,"$>TMPDEF"
          SYSVAR SV_pTMPDEF         ; pointer to memory allocated for temp def
eword

; H: ( -- ) Enter interpretation state.
dword     STATEI,"[",F_IMMED|F_CONLY
          ENTER
          .dword STATE
          .dword OFF
          EXIT
eword

; H: ( -- ) Enter compilation state.
; immediacy called out in IEEE 1275-1994
dword     STATEC,"]",F_IMMED
          ENTER
          .dword STATE
          .dword ON
          EXIT
eword

; H: ( -- a-addr ) Variable containing current numeric base.
dword     BASE,"BASE"
          SYSVAR SV_BASE
eword

; H: ( ... u -- ... ) Call system interface function u.
dword     dSYSIF,"$SYSIF"
          jsr   _popay
          tya
          jsl   _call_sysif
          bcc   :+
          jmp   _throway
:         NEXT
eword

; Raw function needed by line editor
.proc     _emit
do_emit:  lda   #SI_EMIT
          jsl   _call_sysif
          bcc   :+
          jmp   _throway
:         rts
.endproc          

; H: ( char -- ) Output char.
dword     EMIT,"EMIT"
          jsr   _peekay
          tya
          and   #$FF
          cmp   #' '
          bcc   do_emit           ; don't count control chars
          ldy   #SV_NOUT
          lda   [SYSVARS],y       ; increment #OUT
          inc   a
          sta   [SYSVARS],y
          bne   do_emit
          iny
          iny
          lda   [SYSVARS],y
          inc   a
          sta   [SYSVARS],y
do_emit:  jsr   _emit
          NEXT
eword

; H: ( addr u -- ) Output string.
dword     TYPE,"TYPE"
          jsr   _popxr
          jsr   _popwr
          ldy   #.loword(do_emit-1)
          lda   #.hiword(do_emit-1)
          jsr   _str_op_ay
          NEXT
do_emit:  jsr   _pusha
          ENTER
          .dword EMIT
          CODE
          clc
          rtl
eword

; H: ( -- f ) If #LINE >= 20, prompt user to continue and return false if they want to.
dword     EXITQ,"EXIT?"
          ENTER
          .dword NLINE
          .dword FETCH
          ONLIT 20                ; TODO: replace with variable
          .dword UGTE
          .dword _IF
          .dword nopage
          ONLIT 0
          .dword NLINE
          .dword STORE
          SLIT "more? (Y/n)"
          .dword TYPE
          .dword KEY
          .dword CR
          .dword LCC
          ONLIT 'n'
          .dword EQUAL
          EXIT
nopage:   .dword FALSE
          EXIT
eword

; H: ( -- addr ) Variable containing the number of lines output.
dword     NLINE,"#LINE"
          SYSVAR SV_NLINE
eword

; H: ( -- addr ) Variable containing the number of chars output on the current line.
dword     NOUT,"#OUT"
          SYSVAR SV_NOUT
eword

; H: ( -- addr ) Variable containing offset to the current parsing area of input buffer.
dword     PIN,">IN"
          SYSVAR SV_PIN
eword

; H: ( -- addr ) Variable containing number of chars in the current input buffer.
dword     NIN,"#IN"
          SYSVAR SV_NIN
eword

; H: ( xt -- ) execute xt, regardless of its flags
dword     EXECUTE,"EXECUTE"
          jsr   _popay
          RUN
eword

; ( -- ) Read a cell from the instruction stream, set the next IP to it.
hword     _JUMP,"_JUMP"
          jsr   _fetch_ip_cell
          jsr   _decay
go:       sty   IP
          sta   IP+2
          NEXT
eword

; ( -- ) Read and discard a cell from the instruction stream.
hword     _SKIP,"_SKIP"
          jsr   _fetch_ip_cell
          NEXT
eword

; ( -- ) Read a cell from the instruction stream; if interpretation state set IP to it.
hword     _SMART,"_SMART"
          .if 1 ; native
          ldy   #SV_STATE
          lda   [SYSVARS],y
          bne   _SKIP::code
          iny
          iny
          lda   [SYSVARS],y
          bne   _SKIP::code
          beq   _JUMP::code
          .else ; mixed
          ENTER
          .dword STATE
          .dword FETCH
          CODE
          jsr   _popay
          sty   WR
          ora   WR
          beq   _JUMP::code
          bne   _SKIP::code
          .endif
eword

; ( -- ) Read and discard two cells from the instruction stream.
hword     _SKIP2,"_SKIP2"
          jsr   _fetch_ip_cell
          bra   _SKIP::code
eword

; H: ( n -- ) Compile cell n into the dictionary.
dword     COMMA,","
          jsr   _popay
          jsr   _ccellay
          NEXT
eword

; H: ( xt -- ) Compile xt into the dictionary.
; immediacy called out in IEEE 1275-1994
dword     COMPILECOMMA,"COMPILE,",F_IMMED
          bra   COMMA::code
eword

; H: ( char -- ) Compile char into dictionary.
dword     CCOMMA,"C,"
          jsr   _popay
          tya
          jsr   _cbytea
          NEXT
eword

; H: ( word -- ) Compile word into dictionary.
dword     WCOMMA,"W,"
          jsr   _popay
          tya
          jsr   _cworda
          NEXT
eword

; H: ( q -- ) Compile cell q into dictionary.
dword     LCOMMA,"L,"
          bra COMMA::code
eword

; H: Compilation: ( n -- )
; H: Execution: ( -- n )
dword     LITERAL,"LITERAL",F_IMMED
          jsr   _1parm
          .if no_fast_lits
          ldy   #.loword(_LIT)
          lda   #.hiword(_LIT)
          jsr   _ccellay          ; compile _LIT
          bra   COMMA::code       ; compile actual number
          .else
          lda   STACKBASE+2,x
          beq   COMMA::code       ; compile fast literal
          ldy   #.loword(_LIT)
          lda   #.hiword(_LIT)
          jsr   _ccellay          ; compile _LIT
          bra   COMMA::code       ; compile actual number
          .endif
eword

dword     TWOLITERAL,"2LITERAL",F_IMMED
          ENTER
do2lit:   .dword SWAP
          .dword LITERAL
          .dword LITERAL
          EXIT
eword

; do LITERAL or 2LITERAL
hword     XLITERAL,"XLITERAL"
          ENTER
          .dword TWO
          .dword EQUAL
          .dword _IFFALSE
          .dword TWOLITERAL::do2lit ; true branch
          .dword LITERAL
          EXIT
eword

; H: ( u -- u ) Align u (no-op in this implementation).
dword     ALIGN,"ALIGN"
          NEXT
eword

; H: ( n -- ) Allocate n bytes in the dictionary.
dword     ALLOT,"ALLOT"
          jsr   _popay
          pha
          tya
          clc
          adc   DHERE
          sta   DHERE
          pla
          adc   DHERE+2
          sta   DHERE+2
          NEXT
eword

; H: ( addr -- n ) Fetch n from addr.
dword     FETCH,"@"
          jsr   _popwr
fetch2:   jsr   _wrfetchind
          PUSHNEXT
eword

; H: ( addr -- n ) Fetch n from addr.
dword     LFETCH,"L@"
          bra   FETCH::code
eword

.if unaligned_words
; H: ( addr -- n ) Fetch n from addr.
dword     LFECTCHU,"UNALIGNED-L@"
          bra   LFETCH::code
eword
.endif

; H: ( addr -- n1 n2 ) Fetch two consecutive cells from addr.
dword     TWOFETCH,"2@"
          jsr   _popwr
          jsr   _wrplus4
          jsr   _wrfetchind
          jsr   _pushay
          jsr   _wrminus4
          bra   FETCH::fetch2
eword

; H: ( addr -- char ) Fetch char from addr.
dword     CFETCH,"C@"
          jsr   _popwr
          sep   #SHORT_A
          lda   [WR]
          rep   #SHORT_A
          and   #$00FF
          jsr   _pusha
          NEXT
eword

; H: ( addr -- word ) Fetch word from addr.
dword     WFETCH,"W@"
          jsr   _popwr
          lda   [WR]
          jsr   _pusha
          NEXT
eword

; H: ( addr -- n ) Fetch sign-extended word from addr.
dword     WFETCHS,"<W@"
          ENTER
          .dword WFETCH
          .dword WSX
          EXIT
eword

.if unaligned_words
; H: ( addr -- n ) Fetch word from addr.
dword     WFECTCHU,"UNALIGNED-W@"
          bra   WFETCH::code
eword
.endif

; H: ( n addr -- ) Store n at addr.
dword     STORE,"!"
          jsr   _popwr
store2:   jsr   _popay
          jsr   _wrstoreind
          NEXT
eword

; H: ( n addr -- ) Store n at addr.
dword     LSTORE,"L!"
          bra   STORE::code
eword

.if unaligned_words
; H: ( n addr -- ) Store n at addr.
dword     LSTOREU,"UNALIGNED-L!"
          bra   LSTORE::code
eword
.endif

; H: ( n1 n2 addr -- ) Store two consecutive cells at addr.
dword     TWOSTORE,"2!"
          jsr   _popwr
          jsr   _popay
          jsr   _wrstoreind
          jsr   _wrplus4
          bra   STORE::store2
eword

; H: ( char addr -- ) Store char at addr.
dword     CSTORE,"C!"
          jsr   _popwr
          jsr   _popay
          tya
          sep   #SHORT_A
          sta   [WR]
          rep   #SHORT_A
          NEXT
eword

; H: ( word addr -- ) Store word at addr.
dword     WSTORE,"W!"
          jsr   _popwr
          jsr   _popay
          tya
          sta   [WR]
          NEXT
eword

.if unaligned_words
; H: ( word addr -- ) Store word at addr.
dword     WSTOREU,"UNALIGNED-W!"
          bra   WSTORE::code
eword
.endif

; ( n1 addr -- n2 ) Swap n1 with n2 at addr.
hword     CSWAP,"CSWAP"
          ENTER
          .dword DUP
          .dword FETCH
          .dword NROT
          .dword STORE
          EXIT
eword

; H: ( n1 -- n1 n2 ) n2 = n1.
dword     DUP,"DUP"
          jsr   _peekay
          PUSHNEXT
eword

; H: ( 0 -- 0 ) | ( n1 -- n1 n2 ) n2 = n1.
dword     QDUP,"?DUP"
          jsr   _peekay
          cmp   #$00
          bne   :+
          cpy   #$00
          bne   :+
          NEXT
:         PUSHNEXT
eword

; H: ( n -- ) (R: -- n )
; must be primitive   
dword     PtoR,">R"
          jsr   _popay
          pha
          phy
          NEXT
eword

; H: ( n1 n2 -- ) (R: -- n1 n2 )
; must be primitive   
dword     TWOPtoR,"2>R"
          jsr   _swap
          jsr   _popay
          pha
          phy
          bra   PtoR::code
eword

; Common code to copy YR items from parameter stack to
; return stack.
.proc     _xNPtoR
          lda   YR
          beq   done
:         jsr   _popay
          pha
          phy
          dec   YR
          bne   :-
done:     lda   YR+2
          bpl   :+
          and   #$7FFF
          jsr   _pusha
:         NEXT
.endproc

; ( xu ... x1 u -- u ) ( R: -- x1 ... xu ) remove u items from parameter stack
; and place on return stack, used by SAVE-INPUT.
hword     XNPtoR,"XN>R"
          jsr   _popay
          sty   YR
          sty   YR+2
          lda   #$8000
          tsb   YR+2
          bra   _xNPtoR
eword

; H: ( xu ... x0 u -- ) ( R: -- x0 ... xu ) remove u+1 items from parameter stack
; H: and place on return stack.
dword     NPtoR,"N>R"
          jsr   _popay
          iny
          sty   YR
          stz   YR+2
          bra   _xNPtoR
eword

; H: ( R: x -- ) ( -- x )
; must be primitive   
dword     RtoP,"R>"
          ply
          pla
          PUSHNEXT
eword

; H: ( R: x1 x2 -- ) ( -- x1 x2 )
; must be primitive   
dword     TWORtoP,"2R>"
          ply
          pla
          jsr   _pushay
          ply
          pla
          jsr   _pushay
          jsr   _swap
          NEXT
eword

; Common code to copy YR items from return stack to
; parameter stack.
.proc     _xNRtoP
          lda   YR
          beq   done
:         ply
          pla
          jsr   _pushay
          dec   YR
          bne   :-
done:     lda   YR+2
          bpl   :+
          and   #$7FFF
          jsr   _pusha
:         NEXT
.endproc

; ( R: x1 ... xu -- ) ( u -- xu ... x1 u ) remove u items from return stack
; and place on parameter stack, used by RESTORE-INPUT.
hword     XNRtoP,"XNR>"
          jsr   _popay
          sty   YR
          sty   YR+2
          lda   #$8000
          tsb   YR+2
          bra   _xNRtoP
eword

; H: ( R: x0 ... xu -- ) ( u -- xu ... x0 ) remove u+1 items from return stack
; H: and place on parameter stack.
dword     NRtoP,"NR>"
          jsr   _popay
          iny
          sty   YR
          stz   YR+2
          bra   _xNRtoP
eword

; H: ( R: n -- n ) ( -- n )
dword     RCOPY,"R@"
          lda   1,S
          tay
          lda   3,S
          PUSHNEXT
eword

; H: ( n -- n ) ( R: -- n )
dword     COPYR,">R@"
          jsr  _peekay
          pha
          phy
          NEXT
eword

; H: ( R: n1 n2 -- n1 n2 ) ( -- n1 n2 )
dword     TWORCOPY,"2R@"
          lda   5,S
          tay
          lda   7,S
          jsr   _pushay
          bra   RCOPY::code
eword

; H: ( R: n -- )
dword     RDROP,"RDROP"
          pla
          pla
          NEXT
eword

; H: ( R: n1 -- n2 ) n2 = n1 + 1
; increment item on return stack
dword     RINCR,"R+1"
          lda   1,s
          inc   a
          sta   1,s
          bne   :+
          lda   3,s
          inc   a
          sta   3,s
:         NEXT
eword

.if 0 ; currently unused
; H: ( u -- xu ) (R: xu ... x0 -- xu ... x0 )
hword     RPICK,"RPICK"
          jsr   _popwr
          tya
          asl
          asl
          sta   WR
          tsc
          sec                       ; +1
          adc   WR
          sta   WR
          stz   WR+2
          ldy   #$02
          lda   [WR],y
          pha
          dey
          dey
          lda   [WR],y
          tay
          pla
          NEXT
eword
.endif

; ( -- n ) n = cell-extended 24-bit address
; pluck the machine return address underneath the Forth return address
; on the return stack and place it on the data stack.  Used by DOES>
hword     RPLUCKADDR,"RPLUCKADDR"
          ply                     ; save top of stack address
          sty   WR
          pla
          sta   WR+2
          sep   #SHORT_A
          .a8
          ply                     ; pull desired address
          pla
          rep   #SHORT_A
          .a16
          and   #$00FF
          jsr   _pushay
          lda   WR+2              ; put back top of stack
          pha
          ldy   WR
          phy
          NEXT
eword

; H: ( x1 x2 -- x2 x1 )
dword     SWAP,"SWAP"
          jsr   _swap
          NEXT
eword

; H: ( x -- )
dword     DROP,"DROP"
          jsr   _stackincr
          NEXT
eword

; H: ( x1 x2 x3 -- )
dword     THREEDROP,"3DROP"
          jsr   _stackincr
twodrop:  jsr   _stackincr
          jsr   _stackincr
          NEXT
eword

; H: ( x1 x2 -- )
dword     TWODROP,"2DROP"
          bra   THREEDROP::twodrop
eword

; H: ( ... -- ) Empty stack.
dword     CLEAR,"CLEAR"
          ldx   STK_TOP
          NEXT
eword

; H: ( xu ... x1 -- xu ... x1 u )
dword     DEPTH,"DEPTH"
          stx   WR
          lda   STK_TOP
          sec
          sbc   WR
          lsr
          lsr
          tay
          lda   #$0000
          PUSHNEXT
eword

; H: ( x1 x2 -- x1 x2 x2 )
dword     OVER,"OVER"
          jsr   _over
          NEXT
eword

; H: ( xu ... x1 x0 u -- xu ... x1 xu )
dword     PICK,"PICK"
          jsr   _2parm
          lda   STACKBASE+0,x
          asl
          asl
          sta   WR
          txa
          clc
          adc   WR
          phx
          tax
          ldy   STACKBASE+4,x
          lda   STACKBASE+6,x
          plx
          sty   STACKBASE+0,x
          sta   STACKBASE+2,x
          NEXT
eword

; H: ( -- ) Display stack contents.
dword     DOTS,".S"
          ENTER
          ONLIT '{'
          .dword EMIT
          .dword SPACE
          .dword DEPTH
          .dword DUP
          .dword DOT
          ONLIT ':'
          .dword EMIT
          .dword SPACE
          .dword DUP
          .dword _IF
          .dword done
lp:       .dword DECR
          .dword DUP
          .dword PtoR
          .dword PICK
          .dword DOT
          .dword RtoP
          .dword DUP
          .dword _IFFALSE
          .dword lp
done:     .dword DROP
          ONLIT '}'
          .dword EMIT
          EXIT
eword

; H: ( x1 x2 -- x2 )
dword     NIP,"NIP"
          jsr   _2parm
          lda   STACKBASE+0,x
          sta   STACKBASE+4,x
          lda   STACKBASE+2,x
          sta   STACKBASE+6,x
          inx
          inx
          inx
          inx
          NEXT
eword

; H: ( x1 x2 -- x2 x1 x2 )
dword     TUCK,"TUCK"
          ENTER
          .dword SWAP
          .dword OVER
          EXIT
eword

; H: ( x1 x2 x3 -- x3 )
hword     NIPTWO,"NIP2"
          ENTER
          .dword PtoR
          .dword TWODROP
          .dword RtoP
          EXIT
eword

; H: ( x1 x2 -- x1 x2 x1 x2 )
dword     TWODUP,"2DUP"
          jsr   _over
          jsr   _over
          NEXT
eword

; H: ( x1 x2 x3 -- x1 x2 x3 x1 x2 x3 )
dword     THREEDUP,"3DUP"
          ENTER
          ONLIT 2
          .dword PICK
          ONLIT 2
          .dword PICK
          ONLIT 2
          .dword PICK
          EXIT
eword

.proc     _rot
          ldy   STACKBASE+10,x
          lda   STACKBASE+6,x
          sta   STACKBASE+10,x
          lda   STACKBASE+2,x
          sta   STACKBASE+6,x
          sty   STACKBASE+2,x
          ldy   STACKBASE+8,x
          lda   STACKBASE+4,x
          sta   STACKBASE+8,x
          lda   STACKBASE+0,x
          sta   STACKBASE+4,x
          sty   STACKBASE+0,x
          rts
.endproc

; H: ( x1 x2 x3 -- x2 x3 x1 )
dword     ROT,"ROT"
          .if 1 ; native
          jsr   _3parm
          jsr   _rot
          NEXT
          .else ; secondary
          ENTER
          .dword PtoR
          .dword SWAP
          .dword RtoP
          .dword SWAP
          EXIT
          .endif
eword

; H: ( x1 x2 x3 -- x3 x1 x2 )
dword     NROT,"-ROT"
          .if 1 ; native
          jsr   _3parm
          ldy   STACKBASE+2,x
          lda   STACKBASE+6,x
          sta   STACKBASE+2,x
          lda   STACKBASE+10,x
          sta   STACKBASE+6,x
          sty   STACKBASE+10,x
          ldy   STACKBASE+0,x
          lda   STACKBASE+4,x
          sta   STACKBASE+0,x
          lda   STACKBASE+8,x
          sta   STACKBASE+4,x
          sty   STACKBASE+8,x
          NEXT
          .else ; secondary
          ENTER
          .dword ROT
          .dword ROT
          EXIT
          .endif
eword

; H: ( xu ... x0 u -- xu-1 .. x0 xu )
dword     ROLL,"ROLL"
          jsr   _popxr            ; put roll depth into XR
          lda   XR                ; number of items - 1 that we are moving
          beq   done              ; if none, GTFO
          asl                     ; to see if enough room on stack
          asl
          sta   XR+2              ; number of cells we are moving
          txa
          adc   XR+2
          cmp   STK_TOP
          bcc   :+
          jmp   _stku_err
:         stx   WR                ; save SP
          tax                     ; change SP to xu
          lda   STACKBASE+2,x     ; save xu
          pha
          lda   STACKBASE+0,x
          pha
lp:       dex                     ; move to next-toward-top entry
          dex
          dex
          dex
          lda   STACKBASE+2,x     ; copy this entry to the one below
          sta   STACKBASE+6,x
          lda   STACKBASE+0,x
          sta   STACKBASE+4,x
          cpx   WR                ; are we done?
          beq   :+
          bcs   lp
:         pla                     ; finally put xu on top
          sta   STACKBASE+0,x
          pla
          sta   STACKBASE+2,x
done:     NEXT
eword

; H: ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
dword     TWOSWAP,"2SWAP"
          ENTER
          .dword PtoR
          .dword NROT
          .dword RtoP
          .dword NROT
          EXIT
eword

; H: ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
dword     TWOOVER,"2OVER"
          ENTER
          .dword TWOPtoR
          .dword TWODUP
          .dword TWORtoP
          .dword TWOSWAP
          EXIT
eword

; H: ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
dword     TWOROT,"2ROT"
          ENTER
          .dword TWOPtoR
          .dword TWOSWAP
          .dword TWORtoP
          .dword TWOSWAP
          EXIT
eword

; H: ( addr -- ) Store all zero bits in cell at addr.
dword     OFF,"OFF"
          jsr   _popwr
          lda   #$0000
onoff:    tay
          jsr   _wrstoreind
          NEXT
eword

; H: ( addr -- ) Store all one bits to cell at addr.
dword     ON,"ON"
          jsr   _popwr
          lda   #$FFFF
          bra   OFF::onoff
eword

; H: ( -- false ) false = all zero bits
dword     FALSE,"FALSE"
          lda   #$0000
          tay
          PUSHNEXT
eword

; H: ( -- true ) true = all one bits
dword     TRUE,"TRUE"
          lda   #$FFFF
          tay
          PUSHNEXT
eword

; small assembly routine common to zero comparisons
.proc     _zcmpcom
          jsr   _1parm
          ldy   #$0000
          lda   STACKBASE+2,x
          rts
.endproc

; H: ( x -- f ) f = true if x is zero, false if not.
dword     ZEROQ,"0="
          jsr   _zcmpcom
          ora   STACKBASE+0,x
          bne   :+
          dey
st:       jmp   _cmpstore
eword
_cmpstore2 = ZEROQ::st

; H: ( x -- f ) f = false if x is zero, true if not.
dword     ZERONEQ,"0<>"
          jsr   _zcmpcom
          ora   STACKBASE+0,x
          beq   _cmpstore2
          dey
:         bra   _cmpstore2
eword

; H: ( n -- f ) f = true if n > 0, false if not.
dword     ZEROGT,"0>"
          jsr   _zcmpcom
          bmi   _cmpstore2
          ora   STACKBASE+0,x
          beq   _cmpstore2
          dey
          bra   _cmpstore2
eword

; H: ( n -- f ) f = true if n >= 0, false if not.
dword     ZEROGTE,"0>="
          jsr   _zcmpcom
          bmi   _cmpstore2
          dey
          bra   _cmpstore2
eword

; H: ( n -- f ) f = true if n < 0, false if not.
dword     ZEROLT,"0<"
          jsr   _zcmpcom
          bpl   _cmpstore
          dey
          bra   _cmpstore
eword

; H: ( n -- f ) f = true if n <= 0, false if not.
dword     ZEROLTE,"0<="
          jsr   _zcmpcom
          bmi   :+
          ora   STACKBASE+0,x
          bne   _cmpstore
:         dey
          bra   _cmpstore
eword

; H: ( x1 x2 -- f ) f = true if x1 = x2, false if not.
dword     EQUAL,"="
          jsr   _ucmpcom
          bne   _2cmpstore
          dey
          bra   _2cmpstore
eword

; H: ( x1 x2 -- f ) f = true if x1 <> x2, false if not.
dword     NOTEQUAL,"<>"
          jsr   _ucmpcom
          beq   _2cmpstore
          dey
          bra   _2cmpstore
eword

; H: ( u1 u2 -- f ) f = true if u1 < u2, false if not.
dword     ULT,"U<"
          jsr   _ucmpcom
          bcs   _2cmpstore
          dey
          bra   _2cmpstore
eword

; H: ( u1 u2 -- f ) f = true if u1 <= u2, false if not.
dword     ULTE,"U<="
          jsr   _ucmpcom
          beq   :+
          bcs   _2cmpstore
:         dey
          bra   _2cmpstore
eword

; more comparison helper routines
.proc     _2cmpstore
          inx
          inx
          inx
          inx
          ; fall-through
.endproc

.proc     _cmpstore
          sty   STACKBASE+0,x
          sty   STACKBASE+2,x
          NEXT
.endproc   

; H: ( u1 u2 -- f ) f = true if u1 > u2, false if not.
dword     UGT,"U>"
          jsr   _ucmpcom
          beq   _2cmpstore
          bcc   _2cmpstore
          dey
          bra   _2cmpstore
eword

; H: ( u1 u2 -- f ) f = true if u1 >= u2, false if not.
dword     UGTE,"U>="
          jsr   _ucmpcom
          bcc   _2cmpstore
          dey
          bra   _2cmpstore
eword

; H: ( n1 n2 -- f ) f = true if n1 < n2, false if not.
dword     SLT,"<"
          jsr   _scmpcom
          bcs   _2cmpstore
          dey
          bra   _2cmpstore
eword

; H: ( n1 n2 -- f ) f = true if n1 <= n2, false if not.
dword     SLTE,"<="
          jsr   _scmpcom
          beq   :+
          bcs   _2cmpstore
:         dey
          bra   _2cmpstore
eword

; H: ( n1 n2 -- f ) f = true if n1 > n2, false if not.
dword     SGT,">"
          jsr   _scmpcom
          beq   _2cmpstore
          bcc   _2cmpstore
          dey
          bra   _2cmpstore
eword

; H: ( n1 n2 -- f ) f = true if n1 >= n2, false if not.
dword     SGTE,">="
          jsr   _scmpcom
          beq   :+
          bcc   _2cmpstore
:         dey
          bra   _2cmpstore
eword

; H: ( n1 n2 -- n1|n2 ) Return the greater of n1 or n2.
dword     MAX,"MAX"
          jsr   _scmpcom
          bcs   drop
swap:     jsr   _swap
drop:     inx
          inx
          inx
          inx
          NEXT
eword

; H: ( n1 n2 -- n1|n2 ) Return the smaller of n1 or n2.
dword     MIN,"MIN"
          jsr   _scmpcom
          bcc   MAX::drop
          bra   MAX::swap
eword

; common routine for unsigned comparisons
.proc     _ucmpcom
          jsr   _2parm
          ldy   #$0000
          lda   STACKBASE+6,x
          cmp   STACKBASE+2,x
          bne   :+
          lda   STACKBASE+4,x
          cmp   STACKBASE+0,x
:         rts
.endproc

; common routine for signed comparisons
.proc     _scmpcom
          jsr   _2parm
          ldy   #$0000
          jmp   _stest32
.endproc

; ( addr -- ) Set dictionary pointer to addr.
hword     toHERE,"->HERE"
          jsr   _popay
          sty   DHERE
          sta   DHERE+2
          NEXT
eword

; H: ( -- addr ) Return dictionary pointer.
dword     HERE,"HERE"
          ldy   DHERE
          lda   DHERE+2
          PUSHNEXT
eword

; H: ( -- addr ) Return address of last definition in current vocabulary.
; non-standard
dword     LAST,"LAST"
          ENTER
          .dword GET_CURRENT
          .dword FETCH
          EXIT
eword

hword     dCURDEF,"$CURDEF"
          SYSVAR SV_dCURDEF
eword

; ( -- c-addr ) return address of $OLDHERE system variable
hword     dOLDHERE,"$OLDHERE"
          SYSVAR SV_OLDHERE
eword

; ( -- c-addr ) return HERE address prior to starting current definition
; used by PATCH to forget partial definiton when uncaught exception occurs
hword     OLDHERE,"OLDHERE"
          ENTER
          .dword dOLDHERE
          .dword FETCH
          EXIT
eword

; H: ( -- ) Exit this word, to the caller.
dword     DEXIT,"EXIT",F_CONLY
          jmp   _exit_next
eword

; ( n -- ) read cell from instruction stream, discard if n is true, set IP if false
; word compiled by IF   
hword     _IF,"_IF"
          jsr   _popay
          ora   #$0000
          bne   :+
          tya
          bne   :+
          jmp   _JUMP::code
  :       jmp   _SKIP::code        
eword

; ( n -- ) read cell from instruction stream, discard if n is false, set IP if true
hword     _IFFALSE,"_IFFALSE"
          jsr   _popay
          ora   #$0000
          bne   :+
          tya
          bne   :+
          jmp   _SKIP::code
:         jmp   _JUMP::code        
eword

; ( x1 x2 -- x1 ) read cell from instruction stream, discard if x1 = x2, set IP if false
; saves some space in hand-coded routines that need CASE-like construction such as
; _MESSAGE
hword     _IFEQUAL,"_IFEQUAL"
          jsr   _popay
          cmp   STACKBASE+2,x
          bne   :+
          tya
          cmp   STACKBASE+0,x
          bne   :+
          jmp   _SKIP::code
:         jmp   _JUMP::code
eword

; ( -- ) throw exception -22, control structure mismatch
; used for unresolved forward references
hword     _CONTROL_MM,"_CONTROL_MM"
          ldy   #.loword(-22)
          lda   #.hiword(-22)
          jmp   _throway
eword

; H: Compilation: ( -- orig )
; H: Execution: ( -- ) Jump ahead as to the resolution of orig.
dword     AHEAD,"AHEAD",F_IMMED|F_CONLY|F_TEMPD
          ENTER
          .dword _COMP_LIT
          .dword _JUMP
          .dword HERE
          .dword _COMP_LIT
          .dword _CONTROL_MM
          EXIT
eword

; H: Compilation: ( -- if-sys )
; H: Execution: ( n -- ) Begin IF ... ELSE ... ENDIF.
dword     IF,"IF",F_IMMED|F_CONLY|F_TEMPD
          ENTER
          .dword _COMP_LIT
          .dword _IF                ; compile _IF
          .dword HERE               ; save to resolve later
          .dword _COMP_LIT
          .dword _CONTROL_MM        ; compile unresolved
          EXIT
eword

; H: Compilation: ( if-sys -- else-sys )
; H: Execution: ( -- ) ELSE clause of IF ... ELSE ... THEN.
dword     ELSE,"ELSE",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT
          .dword _JUMP
          .dword HERE               ; to be resolved later
          .dword _COMP_LIT
          .dword _CONTROL_MM
          .dword SWAP               ; put IF's unresolved address in place
          .dword HERE               ; IF's false branch goes here
          .dword SWAP
          .dword STORE              ; resolve IF
          EXIT
eword

; H: Compilation: ( if-sys|else-sys -- )
; H: Execution: ( -- ) Conclustion of IF ... ELSE ... THEN.
dword     THEN,"THEN",F_IMMED|F_CONLY
          ENTER
          .dword HERE               ; IF or ELSE branch goes here
          .dword SWAP
          .dword STORE              ; resolve IF or ELSE
          .dword dTEMPSEMIQ         ; see if we need to end a temporary def
          EXIT
eword

; H: ( n1 n2 -- n1+n2 n1 )
dword     BOUNDS,"BOUNDS"
          jsr   _swap
          lda   STACKBASE+0,x
          clc
          adc   STACKBASE+4,x
          sta   STACKBASE+4,x
          lda   STACKBASE+2,x
          adc   STACKBASE+6,x
          sta   STACKBASE+6,x
          NEXT
eword

; H: Compilation: ( -- dest )
; H: Execution: ( -- ) start a BEGIN loop
; BEGIN is basically an immediate HERE   
dword     BEGIN,"BEGIN",F_IMMED|F_CONLY|F_TEMPD
          jmp   HERE::code        ; dest on stack
eword

; H: Compilation: ( dest -- orig dest )
; H: Execution: ( x -- ) WHILE clause of BEGIN...WHILE...REPEAT loop
dword     WHILE,"WHILE",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT
          .dword _IF
          .dword HERE             ; ( dest -- dest orig )
          .dword SWAP             ; ( dest orig -- orig dest )
          .dword _COMP_LIT
          .dword _CONTROL_MM
          EXIT
eword

; H: Compilation: ( dest -- )
; H: Execution: ( x -- ) UNTIL clause of BEGIN...UNTIL loop
dword     UNTIL,"UNTIL",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT
          .dword _IF
          .dword COMMA
          .dword dTEMPSEMIQ       ; see if we need to end a temporary def
          EXIT
eword

; H: Compilation: ( orig dest -- ) Resolve orig and dest.
; H: Execution: ( -- ) Repeat BEGIN loop.
dword     REPEAT,"REPEAT",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT
          .dword _JUMP
          .dword COMMA
          .dword HERE
          .dword SWAP
          .dword STORE
          .dword dTEMPSEMIQ       ; see if we need to end a temporary def
          EXIT
eword

; H: Compilation: ( dest -- )  Resolve dest.
; H: Execution: ( -- ) Jump to BEGIN.
dword     AGAIN,"AGAIN",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT
          .dword _JUMP
          .dword COMMA
          .dword dTEMPSEMIQ       ; see if we need to end a temporary def
          EXIT
eword

; H: ( n1|u1 n2|u2 n3|u3 -- f ) f =  true if n2|u2 <= n1|u1 < n3|u3, false otherwise
dword     WITHIN,"WITHIN"
          ENTER
          .dword OVER             ; ( n1 n2 n3  -- n1 n2 n3 n2' )
          .dword MINUS            ; ( n1 n2 n3 n2' -- n1 n2 n4 )
          .dword PtoR             ; ( n1 n2 n4 -- n1 n2 ) ( R: -- n4 )
          .dword MINUS            ; ( n1 n2 -- n5 )
          .dword RtoP             ; ( n5 -- n5 n4 )
          .dword ULT              ; ( n5 n4 -- f )
          EXIT
eword

; H: ( n1 n2 n3 -- f ) f =  true if n2<=n1<=n3, false otherwise
; this implementation fails when N3 is max-int and should be
; replaced with something better at some point
dword     BETWEEN,"BETWEEN"
          ENTER
          .dword INCR
          .dword WITHIN
          EXIT
eword

; ( limit start -- ) ( R: -- loop-sys )
; Run-time semantics for DO
; loop-sys = ( -- leave-IP index limit )
hword     _DO,"_DO"
          jsr   _2parm
          lda   IP+2              ; put IP on stack for LEAVE target
          pha
          lda   IP
          pha
          jsr   _popay            ; index
          pha
          phy
          jsr   _popay            ; limit
          pha
          phy
          jmp   _SKIP2::code      ; skip LEAVE target (usually a _JUMP)
eword

; ( limit start -- ) ( R: -- loop-sys )
; Run-time semantics for ?DO
hword     _QDO,"_QDO"
          jsr   _2parm
          lda   IP+2              ; put IP on stack for LEAVE target
          pha
          lda   IP
          pha
          jsr   _popay            ; index
          pha
          phy
          jsr   _popay            ; limit
          pha
          phy
          lda   1,s
          cmp   5,s
          bne   doloop
          lda   3,s
          cmp   7,s
          bne   doloop
          NEXT                    ; leave immediately
doloop:   jmp   _SKIP2::code      ; enter loop
eword

; H: Compilation: ( -- do-sys )
; H: Execution: ( limit start -- ) Start DO loop.
dword     DO,"DO",F_IMMED|F_CONLY|F_TEMPD
          ENTER
          .dword _COMP_LIT
          .dword _DO              ; compile execution semantics
qdo:      .dword HERE             ; do-sys
          .dword _COMP_LIT
          .dword _JUMP            ; LEAVE resumes execution here
          .dword _COMP_LIT
          .dword _CONTROL_MM      ; LOOP/+LOOP will jump to do-sys+4, after this cell
          EXIT
eword

; H: Compilation: ( -- do-sys )
; H: Execution: ( limit start -- ) Start DO loop, skip if limit=start.
dword     QDO,"?DO",F_IMMED|F_CONLY|F_TEMPD
          ENTER
          .dword  _COMP_LIT
          .dword  _QDO
          JUMP    DO::qdo
eword

; H: ( -- ) ( R: loop-sys -- ) Remove loop parameters from return stack.
dword     UNLOOP,"UNLOOP",F_CONLY
          pla                     ; drop limit
          pla
          pla                     ; drop index
          pla
          pla                     ; drop leave-IP
          pla
          NEXT
eword

; run-time semantics for +LOOP
; With ( i -- ) and ( R: index(5,7) limit(1,3) -- index' limit )
; if new index in termination range, exit va _SKIP, otherwise via _JUMP
; stack-relative addressing is very helpful here
; WR will contain the limit, XR will contain the limit plus the loop increment
; We then see if the loop index is between them and if so we terminate the loop
hword     _PLOOP,"_+LOOP"
          jsr   _1parm
          lda   5,s               ; Compute new index low byte
          clc
          adc   STACKBASE+0,x     ; increment low byte
          sta   5,s               ; write it back
          lda   7,s               ; new index high byte
          adc   STACKBASE+2,x     ; increment high byte
          sta   7,s               ; write it back
          jsr   _stackdecr        ; make some room on stack
          jsr   _stackdecr
          lda   1,s               ; compute termination bounds
          sta   STACKBASE+4,x
          clc
          adc   STACKBASE+8,x
          sta   STACKBASE+0,x
          lda   3,s
          sta   STACKBASE+6,x
          adc   STACKBASE+10,x
          sta   STACKBASE+2,x
          lda   5,s               ; finally, write new index into third stack entry
          sta   STACKBASE+8,x
          lda   7,s
          sta   STACKBASE+10,x
          ENTER
          .dword TWODUP
          .dword MAX
          .dword PtoR
          .dword MIN
          .dword RtoP
          .dword WITHIN
          CODE
          lda   STACKBASE+0,x
          ora   STACKBASE+2,x
          php
          inx
          inx
          inx
          inx
          plp
          beq   :+
          jmp   _SKIP::code
:         jmp   _JUMP::code
eword

; H: Compilation: ( do-sys -- )
; H: Execution: ( u|n -- ) Add u|n to loop index and continue loop if within bounds.
dword     PLOOP,"+LOOP",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT        ; compile execution semantics
          .dword _PLOOP
          .dword DUP              ; ( loop-sys -- loop-sys loop-sys' )
          ONLIT 8                 ; two cells
          .dword PLUS             ; ( loop-sys loop-sys' -- loop-sys loop-sys'' ) get target of loop jump
          .dword COMMA            ; ( loop-sys loop-sys'' -- loop-sys ) and compile as target of _PLOOP
          .dword HERE             ; ( loop-sys -- loop-sys t )
          .dword SWAP             ; ( loop-sys t -- t loop-sys )
          .dword _COMP_LIT        ; compile in an UNLOOP
          .dword UNLOOP
          ONLIT 4                 ; one cell
          .dword PLUS             ; get address to resolve
          .dword STORE            ; and resolve all the leaves
          .dword dTEMPSEMIQ       ; see if we need to end a temporary def
          EXIT
eword

; H: Compilation: ( do-sys -- )
; H: Execution: ( -- ) Add 1 to loop index and continue loop if within bounds.
dword     LOOP,"LOOP",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT
          .dword ONE
          .dword PLOOP
          EXIT
eword

; H: ( -- ) Exit DO loop.
dword     LEAVE,"LEAVE",F_CONLY
          lda   9,s
          tay
          lda   11,s
          jmp   _JUMP::go
eword

; H: ( f -- ) Exit do loop if f is nonzero.
dword     QLEAVE,"?LEAVE",F_CONLY
          jsr   _popay
          ora   #$0000
          bne   LEAVE::code
          tya
          bne   LEAVE::code
          NEXT
eword

; H: ( -- n ) Copy inner loop index to stack.
dword     IX,"I",F_CONLY
          lda   5,s
          tay
          lda   7,s
          PUSHNEXT
eword

; H: ( -- n ) Copy second-inner loop index to stack.
dword     JX,"J",F_CONLY
          lda   17,s
          tay
          lda   19,s
          PUSHNEXT
eword

.if 0
; H: ( -- n ) Copy third-inner loop index to stack.
dword     KX,"K",F_CONLY ; noindex
          lda   29,s
          tay
          lda   31,s
          PUSHNEXT
eword
.endif

; H: Compilation: ( -- case-sys ) start a CASE...ENDCASE structure
; H: Execution: ( -- )
dword     CASE,"CASE",F_IMMED|F_CONLY|F_TEMPD
          ENTER
          .dword _COMP_LIT
          .dword _SKIP2           ; compile execution semantics
          .dword HERE             ; case-sys
          .dword _COMP_LIT
          .dword _JUMP            ; ENDOF resumes execution here 
          .dword _COMP_LIT        ; compile unresolved
          .dword _CONTROL_MM
          EXIT
eword

; ( n1 n2 -- n1 ) run-time semantics of OF
; test against CASE value, SKIP if match
; otherwise JUMP (to cell after ENDOF)
hword     _OF,"_OF"
          jsr   _2parm
          lda   STACKBASE+4,x
          cmp   STACKBASE+0,x
          bne   nomatch
          lda   STACKBASE+6,x
          cmp   STACKBASE+2,x
          bne   nomatch
          jsr   _stackincr        ; drop test value
          jsr   _stackincr        ; and value being tested
          jmp   _SKIP::code       ; and skip jump target
nomatch:  jsr   _stackincr        ; drop test value
          jmp   _JUMP::code       ; go to jump target
eword

; H: Compilation: ( case-sys -- case-sys of-sys ) Begin an OF...ENDOF structure.
; H: Execution: ( x1 x2 -- | x1 ) Execute OF clause if x1 = x2, leave x1 on stack if not.
dword     OF,"OF",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT
          .dword _OF
          .dword HERE             ; of-sys
          .dword _COMP_LIT        ; compile unresolved
          .dword _CONTROL_MM
          EXIT
eword

; H: Compilation; ( case-sys of-sys -- case-sys ) Conclude an OF...ENDOF structure.
; H: Execution: Continue execution at ENDCASE of case-sys.
dword     ENDOF,"ENDOF",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT        ; compile a jump
          .dword _JUMP
          .dword OVER             ; copy case-sys
          .dword COMPILECOMMA     ; which is the jump target
          .dword HERE             ; unmatched OF jumps here
          .dword SWAP
          .dword STORE            ; resolve of-sys
          EXIT
eword

; H: Compilation: ( case-sys -- ) Conclude a CASE...ENDCASE structure.
; H: Execution: ( | n -- ) Continue execution, dropping n if no OF matched.
dword     ENDCASE,"ENDCASE",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT        ; compile drop value under test
          .dword DROP
          .dword HERE             ; case-sys jump goes here
          .dword SWAP
          .dword CELLPLUS
          .dword STORE            ; resolve case-sys
          .dword dTEMPSEMIQ       ; see if we need to end a temporary def
          EXIT
eword

; H: ( -- ) Store 16 to BASE.
dword     HEX,"HEX"
          ENTER
          ONLIT  16
          .dword BASE
          .dword STORE
          EXIT
eword

; H: ( -- ) Store 10 to BASE.
dword     DECIMAL,"DECIMAL"
          ENTER
          ONLIT  10
          .dword BASE
          .dword STORE
          EXIT
eword

; H: ( -- ) Store 2 to BASE.
dword     BINARY,"BINARY"
          ENTER
          ONLIT  2
          .dword BASE
          .dword STORE
          EXIT
eword

; H: ( -- ) Store 8 to BASE.
dword     OCTAL,"OCTAL"
          ENTER
          ONLIT  8
          .dword BASE
          .dword STORE
          EXIT
eword

; H: ( x1 -- x2 ) x2 = x1 + 1
dword     INCR,"1+"
          jsr   _1parm
doinc:    inc   STACKBASE+0,x
          bne   :+
          inc   STACKBASE+2,x
:         NEXT
eword

; H: ( x1 -- x2 ) x2 = x1 - 1
dword     DECR,"1-"
          jsr   _1parm
          lda   STACKBASE+0,x
          bne   :+
          dec   STACKBASE+2,x
:         dec   STACKBASE+0,x
          NEXT
eword

; H: ( x1 -- x2 ) x2 = x1 + 2
dword     TWOINCR,"2+"
          jsr   _1parm
          lda   STACKBASE+0,x
          clc
          adc   #$02
          sta   STACKBASE+0,x
          bcc   :+
          inc   STACKBASE+2,x
:         NEXT
eword

; H: ( x1 -- x2 ) x2 = x1 - 2
dword     TWODECR,"2-"
          jsr   _1parm
          lda   STACKBASE+0,x
          sec
          sbc   #$02
          sta   STACKBASE+0,x
          bcs   :+
          dec   STACKBASE+2,x
:         NEXT
eword

; H: ( x1 -- x2 ) Invert the bits in x1.
dword     INVERT,"INVERT"
          jsr   _1parm
          jsr   _invert
          NEXT
eword

; H: ( x1 -- x2 ) Invert the bits in x1.
dword     NOT,"NOT"
          bra   INVERT::code
eword

; H: ( n1 -- n2 ) Negate n1.
dword     NEGATE,"NEGATE"
          jsr   _1parm
          jsr   _negate
          NEXT
eword

; H: ( n1 f -- n1|n2 ) If f < 0, then negate n.
; non-standard   
hword     QNEGATE,"?NEGATE"
          jsr   _popay
          and   #$8000
          bne   NEGATE::code
          NEXT
eword

; H: ( n1 -- n2 ) Take the absolute value of n1.
; we don't check parms on stack here because
; NEGATE will error if empty
dword     ABS,"ABS"
          lda   STACKBASE+2,x
          bpl   :+
          jsr   _negate
:         NEXT
eword

; H: ( d1 -- d2 ) Negate d1.
dword     DNEGATE,"DNEGATE"
          jsr   _2parm
          jsr   _dnegate
          NEXT                    ; push high cell
eword

; H: ( d1 -- d1|d2 ) Take the absolute value of d1.
dword     DABS,"DABS"
          lda   STACKBASE+2,x
          bpl   :+
          jsr   _dnegate
:         NEXT
eword

; H: ( x1 x2 -- x3 ) x3 = x1 + x2
dword     PLUS,"+"
          jsr   _2parm
          lda   STACKBASE+4,x
          clc
          adc   STACKBASE+0,x
          sta   STACKBASE+4,x
          lda   STACKBASE+6,x
          adc   STACKBASE+2,x
          sta   STACKBASE+6,x
stkinc:   inx
          inx
          inx
          inx
          NEXT
eword

; H: ( x1 x2 -- x3 ) x3 = x1 - x2
dword     MINUS,"-"
          jsr   _2parm
          lda   STACKBASE+4,x
          sec
          sbc   STACKBASE+0,x
          sta   STACKBASE+4,x
          lda   STACKBASE+6,x
          sbc   STACKBASE+2,x
          sta   STACKBASE+6,x
          bra   PLUS::stkinc
eword

; H: ( u1 u2 -- u3 ) u3 = u1 & u2
dword     LAND,"AND"
          jsr   _2parm
          lda   STACKBASE+4,x
          and   STACKBASE+0,x
          sta   STACKBASE+4,x
          lda   STACKBASE+6,x
          and   STACKBASE+2,x
          sta   STACKBASE+6,x
          bra   PLUS::stkinc
eword

; H: ( u1 u2 -- u3 ) u3 = u1 | u2
dword     LOR,"OR"
          jsr   _2parm
          lda   STACKBASE+4,x
          ora   STACKBASE+0,x
          sta   STACKBASE+4,x
          lda   STACKBASE+6,x
          ora   STACKBASE+2,x
          sta   STACKBASE+6,x
          bra   PLUS::stkinc
eword

; H: ( u1 u2 -- u3 ) u3 = u1 ^ u2
dword     LXOR,"XOR"
          jsr   _2parm
          lda   STACKBASE+4,x
          eor   STACKBASE+0,x
          sta   STACKBASE+4,x
          lda   STACKBASE+6,x
          eor   STACKBASE+2,x
          sta   STACKBASE+6,x
          bra   PLUS::stkinc
eword

; H: ( u1 u2 -- u3 ) u3 = u1 << u2
dword     LSHIFT,"LSHIFT"
          jsr   _2parm
          jsr   _popxr
          ldy   #.loword(shift-1)
          lda   #.hiword(shift-1)
          jsr   _iter_ay
          NEXT
shift:    asl   STACKBASE+0,x
          rol   STACKBASE+2,x
          clc
          rtl
eword

; H: ( u1 u2 -- u3 ) u3 = u1 >> u2
dword     RSHIFT,"RSHIFT"
          jsr   _2parm
          jsr   _popxr
          ldy   #.loword(shift-1)
          lda   #.hiword(shift-1)
          jsr   _iter_ay
          NEXT
shift:    lsr   STACKBASE+2,x
          ror   STACKBASE+0,x
          clc
          rtl
eword

; H: ( u1 u2 -- u3 ) u3 = u1 << u2
dword     LSHIFTX,"<<"
          bra   LSHIFT::code
eword

; H: ( u1 u2 -- u3 ) u3 = u1 >> u2
dword     RSHIFTX,">>"
          bra   RSHIFT::code
eword

; H: ( x1 x2 -- x3 ) x3 = x1 >> x2, extending sign bit.
dword     ARSHIFT,">>A"
          jsr   _2parm
          jsr   _popxr
          ldy   #.loword(shift-1)
          lda   #.hiword(shift-1)
          jsr   _iter_ay
          NEXT
shift:    lda   STACKBASE+2,x
          cmp   #$8000
          ror   STACKBASE+2,x
          ror   STACKBASE+0,x
          clc
          rtl
eword        

; H: ( u1 -- u2 ) Shift n1 one bit left.
dword     TWOMULT,"2*"
          jsr   _1parm
          jsl   LSHIFT::shift
          NEXT
eword

; H: ( u1 -- u2 ) Shift n1 one bit right.
dword     UTWODIV,"U2/"
          jsr   _1parm
          jsl   RSHIFT::shift
          NEXT
eword

; H: ( x1 -- x2 ) Shift x1 one bit right, extending sign bit.
dword     TWODIV,"2/"
          jsr   _1parm
          jsl   ARSHIFT::shift
          NEXT
eword

; H: ( n addr -- ) Add n to value at addr.
dword     PSTORE,"+!"
          ENTER
          .dword DUP
          .dword FETCH
          .dword ROT
          .dword PLUS
          .dword SWAP
          .dword STORE
          EXIT
eword

; H: ( d -- n ) Convert double-number to number.
dword     DtoS,"D>S"
          jmp   DROP::code
eword

; H: ( n -- d ) Convert number to double-number.
dword     StoD,"S>D"
          jsr   _1parm
          lda   STACKBASE+2,x
          and   #$8000
          bpl   :+
          lda   #$FFFF
:         tay
          PUSHNEXT
eword

; H: ( n1 n2 -- d1 d2 ) Convert two numbers to double-numbers.
dword     TWOStoD,"2S>D"
          ENTER
          .dword PtoR
          .dword StoD
          .dword RtoP
          .dword StoD
          EXIT
eword

; Factored for number conversion
.proc     _dplus
          lda   STACKBASE+12,x
          clc
          adc   STACKBASE+4,x
          sta   STACKBASE+12,x
          lda   STACKBASE+14,x
          adc   STACKBASE+6,x
          sta   STACKBASE+14,x
          lda   STACKBASE+8,x
          adc   STACKBASE+0,x
          sta   STACKBASE+8,x
          lda   STACKBASE+10,x
          adc   STACKBASE+2,x
          sta   STACKBASE+10,x
stkinc:   txa
          clc
          adc   #$08
          tax
          rts
.endproc

; H: ( d1 d2 -- d3 ) d3 = d1 + d2
dword     DPLUS,"D+"
          jsr   _4parm
          jsr   _dplus
          NEXT
eword

; H: ( d1 d2 -- d3 ) d3 = d1 - d2
dword     DMINUS,"D-"
          jsr   _4parm
          lda   STACKBASE+12,x
          sec
          sbc   STACKBASE+4,x
          sta   STACKBASE+12,x
          lda   STACKBASE+14,x
          sbc   STACKBASE+6,x
          sta   STACKBASE+14,x
          lda   STACKBASE+8,x
          sbc   STACKBASE+0,x
          sta   STACKBASE+8,x
          lda   STACKBASE+10,x
          sbc   STACKBASE+2,x
          sta   STACKBASE+10,x
          jsr   _dplus::stkinc
          NEXT
eword

; System variables for temporary string buffers
hword     dSBUF0,"$SBUF0"
          SYSVAR SV_SBUF0
eword

hword     dSBUF1,"$SBUF1"
          SYSVAR SV_SBUF1
eword

hword     dCSBUF,"$CSBUF"
          SYSVAR SV_CSBUF
eword

; H: ( addr1 u1 -- addr2 u1 )
; H: Allocate a temporary string buffer for interpretation semantics of strings
; H: and return the address and length of the buffer.  If taking the slot used
; H: by an existing buffer, free it.
dword     dTMPSTR,"$TMPSTR"
          jsr   _2parm
          lda   STACKBASE+0,x     ; get u1
          sta   XR
          lda   STACKBASE+2,x
          bne   nomem             ; only going to support ~64K strings for this
          sta   XR+2
          jsr   _alloc            ; allocate memory for it
          bcc   nomem
          pha                     ; save pointer
          phy
          ldy   #SV_CSBUF         ; get current string buffer
          lda   [SYSVARS],y
          inc   a
          and   #$01              ; only need low bit
          sta   [SYSVARS],y
          pha                     ; save it
          bne   getbuf1
          ldy   #SV_SBUF0+2       ; select buf 0
          bra   getbuf
getbuf1:  ldy   #SV_SBUF1+2       ; select buf 1
getbuf:   lda   [SYSVARS],y         ; get buffer pointer
          sta   WR+2              ; into WR
          dey
          dey
          lda   [SYSVARS],y
          sta   WR
          ora   WR+2
          beq   :+                ; no prior allocation if zero
          jsr   _free             ; otherwise, free current memory
:         lda   STACKBASE+0,x     ; length to XR
          sta   XR
          lda   STACKBASE+2,x
          sta   XR+2
          lda   STACKBASE+4,x     ; original address to WR
          sta   WR
          lda   STACKBASE+6,x
          sta   WR+2
          pla
          bne   setbuf1
          ldy   #SV_SBUF0         ; select buf 0
          bra   setbuf
setbuf1:  ldy   #SV_SBUF1         ; select buf 1
setbuf:   pla                     ; update pointers
          sta   YR                ; in YR
          sta   [SYSVARS],y       ; in the appropriate system var
          sta   STACKBASE+4,x     ; in the parameter stack
          iny
          iny
          pla
          sta   YR+2
          sta   [SYSVARS],y
          sta   STACKBASE+6,x
          sec                     ; move down is faster
          jsr   _memmove
          NEXT
nomem:    ldy   #.loword(-18)
          lda   #.hiword(-18)
          jmp   _throway          
eword

; H: ( -- <space> )
dword     BL,"BL"
          lda   #' '
          jsr   _pusha
          NEXT
eword

; H: ( -- ) emit a space
dword     SPACE,"SPACE"
          ENTER
          .dword BL
          .dword EMIT
          EXIT
eword

; H: ( u -- ) emit u spaces
dword     SPACES,"SPACES"
          jsr   _popxr
          ldy   #.loword(do_emit-1)
          lda   #.hiword(do_emit-1)
          jsr   _iter_ay
          NEXT
do_emit:  ENTER
          .dword BL
          .dword EMIT
          CODE
          clc
          rtl
eword

; H: ( -- <cr> )
dword     CARRET,"CARRET"
          lda   #c_cr
          jsr   _pusha
          NEXT
eword

; H: ( -- <lf> )
dword     LINEFEED,"LINEFEED"
          lda   #c_lf
          jsr   _pusha
          NEXT
eword

; H: ( -- ) Emit a CR with no linefeed, set #OUT to 0.
dword     pCR,"(CR"
          ENTER
          .dword CARRET
          .dword EMIT
          .dword NOUT
          .dword OFF
          EXIT
eword

; H: ( -- ) Emit a LF, increment #LINE.
hword     LF,"LF"
          ENTER
          ONLIT 1
          .dword NLINE
          .dword PSTORE
          .dword LINEFEED
          .dword EMIT
          EXIT
eword

; H: ( -- ) Emit a CR/LF combination, increment #LINE, set #OUT to 0.
dword     CR,"CR"
          ENTER
          .dword pCR
          .dword LF
          EXIT
eword

; H: ( -- <bel> )
dword     BELL,"BELL"
          lda   #c_bell
          jsr   _pusha
          NEXT
eword

; H: ( -- <bs> )
dword     BS,"BS"
          lda   #c_bs
          jsr   _pusha
          NEXT
eword

; H: ( -- ) Clear screen & home cursor (uses ANSI escape sequence).
dword     PAGE,"PAGE"
          ENTER
          .dword _SLIT
          .dword 7
          .byte $1B,"[2J",$1B,"[H"
          .dword TYPE
          EXIT
eword

; H: ( u1 u2 -- ) Place cursor at col u1 row u2 (uses ANSI escape sequence).
dword     AT_XY,"AT-XY"
          ENTER
          ONLIT $1B
          .dword EMIT
          ONLIT '['
          .dword EMIT
          .dword INCR
          ONLIT UDOTZ
          ONLIT 10
          .dword TMPBASE
          ONLIT ';'
          .dword EMIT
          .dword INCR
          ONLIT UDOTZ
          ONLIT 10
          .dword TMPBASE
          ONLIT 'H'
          .dword EMIT
          EXIT
eword

; H: ( ud u1 -- u2 u3 ) Divide ud by u1, giving quotient u3 and remainder u2.
dword     UMDIVMOD,"UM/MOD"
          jsr   _3parm
          lda   STACKBASE+0,x
          ora   STACKBASE+2,x
          beq   _divzero
          jsr   _umdivmod
          bcs   _overflow
          NEXT
eword

; H: ( d n1 -- n2 n3 ) Symmetric divide d by n1, giving quotient n3 and remainder n2.
dword     SMDIVREM,"SM/REM"
          .if 1 ; native version
          jsr   _3parm
          lda   STACKBASE+0,x
          ora   STACKBASE+2,x
          beq   _divzero
          jsr   _smdivrem
          bcs   _overflow
          NEXT
          .else ; secondary version
          ENTER
          .dword TWODUP
          .dword LXOR             ; compute result sign
          .dword PtoR             ; and save
          .dword OVER             ; copy dividend sign
          .dword PtoR             ; and save
          .dword ABS              ; take absolute value of args
          .dword PtoR
          .dword DABS
          .dword RtoP
          .dword UMDIVMOD         ; perform unsigned division
          .dword SWAP             ; move quotient out of the way
          .dword RtoP             ; get dividend sign
          .dword QNEGATE          ; and negate the remainder if it should be negative
          .dword SWAP             ; put the quotient back
          .dword RtoP             ; get result sign
          .dword QNEGATE          ; and make negative if it should be negative
          EXIT
          .endif
eword

; helpers to throw division errors
.proc     _divzero
          ldy   #.loword(-10)
          lda   #.hiword(-10)
          jmp   _throway
.endproc

.proc     _overflow
          ldy   #.loword(-11)
          lda   #.hiword(-11)
          jmp   _throway
.endproc

; H: ( n -- s ) s = -1 if n is negative, 0 if 0, 1 if positive.
dword     SIGNUM,"SIGNUM"
          jsr   _1parm
          jsr   _signum
          NEXT
eword

; H: ( d n1 -- n2 n3 ) Floored divide d by n1, giving quotient n3 and remainder n2.
dword     FMDIVMOD,"FM/MOD"
          .if 0 ; primitive, using math lib FM/MOD code based on SM/REM
          jsr   _3parm
          lda   STACKBASE+0,x
          ora   STACKBASE+2,x
          beq   _divzero
          jsr   _fmdivmod
          bcs   _overflow
          NEXT
          .else ; secondary, using SM/REM
          ENTER
          .dword DUP
          .dword PtoR
          .dword SMDIVREM
          .dword OVER
          .dword SIGNUM
          .dword RCOPY
          .dword SIGNUM
          .dword NEGATE
          .dword EQUAL
          .dword _IF
          .dword else
          .dword DECR
          .dword SWAP
          .dword RtoP
          .dword PLUS
          .dword SWAP
          EXIT
else:     .dword RDROP
          EXIT
          .endif
eword

; H: ( u1 u2 -- u3 u4 ) Divide u1 by u2, giving quotient u4 and remainder u3.
dword     UDIVMOD,"U/MOD"
          ENTER
          .dword PtoR
          .dword StoD
          .dword RtoP
          .dword UMDIVMOD
          EXIT
eword

; H: ( n1 n2 -- n3 n4 ) Divide n1 by n2, giving quotient n4 and remainder n3.
dword     DIVMOD,"/MOD"
          ENTER
          .dword PtoR
          .dword StoD
          .dword RtoP
          .dword FMDIVMOD
          EXIT
eword

; H: ( n1 n2 -- n3 ) Divide n1 by n2, giving remainder n3.
dword     MOD,"MOD"
          ENTER
          .dword DIVMOD
          .dword DROP
          EXIT
eword

; H: ( n1 n2 -- n3 ) Divide n1 by n2, giving quotient n3.
dword     DIV,"/"
          ENTER
          .dword DIVMOD
          .dword NIP
          EXIT
eword

; H: ( n1 n2 n3 -- n4 n5 ) n4, n5 = rem, quot of n1*n2/n3.
dword     MULTDIVMOD,"*/MOD"
          ENTER
          .dword PtoR
          .dword MMULT
          .dword RtoP
          .dword FMDIVMOD
          EXIT
eword

; H: ( n1 n2 n3 -- n4 ) n4 = quot of n1*n2/n3.
dword     MULTDIV,"*/"
          ENTER
          .dword MULTDIVMOD
          .dword NIP
          EXIT
eword

; H: ( d1 n1 -- d2 n2 ) d2, n2 = remainder and quotient of d1/n1
; unsigned 64-bit by 32-bit divide, leaving 64-bit quotient and 32-bit remainder
; used by double-number pictured numeric output routines only
dword     UDDIVMOD,"UD/MOD"
          ENTER
          .dword PtoR
          .dword ZERO
          .dword RCOPY
          .dword UMDIVMOD
          .dword RtoP
          .dword SWAP
          .dword PtoR
          .dword UMDIVMOD
          .dword RtoP
          EXIT
eword

; H: ( u1 u2 -- ud ) ud = u1*u2
dword     UMMULT,"UM*"
          jsr   _2parm
          jsr   _umult
          NEXT
eword

; H: ( u1 u2 -- u3 ) u3 = u1*u2
dword     UMULT,"U*"
          ENTER
          .dword UMMULT
          .dword DtoS
          EXIT
eword 

; H: ( n1 n2 -- d ) d = n1*n2
dword     MMULT,"M*"
          jsr   _2parm
          lda   STACKBASE+2,x     ; calculate sign flag
          eor   STACKBASE+6,x
          pha                     ; save it for later
          jsr   _2abs
          jsr   _umult
          pla
          bpl   :+
          jsr   _dnegate
:         NEXT
eword

; H: ( n1 n2 -- n3 ) n3 = n1*n2
dword     MULT,"*"
          ENTER
          .dword MMULT
          .dword DtoS
          EXIT
eword

; H: ( u1 -- u2 u3 ) u2 = closest square root <= to the true root, u3 = remainder.
dword     SQRTREM,"SQRTREM"
          jsr   _sqroot
          NEXT
eword

; H: ( n1 -- n1|n2 ) n2 = n1+1 if n1 is odd.
dword     EVEN,"EVEN"
          jsr   _1parm
          lda   STACKBASE+0,x
          and   #1
          beq   :+
          jmp   INCR::code
:         NEXT
eword

; ( -- a-addr ) return address of WORD buffer
hword     WORDBUF,"WORDBUF"
          ENTER
          .dword HERE
          ONLIT  16
          .dword  PLUS
          EXIT
eword

.if pad_size > 0
; H: ( -- a-addr ) return address of PAD
dword     PAD,"PAD"
          ENTER
          .dword WORDBUF
          ONLIT word_buf_size
          .dword PLUS
          EXIT
eword
.endif

; ( -- a-addr ) variable containing pictured numeric output pointer
hword     dPPTR,"$PPTR"
          SYSVAR SV_dPPTR
eword

; H: ( -- ) Begin pictured numeric output.
dword     PBEGIN,"<#"
          ENTER
          .dword WORDBUF
          ONLIT word_buf_size
          .dword PLUS
          .dword dPPTR
          .dword STORE
          EXIT
eword

; H: ( c -- ) Place c in pictured numeric output.
dword     PHOLD,"HOLD"
          ENTER
          .dword dPPTR
          .dword FETCH
          .dword DECR
          .dword DUP
          .dword dPPTR
          .dword STORE
          .dword CSTORE
          EXIT
eword

; H: ( n -- ) Place - in pictured numeric output if n is negative.
dword     PSIGN,"SIGN"
          jsr   _popay
          and   #$8000
          beq   :+
          lda   #'-'
          jsr   _pusha
          jmp   PHOLD::code
:         NEXT
eword

; H: ( ud1 -- ud2 ) Divide ud1 by BASE, convert remainder to char and HOLD it, ud2 = quotient.
dword     PNUM,"#"
          ENTER
          .dword BASE
          .dword FETCH
          .dword UDDIVMOD
          .dword ROT
          CODE
hold:     jsr   _popay
          tya
          jsr   _d_to_c
          jsr   _pusha
          jmp   PHOLD::code
eword

; H: ( u1 -- u2 ) Divide u1 by BASE, convert remainder to char and HOLD it, u2 = quotient.
dword     PUNUM,"U#"
          ENTER
          .dword ZERO
          .dword BASE
          .dword FETCH
          .dword UMDIVMOD
          .dword SWAP
          CODE
          bra   PNUM::hold
eword

; H: ( ud -- 0 ) Perform # until quotient is zero.
dword     PNUMS,"#S"
          ENTER
another:  .dword PNUM
          .dword TWODUP
          .dword LOR
          .dword _IFFALSE
          .dword another
          EXIT
eword

; H: ( u -- 0 ) Perform U# until quotient is zero.
dword     PUNUMS,"U#S"
          ENTER
another:  .dword PUNUM
          .dword DUP
          .dword _IFFALSE
          .dword another
          EXIT
eword

; H: ( ud -- ) Conclude pictured numeric output.
dword     PDONE,"#>"
          ENTER
          .dword TWODROP
getstr:   .dword dPPTR
          .dword FETCH
          .dword WORDBUF
          ONLIT  word_buf_size
          .dword PLUS
          .dword dPPTR
          .dword FETCH
          .dword MINUS
          EXIT
eword

; H: ( u -- ) Conclude pictured numeric output.
dword     PUDONE,"U#>"
          ENTER
          .dword DROP
          JUMP  PDONE::getstr
eword

; ( d f -- c-addr u), f = true if signed number
hword     dUDFMT,"$UDFMT"
          ENTER
          .dword _IF
          .dword ns
          .dword DUP
          .dword PtoR
          .dword DABS
          JUMP doit
ns:       .dword ZERO
          .dword PtoR
doit:     .dword PBEGIN
          .dword PNUMS
          .dword RtoP
          .dword PSIGN
          .dword PDONE
          EXIT
eword

; ( n f -- c-addr u), f = true if signed number
hword     dUFMT,"$UFMT"
.if 1 ; slightly smaller & slower
          ENTER
          .dword _IF
          .dword ns
          .dword DUP
          .dword PtoR
          .dword ABS
          JUMP :+
ns:       .dword ZERO
          .dword PtoR
:         .dword ZERO             ; we already saved the sign, no need to sign-extend
          JUMP dUDFMT::doit
.else ; bigger & faster
          ENTER
          .dword _IF
          .dword ns
          .dword DUP
          .dword PtoR
          .dword ABS
          JUMP doit
ns:       .dword ZERO
          .dword PtoR
doit:     .dword PBEGIN
          .dword PUNUMS
          .dword RtoP
          .dword PSIGN
          .dword PUDONE
          EXIT
.endif
eword

; H: ( n -- addr u ) Convert n to text via pictured numeric output.
dword     NTOTXT,"(.)"
          ENTER
          .dword TRUE
          .dword dUFMT
          EXIT
eword

; H: ( u -- addr u ) Convert u to text via pictured numeric output.
dword     UTOTXT,"(U.)"
          ENTER
          .dword FALSE
          .dword dUFMT
          EXIT
eword

; H: ( addr u1 u2 ) output addr u1 in a field of size u2
hword     DFIELD,"$FIELD"
          ENTER
          .dword OVER             ; ( c-addr u1 u2 -- c-addr u1 u2 u1' )
          .dword MINUS            ; ( c-addr u1 u2 u1' -- c-addr u1 u3 ) u3=remaining field
          .dword DUP              ; ( c-addr u1 u3 -- c-addr u1 u3 u3'
          .dword ZEROLT           ; ( c-addr u1 u3 u3' -- c-addr u1 u3 f )
          .dword _IF              ; ( c-addr u1 u3 f -- c-addr u1 u3 )
          .dword :+               ; 0 or more in field, go print some spaces
          .dword DROP
          .dword TYPE
          EXIT
:         .dword SPACES
          .dword TYPE
          EXIT
eword

; H: ( d u -- ) Output d in a field of u chars.
dword     DDOTR,"D.R"
          ENTER
          .dword PtoR
          .dword TRUE
          .dword dUDFMT
          .dword RtoP
          .dword DFIELD
          EXIT
eword

; H: ( d -- ) Output d.
dword     DDOT,"D."
          ENTER
          .dword TRUE
          .dword dUDFMT
          .dword TYPE
          .dword SPACE
          EXIT
eword

; H: ( u1 u2 -- ) Output u1 in a field of u2 chars.
dword     UDOTR,"U.R"
          ENTER
          .dword PtoR
          .dword FALSE
          .dword dUFMT
          .dword RtoP
          .dword DFIELD
          EXIT
eword

; H: ( u1 -- ) Output u1 with no trailing space.
dword     UDOTZ,"U.0"
          ENTER
          .dword ZERO
          .dword UDOTR
          EXIT
eword

; H: ( n u -- ) Output n in a field of u chars.
dword     DOTR,".R"
          ENTER
          .dword PtoR
          .dword TRUE
          .dword dUFMT
          .dword RtoP
          .dword DFIELD
          EXIT
eword

; H: ( u -- ) Output u.
dword     UDOT,"U."
          ENTER
          .dword FALSE
          .dword dUFMT
          .dword TYPE
          .dword SPACE
          EXIT
eword

; H: ( n -- ) Output n.
dword     DOT,"."
          ENTER
          .dword TRUE
          .dword dUFMT
          .dword TYPE
          .dword SPACE
          EXIT
eword

; H: ( n -- ) Output n.
dword     SDOT,"S."
          bra   DOT::code
eword

; H: ( addr -- ) Output signed contents of cell at addr.
dword     SHOW,"?"
          ENTER
          .dword FETCH
          .dword DOT
          EXIT
eword

; H: ( n -- ) Output n in decimal base.
dword     DOTD,".D"
          ENTER
          ONLIT 10
tmpbase:  ONLIT DOT
          .dword SWAP
          .dword TMPBASE
          EXIT
eword

; H: ( n -- ) Output n in hexadecimal base.
dword     DOTH,".H"
          ENTER
          ONLIT 16
          JUMP DOTD::tmpbase
eword

.proc     _popxryrwr
          jsr   _popxr
          jsr   _popyr
          jmp   _popwr
.endproc

; H: ( addr1 addr2 len -- ) Move memory.
dword     MOVE,"MOVE"
          jsr   _popxryrwr
          jsr   _memmove
          NEXT
eword

; H: ( addr1 addr2 len -- ) Move memory, startomg from the bottom.
dword     CMOVE,"CMOVE"
          jsr   _popxryrwr
          clc
          jsr   _memmove_c
          NEXT
eword

; H: ( addr1 addr2 len -- ) Move memory, starting from the top.
dword     CMOVEUP,"CMOVE>"
          jsr   _popxryrwr
          sec
          jsr   _memmove_c
          NEXT
eword

; H: ( addr1 addr2 u1 -- n1 ) Compare two strings of length u1.
; IEEE 1275
dword     COMP,"COMP"
          stz   ZR                ; case sensitive
docomp:   jsr   _popxryrwr
          sep   #SHORT_A
          .a8
          ldy   #$0000
lp:       cpy   XR
          bcs   equal
          bit   ZR
          bmi   insens
          lda   [WR],y            ; case sensitive compare
          cmp   [YR],y
postcmp:  bne   neq
          iny
          bra   lp
insens:   lda   [WR],y            ; case insensitive compare
          jsr   _cupper8
          sta   ZR+2              ; use ZR+2 to hold converted byte
          lda   [YR],y
          jsr   _cupper8
          cmp   ZR+2
          bra   postcmp
neq:      rep   #SHORT_A
          .a16
          bcc   less
          lda   #$0000
          tay
          iny
          PUSHNEXT
less:     lda   #$FFFF
          tay
          PUSHNEXT
equal:    rep   #SHORT_A
          .a16
          lda   #$0000
          tay
          PUSHNEXT 
eword

; H: ( addr1 addr2 u1 -- n1 ) Case-insensitive compare two strings of length u1.
; non-standard
dword     CICOMP,"CICOMP"
          stz   ZR
          dec   ZR
          bra   COMP::docomp
eword

; H: ( addr1 u1 addr2 u2 -- n1 ) Compare two strings.
; ANS Forth
dword     COMPARE,"COMPARE"
          ENTER
          .dword ROT              ; ( addr1 u1 addr2 u2 -- addr1 addr2 u2 u1 )
          .dword TWODUP
          .dword TWOPtoR          ; ( R: -- u2' u1' )
          .dword MIN
          .dword COMP
          .dword DUP
          .dword _IF
          .dword equal
          .dword RDROP
          .dword RDROP
          EXIT
equal:    .dword DROP
          .dword TWORtoP
          .dword SWAP
          .dword MINUS
          .dword SIGNUM
          EXIT
eword

; H: ( c-addr1 u1 n -- c-addr2 u2 ) Adjust string.
dword     sSTRING,"/STRING"
.if 1 ; secondary - shorter, slower
          ENTER
          .dword TUCK
          .dword MINUS
          .dword PtoR
          .dword PLUS
          .dword RtoP
          EXIT
.else ; primitive - longer, faster
          jsr   _3parm
          lda   STACKBASE+8,x
          clc
          adc   STACKBASE+0,x
          sta   STACKBASE+8,x
          lda   STACKBASE+10,x
          adc   STACKBASE+2,x
          sta   STACKBASE+10,x
          lda   STACKBASE+4,x
          sec
          sbc   STACKBASE+0,x
          sta   STACKBASE+4,x
          lda   STACKBASE+6,x
          sbc   STACKBASE+2,x
          sta   STACKBASE+6,x
          jsr   _stackincr
          NEXT
.endif
eword

; H: ( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag ) Search for substring.
;         WR   XR    YR   ZR
; in practice ZR can only be 16-bit like most other string stuff
dword     SEARCH,"SEARCH"
          jsr   _4parm
          jsr   _popay
          sty   ZR
          sta   ZR+2
          jsr   _popyr
          lda   STACKBASE+0,x     ; now we are down to ( c-addr1 u1 ) on stack
          sta   XR                ; get them and put them into WR and XR
          lda   STACKBASE+2,x
          sta   XR+2
          lda   STACKBASE+4,x
          sta   WR
          lda   STACKBASE+6,x
          sta   WR+2
          bra   chklen
next:     rep   #SHORT_A
          .a16
          jsr   _incwr
          jsr   _decxr
chklen:   lda   XR+2
          cmp   ZR+2
          bne   :+
          lda   XR
          cmp   ZR
:         bcc   nomatch           ; XR < ZR, no match found!
          ldy   ZR                ; let's see if there's a match
          beq   nomatch           ; nope out of u2 is zero
          sep   #SHORT_A
          .a8
lp:       dey                     ; it needs to be one less than
          lda   [WR],y
          cmp   [YR],y
          bne   next
          cpy   #$0000
          bne   lp                ; keep matching
          rep   #SHORT_A
          .a16
          lda   WR+2              ; match found, return results!
          sta   STACKBASE+6,x
          lda   WR
          sta   STACKBASE+4,x
          lda   XR+2
          sta   STACKBASE+2,x
          lda   XR
          sta   STACKBASE+0,x
          lda   #$FFFF
          bra   :+
nomatch:  lda   #$0000
:         tay
          PUSHNEXT
eword

; H: ( addr len char -- ) Fill memory with char.
dword     FILL,"FILL"
          ENTER
          .dword NROT
          CODE
          ldy   #.loword(dofill-1)
          lda   #.hiword(dofill-1)
          jsr   _str_op_ays
          jsr   _stackincr
          NEXT
dofill:   sep   #SHORT_A
          .a8
          lda   STACKBASE+0,x
          sta   [WR]
          rep   #SHORT_A
          .a16
          clc
          rtl
eword

; H: ( addr len -- ) Fill memory with spaces.
dword     BLANK,"BLANK"
          ENTER
          ONLIT ' '
          .dword FILL
          EXIT
eword

; H: ( addr len -- ) Zero fill memory.
dword     ERASE,"ERASE"
          ENTER
          .dword ZERO
          .dword FILL
          EXIT
eword

; H: ( addr len -- ) Perform WBFLIP on the words in memory.
dword     WBFLIPS,"WBFLIPS"
          ldy   #.loword(doflip-1)
          lda   #.hiword(doflip-1)
          jsr   _str_op_ays
          NEXT
doflip:   lda   [WR]
          xba
          sta   [WR]
          jsr   _incwr
          clc
          rtl
eword

; H: ( addr len -- ) Perform LBFLIP on the cells in memory.
dword     LBFLIPS,"LBFLIPS"
          ldy   #.loword(doflip-1)
          lda   #.hiword(doflip-1)
          jsr   _str_op_ays
          NEXT
doflip:   ldy   #$02
          lda   [WR]
          xba
          pha
          lda   [WR],y
          xba
cont:     sta   [WR]
          pla
          sta   [WR],y
          lda   WR
          clc
          adc   #.loword(3)
          sta   WR
          lda   WR+2
          adc   #.hiword(3)
          sta   WR+2
          clc
          rtl
eword

; H: ( addr len -- ) Perform LWFLIP on the cells in memory.
dword     LWFLIPS,"LWFLIPS"
          ldy   #.loword(doflip-1)
          lda   #.hiword(doflip-1)
          jsr   _str_op_ays
          NEXT
doflip:   ldy   #$02
          lda   [WR]
          pha
          lda   [WR],y
          bra   LBFLIPS::cont
eword

.if include_fcode
; FCode support words

; H: ( addr -- char true ) Access memory at addr, returning char.
dword     CPEEK,"CPEEK"
          ENTER
          .dword CFETCH
          .dword TRUE
          EXIT
eword

; H: ( addr -- word true ) Access memory at addr, returning word.
dword     WPEEK,"WPEEK"
          ENTER
          .dword WFETCH
          .dword TRUE
          EXIT
eword

; H: ( addr -- cell true ) Access memory at addr, returning cell.
dword     LPEEK,"LPEEK"
          ENTER
          .dword LFETCH
          .dword TRUE
          EXIT
eword

; H: ( char addr -- true ) Store char at addr.
dword     CPOKE,"CPOKE"
          ENTER
          .dword CSTORE
          .dword TRUE
          EXIT
eword

; H: ( word addr -- true ) Store word at addr.
dword     WPOKE,"WPOKE"
          ENTER
          .dword WSTORE
          .dword TRUE
          EXIT
eword

; H: ( cell addr -- true ) Store cell at addr.
dword     LPOKE,"LPOKE"
          ENTER
          .dword LSTORE
          .dword TRUE
          EXIT
eword

; FCode evaluator variables:

; Variable containing FCode instruction pointer
hword     dFCODE_IP,"$FCODE-IP"
          SYSVAR SV_FCODE_IP
eword

; If set nonzero, FCode interpretation will end and the value thrown
hword     dFCODE_END,"$FCODE-END"
          SYSVAR SV_FCODE_END
eword

; Bytes to increment $FCODE-IP for an FCode fetch.  Nearly always 1.
hword     dFCODE_SPREAD,"$FCODE-SPREAD"
          SYSVAR SV_FCODE_SPREAD
eword

; If zero, the FCode offset size is 8 bits, otherwise 16.
hword     dFCODE_OFFSET,"$FCODE-OFFSET"
          SYSVAR SV_FCODE_OFFSET
eword

; Contains the XT of the FCode fetch instruction, usually RB@
hword     dFCODE_FETCH,"$FCODE-FETCH"
          SYSVAR SV_FCODE_FETCH
eword

; Contains the address of the FCode Master Table
hword     dFCODE_TABLES,"$FCODE-TABLES"
          SYSVAR SV_FCODE_TABLES
eword

; Contains the address of the last defined FCode function
hword     dFCODE_LAST,"$FCODE-LAST"
          SYSVAR SV_FCODE_LAST
eword

; If one, place headers on header-optional Fcode functions
; set by $BYTE-EXEC to the result of FCODE-DEBUG? if it exists
hword     dFCODE_DEBUG,"$FCODE-DEBUG"
          SYSVAR SV_FCODE_DEBUG
eword

; H: ( -- u ) Return FCode revision
dword     xFCODE_REVISION,"FCODE-REVISION"
          ENTER
          ONLIT $87
          .dword DO_TOKEN
          EXIT
eword

; H: ( -- ) Display FCode IP and byte, throw exception -256.
dword     FERROR,"FERROR"
          ENTER
          .dword dFCODE_IP
          .dword FETCH
          .dword DUP
          .dword UDOT
          .dword CFETCH
          .dword UDOT
          ONLIT -256
          .dword THROW
          EXIT
eword

; H: ( xt fcode# f -- ) Set fcode# to execute xt, immediacy f.
dword     SET_TOKEN,"SET-TOKEN"
          jml   xSET_TOKEN_code
eword

; H: ( fcode# -- xt f ) Get fcode#'s xt and immediacy.
dword     GET_TOKEN,"GET-TOKEN"
          jsr   _1parm
          jsl   lGET_TOKEN
          NEXT
eword

; FCode atomic memory accessors, IEEE 1275-1994 says these may be overwritten by FCode
; to do device-specific accesses.  

; ( addr -- char ) fetch char at addr, atomically
hword     dRBFETCH,"$RB@"
          jmp   CFETCH::code
eword

; ( addr -- word ) fetch word at addr
; Note that IEEE 1275-1994 requires the fetch to occur in a single access, but the '816
; has an 8-bit bus so this is technically impossible.
hword     dRWFETCH,"$RW@"
          jmp   WFETCH::code
eword

; ( addr -- cell ) fetch cell at addr
; Note that IEEE 1275-1994 requires the fetch to occur in a single access, but the '816
; has an 8-bit bus so this is technically impossible.
hword     dRLFETCH,"$RL@"
          jmp   LFETCH::code
eword

; ( byte addr -- ) store byte at addr, atomically
hword     dRBSTORE,"$RB!"
          jmp   CSTORE::code
eword

; ( word addr -- ) store word at addr
; Note that IEEE 1275-1994 requires the store to occur in a single access, but the '816
; has an 8-bit bus so this is technically impossible.
hword     dRWSTORE,"$RW!"
          jmp   WSTORE::code
eword

; ( cell addr -- ) store cell at addr
; Note that IEEE 1275-1994 requires the store to occur in a single access, but the '816
; has an 8-bit bus so this is technically impossible.
hword     dRLSTORE,"$RL!"
          jmp   LSTORE::code
eword

; H: ( addr -- byte ) Perform FCode-equivalent RB@: fetch byte.
dword     RBFETCH,"RB@",F_IMMED
          ENTER
          ONLIT $230
          .dword DO_TOKEN
          EXIT
eword

; H: ( addr -- word ) Perform FCode-equivalent RW@: fetch word.
dword     RWFETCH,"RW@",F_IMMED
          ENTER
          ONLIT $232
          .dword DO_TOKEN
          EXIT
eword

; H: ( addr -- cell ) Perform FCode-equivalent RL@: fetch cell.
dword     RLFETCH,"RL@",F_IMMED
          ENTER
          ONLIT $234
          .dword DO_TOKEN
          EXIT
eword

; H: ( byte addr -- ) Perform FCode-equivalent RB!: store byte.
dword     RBSTORE,"RB!",F_IMMED
          ENTER
          ONLIT $231
          .dword DO_TOKEN
          EXIT
eword

; H: ( word addr -- ) Perform FCode-equivalent RW!: store word.
dword     RWSTORE,"RW!",F_IMMED
          ENTER
          ONLIT $233
          .dword DO_TOKEN
          EXIT
eword

; H: ( cell addr -- ) Perform FCode-equivalent RL!, store cell.
dword     RLSTORE,"RL!",F_IMMED
          ENTER
          ONLIT $235
          .dword DO_TOKEN
          EXIT
eword

.if 0 ; stuff for testing
dword     xSET_MUTABLE_FTABLES,"SET-MUTABLE-FTABLES" ; noindex
          ENTER
          .dword SET_MUTABLE_FTABLES
          EXIT
eword

dword     xSET_RAM_FTABLE,"SET-RAM-FTABLE" ; noindex
          ENTER
          .dword SET_RAM_FTABLE
          EXIT
eword

dword     xSET_ROM_FTABLE,"SET-ROM-FTABLE" ; noindex
          ENTER
          .dword SET_ROM_FTABLE
          EXIT
eword

dword     xGET_FTABLES,"GET-FTABLES" ; noindex
          ENTER
          .dword GET_FTABLES
          EXIT
eword

dword     xSAVE_FCODE_STATE,"SAVE-FCODE-STATE" ; noindex
          ENTER
          .dword SAVE_FCODE_STATE
          EXIT
eword

dword     xRESTORE_FCODE_STATE,"RESTORE-FCODE-STATE" ; noindex
          ENTER
          .dword RESTORE_FCODE_STATE
          EXIT
eword
.endif

; FCode evaluation
; this does *not* save and restore the FCode evaluator state, that's what byte-load is
; for.  This just gets things going, and unless SET-TOKEN is called, sticks with the ROM
; FCode tables.
; H: ( addr xt -- ) evaluate FCode at addr with fetch function xt, do not save FCode
; H: evaluator state
dword     dBYTE_EXEC,"$BYTE-EXEC"
          jsr   _2parm
          ENTER
          SLIT "FCODE-DEBUG?"     ; see if user wants optional headers
          .dword dFIND
          .dword _IF
          .dword nope
          .dword EXECUTE
          .dword dFCODE_DEBUG
          .dword STORE
          .dword _SKIP
nope:     .dword TWODROP
          .dword DUP
          .dword ONE
          .dword ULTE
          .dword _IF
          .dword usext
          .dword DROP             ; Drop supplied xt
          ONLIT $230              ; RB@
          .dword GET_TOKEN        ; get XT
          .dword DROP             ; drop the flag
usext:    .dword dFCODE_FETCH     ; and put it in $FCODE-FETCH
          .dword STORE
          .dword DECR             ; need to start with address -1
          .dword dFCODE_IP
          .dword STORE
          .dword ONE
          .dword dFCODE_SPREAD
          .dword STORE
          .dword dFCODE_END
          .dword OFF
          .dword dFCODE_OFFSET
          .dword OFF
          .dword xFCODE_EVALUATE
          EXIT     
eword

; H: ( addr xt -- ) Evaluate FCode at addr with fetch function xt, saving and
; restoring FCode evaluator state.
dword     BYTE_LOAD,"BYTE-LOAD"
          ENTER
          .dword SAVE_FCODE_STATE
          .dword PtoR
          ONLIT dBYTE_EXEC
          .dword CATCH
          ;.dword DOTS
          .dword RtoP
          .dword RESTORE_FCODE_STATE
          .dword THROW
          EXIT
eword
.endif ; end of FCode stuff

; H: ( addr len -- ) Dump memory.
dword     DUMP,"DUMP"
          ENTER
          .dword BOUNDS
          JUMP addr
lp:       .dword DUP
          ONLIT $F
          .dword LAND
          .dword _IFFALSE
          .dword noaddr
addr:     .dword CR
          .dword DUP
          ONLIT 8
          .dword UDOTR
          ONLIT ':'
          .dword EMIT
          .dword SPACE
noaddr:   .dword DUP
          .dword CFETCH
          ONLIT 2
          .dword UDOTR
          .dword SPACE
          .dword INCR
          .dword TWODUP
          .dword ULTE
          .dword _IF
          .dword lp
          .dword TWODROP
          EXIT
eword

; H: ( xt -- addr|0 ) Get link field of word at xt or 0 if none.
dword     rLINK,">LINK"
          jsr   _popyr
          jsr   _xttohead
          bcc   nolink
          ldy   YR
          lda   YR+2
          PUSHNEXT
nolink:   lda   #$0000
          tay
          PUSHNEXT
eword

; H: ( xt -- c-addr u ) Get string name of word at xt, or ^xt if anonymous/noname.
; H: Uses pictured numeric output.
dword     rNAME,">NAME"
          ENTER
          .dword ZERO             ; ( xt -- xt 0 )
          .dword PtoR             ; ( xt 0 -- xt ) ( R: -- 0 )
lp:       .dword RCOPY            ; ( xt u )
          ONLIT NAMEMSK           ; ( xt u -- xt u u1 )
          .dword UGT              ; ( xt u u1 -- xt f ) is name too long?
          .dword _IFFALSE         ; ( xt f -- xt )
          .dword noname           ; True branch, stack is ( xt 0 ) (R: u )
          .dword DUP              ; ( xt -- xt xt' ) 
          .dword RCOPY            ; ( xt xt' - xt xt' u )
          .dword INCR             ; ( xt xt' u -- xt xt' u' )
          .dword MINUS            ; ( xt xt' u' -- xt xt'' )
          .dword CFETCH           ; ( xt xt'' -- xt c )
          .dword DUP              ; ( xt c -- xt c c' )
          ONLIT $80               ; ( xt c c' -- xt c c' $80 )
          .dword LAND             ; ( xt c c' -- xt c f )
          .dword _IFFALSE         ; ( xt c f -- xt c )
          .dword done             ; true branch
          .dword DROP             ; ( xt c -- xt )
          .dword RINCR            ; ( xt ) ( R: u -- u' )
          JUMP lp
done:     ONLIT NAMEMSK           ; ( xt c -- xt c m )
          .dword LAND             ; ( xt c m -- xt l ) l = length
          .dword RCOPY            ; ( xt l -- xt l u ) ( R: u )
          .dword EQUAL            ; ( xt l u -- xt f )
          .dword _IF              ; ( xt f -- xt )
          .dword noname           ; false branch, stack is ( xt ) ( R: u )
          .dword RCOPY            ; ( xt -- xt u ) ( R: u )
          .dword QDUP             ; ( xt u -- xt u | xt u u )
          .dword _IF              ; ( xt u | xt u u -- xt | xt u )
          .dword noname           ; false branch, stack is ( xt ) ( R: u )
          .dword MINUS            ; ( xt u -- c-addr )
          .dword RtoP             ; ( c-addr -- c-addr u )
          EXIT
noname:   .dword RDROP            ; ( xt ) ( R: u -- )
noname1:  .dword PBEGIN
          .dword PUNUMS           ; ( xt -- )
          ONLIT '^'
          .dword PHOLD
          .dword PUDONE           ; ( -- c-addr u )
          EXIT
eword
rNAME_noname1 = rNAME::noname1

; H: ( addr -- addr+1 u ) Count packed string at addr.
dword     COUNT,"COUNT"
          ENTER
          .dword DUP
          .dword INCR
          .dword SWAP
          .dword CFETCH
          EXIT
eword

; H: ( str len addr -- addr ) Pack string into addr, similar to PLACE in some Forths.
dword     PACK,"PACK"
          jsr   _3parm
          jsr   _popyr
          jsr   _popxr
          jsr   _popwr
          lda   XR+2
          bne   bad
          lda   XR
          cmp   #$100
          bcs   bad
          sta   [YR]
          ldy   YR
          lda   YR+2
          jsr   _pushay
          inc   YR
          bne   :+
          inc   YR+2
:         sec                     ; move down is faster
          jsr   _memmove_c
          NEXT
bad:      ldy   #.loword(-18)
          lda   #.hiword(-18)
          jmp   _throway
eword

; H: ( addr u1 -- addr u2 ) u2 = length of string with trailing spaces omitted.
dword     MTRAILING,"-TRAILING"
          lda   STACKBASE+4,x
          sta   WR
          lda   STACKBASE+6,x
          sta   WR+2
          jsr   _decwr
          ldy   STACKBASE+0,x
lp:       lda   [WR],y
          and   #$FF
          cmp   #' '
          bne   done
          dey
          bne   lp
done:     sty   STACKBASE+0,x
          NEXT
eword

; H: ( ud1 addr1 u1 -- ud2 addr2 u2 ) Convert text to number.
; note: only converts positive numbers!
; Direct page use:
; YR = current BASE
; XR = length left to go (initially u1), only 64K string supported
; XR + 2 = number of chars processed so far
; WR = pointer to current char
dword     GNUMBER,">NUMBER"
          jsr   _4parm
          ldy   #SV_BASE+2
          lda   [SYSVARS],y
          sta   YR+2
          dey
          dey
          lda   [SYSVARS],y
          sta   YR
          jsr   _popxr              ; u1 (length)
          jsr   _popwr              ; c-addr1 ( stack is now just d )
          stz   XR+2
digit:    lda   XR                  ; see if no more chars left
          beq   done
          lda   [WR]
          and   #$FF                ; enforce char from 16-bit load
          cmp   #'.'                ; IEEE 1275-1994 requires these to be ignored
          beq   ignore              ; when embedded in the number
          cmp   #','
          beq   ignore
          jsr   _c_to_d             ; convert to digit
          bcc   done                ; if out of range, can't use it
          cmp   YR                  ; check against base
          bcs   done                ; if >=, can't use it
          jsr   _pusha              ; ( -- ud1l ud1h n )
          jsr   _swap               ; ( -- ud1l n ud1h )
          ldy   YR
          lda   #$0000
          jsr   _pushay             ; ( -- ud1l n ud1h base ) 
          jsr   _umult              ; ( -- ud1l n ud1h*basel 0 )
          inx
          inx
          inx
          inx                       ; ( -- ud1l n ud1h*basel )
          jsr   _rot                ; ( -- n ud1h*basel ud1l )
          ldy   YR
          lda   #$0000
          jsr   _pushay             ; ( -- n ud1h*basel ud1l base )
          jsr   _umult              ; ( -- n ud1h*basel ud1l*basel ud1l*baseh )
          jsr   _dplus              ; ( -- ud2 )
next:     jsr   _incwr
          dec   XR
          inc   XR+2
          bra   digit
done:     ldy   WR
          lda   WR+2
          jsr   _pushay
          ldy   XR
          lda   #$0000
          PUSHNEXT
ignore:   lda   XR+2
          beq   done                ; can't be the first
          lda   XR
          dec   a
          beq   done                ; nor the last
          bra   next
eword

; H: ( str len char -- r-str r-len l-str l-len ) Parse string for char, returning
; H: the left and right sides.
dword     LEFT_PARSE_STRING,"LEFT-PARSE-STRING"
          jsr   _popyr              ; char
          jsr   _popxr              ; len
          jsr   _popwr              ; str
          ldy   #$0000
          lda   XR
          ora   XR+2
          beq   done
lp:       lda   [WR],y
          and   #$00FF
          iny
          beq   done
          cmp   YR
          beq   done
          cpy   XR
          bcc   lp
          ldy   #$0000
done:     tya
          beq   nomatch
          sta   XR+2
          lda   WR                  ; addr of str 2 = WR+(XR+2)
          clc
          adc   XR+2
          tay
          lda   WR+2
          adc   #$0000
          jsr   _pushay
          lda   XR                  ; len of str 2 = XR-(XR+2)
          sec
          sbc   XR+2
          jsr   _pusha
          ldy   WR
          lda   WR+2
          jsr   _pushay
          ldy   XR+2
          dey
:         lda   #$0000
          PUSHNEXT
nomatch:  jsr   _pushay
          jsr   _pushay
          ldy   WR
          lda   WR+2
          jsr   _pushay
          ldy   XR
          bra   :-  
eword

; H: ( str len -- val.lo val.hi ) Parse two integers from string in the form "n2,n2".
dword     PARSE_2INT,"PARSE-2INT"
          ENTER
          ONLIT ','
          .dword LEFT_PARSE_STRING
          .dword TWOPtoR
          .dword ZERO
          .dword StoD
          .dword TWOSWAP
          .dword GNUMBER
          .dword THREEDROP
          .dword ZERO
          .dword StoD
          .dword TWORtoP
          .dword GNUMBER
          .dword THREEDROP
          EXIT
eword

; ( c-addr u wid -- xt ) Search wordlist wid for word.
hword     dWLSEARCH,"$WLSEARCH"
          jsr   _popwr
          ldy   #$02
          lda   [WR],y
          sta   YR+2
          dey
          dey
          lda   [WR],y
          sta   YR
          jsr   _popxr
          jsr   _popwr
          jsr   _search_unsmudged
          PUSHNEXT
eword

.if max_search_order > 0
; H: ( c-addr u wid -- 0 | xt +-1 ) Search wordlist for word.
dword     SEARCH_WORDLIST,"SEARCH-WORDLIST"
.else
hword     SEARCH_WORDLIST,"SEARCH-WORDLIST"
.endif
          ENTER
          .dword dWLSEARCH
          .dword DUP
          .dword _IF
          .dword notfound
          .dword IMMEDQ
          ONLIT 1
          .dword LOR
          .dword NEGATE
notfound: EXIT
eword

; H: ( c-addr u -- 0 | xt +-1 ) Search for word in current search order.
dword     SEARCH_ALL,"$SEARCH"
          ENTER
.if max_search_order > 0
          .dword dORDER
          .dword FETCH
          .dword QDUP
          .dword _IF
          .dword noorder
lp:       .dword PtoR             ; ( c-addr u1 u2 -- c-addr u1 )
          .dword TWODUP           ; ( c-addr u1 -- c-addr u1 c-addr' u1' )
          .dword RtoP             ; ( ... c-addr u1 c-addr' u1' u2 )
          .dword DECR             ; ( ... c-addr u1 c-addr' u1' u2' )
          .dword DUP              ; ( ... c-addr u1 c-addr' u1' u2' u2'' )
          .dword PtoR             ; ( ... c-addr u1 c-addr' u1' u2' )
          .dword WLNUM            ; ( ... c-addr u1 c-addr' u1' wid-addr )
          .dword FETCH            ; ( ... c-addr u1 c-addr' u1' wid )
          .dword SEARCH_WORDLIST  ; ( ... c-addr u1 0 | c-addr u1 xt +-1 )
          .dword QDUP             ; ( ... c-addr u1 0 | c-addr u1 xt +-1 +-1 )
          .dword _IFFALSE         ; ( ... c-addr u1 | c-addr u1 xt +-1 )
          .dword found
          .dword RtoP             ; ( ... c-addr u1 u2 )
          .dword DUP              ; ( ... c-addr u1 u2 u2' )
          .dword _IFFALSE         ; ( ... c-addr u1 u2 )
          .dword lp
          .dword NIPTWO           ; ( ... u2 )
          EXIT
found:    .dword RDROP
          .dword TWOPtoR          ; ( c-addr u1 xt +-1 -- c-addr u1 )
          .dword TWODROP          ; ( c-addr u1 -- )
          .dword TWORtoP          ; ( -- xt +-1 )
          EXIT
.endif
noorder:  .dword GET_CURRENT      ; If no search order, search current
          .dword SEARCH_WORDLIST  ; compiler wordlist.
          EXIT
eword

; H: ( c-addr u -- xn...x1 t | f ) Environmental query.
dword     ENVIRONMENTQ,"ENVIRONMENT?"
          ENTER
          .dword dENVQ_WL
          .dword SEARCH_WORDLIST
          .dword DUP
          .dword _IF
          .dword nope
          .dword DROP
          .dword EXECUTE
          .dword TRUE        
nope:     EXIT
eword

; H: ( c-addr u -- xt true | c-addr u false ) Find word in search order.
dword     dFIND,"$FIND"
          ENTER
          .dword TWODUP
          .dword SEARCH_ALL
          .dword DUP
          .dword _IF
          .dword notfnd
          .dword DROP
          .dword NIPTWO
          .dword TRUE             ; IEEE 1275 requires true, not -1 or 1
notfnd:   EXIT
eword

; H: ( c-addr -- xt|0 ) Find packed string word in search order, 0 if not found.
dword     FIND,"FIND"
          ENTER
          .dword DUP
          .dword PtoR
          .dword COUNT
          .dword SEARCH_ALL
          .dword DUP
          .dword _IF
          .dword notfd
          .dword RDROP
          EXIT
notfd:    .dword RtoP
          .dword SWAP
          EXIT
eword

; H: ( [old-name< >] -- xt ) Parse old-name in input stream, return xt of word.
dword     PARSEFIND,"'"
          ENTER
          .dword PARSE_WORD
          .dword SEARCH_ALL
          .dword QDUP
          .dword _IF
          .dword exc
          .dword DROP
          EXIT
exc:      ONLIT -13
          .dword THROW
eword

; H: ( [old-name< >] -- xt ) Immediately parse old-name in input stream, return xt of word.
dword     CPARSEFIND,"[']",F_IMMED
          ENTER
          .dword PARSEFIND
          .dword LITERAL
          EXIT
eword

; H: ( xt -- a-addr) return body of word at xt, if unable then throw exception -31
dword     rBODY,">BODY"
          jsr   _popwr            ; xt -> wr
          ldy   #$01
          lda   [WR],y
          and   #$FF
          cmp   #opJSL
          beq   :+
          ldy   #.loword(-31)
          lda   #.hiword(-31)
          jmp   _throway
:         lda   WR
          clc
          adc   #$05
          tay
          lda   WR+2
          adc   #$00
          PUSHNEXT
eword

; H: ( a-addr -- xt ) return xt of word with body at a-addr, if unable throw exc. -31
dword     BODYr,"BODY>"
          ENTER
          ONLIT 1
          .dword CELLS
          .dword MINUS
          .dword DUP
          .dword CFETCH
          ONLIT opJSL
          .dword EQUAL
          .dword _IF
          .dword bad
          .dword DECR
          EXIT
bad:      ONLIT -31
          .dword THROW
eword

; ( a-addr -- xt ) from link field address, return xt of word
hword     drXT,"$>XT"
          ENTER
          .dword CELLPLUS
          .dword DUP
          .dword CFETCH
          ONLIT NAMEMSK
          .dword LAND
          .dword PLUS
          .dword CHARPLUS
          EXIT
eword

; ( xt -- xt f ) return immediacy of word at xt
hword     IMMEDQ,"IMMED?"
          jsr   _peekwr
          lda   [WR]          
          and   #F_IMMED
tf:       beq   :+
          lda   #$FFFF
:         tay
          PUSHNEXT
eword

; ( xt -- xt f ) return compile-only flag of word at xt
hword     CONLYQ,"CONLY?"
          jsr   _peekwr
          lda   [WR]
          and   #F_CONLY
          bra   IMMEDQ::tf
eword

; ( xt -- xt f ) return temp def flag of word at xt
; words with temp def flag will trigger a temporary definition to be created in order
; to run control-flow words in interpretation state
hword     TEMPDQ,"TEMPD?"
          jsr   _peekwr
          lda   [WR]
          and   #F_TEMPD
          bra   IMMEDQ::tf
eword

; needed by line editor
.proc     _key
          lda   #SI_KEY
          jsl   _call_sysif
          bcc   :+
          jmp   _throway
:         rts
.endproc

; H: ( -- char ) wait for input char, return it
dword     KEY,"KEY"
          jsr   _key
          NEXT
eword

; H: ( -- f ) f = true if input char is ready, false otherwise
dword     KEYQ,"KEY?"
          lda   #SI_KEYQ
          jsl   _call_sysif
          bcc   :+
          jmp   _throway
:         NEXT
eword

; ( -- a-addr ) variable with address of terminal input buffer
hword     dTIB,"$TIB"
          SYSVAR SV_dTIB
eword

; ( -- c-addr ) return address of terminal input buffer
hword     TIB,"TIB"
          ENTER
          .dword dTIB
          .dword FETCH
          EXIT
eword

; ( -- a-addr ) variable with address of current input buffer
hword     dCIB,"$CIB"
          SYSVAR SV_dCIB
eword

; ( -- u ) variable with number of characters accepted by EXPECT
dword     SPAN,"SPAN"
          SYSVAR SV_SPAN
eword

; TODO: add Open Firmware editing
; H: ( addr len -- u ) get input line of up to len chars, stor at addr, u = # chars accepted
dword     ACCEPT,"ACCEPT"
          clc
expect1:  ror   YR                ; if YR high bit set, do auto-termination mode
          jsr   _popxr
          jsr   _popwr
inline:   ldy   #$00              ; entered length
getchar:  phy
          jsr   _key
          jsr   _popay
          tya
          ply
          cmp   #c_bs             ; basic editing functions
          beq   backspc
          cmp   #c_del
          beq   backspc
          cmp   #c_cr
          beq   done
          cmp   #' '
          bcc   getchar           ; ignore nonprintables
          cpy   XR                ; if we are at max size already
          bcs   getchar           ; then don't accept this char
          sta   [WR],y
          phy
          tay
          jsr   do_emit
          ply
          iny
          cpy   XR
          bcc   getchar
checkexp: bit   YR                ; in EXPECT mode?
          bmi   done              ; yep, auto-terminate
          bra   getchar
backspc:  cpy   #$00              ; is line empty?
          beq   inline            ; just start over if so
          dey
          phy                     ; otherwise do backspace & erase
          ldy   #c_bs
          jsr   do_emit
          ldy   #' '
          jsr   do_emit
          ldy   #c_bs
          jsr   do_emit
          ply
          bra   getchar
done:     lda   #$00
          jsr   _pushay
          bit   YR
          bmi   expect2
          ENTER
          JUMP  docr
expect2:  ENTER
          .dword SPAN
          .dword STORE
docr:     .dword CR
          EXIT
do_emit:  jsr   _pushay
          jsr   _emit
          rts
eword          

; H: ( addr len -- ) get input line of up to len chars, stor at addr, actual len in SPAN
dword     EXPECT,"EXPECT"
          sec
          jmp   ACCEPT::expect1
eword

; ( -- ) set current input source to the keyboard/console
hword     SETKBD,"SETKBD"
          ENTER
          .dword TIB
          .dword dCIB
          .dword STORE
dokbd:    ONLIT 0
doany:    .dword dSOURCEID
          .dword STORE
          EXIT
eword

; H: ( -- a-addr ) variable containing current input source ID
dword     dSOURCEID,"$SOURCE-ID"
          SYSVAR SV_SOURCEID
eword

; H: ( -- n ) return current input source id (0 = console, -1 = string, >0 = file)
dword     SOURCEID,"SOURCE-ID"
          ldy   #SV_SOURCEID
          lda   [SYSVARS],y
          pha
          iny
          iny
          lda   [SYSVARS],y
          ply
          PUSHNEXT
eword

; H: ( -- c-addr u ) return address and length of input source buffer
dword     SOURCE,"SOURCE"
          ENTER
          .dword dCIB
          .dword FETCH
          .dword NIN
          .dword FETCH
          EXIT
eword

; H: ( -- f ) refill input buffer, f = true if that worked, false if not
dword     REFILL,"REFILL"
          ENTER
          .dword SOURCEID
          .dword DUP
          .dword _IFFALSE
          .dword notkbd           ; return false if input source isn't console
          .dword PIN              ; >IN, note zero is on the stack here
          .dword STORE
          .dword TIB
          ONLIT tib_size
          .dword ACCEPT
          .dword NIN              ; #IN
          .dword STORE
          .dword TRUE
          EXIT
notkbd:   .dword ZEROLT
          .dword _IFFALSE         ; is less than zero?
          .dword noinput          ; yes, go throw a false on the stack
          SLIT "$REFILL"          ; ( -- addr len true | false )
          .dword dFIND            ; see if someone else handles it
          .dword _IF              ; $REFILL exists?
          .dword noinput          ; nope, nobody handles it
          .dword EXECUTE          ; otherwise, execute it and see what happens
          .dword _IF              ; that work out OK?
          .dword noinput          ; nope, just return false 
          .dword ZERO             ; otherwise zero input pointer
          .dword PIN
          .dword STORE
          .dword NIN              ; set #IN to returned length
          .dword STORE
          .dword dCIB             ; make it the input buffer
          .dword STORE
          EXIT
noinput:  .dword FALSE
          EXIT
eword

; ( -- f ) f = true if there is remaining input in the input stream, false otherwise
hword     INQ,"IN?"
          ENTER
          .dword PIN
          .dword FETCH
          .dword NIN
          .dword FETCH
          .dword ULT
          EXIT
eword

; ( -- c-addr ) return address of next character in input stream
hword     INPTR,"INPTR"
          ENTER
          .dword PIN
          .dword FETCH
          .dword dCIB
          .dword FETCH
          .dword PLUS
          EXIT
eword

; ( -- ) increment >IN
hword     INC_INPTR,"INPTR+"
          ENTER
          .dword ONE
          .dword PIN
          .dword PSTORE
          EXIT
eword

; ( -- char ) fetch char from input stream
hword     GETCH,"GETCH"
          ENTER
          .dword INPTR
          .dword CFETCH
          .dword INC_INPTR
          EXIT
eword

hword     tSTATUS,">STATUS"
          ENTER
          SLIT "STATUS"
          .dword dFIND
          EXIT
eword

; ( -- ) call STATUS if defined, display OK (interpreting) or [OK] (compiling).
hword     dSTATUS,"$STATUS"
          ENTER
          .dword SOURCEID
          .dword ZEROQ
          .dword _IF
          .dword done             ; do nothing if console is not source
          .dword tSTATUS
          .dword _IF
          .dword nostatus
          .dword EXECUTE
          JUMP :+
nostatus: .dword TWODROP
:         .dword SPACE
          .dword _SMART
          .dword interp
          SLIT   "[OK]"
          JUMP  dprompt
interp:   SLIT   "OK"
dprompt:  .dword TYPE
          .dword CR
done:     EXIT
eword

; H: ( -- ) assuming STATUS is a defer, set it to .S
dword     SHOWSTACK,"SHOWSTACK"
          ENTER
          ONLIT DOTS
set:      .dword tSTATUS
          .dword _IF
          .dword nostatus
          .dword rBODY
          .dword STORE
          EXIT
nostatus: .dword THREEDROP
          EXIT
eword

; H: ( -- ) assuming STATUS is a defer, set it to NOOP
dword     NOSHOWSTACK,"NOSHOWSTACK"
          ENTER
          ONLIT NOOP
          JUMP SHOWSTACK::set
eword

; ( char -- ) see if char is a space (or unprintable)
hword     ISSPC,"ISSPACE?"
          ENTER
          .dword BL
          .dword INCR
          .dword ULT
          EXIT
eword

; H: ( [word< >] -- addr u ) Parse word from input stream, return address and length.
dword     PARSE_WORD,"PARSE-WORD"
          ENTER
l1:       .dword INQ              ; is there input?
          .dword _IF
          .dword none             ; nope, return empty
          .dword GETCH            ; get char
          .dword ISSPC            ; is space?
          .dword _IFFALSE         ; if not...
          .dword l1               ; do loop if it is
          .dword INPTR            ; get address
          .dword DECR             ; fixup because INPTR is 1 ahead now
          .dword ONE              ; we have 1 char
l2:       .dword INQ              ; more input?
          .dword _IF
          .dword e1               ; if not, exit
          .dword GETCH
          .dword ISSPC
          .dword _IFFALSE
          .dword e1               ; yes, stop
          .dword INCR             ; count non-spaces
          JUMP l2
e1:       EXIT
none:     .dword INPTR
          .dword ZERO
          EXIT
eword

; H: ( [word< >] -- addr u ) Alias of PARSE-WORD.
dword     PARSE_NAME,"PARSE-NAME"
          bra PARSE_WORD::code
eword

; H: ( char [text<char>] -- addr u ) Parse text from input stream, delimited by char.
dword     PARSE,"PARSE"
          ENTER
          .dword PtoR
          .dword INPTR
          .dword ZERO
l1:       .dword INQ
          .dword _IF
          .dword e1
          .dword GETCH
          .dword RCOPY
          .dword EQUAL
          .dword _IF
          .dword i1
e1:       .dword RDROP
          EXIT
i1:       .dword INCR
          JUMP l1
eword

; H: ( char [text<char>] -- addr ) Parse text from input stream delimited by char, return
; H: address of WORD buffer containing packed string.
dword     WORD,"WORD"
          ENTER
          .dword PARSE
          .dword DUP
          ONLIT word_buf_size
          .dword ULT
          .dword _IF
          .dword bad
          .dword WORDBUF
          .dword PACK
          EXIT
bad:      ONLIT -18
          .dword THROW
eword

; H: ( [word< >] -- char ) Parse word from input stream, return value of first char.
dword     CHAR,"CHAR"
          ENTER
do:       .dword PARSE_WORD
          .dword DROP
          .dword CFETCH
          EXIT
eword

; H: ( [word< >] -- char ) Immediately perform CHAR and compile literal.
dword     CCHAR,"[CHAR]",F_IMMED|F_CONLY
          ENTER
do:       .dword  CHAR
          .dword  LITERAL
          EXIT
eword

; H: ( [word< >] -- char ) Perform either CHAR or [CHAR] per the current compile state.
dword     ASCII,"ASCII",F_IMMED
          ENTER
          .dword _SMART
          .dword CHAR::do
          JUMP CCHAR::do
eword

; H: ( [text<)>] -- ) Parse and discard text until a right paren or end of input.
dword     LPAREN,"(",F_IMMED
          ENTER
          ONLIT ')'
          .dword PARSE
          .dword TWODROP
          EXIT
eword

; H: ( [text<)>] -- ) Parse text until a right paren or end of input, output text.
dword     DOTPAREN,".(",F_IMMED
          ENTER
          ONLIT ')'
          .dword PARSE
          .dword TYPE
          EXIT
eword

; Helper to compile a string
; ( addr u -- )
hword     CSTRING,"CSTRING"
          jsr   _2parm
          ldy   #.loword(docs-1)
          lda   #.hiword(docs-1)
          jsr   _str_op_ays
          NEXT
docs:     jsr   _cbytea
          clc
          rtl
eword

; H: Compiling: ( addr1 u -- ) compile string literal into current def
; H: Execution: ( -- addr2 u ) return compiled string
dword     SLITERAL,"SLITERAL",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT
          .dword _SLIT
          .dword DUP
          .dword COMPILECOMMA
          .dword CSTRING
          EXIT
eword

; H: ( [text<">] -- addr u )
dwordq    SQ,"S'",F_IMMED
          ENTER
          ONLIT '"'
          .dword PARSE
          .dword _SMART
          .dword interp
          .dword SLITERAL
          EXIT
interp:   .dword dTMPSTR
          EXIT
eword

; H: ( [text<">] -- ) Parse text and output.
dwordq    DOTQ,".'",F_IMMED
          ENTER
          .dword SQ
          .dword _SMART
          .dword interp
          .dword _COMP_LIT
interp:   .dword TYPE
          EXIT
eword

; parse paired hex digits until right paren
; return string in buffer created by alloc-mem
; H: ( [text<)>] -- addr u ) Parse hex digits, return in allocated string.
dword     dHEXP,"$HEX(",F_IMMED
          ENTER
          ONLIT 256
          .dword ALLOC
          ONLIT ')'
          .dword PARSE
          CODE
          jsr   _popxr            ; length of parsed string
          jsr   _popwr            ; address of parsed string
          jsr   _popyr            ; address of allocated buffer
          stz   XR+2              ; will count how many digits we have stuffed
          ldy   #$00              ; will count the source chars processed
lp:       cpy   XR
          beq   done
          sep   #SHORT_A
          lda   [WR],y
          rep   #SHORT_A
          and   #$FF
          jsr   _c_to_d
          bcc   next              ; invalid digit
          cmp   #$10
          bcs   next              ; bigger than a hex digit
          phy                     ; save index
          pha                     ; save digit
          lda   XR+2
          inc   XR+2
          lsr
          tay
          pla
          bcc   store             ; even digits (from 0) just need to store
odd:      sep   #SHORT_A          ; odd digits shift into the low nibble
          asl                     ; C 000d => 00d0
          asl
          asl
          asl
          xba                     ; C 00d0 => d000
          lda   [YR],y            ; C d000 => d00e
          xba                     ; C d00e => 0ed0
          rep   #SHORT_A
          lsr
          lsr
          lsr
          lsr
store:    sep   #SHORT_A
          sta   [YR],y
          rep   #SHORT_A
          ply                     ; get counter back
next:     iny
          bra   lp
done:     ldy   YR
          lda   YR+2
          jsr   _pushay
          lda   XR+2              ; # of digits
          lsr                     ; convert to # chars
          adc   #$00              ; if odd, round up
          tay
          lda   #$00
          PUSHNEXT
eword

; ( addr1 u1 addr2 u2 -- addr1 u1+u2 )  Concatenate strings.
; addr1 is assumed to have enough room for the string
hword     SCONCAT,"SCONCAT"
          jsr   _4parm
          lda   STACKBASE+12,x    ; get c-addr1+u1 to YR
          clc
          adc   STACKBASE+8,x
          sta   YR
          lda   STACKBASE+14,x
          adc   STACKBASE+10,x
          sta   YR+2
          jsr   _popxr            ; u2 to xr
          jsr   _popwr            ; c-addr2 to WR
          lda   XR
          clc
          adc   STACKBASE+0,x     ; make u1+u2
          sta   STACKBASE+0,x
          lda   XR+2
          adc   STACKBASE+2,x
          sta   STACKBASE+2,x
          sec                     ; move down is faster
          jsr   _memmove_c        ; move the string
          NEXT
eword

; H: ( [text<">] -- c-addr u ) Parse text in input buffer, copy to allocated string.
dwordq    ASTR,"A'"
          ENTER
          ONLIT '"'
          .dword PARSE
          .dword DUP
          .dword ALLOC
          .dword ZERO
          .dword TWOSWAP
          .dword SCONCAT
          EXIT
eword

; H: ( addr1 u1 addr2 u2 -- addr3 u1+u2 ) Concatenate allocated strings,
; H: freeing the originals.
; Concatenate two strings that are in memory returned by ALLOC-MEM
; returning a string allocated via ALLOC-MEM and the original strings
; freed via FREE-MEM
dword     ACONCAT,"ACONCAT"
          ENTER
          .dword TWOPtoR          ; ( c-addr1 u1 c-addr2 u2 -- c-addr u1 ) save second string
          .dword DUP              ; ( ... c-addr1 u1 u1' ) copy u1
          .dword RCOPY            ; ( ... c-addr1 u1 u1' u2' ) get a copy of u2
          .dword PLUS             ; ( ... c-addr1 u1 u3 )sum them to get u1+u2
          .dword ALLOC            ; ( ... c-addr1 u1 c-addr3 ) allocate that many
          ONLIT 0                 ; ( ... c-addr1 u1 c-addr3 0 ) say it's zero length
          .dword TWOSWAP          ; ( ... c-addr3 0 c-addr1 u1 ) put it at the front
          .dword OVER             ; ( ... c-addr3 0 c-addr1 u1 c-addr1' )copy c-addr1
          .dword PtoR             ; ( ... c-addr3 0 c-addr1 u1 ) save for FREE-MEM
          .dword SCONCAT          ; ( ... c-addr3 u1 ) copy first string
          .dword RtoP             ; ( ... c-addr3 u1 c-addr1 )
          ONLIT 0
          .dword FREE             ; ( ... c-addr3 u1 ) free it
          .dword TWORtoP          ; ( ... c-addr3 u1 c-addr2 u2 )
          .dword OVER             ; ( ... c-addr3 u1 c-addr2 u2 c-addr2' )
          .dword PtoR             ; ( ... c-addr3 u1 c-addr2 u2 )
          .dword SCONCAT          ; ( ... c-addr3 u1+u2 )
          .dword RtoP             ; ( ... c-addr3 u1+u2 c-addr2 )
          ONLIT 0
          .dword FREE             ; ( ... c-addr3 u1+u2 )
          EXIT
eword

; H: Compiling: ( [text<">] -- ) Parse string, including IEEE 1275-1994 hex interpolation.
; H: Execution: ( -- addr u ) Return parsed string.
dwordq    QUOTE,"'",F_IMMED
          ENTER
          .dword ZERO             ; ( -- 0 )
          .dword ALLOC            ; ( 0 -- c-addr1 ) empty allocation
          .dword ZERO             ; ( c-addr1 -- c-addr1 0 )
moretext: .dword ASTR             ; ( c-addr1 u1 -- c-addr1 u1 c-addr2 u2 )
          .dword ACONCAT          ; ( ... c-addr3 u3 )
          .dword INQ              ; ( ... c-addr3 u3 f )
          .dword _IF              ; ( ... c-addr3 u3 )
          .dword finish           ; no more text to parse, finish up
          .dword GETCH            ; ( ... c-addr3 u3 c )
          .dword DUP              ; ( ... c-addr3 u3 c c' )
          .dword ISSPC            ; ( ... c-addr3 u3 c f )
          .dword _IFFALSE         ; ( ... c-addr3 u3 c )
          .dword space            ; is a space, drop space and return string
          ONLIT '('               ; ( ... c-addr3 u3 c '(' )
          .dword EQUAL            ; ( ... c-addr3 u3 f )
          .dword _IF              ; ( ... c-addr3 u3 )
          .dword finish           ; finish, but we will probably error later in parsing
          .dword dHEXP            ; ( ... c-addr3 u3 c-addr4 u4 )
          .dword ACONCAT          ; ( ... c-addr5 u5 )
          JUMP moretext           ; and switch back to parsing quoted string
space:    .dword DROP
finish:   .dword OVER             ; ( c-addr3 u3 -- c-addr3 u3 c-addr3' )
          .dword PtoR             ; ( ... c-addr3 u3 ) ( R: -- c-addr3' )
          .dword _SMART
          .dword interp
          .dword SLITERAL         ; ( c-addr3 u3 -- )
          JUMP  done
interp:   .dword dTMPSTR
done:     .dword RtoP             ; ( -- c-addr3' ) ( R: c-addr3' -- )
          ONLIT 0
          .dword FREE             ; ( c-addr3' -- )
          EXIT
eword

; H: ( -- ) Compile code to compile the immediately following word which must resolve to an xt.
; H: Better to use POSTPONE in most cases.
dword     COMPILE,"COMPILE",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT        ; Compile a _COMP_LIT
          .dword _COMP_LIT
          EXIT
eword

; H: ( [name< >] -- ) Compile name now.  Better to use POSTPONE.
dword     ICOMPILE,"[COMPILE]",F_IMMED
          ENTER
          .dword PARSEFIND
          .dword COMPILECOMMA
          EXIT
eword

; H: ( [name< >] -- ) Compile the compilation semantics of name.
; Basically, if the word is immediate, compile its xt
; If not, compile code that compiles its xt
dword     POSTPONE,"POSTPONE",F_IMMED
          ENTER
          .dword PARSE_WORD
          .dword SEARCH_ALL
          .dword QDUP
          .dword _IF
          .dword exc
          .dword ZEROLT
          .dword _IF
          .dword immed            ; if >0, it is an IMMEDIATE word, go compile xt
          .dword LITERAL          ; compile its xt as a literal
          .dword _COMP_LIT        ; and compile COMPILE,
immed:    .dword COMPILECOMMA
          EXIT
exc:      ONLIT -13
          .dword THROW
eword

; H: ( -- ) Output the words in the CONTEXT wordlist.
dword     WORDS,"WORDS"
          ENTER
          .dword CONTEXT
          .dword FETCH
lp:       .dword DUP              ; ( h -- h h )
          .dword _IF              ; ( h h -- h ) 
          .dword done
          .dword DUP              ; ( h -- h h )
          .dword drXT             ; ( h -- h xt )
          .dword DUP              ; ( h xt -- h xt xt )
          .dword UDOT             ; ( h xt xt -- h xt )
          .dword rNAME            ; ( h xt -- h c-addr u )
          .dword TYPE             ; ( h c-addr u -- h )
          .dword CR
          .dword EXITQ            ; ( h -- h f )
          .dword _IFFALSE
          .dword done
          .dword FETCH            ; ( h -- h' )
          JUMP lp
done:     .dword DROP             ; ( h -- )
          EXIT
eword

.if include_see
; H: ( xt -- ) Attempt to decompile the word at xt.
dword     dSEE,"(SEE)"
          ENTER
          .dword QDUP
          .dword _IF
          .dword notxt
          SLIT "Flags: "          ; ( xt -- xt str len )
          .dword TYPE             ; ( str len -- )
          .dword DUP              ; ( xt -- xt xt' )
          .dword CFETCH           ; ( xt xt' -- xt u )
          .dword UDOT             ; ( xt u -- xt )
          .dword CR
          .dword DUP              ; ( xt -- xt xt' )
          .dword rNAME            ; ( xt xt' -- xt str len )
          .dword ROT              ; ( xt str len -- str len xt )
          .dword INCR             ; ( str len xt -- str len a-addr )
          .dword DUP              ; ( ... str len a-addr a-addr' )
          .dword FETCH            ; ( ... str len a-addr u )
          ONLIT (_enter << 8)+opJSL ; ( ... str len a-addr u x )
          .dword EQUAL            ; ( ... str len a-addr f )
          .dword _IF              ; ( ... str len a-addr )
          .dword cant
          ONLIT ':'               ; ( ... str len a-addr ':' )
          .dword EMIT             ; ( ... str len a-addr )
          .dword SPACE
          .dword NROT             ; ( ... a-addr str len )
          .dword TYPE             ; ( ... a-addr )
          .dword CR
lp:       .dword CELLPLUS         ; ( a-addr(old) -- a-addr )
          .dword DUP              ; ( ... a-addr a-addr' )
          .dword FETCH            ; ( ... a-addr u )
          ONLIT _exit_next-1
          .dword _IFEQUAL
          .dword :+
          .dword DROP
          ONLIT ';'
          .dword EMIT
quit:     .dword DROP
notxt:    EXIT
:         .dword OVER             ; ( ... a-addr u a-addr' )
          .dword UDOT             ; ( ... a-addr u )
          ONLIT _LIT
          .dword _IFEQUAL
          .dword :+
          .dword DROP
          .dword CELLPLUS
          .dword DUP
          .dword FETCH
          .dword DOT
          JUMP crlp
:         ONLIT _WLIT
          .dword _IFEQUAL
          .dword :+
          .dword DROP
          .dword CELLPLUS
          .dword DUP
          .dword WFETCH
          .dword DOT
          .dword TWODECR
          JUMP crlp
:         ONLIT _CLIT
          .dword _IFEQUAL
          .dword :+
          .dword DROP
          .dword CELLPLUS
          .dword DUP
          .dword CFETCH
          .dword DOT
          .dword THREE
          .dword MINUS
          JUMP crlp
:         ONLIT _SLIT
          .dword _IFEQUAL
          .dword :+
          .dword DROP             ; ( ... a-addr )             
          .dword CELLPLUS         ; skip _SLIT
          .dword DUP
          .dword FETCH            ; ( ... a-addr len ) get length of string
          .dword SWAP             ; ( ... len a-addr )
          ;.dword CELLPLUS         ; ( ... len a-addr )
          .dword TWODUP           ; ( ... len a-addr len a-addr )
          .dword CELLPLUS
          .dword SWAP             ; ( ... len a-addr a-addr len )
          ONLIT '"'
          .dword EMIT
          .dword TYPE             ; ( ... len a-addr )
          ONLIT '"'
          .dword EMIT
          .dword PLUS
          JUMP crlp
:         .dword rNAME            ; ( ... a-addr str len )
          .dword TYPE             ; ( ... a-addr )
crlp:     .dword CR
          .dword EXITQ            ; ( ... a-addr f )
          .dword _IFFALSE         ; ( ... a-addr )
          .dword quit
          JUMP lp
cant:     .dword DROP             ; drop pointer
          SLIT "Can't see "
          .dword TYPE
          .dword TYPE
          EXIT
eword

; H: ( [text< >] -- ) Attempt to decompile name.
dword     SEE,"SEE"
          ENTER
          .dword PARSEFIND
          .dword dSEE
          EXIT
eword
.endif

; H: ( addr u -- ) Like CREATE but use addr u for name.
dword     dCREATE,"$CREATE"
          jsr   _mkentry
docreate: ldy   #.loword(_pushda)
          lda   #.hiword(_pushda)
          jsr   _cjsl
          NEXT
eword

; H: ( [name< >] -- ) Create a definition, when executed pushes the body address.
dword     CREATE,"CREATE"
          ENTER
          .dword PARSE_WORD
          .dword dCREATE
          EXIT
eword

; H: ( [name< >] -- ) Execute CREATE name and allocate one cell, initially a zero.
dword     VARIABLE,"VARIABLE"
          ENTER
          .dword CREATE
          .dword ZERO
          .dword COMMA
          EXIT
eword

; action of DOES
; modify the most recent definition (CREATED) to jsl to the address immediately
; following whoever JSLed to this and return to caller
.proc     _does
          ENTER
          .dword LAST
          .dword drXT
          .dword INCR
          CODE
          jsr   _popyr                    
          pla
          sta   WR
          sep   #SHORT_A
          pla
          rep   #SHORT_A
          and   #$00FF
          sta   WR+2
          jsr   _incwr
          ldy   #$00
          lda   [YR],y
          and   #$00FF
          cmp   #opJSL
          bne   csmm
          lda   WR
          iny
          sta   [YR],y
          lda   WR+2
          iny
          iny
          sep   #SHORT_A
          sta   [YR],y
          rep   #SHORT_A
          NEXT
csmm:     jmp   _CONTROL_MM::code
.endproc

; H: ( -- ) alter execution semantics of most recently-created definition to
; H: perform the execution semantics of the code following DOES>.
dword     DOES,"DOES>",F_IMMED|F_CONLY
          ENTER
          .dword SEMIS
          .dword _COMP_LIT
          jsl f:_does               ; better be 4 bytes!
          .dword _COMP_LIT
          ENTER                     ; not really, now
          .dword _COMP_LIT
          .dword RPLUCKADDR
          .dword _COMP_LIT
          .dword INCR
          .dword STATEC             ; ensure still in compiling state
          EXIT
eword

; ( -- ) throw exception -13
hword     dUNDEFERRED,"$UNDEFERRED"
          ldy   #.loword(-13)
          lda   #.hiword(-13)
          jmp   _throway
eword

; ( xt addr u -- ) Create a deferred word with xt as its initial behavior.
hword     dDEFER,"$DEFER"
          jsr   _3parm
          jsr   _mkentry
dodefer:  ldy   #.loword(_deferred)
          lda   #.hiword(_deferred)
          jsr   _cjsl
          jsr   _popay
          jsr   _ccellay
          NEXT
eword

; H: ( [name< >] -- ) Create definition that executes the first word of the body as an xt.
dword     DEFER,"DEFER"
          ENTER
          NLIT dUNDEFERRED
          .dword PARSE_WORD
          .dword dDEFER
          EXIT
eword

; H: ( xt -- ) Return the first cell of the body of word at xt, normally a DEFER word
; H: but will do the same on some other types of words (CREATE, VARIABLE, VALUE, etc).
dword     BEHAVIOR,"BEHAVIOR"
          ENTER
          .dword  rBODY
          .dword  FETCH
          EXIT
eword

; H: ( addr u xt -- ) Create a DEFER definition for string with xt as its initial behavior.
dword     IS_USER_WORD,"(IS-USER-WORD)"
          ENTER
          .dword NROT             ; reorder for $DEFER
          .dword dDEFER
          EXIT
eword

; H: ( n addr u -- ) Create a definition that pushes the first cell of the body, initially n.
dword     dVALUE,"$VALUE"
          jsr   _3parm            ; avoid dictionary corruption from stack underflow
          jsr   _mkentry
dovalue:  ldy   #.loword(_pushvalue)
          lda   #.hiword(_pushvalue)
          jsr   _cjsl
          jsr   _popay
          jsr   _ccellay
          NEXT
eword

; H: ( n1 n2 addr u -- ) Create a definition that pushes the first two cells of the body.
; H: initially n1 and n2
dword     dTWOVALUE,"$2VALUE"
          jsr   _4parm            ; avoid dictionary corruption from stack underflow
          jsr   _mkentry
          ldy   #.loword(_push2value)
          lda   #.hiword(_push2value)
          jsr   _cjsl
          jsr   _popay
          jsr   _ccellay
          jsr   _popay
          jsr   _ccellay
          NEXT
eword

; H: ( n [name< >] -- ) Create a definition that pushes n on the stack,
; H:  n can be changed with TO.
dword     VALUE,"VALUE"
          ENTER
          .dword PARSE_WORD
          .dword dVALUE
          EXIT
eword

; H: ( n [name< >] -- ) Allocate n bytes of memory, create definition that
; H: returns the address of the allocated memory.
dword     BUFFERC,"BUFFER:"
          ENTER
          .dword ALLOC
          .dword VALUE
          EXIT
eword

; H: ( n [name< >] -- ) alias of VALUE, OF816 doesn't have true constants
; we don't have real constants, they can be modified with TO
dword     CONSTANT,"CONSTANT"
          bra   VALUE::code
eword

; FCode support, these are needed to support the INSTANCE feature when it is installed
; and so are included in the main dictionary.  By default the FCodes for b(value),
; b(buffer), b(variable), and b(defer) point to these.  When the INSTANCE feature
; is installed, it will call set-token to replace these, but will still need to call them
; in the case that INSTANCE was not used.
.if include_fcode
; ( -- ) compile the machine execution semantics of CREATE (jsl _pushda)
hword     pCREATE,"%CREATE" ; noindex
          jmp   dCREATE::docreate
eword

; H: ( n -- ) Compile the machine execution semantics of VALUE (jsl _pushvalue)
; H: and the value.
dword     pVALUE,"%VALUE" ; noindex
          jsr   _1parm
          jmp   dVALUE::dovalue
eword

; H: ( addr -- ) Compile the machine execution semantics of BUFFER (jsl _pushvalue)
; H: and the buffer address.
dword     pBUFFER,"%BUFFER" ; noindex
          ENTER
          .dword ALLOC
          .dword pVALUE
          EXIT
eword

; H: ( -- ) Compile the machine execution semantics of CREATE (jsl _pushda)
; H: and compile a zero.
dword     pVARIABLE,"%VARIABLE" ; noindex
          ENTER
          .dword pCREATE
          .dword ZERO
          .dword COMMA
          EXIT
eword

; H: ( -- ) Compile the machine execution semantics of DEFER (jsl _deferred).
dword     pDEFER,"%DEFER" ; noindex
          ldy   #.loword(dUNDEFERRED)
          lda   #.hiword(dUNDEFERRED)
          jsr   _pushay
          jmp   dDEFER::dodefer
eword
.endif

; H: ( n1 n2 [name< >] -- ) Create name, name does ( -- n1 n2 ) when executed.
dword     TWOCONSTANT,"2CONSTANT"
          ENTER
          .dword PARSE_WORD
          .dword dTWOVALUE
          EXIT
eword

; H: ( [name1< >] [name2< >] -- ) create name1, name1 is a synonym for name2
dword     ALIAS,"ALIAS"
          ENTER
          .dword PARSE_WORD
          .dword PARSEFIND
          .dword INCR
          .dword NROT
          CODE
          jsr   _mkentry
          jsr   _popay
          jsr   _cjml
          NEXT
eword

; ( n xt -- ) change the first cell of the body of xt to n
hword     _TO,"_TO"
          ENTER
          .dword rBODY
          .dword STORE
          EXIT
eword

; H: ( n [name< >] -- ) Change the first cell of the body of xt to n.  Can be used on
; H: most words created with CREATE, DEFER, VALUE, etc. (even VARIABLE).
dword     TO,"TO",F_IMMED
          ENTER
          .dword PARSEFIND
doto:     .dword _SMART
          .dword setval
          .dword LITERAL
          .dword _COMP_LIT
setval:   .dword _TO
          EXIT
eword

; H: ( -- 0 )
dword     STRUCT,"STRUCT"
          lda   #$0000
          tay
          PUSHNEXT
eword

; ( offset size addr u -- offset+size ) create word specified by addr u with
; execution semantics: ( addr -- addr+offset)
hword     dFIELD,"$FIELD"
          jsr   _4parm
          jsr   _mkentry
dofield:  ldy   #.loword(_field)
          lda   #.hiword(_field)
          jsr   _cjsl
          ldy   STACKBASE+4,x
          lda   STACKBASE+6,x
          jsr   _ccellay
          lda   STACKBASE+0,x
          clc
          adc   STACKBASE+4,x
          sta   STACKBASE+4,x
          lda   STACKBASE+2,x
          adc   STACKBASE+6,x
          sta   STACKBASE+6,x
          jsr   _stackincr
          NEXT
eword

; H: Compilation: ( offset size [name< >] -- offset+size ) create name
; H: Execution of name: ( addr -- addr+offset)
dword     FIELD,"FIELD"
          ENTER
          .dword PARSE_WORD
          .dword dFIELD
          EXIT
eword

; ( str len -- xt ) define word with empty execution semantics
hword     dDEFWORD,"$DEFWORD"
          ldy   #SV_OLDHERE
          lda   DHERE
          sta   [SYSVARS],y
          iny
          iny
          lda   DHERE+2
          sta   [SYSVARS],y
          jsr   _mkentry
          jsr   _pushay           ; flags/XT
          NEXT
eword

; ( -- ) compile colon definition execution semantics (JSL _enter)
hword     dCOLON,"$COLON"
          ldy   #.loword(_enter)
          lda   #.hiword(_enter)
          jsr   _cjsl
          NEXT          
eword

; ( xt -- ) hide visibility of definition at xt
hword     SMUDGE,"SMUDGE"
          ENTER
          .dword DUP              ; dup XT (flags addr)
          .dword CFETCH           ; so we can smudge it
          ONLIT F_SMUDG
          .dword LOR
          .dword SWAP
          .dword CSTORE
          EXIT
eword

; H: ( [name< >] -- colon-sys ) Parse name, start colon definition and enter compiling state.
dword     COLON,":"
          ENTER
          .dword PARSE_WORD
          .dword dDEFWORD
          .dword dCOLON
          .dword DUP              ; one for setting flags, one for colon-sys
          .dword SMUDGE
          .dword DUP              ; and one for RECURSE
          .dword dCURDEF
          .dword STORE
          .dword STATEC
          EXIT
eword

; H: ( -- colon-sys ) Create an anonymous colon definition and enter compiling state.
; H: The xt of the anonymous definition is left on the stack after ;.
dword     NONAME,":NONAME"
          ENTER
          ONLIT $80               ; name length is 0 for noname
          .dword CCOMMA
          .dword HERE             ; XT/flags
          .dword DUP              ; one for user, one for colon-sys
          .dword DUP              ; and one for RECURSE
          .dword dCURDEF
          .dword STORE          
          ONLIT $00               ; noname flags
          .dword CCOMMA
          .dword STATEC
          .dword dCOLON
          EXIT
eword

; H: ( -- colon-sys ) Create a temporary anonymous colon definition and enter
; H: compiling state.  The temporary definition is executed immediately after ;.
; word supporting temporary colon definitions to implement IEEE 1275
; words that are extended to run in interpretation state
dword     dTEMPCOLON,":TEMP"
          ENTER
          ;SLIT "Starting temp def... "
          ;.dword TYPE
          ONLIT max_tempdef       ; allocate 128 cells worth of tempdef
          .dword ALLOC
          .dword DUP
          .dword dTMPDEF          ; and save its allocation
          .dword STORE
          .dword HERE             ; save HERE
          .dword dSAVEHERE
          .dword STORE
          .dword toHERE           ; and then set it to the temp def allocation
          .dword NONAME           ; start anonymous definition
          .dword DEPTH            ; save stack depth (data stack is control stack)
          .dword dCSDEPTH
          .dword STORE
done:     EXIT
eword

; word to end temporary colon definition and run it
; called whenever control-flow-ending words are executed
; and a temporary definition is open
; ( xt xt' -- ) 
hword     dTEMPSEMIQ,"$;TEMP?",F_IMMED|F_CONLY
          ENTER
          .dword dTMPDEF          ; ( -- a-addr ) first see if we are in a temp def
          .dword FETCH            ; ( a-addr -- x ) 0 if not in temp def
          .dword _IF              ; ( x -- )
          .dword notmp            ; if not in temp def
dosemi:   .dword DEPTH            ; ( -- u1 ) next see if the stack depth matches
          .dword dCSDEPTH         ; ( u1 -- u1 c-addr1 ) verify stack depth is what it should be
          .dword FETCH            ; ( u1 c-addr1 -- u1 u2 )
          .dword ULTE             ; ( u1 u2 -- f ) is less than or equal to?
          .dword _IFFALSE         ; ( f -- )
          .dword tmpdone          ; true branch, finish up temp def
notmp:    EXIT
tmpdone:  ;SLIT "Ending temp def... "
          ;.dword TYPE
          .dword DEPTH            ; ( -- u1 )
          .dword dCSDEPTH         ; ( u1 -- u1 c-addr1 ) verify stack depth is what it should be
          .dword FETCH            ; ( u1 c-addr1 -- u1 u2 )
          ;.dword DOTS
          .dword EQUAL            ; ( u1 u2 -- f )
          .dword _IF              ; ( f -- )
          .dword csmm             ; if not, we have a problem
          .dword _COMP_LIT        ; compile EXIT into temporary def
          EXIT                    ; NOTE: not really EXITing here
          .dword STATEI           ; ( -- )
          .dword dSAVEHERE        ; ( -- a-addr ) restore HERE
          .dword FETCH            ; ( a-addr -- c-addr )
          .dword toHERE           ; ( c-addr -- )
          .dword dTMPDEF          ; ( -- a-addr ) get location of temporary definition
          .dword DUP              ; ( -- a-addr a-addr' ) one for FREE, one to write zero into it
          .dword FETCH            ; ( a-addr a-addr' -- a-addr c-addr )
          .dword PtoR             ; ( a-addr c-addr -- a-addr ) ( R: -- c-addr ) safe for FREE
          .dword OFF              ; ( a-addr -- ) zero $TEMPDEF
          .dword DROP             ; ( xt xt -- xt ) now we worry about ( xt xt ) consume colon-sys
          .dword CATCH            ; ( xt -- * r ) execute the temporary definition within catch
          .dword RtoP             ; ( r -- r c-addr ) ( R: c-addr -- )
dofree:    ONLIT max_tempdef      ; ( r c-addr -- r c-addr u )
          .dword FREE             ; ( r c-addr u -- r )
          .dword THROW            ; ( r -- ) re-throw any error in temp def
          EXIT                    ; this really is an exit
csmm:     .dword STATEI           ; ( -- )
          .dword dSAVEHERE        ; ( -- a-addr ) restore HERE
          .dword FETCH            ; ( a-addr -- c-addr )
          .dword toHERE           ; ( c-addr -- )
          ONLIT -22               ; ( -- -22 ) will be thrown
          .dword dTMPDEF          ; ( -22 -- -22 c-addr )
          JUMP dofree             ; note that thrown error will clean up dTMPDEF
eword

; ( xt -- ) make definition at xt visible
hword     UNSMUDGE,"UNSMUDGE"
          ENTER
          .dword DUP              ; dup XT (flags addr)
          .dword CFETCH           ; so we can unsmudge it
          ONLIT F_SMUDG
          .dword INVERT
          .dword LAND
          .dword SWAP
          .dword CSTORE
          EXIT
eword

; H: ( colon-sys -- ) Consume colon-sys and enter interpretation state, ending the current
; H: definition.  If the definition was temporary, execute it.
dword     SEMI,";",F_IMMED|F_CONLY
          ENTER
          .dword dTMPDEF          ; see if it's a temporary definition
          .dword FETCH
          .dword _IF
          .dword :+
          .dword dTEMPSEMIQ       ; if it is, do that instead
          EXIT
:         .dword _COMP_LIT        ; compile EXIT into current def
          EXIT                    ; NOTE: not really EXITing here
dosemi:   .dword UNSMUDGE         ; consume colon-sys
          .dword STATEI           ; exit compilation state
          ONLIT 0
          .dword dOLDHERE
          .dword STORE
          EXIT
eword

; H: ( -- ) Make the current definition findable during compilation.
dword     RECURSIVE,"RECURSIVE",F_IMMED|F_CONLY
          ENTER
          .dword dCURDEF
          .dword FETCH
          .dword UNSMUDGE
          EXIT
eword

; H: ( -- ) Compile the execution semantics of the most current definition.
dword     RECURSE,"RECURSE",F_IMMED|F_CONLY
          ENTER
          .dword dCURDEF
          .dword FETCH
          .dword COMPILECOMMA
          EXIT
eword

; H: ( [name< >] -- code-sys ) Create a new CODE definiion.
; TODO: activate ASSEMBLER words if available
dword     CODEDEF,"CODE"
          ENTER
          .dword PARSE_WORD
          .dword dDEFWORD
docode:   .dword DUP              ; one for setting flags, one for colon-sys
          .dword SMUDGE
          ; .dword STATEC
          EXIT
eword

; H: ( [name< >] -- code-sys ) Create a new LABEL definition.
dword     LABEL,"LABEL"
          ENTER
          .dword PARSE_WORD
          .dword dCREATE
          .dword  LAST
          .dword  drXT
          JUMP CODEDEF::docode
eword

; H: ( code-sys -- ) Consume code-sys, end CODE or LABEL definition.
dword     CSEMI,"C;"
          jsr   _1parm
          ldy   #.loword(_next)
          lda   #.hiword(_next)
          jsr   _cjml          
          ENTER
          JUMP SEMI::dosemi
eword

; H: ( code-sys -- ) Synonym for C;.
dword     ENDCODE,"END-CODE",F_IMMED|F_CONLY
          bra   CSEMI::code
eword

; ( xt -- ) Mark XT as immediate.
hword     dIMMEDIATE,"$IMMEDIATE"
          ENTER
          .dword DUP              ; dup XT (flags addr)
          .dword CFETCH
          ONLIT F_IMMED
          .dword LOR
          .dword SWAP
          .dword CSTORE
          EXIT
eword

; H: ( -- ) Mark last compiled word as an immediate word.
dword     IMMEDIATE,"IMMEDIATE"
          ENTER
          .dword LAST
          .dword drXT
          .dword dIMMEDIATE          
          EXIT
eword

; ( xt -- ) Mark word at xt as protected (from FORGET, not MARKER).
hword     dPROTECTED,"$PROTECTED"
          ENTER
          .dword DUP              ; dup XT (flags addr)
          .dword CFETCH
          ONLIT F_PROT
          .dword LOR
          .dword SWAP
          .dword CSTORE
          EXIT
eword

; ( -- ) Mark last created word as protected (from FORGET, not MARKER).
hword     PROTECTED,"PROTECTED"
          ENTER
          .dword LAST
          .dword drXT
          .dword dPROTECTED       
          EXIT
eword

; ( -- ) for DOES> and ;CODE
hword     SEMIS,"SEMIS"
          ENTER
          .dword _COMP_LIT
          CODE                    ; not really, see NOTE above
          .dword  RECURSIVE       ; allow word to be found
          EXIT
eword

; TODO attempt to activate assembler package
; H: ( -- ) End compiler mode, begin machine code section of definition.
dword     SCODE,";CODE",F_IMMED|F_CONLY
          bra SEMIS::code
eword

.if 0
; ANS Forth locals - half-baked and not usable yet

; ( u -- ) ( R: -- old_locals_ptr u*0 u2 )
; u2 = old SP after 
hword     dCREATE_LOCALS,"$CREATE-LOCALS"
          lda   locals_ptr        ; current locals pointer (in stack)
          pha                     ; save it
          tsc                     ; current stack pointer (for fast cleanup)
          sta   WR                ; save for now
          jsr   _popay            ; get number of locals
          lda   #$0000            ; gonna zero them all out
lp:       dey
          bmi   done
          pha                     ; for each local, throw a cell on the stack
          pha
          bra   lp
done:     tsc                     ; now set up locals pointer to new block of locals
          inc   a                 ; 'cause '02 stack ptr is at the free byte
          sta   locals_ptr
          lda   WR
          pha
          NEXT
eword

; ( u -- ) ( R: u*n -- )
hword     dDESTROY_LOCALS,"$DESTROY-LOCALS"
          pla                     ; this is the old SP after saved locals poubter
          tcs                     ; restore return stack
          pla                     ; get old locals pointer
          sta   locals_ptr        ; and make it current
eword


; ( u -- ) common routine to set up WR and Y register to access a local by number
.proc     _localcom
          lda   locals_ptr        ; get current locals pointer
          sta   WR                ; set up WR to point to it
          stz   WR+2
          jsr   _popay            ; get local number
          tya                     ; and compute offset into locals
          asl
          tay
          rts
.endproc

; ( u -- n ) fetch from local
hword     dLOCALFETCH,"$LOCAL@"
          jsr   _localcom         ; set up WR and Y reg
          lda   [WR],y            ; low byte
          pha                     ; save for now
          iny                     ; move to high byte
          iny
          lda   [WR],y            ; get it
          ply                     ; get low byte back
          PUSHNEXT                ; and toss on stack
eword

; ( n u -- )
hword     dLOCALSTORE,"$LOCAL!"
          jsr   _swap             ; get value to top
          jsr   _popay            ; and put on return stack for now
          pha
          phy
          jsr   _localcom         ; set up WR and Y reg
          pla                     ; get low byte of value back
          sta   [WR],y            ; store it
          iny                     ; move to high byte
          iny
          pla                     ; get it back
          sta   [WR],y            ; and store
          NEXT
eword

.endif

.if enable_quotations
; Quotations enable syntax as follows:
; during compilation: [: ( -- quot-sys ) ... ;] ( quot-sys -- ) define a quotation
; (anonymous def within a definition)
; run time: ( -- xt ) leave xt of the quotation on the stack
; note that SEE cannot decode words with quotations.
; This implementation skips the quotation with AHEAD and afterwards leaves the
; the xt on the stack.
; quot-sys is ( -- old-$CURDEF forward-ref xt )
; H: Compilation: ( -- quot-sys ) Start a quotation.
; H: Execution: ( -- ) Skip over quotation code.
dword     SQUOT,"[:",F_IMMED|F_CONLY
          ENTER
          .dword dCURDEF          ; fix current def to quotation
          .dword FETCH            ; save current def for RECURSE
          .dword AHEAD            ; leaves address to resolve later
          .dword NONAME           ; start an anonymous definition
          .dword DROP             ; leave only one copy
          EXIT
eword

; H: Compilation: ( quot-sys -- ) End a quotation.
; H: Execution: ( -- xt )  Leave xt of the quotation on the stack.
dword     EQUOT,";]",F_IMMED|F_CONLY
          ENTER
          .dword _COMP_LIT        ; compile EXIT into current def
          EXIT                    ; NOTE: not really EXITing here
          .dword SWAP             ; put ahead target on top
          .dword THEN             ; resolve AHEAD
          .dword LITERAL          ; consume XT of word, place on stack at run-time
          .dword dCURDEF          ; restore current def to parent
          .dword STORE            ; and consume that
          EXIT
eword
.endif


.if max_search_order > 0

; ( -- wid )
; ( root -- wid ) create a wordlist rooted at root
hword     dCREATE_WL,"$CREATE-WL"
          ENTER
          .dword HERE             ; WID
          .dword SWAP
          .dword COMMA            ; compile pointer to root
          .dword _COMP_LIT
          .dword 0                ; pointer to xt of vocabulary def, none in this case
          EXIT
eword

; H: ( -- wid ) Create a new wordlist.
; wordlists are allocated from the dictionary space, containing two cells
; the first being the last word defined in the wordlist, and the second containing
; an xt to an associated vocabulary definition if one has been defined
; the wid is the pointer to the first cell
dword     WORDLIST,"WORDLIST"
          ENTER
          ONLIT H_FORTH           ; root of all dictionaries
          .dword dCREATE_WL
          .dword 0
          EXIT
eword

; H: ( -- wid ) Create a new empty wordlist (danger!).
; non-standard method to create a completely empty wordlist.  If this is the only
; list in the search order, it may be impossible to get out of the situation
dword     dEMPTY_WL,"$EMPTY-WL"
          ENTER
          .dword ZERO             ; null root
          .dword dCREATE_WL
          EXIT
eword

; H: ( "name"<> -- ) Create a new named wordlist definition.  When name is executed,
; H: put the WID of the wordlist at the top of the search order.
; H: The WID is the address of the body of the named wordlist definition.
dword     VOCABULARY,"VOCABULARY"
          ENTER
          .dword CREATE
dovocab:  .dword _COMP_LIT
          .dword H_FORTH          ; root of all dictionaries
          .dword LAST
          .dword drXT             ; XT of the just-created word
          .dword COMMA
          CODE
          jsl f:_does
          ENTER                   ; action of the vocabulary definition
          .dword RPLUCKADDR
          .dword INCR
          .dword TOP_OF_ORDER
          EXIT
eword

; ( c-addr u -- ) Create a new named wordlist definition as per VOCABULARY.
; Meant for adding more builtin dictionaries (e.g. platform specific dictionaries)
; which are expected to adjust the root to the new wordlist
hword    dVOCAB,"$VOCAB"
         ENTER
         .dword dCREATE
         JUMP VOCABULARY::dovocab
eword

.endif

.if 0 ; half-baked
; ( -- )
; "Restore all dictionary allocation and search order pointers to the state they had just
; prior to the definition of name. Remove the definition of name and all subsequent 
; definitions. Restoration of any structures still existing that could refer to deleted
; definitions or deallocated data space is not necessarily provided. No other contextual
; information such as numeric base is affected."
; May need to change the wordlist structures to be a linked list so that we are aware of
; all of them, because at least one of them will have their head change and may not be
; in the search order.
; So in total when the marker is created we need to:
; * save HERE in order to deallocate the space later
; * save CURRENT to restore compiler word list
; * save the search order
; * save the heads of all wordlists
; * save the head of the wordlists list
; When the marker is executed, restore all of the above:
; * restoring head of the wordlists ensures removal of all wordlists
;   that are removed by the marker
; * restoring the heads of the (remaining) wordlists removes all definitions created
;   after the marker
; * restoring the search order and CURRENT ensures no removed wordlists are in use
; * Restoring HERE deallocates all dictionary space from the marker and beyond.
dword     MARKER,"MARKER" ; noindex
          ENTER

          CODE
          jsl f:_does
          ENTER                   ; action of the marker
          
          EXIT
eword
.endif

; H: ( [text<end>] -- ) Discard the rest of the input buffer (or line during EVALUATE)
dword     BACKSLASH,"\",F_IMMED
          ENTER
          .dword SOURCEID
          .dword _IF
          .dword term             ; faster
          ONLIT 0                 ; something to drop...
lp:       .dword DROP
          .dword INQ
          .dword _IF
          .dword done
          .dword GETCH
          .dword DUP
          ONLIT c_cr
          .dword EQUAL
          .dword _IFFALSE
          .dword ddone            ; if true (= CR)
          .dword DUP
          ONLIT c_lf
          .dword EQUAL
          .dword _IF
          .dword lp               ; if false (<> LF)
ddone:    .dword DROP
done:     EXIT
term:     .dword NIN
          .dword FETCH
          .dword PIN
          .dword STORE
          EXIT
eword

; H: ( char -- char' ) Upper case convert char.
dword     UPC,"UPC"
          jsr   _1parm
          lda   STACKBASE+0,x
          jsr   _cupper
          sta   STACKBASE+0,x
          NEXT
eword

; H: ( char -- char' ) Lower case convert char.
dword     LCC,"LCC"
          jsr   _1parm
          lda   STACKBASE+0,x
          cmp   #'A'
          bcc   done
          cmp   #'Z'+1
          bcs   done
          ora   #$20
          sta   STACKBASE+0,X
done:     NEXT
eword

; H: ( [name< >] ) Parse name, place low 5 bits of first char on stack.
; H: If compiling state, compile it as a literal.
dword     CONTROL,"CONTROL",F_IMMED
          ENTER
          .dword CHAR
          ONLIT $1F
          .dword LAND
          .dword _SMART
          .dword interp
          .dword LITERAL
interp:   EXIT
eword

; H: ( char base -- digit true | char false ) Attempt to convert char to digit.
dword     DIGIT,"DIGIT"
          jsr   _2parm
          lda   STACKBASE+4,x
          jsr   _c_to_d
          ldy   #$0000
          bcc   bad
          cmp   STACKBASE+0,x
          bcs   bad
          sta   STACKBASE+4,x
          dey
bad:      sty   STACKBASE+0,x
          sty   STACKBASE+2,X
          NEXT
eword

; H: ( addr len -- 0 | n 1 | d 2 ) Attmept to convert string to number.
hword     dgNUM,"$>NUM"
          ENTER
          .dword OVER
          .dword CFETCH
          ONLIT '-'
          .dword EQUAL
          .dword PtoR
          .dword RCOPY
          .dword _IF
          .dword :+
          .dword DECR
          .dword SWAP
          .dword INCR
          .dword SWAP
:         .dword TWOPtoR          ; ( c-addr u -- )
          .dword ZERO             ; ( -- 0 )
          .dword StoD             ; ( 0 -- ud )
          .dword TWORtoP          ; ( ud -- ud c-addr u )
          .dword GNUMBER          ; ( ud c-addr u -- ud' c-addr' u' ) u' = 0 if no unconverted
          .dword QDUP             ; ( ud' c-addr' u' -- ud' c-addr' u' | ud' c-addr' u' u' )
          .dword _IF
          .dword okay             ; branch taken: ( ... ud c-addr' )
          .dword ONE              ; ( ud' c-addr' u' - ud' c-addr' u' 1 )
          .dword EQUAL            ; ( ud' c-addr' u' 1 -- ud' c-addr' f )
          .dword _IF              ; ( ud' c-addr' f -- ud' c-addr' )
          .dword notok
          .dword CFETCH           ; ( ud' c-addr' -- ud' c )
          ONLIT '.'               ; ( ud' c -- ud' c '.' )
          .dword EQUAL            ; ( ud' c '.' -- ud' f )
          .dword _IFFALSE         ; ( ud' f -- ud' )
          .dword dokay            ; if true
          .dword ZERO             ; ( ud' -- ud' 0 ) p/h for THREEDROP
notok:    .dword THREEDROP        ; ( ud' c-addr' -- )
          .dword RDROP            ; lose negative
          .dword ZERO             ; ( -- 0 )
          EXIT
okay:     .dword DROP             ; ( ud' c-addr' -- ud' )
          .dword DtoS             ; ( ud' -- n )
          .dword RtoP
          .dword QNEGATE
          .dword ONE              ; ( n -- n 1 )
          EXIT
dokay:    .dword RtoP             ; ( ud' -- ud' f )
          .dword _IF              ; ( ud' f -- ud' )
          .dword :+
          .dword DNEGATE          ; ( ud' -- d )
:         .dword TWO              ; ( d -- d 2 )
          EXIT
eword

; H: ( addr len -- true | n false ) Attmept to convert string to number.
dword     dNUMBER,"$NUMBER"
          ENTER
          .dword dgNUM
          .dword ZEROQ
          EXIT
eword

; ( xx...xx1 -- yx...yx1 )
; Interpret text from current input source
hword     INTERPRET,"INTERPRET"
          ENTER
loop:     .dword INQ              ; ( -- f )
          .dword _IF              ; ( f -- )
          .dword done
          .dword PARSE_WORD       ; ( -- c-addr u )
          .dword QDUP             ; ( c-addr u -- c-addr u | c-addr u u )
          .dword _IF              ; ( c-addr u | c-addr u u | c-addr | c-addr u )
          .dword null
          .dword TWODUP           ; ( c-addr u -- c-addr u c-addr u )
          .dword SEARCH_ALL       ; ( c-addr u c-addr u - c-addr u xt|0 )
          .dword QDUP             ; ( c-addr u xt|0 -- c-addr u 0 | c-addr u xt xt )
          .dword _IF              ; ( c-addr u 0 | c-addr u xt xt -- c-addr u | c-addr u xt )
          .dword trynum           ; if xt = 0
          .dword DROP             ; drop flag
          .dword NIPTWO           ; ( c-addr u xt -- xt )
          .dword CONLYQ           ; compile-only? (leaves xt on stack
          .dword _IFFALSE
          .dword conly
          .dword _SMART           ; no, see if we should compile or execute
          .dword exec             ; if interpreting
chkimm:   .dword IMMEDQ           ; compiling, immediate? (leaves xt on stack)
          .dword _IFFALSE
          .dword exec             ; yes, go do it
          NLIT COMPILECOMMA
exec:     .dword EXECUTE
          JUMP  loop
trynum:   .dword TWODUP           ; ( c-addr u -- c-addr u c-addr u )
          .dword dgNUM            ; ( c-addr u c-addr u -- c-addr u 0 | c-addr u n 1 | c-addr u d 2 )
          .dword QDUP
          .dword _IFFALSE
          .dword isnum            ; nonzero = is number
          .dword SPACE
          .dword TYPE
          ONLIT  '?'
          .dword EMIT
          ONLIT  -13
          .dword THROW
isnum:    .dword XNPtoR
          .dword NIPTWO
          .dword XNRtoP
          .dword _SMART
          .dword inum
          .dword XLITERAL
          .dword _SKIP
inum:     .dword DROP
          JUMP loop
conly:    .dword _SMART
          .dword trytemp          ; if interpreting, try temporary def
          JUMP chkimm             ; otherwise check immediacy
trytemp:  .dword TEMPDQ           ; has flag for starting temp def
          .dword _IFFALSE
          .dword dotemp           ; true, so start temporary def
          .dword DROP             ; otherwise bad state, drop XT
          ONLIT -14                ; and throw exception
          .dword THROW
null:     .dword DROP
done:     EXIT
          ; now we gotta do some juggling stack is ( xt )
dotemp:   .dword PtoR             ; ( xt -- ) ( R: -- xt )
          .dword dTEMPCOLON       ; start temporary colon definition
          .dword RtoP             ; ( -- xt ) ( R: xt -- )
          JUMP chkimm             ; most or all of these should also be immediate...
eword

; ( -- xn...x1 n ) save current source input state
dword     SAVEINPUT,"SAVE-INPUT"
          ENTER
          .dword SOURCE           ; address and length of current input
          .dword PIN
          .dword FETCH            ; position in buffer
          .dword SOURCEID
          ONLIT 4                 ; that was 4 things
          EXIT
eword

; H: ( xn...x1 n f1 -- f2 ) restore current source input state,
; H: including source ID if f1 is true.
dword     dRESTOREINPUT,"$RESTORE-INPUT"
          ENTER
          .dword SWAP             ; ( ... addr len ptr srcid f 4 )
          ONLIT 4                 ; ( ... addr len ptr srcid f 4 4 ) sanity check
          .dword EQUAL            ; ( ... addr len ptr srcid f1 f2 )
          .dword _IF              ; ( ... addr len ptr srcid f )
          .dword bad
          .dword _IF              ; ( ... addr len ptr srcid )
          .dword nosrcid
          .dword dSOURCEID        ; ( ... addr len ptr srcid var )
          .dword STORE            ; ( ... addr len ptr )
          JUMP :+
nosrcid:  .dword SOURCEID         ; ( ... addr len ptr srcid srcid' )
          .dword EQUAL            ; ( ... addr len ptr f )
          .dword _IF              ; ( ... addr len ptr )
          .dword bad              ; can't change sources
:         .dword PIN              ; otherwise restore all the things
          .dword STORE
          .dword NIN
          .dword STORE
          .dword dCIB
          .dword STORE
          .dword TRUE
          EXIT
bad:      ONLIT -12
          .dword THROW
          EXIT
eword

; H: ( xn...x1 n -- f ) Restore current source input state, source ID must match current.
dword     RESTOREINPUT,"RESTORE-INPUT"
          ENTER
          .dword FALSE
          .dword dRESTOREINPUT
          EXIT
eword

; H: ( xxn...xx1 addr u -- yxn...yx1 ) Interpret text in addr u.
dword     EVALUATE,"EVALUATE"
          ENTER
          .dword SAVEINPUT
          .dword XNPtoR            ; throw it all on the return stack
          .dword PtoR             ; along with the count
          ONLIT -1
          .dword dSOURCEID        ; standard requires source-id to be -1 during EVALUATE
          .dword STORE
          ONLIT 0                 ; input to first character
          .dword PIN
          .dword STORE
          .dword NIN              ; string length to #IN
          .dword STORE
          .dword dCIB             ; current input buffer to string address
          .dword STORE
          ONLIT INTERPRET
          .dword CATCH            ; we do this so that we can restore input if exception
          .dword RtoP             ; now put the input back to where we were
          .dword XNRtoP
          .dword TRUE
          .dword dRESTOREINPUT    ; restore the input spec, including source ID
          .dword DROP
          .dword THROW            ; finally, re-throw any exception
          EXIT
eword

; H: synonym for EVALUATE
dword     EVAL,"EVAL"
          bra   EVALUATE::code
eword

; ( [number< >] n ) Parse number in input stream, compile as literal if compiling.
hword     nNUM,"#NUM"
          ENTER
          .dword PARSE_WORD
          .dword DUP
          .dword _IF
          .dword empty
          .dword dgNUM
          .dword DUP
          .dword _IF
          .dword bad
          .dword _SMART
          .dword interp
          .dword XLITERAL
          .dword _SKIP
interp:   .dword DROP
          EXIT
empty:    .dword TWODROP
bad:      ONLIT -24
          .dword THROW
eword


; H: ( [number< >] n )  Parse number as decimal, compile as literal if compiling.
dword     DNUM,"D#",F_IMMED
          ENTER
          ONLIT 10
tmpbase:  ONLIT nNUM
          .dword SWAP
          .dword TMPBASE
          EXIT
eword

; H: ( [number< >] n )  Parse number as hexadecimal, compile as literal if compiling.
dword     HNUM,"H#",F_IMMED
          ENTER
          ONLIT 16
          JUMP DNUM::tmpbase
eword          

; H: ( [number< >] n )  Parse number as octal, compile as literal if compiling.
dword     ONUM,"O#",F_IMMED
          ENTER
          ONLIT 8
          JUMP DNUM::tmpbase
eword

; Forget is a stupidly dangerous word when you have multiple wordlists, noname words,
; and such.  Not recommended to use except for the most recently-defined few words in
; the current wordlist.
; first we will scan the dictionary to see if the word to be forgotten is below
; the protection bit, and if it is found before we match the XT, we don't allow the
; forget
; H: ( xt -- ) Forget word referenced by xt and subsequent words.
dword     dFORGET,"$FORGET"
          ENTER
          .dword DUP              ; ( xt -- xt xt' )
          .dword QDUP
          .dword _IF
          .dword cant
          .dword rLINK            ; ( xt xt' -- xt link )
          .dword _IF              ; ( xt link -- xt )
          .dword cant
          .dword LAST             ; ( xt -- xt a-addr )
lp:       .dword DUP              ; ( xt a-addr -- xt a-addr a-addr' )
          .dword drXT             ; ( xt a-addr a-addr' -- xt a-addr xt2 )
          .dword DUP              ; ( xt a-addr xt2 -- xt a-addr xt2 xt2' )
          .dword FETCH            ; ( xt a-addr xt2 xt2' -- xt a-addr xt2 flags )
          ONLIT F_PROT            ; ( xt a-addr xt2 flags -- xt a-addr xt2 flags F_PROT )
          .dword LAND             ; ( xt a-addr xt2 flags F_PROT -- xt a-addr xt2 f )
          .dword _IFFALSE         ; ( xt a-addr xt2 f -- xt a-addr xt2 )
          .dword prot
          .dword SWAP             ; ( ... xt xt2 a-addr )
          .dword PtoR             ; ( ... xt xt2 ) ( R: -- a-addr )
          .dword OVER             ; ( ... xt xt2 xt' )
          .dword EQUAL            ; ( ... xt f )
          .dword _IFFALSE         ; ( ... xt )
          .dword amnesia
          .dword RtoP             ; ( xt -- xt a-addr ) ( R: a-addr -- )
          .dword FETCH            ; ( xt a-addr -- xt a-addr2 )
          .dword QDUP
          .dword _IF
          .dword cant
          JUMP lp
amnesia:  .dword RDROP            ; ( R: a-addr -- )
          .dword rLINK
          .dword DUP
          .dword toHERE
          .dword FETCH
          .dword GET_CURRENT
          .dword STORE
          EXIT
prot:     .dword TWODROP          ; ( xt a-addr xt2 -- xt )
cant:     SLIT "Can't forget "    ; ( xt -- xt str len )
          .dword TYPE             ; ( xt str len -- xt )
          .dword rNAME            ; ( xt -- str len )
          .dword TYPE             ; ( str len -- )
          EXIT
eword

; H: ( [name< >] -- ) Attempt to forget name and subsequent definitions in compiler
; H: word list.  This may have unintended consequences if things like wordlists and
; H: such were defined after name.
dword     FORGET,"FORGET"
          ENTER
          .dword PARSEFIND
          .dword dFORGET
          EXIT
eword

; remove any incomplete or temporary definitions
; executed by QUIT to clean up after an exception results in a return to the outer
; interpreter.
hword     dPATCH,"$PATCH"
          ENTER
          .dword STATEI           ; ensure interpretation state
          .dword dTMPDEF
          .dword FETCH
          .dword _IF              ; in the middle of a temporary definition?
          .dword :+               ; no, see if we were doing a normal def
          .dword dSAVEHERE        ; ( -- a-addr ) restore HERE
          .dword FETCH            ; ( a-addr -- c-addr )
          .dword toHERE           ; ( c-addr -- )
          ONLIT 0                 ; ( -- 0 )
          .dword dTMPDEF          ; ( 0 -- 0 a-addr )
          .dword DUP              ; ( 0 a-addr -- 0 a-addr a-addr' )
          .dword FETCH            ; ( 0 a-addr a-addr' -- 0 a-addr c-addr )
          ONLIT max_tempdef       ; ( ... 0 a-addr c-addr u )
          .dword FREE             ; ( ... 0 a-addr )
          .dword STORE            ; ( 0 a-addr -- )
:         .dword OLDHERE          ; is OLDHERE not 0?
          .dword _IF
          .dword nopatch          ; is zero, no need to patch
          .dword LAST             ; it is! check smudge bit of last definition
          .dword drXT
          .dword CFETCH
          ONLIT F_SMUDG
          .dword LAND
          .dword _IF              ; is smudge bit set?
          .dword nopatch          ; nope, no need to patch
          .dword LAST             ; yes, start fixup by setting LAST to the value at [LAST]
          .dword FETCH            ; LAST @
          .dword GET_CURRENT      ; CURRENT
          .dword STORE            ; !
          .dword OLDHERE          ; fix HERE
          .dword toHERE           ; ->HERE
          ONLIT 0                 ; clear OLDHERE
          .dword dOLDHERE         ; $OLDHERE
          .dword STORE            ; !
nopatch:  EXIT
eword

; H: ( -- ) ( R: ... -- ) Enter outer interpreter loop, aborting any execution.
dword     QUIT,"QUIT"
          lda   RSTK_TOP          ; reset return stack pointer
          tcs
          ENTER
          .dword dPATCH           ; fix top of dictionary/remove temp defs
          .dword CR
source0:  .dword SETKBD           ; set keyboard as input source
lp:       ONLIT 0                 ; clear #LINE since we are at input prompt
          .dword NLINE
          .dword STORE
          .dword REFILL           ; fill input buffer
          .dword _IF              ; get anything?
          .dword source0          ; no, reset to keyboard and get more
          .dword INTERPRET        ; otherwise, interpret
          .dword dSTATUS          ; display status
          JUMP  lp
eword
__doquit  = QUIT::code

PLATFORM_INCLUDE "platform-words.s" ; Platform additional dictionary words

; Leave these toward the top

; H: ( -- -1 )
dword     MINUSONE,"-1"
          lda   #$FFFF
          tay
          PUSHNEXT
eword

; H: ( -- 3 )
dword     THREE,"3"
          FCONSTANT 3
eword

; H: ( -- 2 )
dword     TWO,"2"
          FCONSTANT 2
eword

; H: ( -- 1 )
dword     ONE,"1"
          lda   #$0000
          tay
          iny
          PUSHNEXT
eword

; H: ( -- 0 )
dword     ZERO,"0"
          lda   #$0000
          tay
          PUSHNEXT
eword


dend


