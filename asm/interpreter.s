; Inner interpreter and support routines, and basic stack manipulation routines.


; Inner interpreter entry and Forth call nesting
; this inner interpreter expects cell-sized absolute references to other definitions
; Expectations:
; call with JSL in native mode with long registers
; D register: address of direct page to be used for low-level system functions and
; working registers.
; S register: return stack
; X register: data stack pointer in bank 0, relative to D register.
; See equates.inc.  SP_MIN and SP_MAX reflect minimum and maximum allowed stack pointer
; Pops caller from return stack and initializes IP with it
; saving previous IP on return stack.
.if 1 ; faster
.proc     _enter
          .if trace
          lda   IP
          ldy   IP+2
          wdm   $81
          .endif
          phb                     ; (3) dummy value
          lda   2,s               ; (5)
          ldy   IP                ; (4)
          sta   IP                ; (4)
          tya                     ; (2)
          sta   1,s               ; (5)
          lda   4,s               ; (5)
          ldy   IP+2              ; (4)
          and   #$FF              ; (3)
          sta   IP+2              ; (4)
          tya                     ; (2)
          sta   3,s               ; (5)
          ; fall-through          ; (46 cycles)
.endproc
.else ; original implementation
.proc     _enter
          ldy   IP                ; (4)
          lda   IP+2              ; (4)
          .if trace
          wdm   $81
          .endif
          sta   TMP1              ; (4)
          pla                     ; (5)
          sta   IP                ; (4)
          sep   #SHORT_A          ; (3)
          pla                     ; (4)
          rep   #SHORT_A          ; (3)
          and   #$FF              ; (3)
          sta   IP+2              ; (4)
          lda   TMP1              ; (4)
          pha                     ; (4)
          phy                     ; (4)
          ; fall-through          ; (50 cycles)
.endproc
.endif

.proc     _next
          inc   IP                ; inline fetch
          bne   :+
          inc   IP+2
:         lda   [IP]              ; low word
          tay
          inc   IP
          bne   :+
          inc   IP+2
:         inc   IP
          bne   :+
          inc   IP+2
:         lda   [IP]              ; high word
          inc   IP
          bne   :+
          inc   IP+2
:         
.if !no_fast_lits
          ora   #$0000            ; faster than php+plp
          beq   fast_num
.endif
run:      sep   #SHORT_A
          pha
          rep   #SHORT_A
          phy
          rtl
fast_num: jsr   _pushay
          bra   _next
.endproc


; Exit Forth thread: restore previous IP from return stack
; and resume execution
.proc     _exit_next
          ply
          pla
          .if trace
          wdm $83
          .endif
          sty   IP
          sta   IP+2
          NEXT
.endproc

; Exit Forth thread, resume native code execution at IP+1 by swapping the 32-bit IP on the
; stack for the low 24 bits of the Forth IP
.proc     _exit_code
.if 1 ; ever so slightly faster, eliminate TMP1 use
          .if trace
          lda   IP+2
          ldy   IP
          wdm $82
          .endif
          lda   3,s               ; (5)
          tay                     ; (2)
          lda   IP+1              ; (4) note offset is 1 to get high & middle bytes
          sta   3,s               ; (5)
          sty   IP+2              ; (4)
          lda   1,s               ; (5)
          tay                     ; (2)
          lda   IP                ; (4)
          sta   2,s               ; (5) note offset is 2 to place low (& middle again) bytes
          sty   IP                ; (4)
          tsc                     ; (2)
          inc   a                 ; (2) drop the extra byte
          tcs                     ; (2)
          rtl                     ; (47 cycles)
.else ; original
          ldy   IP                ; (4)
          lda   IP+2              ; (4)
          sta   TMP1              ; (4)
          pla                     ; (5)
          sta   IP                ; (4)
          pla                     ; (5)
          sta   IP+2              ; (4)
          lda   TMP1              ; (4)
          .if trace
          wdm $82
          .endif
          sep   #SHORT_A          ; (3)
          pha                     ; (4)
          rep   #SHORT_A          ; (3)
          phy                     ; (4)
          rtl                     ; (48 cycles)
.endif
.endproc

