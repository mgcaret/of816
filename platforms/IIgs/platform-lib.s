; Note: we *know* this is running in bank 0

cpu_clk   = 2800000 ; nominally

PLATFORM_INCLUDE "platform-include.inc"

.proc     _scrn_tab
          .addr $400
          .addr $480
          .addr $500
          .addr $580
          .addr $600
          .addr $680
          .addr $700
          .addr $780
          .addr $428
          .addr $4A8
          .addr $528
          .addr $5A8
          .addr $628
          .addr $6A8
          .addr $728
          .addr $7A8
          .addr $450
          .addr $4D0
          .addr $550
          .addr $5D0
          .addr $650
          .addr $6D0
          .addr $750
          .addr $7D0
.endproc

.proc     _system_interface
          phx
          asl
          tax
          jmp   (table,x)
table:    .addr _sf_pre_init
          .addr _sf_post_init
          .addr _sf_emit
          .addr _sf_keyq
          .addr _sf_key
          .addr _sf_fcode
          .addr _sf_reset_all
.endproc
.export   _system_interface

.proc     _emulation_call
          sta   AREG
          tdc
          sta   f:DPSAVE
          tsc
          sta   f:SPSAVE
          lda   SYS_RSTK
          tcs
          lda   #$0000
          tcd
          lda   AREG
          sec          
          xce
          .a8
          .i8
          ldx   #$00
          jsr   (ECALL,x)
          php                     ; save carry state
          clc
          xce                     ; back to native
          plp                     ; get it back
          rep   #SHORT_A|SHORT_I  ; go to long registers
          .a16
          .i16
          sta   AREG              ; save A while we do this thing
          lda   f:SPSAVE
          tcs
          lda   f:DPSAVE
          tcd
          lda   AREG
          rts
.endproc

; A=call number, Y=address
.proc     _p8_call
          sty   plist
          sep   #SHORT_A
          .a8
          sta   callnum
          rep   #SHORT_A
          .a16
          tdc
          sta   f:DPSAVE
          tsc
          sta   f:SPSAVE
          lda   SYS_RSTK
          tcs
          lda   #$0000
          tcd
          sec
          xce
          .a8
          .i8
          jsr   MLI
callnum:  .byte $00
plist:    .addr $0000
          php
          clc
          xce
          plp
          rep   #SHORT_A|SHORT_I
          .a16
          .i16
          and   #$00FF
          sta   AREG
          lda   f:SPSAVE
          tcs
          lda   f:DPSAVE
          tcd
          lda   AREG
          rts
.endproc

.proc     _sf_success
          lda   #$0000
          tay
          clc
          rtl
.endproc

.proc     _sf_fail
          ldy   #.loword(-21)
          lda   #.hiword(-21)
          sec
          rtl
.endproc

.proc     _sf_pre_init
          ; Most initialization happens outside of the Forth system
          stz   ESCMODE
          plx
          bra   _sf_success
.endproc

.proc     _sf_post_init
          plx
          bra   _sf_success
.endproc

.proc     _sf_emit
          phk                     ; ensure we are working with bank 0
          plb
          plx
          jsr   _popay
          phx
          cpy   #$00
          beq   do_null           ; ignore nulls
          lda   ESCMODE
          asl
          tax
          jmp   (table,x)
