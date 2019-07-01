; Compiler helpers & primitives

; Compile a byte to the dictionary
; preserves registers
.proc     _cbytea
          phy
          ldy   #$0000
          sep   #SHORT_A
          sta   [DHERE],y
          rep   #SHORT_A
          inc   DHERE
          bne   :+
          inc   DHERE+2
:         ply
          rts
.endproc

; Compile a 16-bit word
.proc     _cworda
          jsr   _cbytea
          xba
          jsr   _cbytea
          xba
          rts
.endproc

; Compile a 32-bit cell
.proc     _ccellay
          pha
          tya
          jsr   _cworda
          pla
          jsr   _cworda
          rts
.endproc

; Make a word link in the dictionary, stores a link to the previous word into the
; dictionary, and sets LAST to this link
.proc     _w_link
          ldy   #SV_CURRENT+2
          lda   [SYSVARS],y       ; get CURRENT (compiler) wordlist address
          sta   YR+2
          dey
          dey
          lda   [SYSVARS],y
          sta   YR
          ldy   #$0002
          lda   [YR],y            ; get LAST entry for the compiler word list
          pha                     ; save on stack
          dey
          dey
          lda   [YR],y
          pha
          lda   DHERE             ; get HERE
          sta   [YR],y            ; and put into CURRENT wordlist
          iny
          iny
          lda   DHERE+2
          sta   [YR],y
          ply                     ; get the old LAST for the compiler word list
          pla
          jsr   _ccellay          ; and compile the link
          rts
.endproc

; make a dictionary entry, return with flags/XT address in AY
.proc     _mkentry
          jsr   _2parm
          jsr   _popxr            ; name length
          jsr   _popwr            ; name address
          lda   XR
          cmp   #NAMEMSK
          bcs   badword
          clc                     ; see if we are in danger of putting the new
          adc   DHERE             ; word's first several bytes across a bank boundary
          bcs   nextbank          ; yes we it will
          clc
          adc   #(4+1+1+4)        ; (link size + name len byte + flag byte + jsl )
          bcc   :+                ; it won't, just go make the entry
nextbank: stz   DHERE             ; move dictionary pointer to next bank
          inc   DHERE+2
:         jsr   _w_link           ; make link, sets LAST to HERE
          lda   XR
          ora   #$80
          jsr   _cbytea           ; compile name length
          ldy   #$0000
:         cpy   XR
          bcs   done
          lda   [WR],y
          and   #$7F              ; normalize
          jsr   _cupper           ; and convert to upper case
          jsr   _cbytea
          iny
          bne   :-
done:     lda   DHERE+2
          ldy   DHERE
          pha
          phy
          lda   #$00
          jsr   _cbytea           ; default flags
          ply
          pla
          rts
badword:  ldy   #<-19
          lda   #>-19
          jmp   _throway
.endproc

.proc     _lmkentry
          jsr   _mkentry
          rtl
.endproc

.if 0
; Compile data pointed at [WR], length in XR to dictionary
.proc     _cdata
          ldy   #.loword(func)
          lda   #.hiword(func)
          jmp   _str_op_ay
func:     jsr   _cbytea
          clc
          rts
.endproc

; Compile (c-addr u) at top of stack into dictionary
.proc     _csdata
          ldy   #.loword(_cdata::func)
          lda   #.hiword(_cdata::func)
          jmp   _str_op_ays
.endproc
.endif

; Compile a JSL to the dictionary
; with target in AY
.proc     _cjsl
          pha
          phy
          lda   #opJSL
doit:     jsr   _cbytea
          pla
          jsr   _cworda
          pla
          jsr   _cbytea
          rts
.endproc

; Compile a JSL to the dictionary
; with target in AY
.proc     _cjml
          pha
          phy
          lda   #opJML
          bra   _cjsl::doit
.endproc

 