.proc     _fetch_ip_word
          inc   IP
          bne   :+
          inc   IP+2
:         lda   [IP]
          ; fall-through
.endproc

.proc     _inc_ip                 ; note fall-through from above!
          inc   IP
          bne   :+
          inc   IP+2
:         rts          
.endproc

.proc     _fetch_ip_byte
          inc   IP
          bne   :+
          inc   IP+2
:         lda   [IP]
          and   #$00FF
          rts
.endproc

.proc     _fetch_ip_cell
          inc   IP
          bne   :+
          inc   IP+2
:         lda   [IP]
          tay
          inc   IP
          bne   :+
          inc   IP+2
:         inc   IP
          bne   :+
          inc   IP+2
:         lda   [IP]
          inc   IP
          bne   :+
          inc   IP+2
:         rts
.endproc

; convert XT address in YR to header address in YR
; return carry set if word has header
; return carry clear if word does not have header (is noname)
; Y = name length
.proc     _xttohead
lp:       jsr   _decyr              ; first one decrements before flags
          lda   [YR]
          and   #$80                ; see if it's the name length field
          beq   lp                  ; nope, go back again
          lda   [YR]                ; get it back
          and   #$7F                ; mask in length
          tay                       ; and save it
          beq   nohead
yrminus4: lda   YR
          sec                       ; move to link field
          sbc   #$04
          sta   YR
          lda   YR+2
          sbc   #$00
          sta   YR+2
          sec                       ; flag OK
          rts
nohead:   clc
          rts
.endproc
_yrminus4 = _xttohead::yrminus4

.if 0
; Get caller address (must call with JSL)
.proc     _trace_word
          ldy   #'>'
          jsr   _emit
          lda   1,S               ; get caller address
          sta   WR
          lda   3,S
          sta   WR+2
          jsr   _wrminus4         ; get xt
          lda   WR                ; copy xt to YR
          sta   YR
          lda   WR+2
          sta   YR+2
          jsr   _xttohead         ; go to header
          bcc   do_hex            ; No name
          sty   XR                ; save length
          stz   XR+2
          lda   YR                ; put address of name back into WR
          clc
          adc   #$04
          sta   WR
          lda   YR+2
          adc   #$00
          sta   WR+2
          ldy   #.loword(do_emit-1)
          lda   #.hiword(do_emit-1)
          jsr   _str_op_ay        ; now print word (destroys YR)
spacer:   lda   #' '              ; print a space and cleverly fall through
do_emit:  tay
          jsr   _emit
          clc
          rtl
do_hex:   jsr   _incwr            ; Move to word XT address
          ldy   #'$'              ; because that's what we want to print
          jsr   _emit
          lda   WR+2              ; high word
          jsr   prhex             ; print
          lda   WR                ; low word
          jsr   prhex             ; print
          bra   spacer            ; and done
prhex:    sta   XR                ; save it
          lda   #$04              ; 4 digits to do
          sta   XR+2              ; counter loc
digit:    lda   #$0000            ; start with nothing
          clc                     ; rotate 4 bits from XR to A
          rol   XR
          rol   a
          rol   XR
          rol   a
          rol   XR
          rol   a
          jsr   _dtoc             ; convert to ASCII
          tay
          jsr   _emit             ; and print
          dec   XR+2
          bne   digit             ; do the rest if there are some left
          rts
.endproc
.endif

; Stack primitives
; stack starts at STK_TOP and grows down toward STK_BTM
; STK_BTM points at the last usable cell
; STK_TOP points at the location above the first usable cell
.proc     _stackdecr
          cpx   STK_BTM           ; past the bottom already?
          bcc   _stko_err
          dex
          dex
          dex
          dex
          rts
.endproc

.proc     _stackincr
          cpx   STK_TOP           ; already past where we can be?
          bcs   _stku_err         ; yep, underflowed stack
          inx
          inx
          inx
          inx
          rts
.endproc

.proc     _popay
          lda   STACKBASE+2,x
          ldy   STACKBASE+0,x
          .if trace
          wdm $85
          .endif
          bra   _stackincr
.endproc