table:    .addr _mode0            ; no ESC sequence in progress
          .addr _mode1            ; ESC but no [ yet
          .addr _mode2            ; ESC[ in progress
do_null:  plx
          jmp   _sf_success
.endproc

.proc     _mode0
          cpy   #$1B              ; ESC
          bne   :+
          inc   ESCMODE
          bra   done
:         cpy   #$0B              ; OF code for cursor up
          bne   :+
          ldy   #$1F              ; Apple II code for cursor up
:         jsr   _con_write
done:     plx
          jmp   _sf_success
.endproc

.proc     _mode1
          cpy   #'['              ; second char in sequence?
          beq   :+                ; yes, change modes
          stz   ESCMODE           ; otherwise back to mode 0
          phy
          ldy   #$1B
          jsr   _con_write        ; output the ESC we ate
          ply
          jsr   _con_write        ; and output this char
          bra   done
:         stz   ESCACC
          stz   ESCNUM1
          inc   ESCMODE           ; sequence started!
done:     plx
          jmp   _sf_success
.endproc

.proc     _mode2
          cpy   #' '              ; ignore spaces in codes
          beq   done
          cpy   #';'
          bne   :+
          lda   ESCACC            ; move ACC to NUM1 if ;
          sta   ESCNUM1           ; note that only supports two params!
          stz   ESCACC
          bra   done
:         tya
          sec
          sbc   #$30
          bmi   endesc            ; eat it and end ESC mode if invalid
          cmp   #$0a
          bcs   :+                ; try letters if not a digit
          tay                     ; a digit, accumulate it into ESCACC
          lda   #10               ; multiply current ESCACC by 10
          sta   MNUM2
          lda   #$0000            ; initialize result
          beq   elp
do_add:   clc
          adc   ESCACC
lp:       asl   ESCACC
elp:      lsr   MNUM2
          bcs   do_add
          bne   lp
          sta   ESCACC            ; now add the current digit
          tya
          clc
          adc   ESCACC
          sta   ESCACC
          bra   done
:         tya                     ; not a digit, try letter codes
          sbc   #'@'              ; carry was set above
          bmi   endesc
          cmp   #$1B              ; ctrl+Z
          bcc   upper             ; upper case code
          sbc   #$20              ; convert lower case to 00-1A
          bmi   endesc
          cmp   #$1B
          bcc   lower             ; lower case codes
endesc:   stz   ESCMODE
done:     plx
          jmp   _sf_success
none:     rts
upper:    asl
          tax
          jsr   (utable,x)
          bra   endesc
utable:   .addr ich               ; @ insert char
          .addr cuu               ; A cursor up
          .addr cud               ; B cursor down
          .addr cuf               ; C cursor forward
          .addr cub               ; D cursor backward
          .addr cnl               ; E cursor next line
          .addr cpl               ; F cursor previous line
          .addr cha               ; G cursor horizontal absolute
          .addr cup               ; H cursor position
          .addr none              ; I
          .addr ed                ; J erase display
          .addr el                ; K erase line
          .addr il                ; L insert lines
          .addr dl                ; M delete lines
          .addr none              ; N
          .addr none              ; O
          .addr dch               ; P delete char
          .addr none              ; Q
          .addr none              ; R
          .addr su                ; S scroll up
          .addr sd                ; T scroll down
          .addr none              ; U
          .addr none              ; V
          .addr none              ; W
          .addr none              ; X
          .addr none              ; Y
          .addr none              ; Z
lower:    asl
          tax
          jsr   (ltable,x)
          bra   endesc
ltable:   .addr none              ; `
          .addr none              ; a
          .addr none              ; b
          .addr none              ; c
          .addr none              ; d
          .addr none              ; e
          .addr cup               ; f cursor position
          .addr none              ; g
          .addr none              ; h
          .addr none              ; i
          .addr none              ; j
          .addr none              ; k
          .addr none              ; l
          .addr sgr               ; m set graphic rendition
          .addr none              ; n device status report (requires input buffer)
          .addr none              ; o
          .addr none              ; p normal screen (optional)
          .addr none              ; q invert screen (optional)
          .addr none              ; r
          .addr none              ; s reset screen (optional)
          .addr none              ; t
          .addr none              ; u
          .addr none              ; v
          .addr none              ; w
          .addr none              ; x
          .addr none              ; y
          .addr none              ; z
; cursor up
cuu:      ldy   #$1F
          jmp   con_wr_n
; cursor down
cud:      ldy   #$0A
          jmp   con_wr_n
; cursor forward
cuf:      ldy   #$1C
          jmp   con_wr_n
; cursor backwards
cub:      ldy   #$08
          jmp   con_wr_n
; cursor previous line
cpl:      jsr   cuu
          bra   :+                ; eventually repos cursor
; cursor next line
cnl:      jsr   cud
:         lda   #$0001            ; set horizontal position to 1
          sta   ESCACC
          ; fall-through to CHA
; cursor horizontal absolute
cha:      lda   a:_CV             ; get current cursor vertical
          and   #$00FF
          inc   a                 ; because ANSI counts from 1...
          sta   ESCNUM1
          ; fall-through to CUP
; cursor position
cup:      ldx   ESCACC
          beq   :+                ; if it's zero, leave it as such
          dex
:         ldy   ESCNUM1
          beq   :+
          dey
:         jmp   _goto_xy
; erase display
ed:       lda   ESCACC
          beq   clreos
          dec   a
          bne   :+
          rts                     ; if 1, clear from beginning to cursor (not supported)
:         lda   _CV               ; otherwise clear whole screen
          and   #$FF
          pha
          lda   _CH
          and   #$FF
          pha
          jsr   clrscr
          plx
          ply
          jmp   _goto_xy
clrscr:   ldy   #$0C
          jmp   _con_write
clreos:   ldy   #$0B
          jmp   _con_write
; erase line
el:       ldy   #$1D              ; clear to end of line
          lda   ESCACC
          beq   :+
          cmp   #$02
          bne   :++
erase_ln: ldy   #$1A              ; clear entire line
:         jmp   _con_write
:         rts
; insert line, cheat because no native function in firmware
; scroll the lines downward and then exit through erase_ln
il:       jsr   _cursor_off
          jsr   do_il
          dec   ESCACC
          bmi   :+
          beq   :+
          bra   il
:         jmp   _cursor_on
do_il:    lda   #23               ; start at line 23 and move toward CV
          sta   ZR                ; source line
:         lda   _CV               ; is it the current line?
          and   #$FF
          cmp   ZR
          beq   erase_ln          ; it is, erase it
          jsr   _80store_on
          lda   ZR
          asl
          tax
          ldy   _scrn_tab,x       ; get dest line address TODO change back to LDY
          dec   ZR                ; next lower line
          lda   ZR
          asl
          tax
          lda   _scrn_tab,x       ; get source line address
          tax
          jsr   _copy_line
          jsr   _80store_off
          bra   :-
; delete line
dl:       jsr   _cursor_off
          jsr   do_dl
          dec   ESCACC
          bmi   :+
          beq   :+
          bra   dl
:         jmp   _cursor_on
do_dl:    lda   _CV               ; start at CV and move toward line 23
          and   #$FF
          sta   ZR
:         lda   ZR                ; dest line
          cmp   #23               ; is it 23?
          bne   :+                ; no, go move the lines
          lda   _CV               ; save current cursor pos
          and   #$FF
          pha
          lda   _CH
          and   #$FF
          pha
          tax
          ldy   #23               ; position on bottom line
          jsr   _goto_xy
          jsr   erase_ln          ; and clear it out
          plx
          ply
          jmp   _goto_xy
:         jsr   _80store_on
          lda   ZR
          asl
          tax
          ldy  _scrn_tab,x
          inc   ZR
          lda   ZR
          asl
          tax
          lda   _scrn_tab,x
          tax
          jsr   _copy_line
          bra   :--
; insert char
ich:      rts                     ; unimplemented
; delete char
dch:      rts                     ; unimplemented
; set graphic rendition
sgr:      lda   ESCACC
          cmp   #10
          beq   mtoff
          bcc   :+
          cmp   #20
          bcc   mton
          rts            
:         and   #$01
          clc
          adc   #$0E              ; $0E = normal, $0F=inverse
          tay
          jsr   _con_write
          rts
mton:     sty   ESCNUM1
          ldy   #$1B
          jsr   _con_write
          ldy   #$0F
          bra   _con_write
mtoff:    ldy   #$18
          jsr   _con_write
          ldy   #$0E
          bra   _con_write
; scroll up
sd:       ldy   #$16
          bra   con_wr_n
su:       ldy   #$17
          ; fall-through
con_wr_n: sty   ESCNUM1
:         jsr   _con_write
          dec   ESCACC
          bmi   :+
          beq   :+
          ldy   ESCNUM1
          bra   :-
:         rts          
.endproc

.proc     _con_write
          lda   CON_WR
          sta   ECALL
          tya
          ldx   #$C3              ; required by P1.1 I/F
          ldy   #$30
          jmp   _emulation_call
.endproc

.proc     _cursor_off
          ldy   #$06
          bra   _con_write
.endproc

.proc     _cursor_on
          ldy   #$05
          bra   _con_write
.endproc

.proc     _goto_xy
          phy
          phx
          ldy   #$1E
          jsr   _con_write
          pla                     ; x coord
          clc
          adc   #32
          tay
          jsr   _con_write
          pla                     ; y coord
          clc
          adc   #32
          tay
          bra   _con_write
.endproc

; copy screen line, source base in X, dst base in Y
.proc     _copy_line
          phb
          phy
          phx
          lda   #38               ; # of chars MINUS ONE
          mvn   $00,$00           ; do main ram bytes
          sep   #SHORT_A
          sta   TXTPAGE2
          rep   #SHORT_A
          plx
          ply
          lda   #38
          mvn   $00,$00           ; do aux ram bytes
          sep   #SHORT_A
          sta   TXTPAGE1
          rep   #SHORT_A
          plb
          rts
.endproc

.proc     _80store_on
          sep   #SHORT_A
          sta   STO80_ON
          rep   #SHORT_A
          rts
.endproc

.proc     _80store_off
          sep   #SHORT_A
          sta   STO80_ON
          rep   #SHORT_A
          rts
.endproc

.proc     _sf_keyq
          lda   CON_ST
          sta   ECALL
          lda   #$01            ; check input status
          ldx   #$C3            ; required by P1.1 I/F
          ldy   #$30
          jsr   _emulation_call
          ldy   #$0000
          bcc   :+              ; if not ready
          dey
:         tya
          plx
          jsr   _pushay
          jmp   _sf_success
.endproc

.proc     _sf_key
          lda   CON_RD
          sta   ECALL
:         ldx   #$C3            ; required by P1.1 I/F
          ldy   #$30
          jsr   _emulation_call
          and   #$00FF
          beq   :-              ; reject nulls
          tay
          lda   #$0000
          plx
          jsr   _pushay
          jmp   _sf_success
.endproc

.proc     _sf_fcode             ; none for now
          lda   #$0000
          tay
          plx
          jsr   _pushay
          jmp   _sf_success
.endproc

.proc     _sf_reset_all
          lda   #Reset
          sta   ECALL
          inc   PwrByte
          jsr   _emulation_call
          jmp   _sf_fail
.endproc