.proc     _peekay
          cpx   STK_TOP
          bcs   _stku_err
          lda   STACKBASE+2,x
          ldy   STACKBASE+0,x
          rts          
.endproc

.proc     _popwr
          jsr   _popay
          sty   WR
          sta   WR+2
          rts
.endproc

; no stack depth check
.proc     _peekwr
          lda   STACKBASE+0,x
          sta   WR
          lda   STACKBASE+2,x
          sta   WR+2
          rts
.endproc

.proc     _popxr
          jsr   _popay
          sty   XR
          sta   XR+2
          rts
.endproc

.proc     _popyr
          jsr   _popay
          sty   YR
          sta   YR+2
          rts
.endproc

.proc     _stku_err
          ldx   STK_TOP
          ldy   #.loword(-4)
          lda   #.hiword(-4)
          jmp   _throway
.endproc

.proc     _1parm
          cpx   STK_TOP
          bcs   _stku_err
          rts
.endproc

.proc     _l1parm
          jsr _1parm
          rtl
.endproc

.proc     _2parm
          txa
          clc
          adc   #$04
docmp:    cmp   STK_TOP
          bcs   _stku_err
          rts
.endproc

.proc     _l2parm
          jsr _2parm
          rtl
.endproc

.proc     _3parm
          txa
          clc
          adc   #$08
          bra   _2parm::docmp
.endproc

.proc     _l3parm
          jsr _3parm
          rtl
.endproc

.proc     _4parm
          txa
          clc
          adc   #$0C
          bra   _2parm::docmp
.endproc

.proc     _l4parm
          jsr _4parm
          rtl
.endproc


.proc     _stko_err
          lda   STK_BTM
          clc
          adc   #32               ; 8 cells
          tax
          ldy   #.loword(-3)
          lda   #.hiword(-3)
          jmp   _throway
.endproc

.proc     _pushay
          .if trace
          wdm   $86
          .endif
          jsr   _stackdecr
          sta   STACKBASE+2,x
          sty   STACKBASE,x
          rts
.endproc

.proc     _pusha
          .if trace
          phy
          tay
          lda   #$00
          jsr   _pushay
          ply
          .else
          jsr   _stackdecr
          stz   STACKBASE+2,x
          sta   STACKBASE,x
          .endif
          rts
.endproc

.proc     _swap
          jsr   _2parm
          ; fall-through
.endproc

; when we know there are 2 parms on stack...
.proc     _swap1
          lda   STACKBASE+6,x
          ldy   STACKBASE+2,x
          sty   STACKBASE+6,x
          sta   STACKBASE+2,x
          lda   STACKBASE+4,x
          ldy   STACKBASE+0,x
          sty   STACKBASE+4,x
          sta   STACKBASE+0,x
          rts
.endproc

.proc     _over
          jsr   _2parm
          ldy   STACKBASE+4,x
          lda   STACKBASE+6,x
          jmp   _pushay
.endproc

          
; Interpretation routines

; Push word data address, default routine used by CREATE
; call via JSL, pops return stack entry, pushes data address
; onto data stack
.proc     _pushda
          pla
          clc
          adc   #$01
          tay
          sep   #SHORT_A
          pla
          rep   #SHORT_A
          and   #$FF
          adc   #$00
          PUSHNEXT
.endproc

; Pushes cell following JSL onto the stack
.proc     _pushvalue
          pla
          clc
          adc   #$01
          sta   WR
          sep   #SHORT_A
          pla
          rep   #SHORT_A
          and   #$FF
          adc   #$00
          sta   WR+2
pushv2:   ldy   #$02
          lda   [WR],y            ; high word
          pha                     ; save for now
          dey
          dey
          lda   [WR],y            ; low word
          tay
          pla
          PUSHNEXT
.endproc

; Pushes stack top + cell following JSL onto the stack
.proc     _field
          jsr   _1parm
          pla
          clc
          adc   #$01
          sta   WR
          sep   #SHORT_A
          pla
          rep   #SHORT_A
          and   #$FF
          adc   #$00
          sta   WR+2
          ldy   #$00
          lda   [WR],y            ; low word
          clc
          adc   STACKBASE+0,x
          sta   STACKBASE+0,x
          iny
          iny
          lda   [WR],y            ; low word
          adc   STACKBASE+0,x
          sta   STACKBASE+0,x
          NEXT
.endproc

.proc     _push2value
          pla
          clc
          adc   #$01
          sta   WR
          sep   #SHORT_A
          pla
          rep   #SHORT_A
          and   #$FF
          adc   #$00
          sta   WR+2
          ldy   #$06
          lda   [WR],y            ; high word
          pha                     ; save for now
          dey
          dey
          lda   [WR],y            ; low word
          tay
          pla
          jsr   _pushay
          bra   _pushvalue::pushv2
.endproc

; Return address of system variable # following the JSL
.proc     _sysvar
          pla                     ; return address + 1 -> WR
          clc
          adc   #$01
          sta   WR
          sep   #SHORT_A
          pla
          rep   #SHORT_A
          and   #$FF
          adc   #$00
          sta   WR+2
          lda   [WR]              ; get sysvar number (max of 16384*4)
          clc
          adc   SYSVARS           ; add to address of SYSVARS
          tay
          lda   SYSVARS+2
          adc   #$00
          PUSHNEXT
.endproc

; Jumps to the XT following JSL
.proc     _deferred
          pla
          clc
          adc   #$01
          sta   WR
          sep   #SHORT_A
          pla
          rep   #SHORT_A
          and   #$FF
          adc   #$00
          sta   WR+2
          ldy   #$02
          lda   [WR],y            ; high word
          sep   #SHORT_A
          pha                     ; bank byte on stack
          rep   #SHORT_A
          dey
          dey
          lda   [WR],y            ; low word
          pha                     ; address on stack
          rtl                     ; really a jump
.endproc

; After pop from data stack into AY, jumps to the XT following JSL
.proc     _pop_deferred
          pla
          clc
          adc   #$01
          sta   WR
          sep   #SHORT_A
          pla
          rep   #SHORT_A
          and   #$FF
          adc   #$00
          sta   WR+1
          ldy   #$02
          lda   [WR],y            ; high word
          sep   #SHORT_A
          pha                     ; bank byte on stack
          rep   #SHORT_A
          dey
          dey
          lda   [WR],y            ; low word
          pha                     ; RTS address on stack
          jsr   _popay
          rts                     ; really a jump
.endproc

; ensure at least room for 8 items on stack
.proc     _stackroom
          txa
          sec
          sbc #$20                ; see if there is room for 8 items on stack
          cmp STK_BTM
          bcc makeroom
chktop:   cpx STK_TOP             ; new see if we are above the top
          bcc :+
          ldx STK_TOP
:         rts
makeroom: txa
          adc #$20
          tax
          bra chktop          
.endproc

.proc     _unimpl
          ldy   #.loword(-21)
          lda   #.hiword(-21)
          jmp   _throway
.endproc

.proc     _callyr
          tay
          lda   YR+2
          sep   #SHORT_A
          pha
          rep   #SHORT_A
          lda   YR
          pha
          tya
          rtl
.endproc

.proc     _str_op_ay
          sta   YR+2
          sty   YR
          ; fall-through
.endproc

; Perform a "string" operation on the string pointed at in WR
; with length in XR and function in YR (address less 1)
; YR is called with A containing the byte from the string
; XR is converted to last address plus one of the string
; [YR] should return with carry clear if processing is to continue
; and carry set if it not.
; note YR is called with long registers
.proc     _str_op
          lda   WR
          clc
          adc   XR
          sta   XR
          lda   WR+2
          adc   XR+2
          sta   XR+2
loop:     lda   WR+2
          cmp   XR+2
          bne   :+
          lda   WR
          cmp   XR
:         bcc   :+
done:     rts
:         lda   [WR]
          and   #$00FF            ; compensate for long register
          jsl   f:_callyr
          bcs   done
          jsr   _incwr
          bra   loop
.endproc

; do string op with function in AY and string described by (c-addr u) on
; top of data stack
.proc     _str_op_ays
          sta   YR+2
          sty   YR
          jsr   _popxr            ; u -> XR
          jsr   _popwr            ; c-addr -> YR
          bra   _str_op
.endproc

.proc     _iter_ay
          sta   YR+2
          sty   YR
          ; fall-through
.endproc

; Perform a function pointed at in YR with count in XR times
; iteration # (from 0) will be in WR
; [YR] should return with carry clear if processing is to continue
; and carry set if it not.
.proc     _iter
          stz   WR
          stz   WR+2
          lda   XR
          ora   XR+2
          beq   done              ; in case no loops requested
loop:     jsl   f:_callyr
          bcs   done
          jsr   _incwr
          lda   WR+2
          cmp   XR+2
          bne   :+
          lda   WR
          cmp   XR
:         bcc   loop
done:     rts
.endproc

.proc     _decay
          cpy   #$0000
          bne   :+
          dec   a
:         dey
          rts
.endproc

; get AY from [WR]
.proc     _wrfetchind
          ldy   #$02
          lda   [WR],y
          pha
          dey
          dey
          lda   [WR],y
          tay
          pla
          rts
.endproc

; store AY into [WR]
.proc     _wrstoreind
          phy
          ldy   #$02
          sta   [WR],y
          dey
          dey
          pla
          sta   [WR],y
          rts
.endproc

.proc     _incwr
          inc   WR
          bne   :+
          inc   WR+2
:         rts
.endproc

.proc     _decwr
          lda   WR
          bne   :+
          dec   WR+2
:         dec   WR
          rts
.endproc

.proc     _decxr
          lda   XR
          bne   :+
          dec   XR+2
:         dec   XR
          rts
.endproc

.proc     _decyr
          lda   YR
          bne   :+
          dec   YR+2
:         dec   YR
          rts
.endproc

.proc     _wrplus4
          lda   WR
          clc
          adc   #$04
          sta   WR
          lda   WR+2
          adc   #$00
          sta   WR+2
          rts
.endproc

.proc     _wrminus4
          lda   WR
          sec
          sbc   #$04
          sta   WR
          lda   WR+2
          sbc   #$00
          sta   WR+2
          rts
.endproc

.if 0
.proc     _wrplusxr
          lda   WR
          clc
          adc   XR
          sta   WR
          lda   WR+2
          adc   XR+2
          sta   WR+2
          rts
.endproc

.proc     _wrminusxr
          lda   WR
          sec
          sbc   XR
          sta   WR
          lda   WR+2
          sbc   XR+2
          sta   WR+2
          rts
.endproc
.endif

; conversion helpers

; Digit to ASCII character
.proc     _d_to_c
          clc
          adc   #'0'
          cmp   #'9'+1
          bcc   :+
          adc   #6
:         rts
.endproc

; ASCII character to digit
; return carry clear if bad
; carry set if good
.proc     _c_to_d
          and   #$ff
          jsr   _cupper
          sec
          sbc   #'0'
          bmi   bad
          cmp   #10
          bcc   good
          sbc   #7
          bmi   bad
          cmp   #10
          bcc   bad               ; so things like < don't convert
          cmp   #37
          bcc   good
bad:      clc
          rts
good:     sec
          rts
.endproc

; Upper case a character in accumulator
.proc     _cupper
          cmp   #'z'+1
          bcs   :+
          cmp   #'a'
          bcc   :+
          and   #$DF
:         rts
.endproc

; Upper case a character, 8 bit accumulator
.a8
.proc     _cupper8
          and   #$7F
          cmp   #'z'+1
          bcs   :+
          cmp   #'a'
          bcc   :+
          and   #$DF
:         rts
.endproc
.a16

; Move XR bytes from [WR] to [YR], starting at the bottom
; trashes WR, YR, and XR
; could be optimized to move words, excepting the last one if odd number of bytes
; use for moving data downward, but that adds two comparison instructions which
; are slower than the SEP/REP, maybe
.proc     _move
.if 1 ; fast move in memmgr.s
          sec
          jmp   _memmove_c
.else ; slower but smaller move
lp:       lda   XR+2                ; see if zero bytes
          ora   XR
          bne   :+
          rts
:         jsr   _decxr              ; pre-decrement XR
          sep   #SHORT_A
          lda   [WR]
          sta   [YR]
          rep   #SHORT_A
          jsr   _incwr              ; post increment WR
          inc   YR                  ; and YR
          bne   lp
          inc   YR+2
          bra   lp
.endif
.endproc

; Move XR bytes from [WR] to [YR], starting at the top
; trashes YR and XR
; could be optimized to move words, excepting the last one if odd number of bytes
; use for moving data upward
.proc     _moveup
.if 1 ; fast move in memmgr.s
          clc
          jmp   _memmove_c
.else ; slower but smaller move
lp:       jsr   _wrplusxr
          lda   WR                  ; move WR to 1 past the end of the block
          clc
          adc   XR
          sta   WR
          lda   WR+2
          adc   XR+2
          sta   WR+2
          lda   YR                  ; move YR to 1 past the end of the block
          clc
          adc   XR
          sta   YR
          lda   YR+2
          adc   XR+2
          sta   YR+2
          lda   XR+2
          ora   XR
          bne   :+
          rts
:         jsr   _decxr              ; decrement XR
          jsr   _decwr              ; and WR
          jsr   _decyr              ; and YR
          sep   #SHORT_A
          lda   [WR]
          sta   [YR]
          rep   #SHORT_A
          bra   lp
.endif
.endproc

; With word header address in YR, set YR to previous dictionary entry header
; return with Z flag set if the new address is zero
.proc     _prevword
          ldy   #$00
          lda   [YR],y              ; low word
          pha
          iny
          iny
          lda   [YR],y              ; high word
          sta   YR+2
          pla
          sta   YR
          ora   YR+2                ; set Z flag
          rts
.endproc


; search dictionary for word at WR, length in XR, start of search (header) at YR
; if found, AY=XT and carry set, otherwise
; AY=0 and carry clear
; preserves WR, XR, and YR
.proc     _search
olp:      lda   YR
          ora   YR+2
          beq   notfnd
          ldy   #$04                ; offset of length
          lda   [YR],y              ; get name length
          and   #$7F                ; mask in significant bits
          cmp   XR                  ; compare to supplied
          bne   snext               ; not the right word
          ; its the right length, compare name
          lda   WR+2                ; save WR
          pha
          lda   WR
          pha
          phx                       ; save SP
          sep   #SHORT_A            ; need to compare bytes
          .a8
          ldx   XR                  ; get length to match
          ldy   #$05                ; offset of name
clp:      lda   [WR]
          jsr   _cupper8            ; upper case
          cmp   [YR],y              ; compare char
          bne   xsnext              ; no match
          iny                       ; move to next char
          jsr   _incwr
          dex                       ; if X hit zero, matched it all
          bne   clp                 ; if it didn't, keep going
          rep   #SHORT_A            ; match!
          .a16
          plx                       ; restore SP
          pla
          sta   WR                  ; restore WR, in case caller needs it
          pla
          sta   WR+2
          tya                       ; y = 5+namelen=offset of flags=XT
          clc
          adc   YR
          tay
          lda   YR+2
          adc   #$00                ; AY=XT
          sec
          rts
xsnext:   rep   #SHORT_A
          plx
          pla
          sta   WR
          pla
          sta   WR+2
snext:    jsr   _prevword
          bne   olp
notfnd:   lda   #$00
          tay
          clc
          rts
.endproc

; find word, skipping any smudged word
.proc     _search_unsmudged
lp:       jsr   _search
          bcs   :+                  ; if carry clear
          rts                       ; it wasn't found anyway
:         pha                       ; save xt
          phy
          lda   WR+2                ; save WR
          pha
          lda   WR
          pha
          lda   5,s                 ; put xt in WR
          sta   WR
          lda   7,s
          sta   WR+2
          lda   [WR]                ; get flags at xt address
          ply                       ; restore WR
          sty   WR
          ply
          sty   WR+2
          and   #F_SMUDG
          beq   f_ok                ; not set, word is OK
          pla                       ; otherwise drop xt from return stack
          pla
          jsr   _prevword           ; go to previous word
          bne   lp                  ; and search if more
          clc                       ; otherwise flag not found
          rts
f_ok:     ply                       ; get XT back
          pla
          sec
          rts
.endproc

