; Platform support library for GoSXB

cpu_clk   = 8000000

.enum     ACIA
          RXD
          SR
          CMD
          CTL
          TXD = RXD
.endenum

ACIA1     = $7F80

.enum     PIA
          PIA
          CRA
          PIB
          CRB
          DDRA = PIA
          DDRB = PIB
.endenum

PIA1      = $7FA0

.enum     VIA
          ORB
          ORA
          DDRB
          DDRA
          T1C_L
          T1C_H
          T1L_L
          T1L_H
          T2C_L
          T2C_H
          SR
          ACR
          PCR
          IFR
          IER
          ORA2
          IRB = ORB
          IRA = ORA
.endenum

VIA1      = $7FC0
VIA2      = $7FE0

dstart "gosxb"
dchain H_FORTH                   ; Make branch off the word FORTH

dword     GOSXB_TEST,"TEST"
          ENTER
          SLIT "Success?"
          .dword TYPE
          EXIT
eword

dend

.proc     _system_interface
          ;wdm 3
          phx
          asl
          tax
          jmp   (.loword(table),x)
table:    .addr _sf_pre_init
          .addr _sf_post_init
          .addr _sf_emit
          .addr _sf_keyq
          .addr _sf_key
          .addr _sf_fcode
          .addr _sf_reset_all
.endproc
.export   _system_interface

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
.if 0
          plx
          jmp   _sf_success     ; assume WDC monitor already did it
.else
          ; set up TIDE interface, the same way WDC does it
          php
          sep   #SHORT_A|SHORT_I
          .a8
          .i8
          lda   #$00
          sta   f:VIA2+VIA::ACR
          sta   f:VIA2+VIA::PCR
          lda   #%00011000      ; b3 = TUSB_RDB; b4 = ???
          sta   f:VIA2+VIA::ORB
          lda   #%00011100      ; set PB2, PB3, PB4 as outputs
          sta   f:VIA2+VIA::DDRB
          lda   #$00
          sta   VIA2+VIA::DDRA
          lda   VIA2+VIA::IRB
          pha
          and   #%11101111      ; b4 = ???
          sta   f:VIA2+VIA::ORB
          ldx   #$5d
          jsr   wait
          pla
          sta   f:VIA2+VIA::ORB
:         lda   f:VIA2+VIA::IRB   ; wait for USB configuration
          bit   #%00100000      ; b5 = TUSB_PWRENB
          bne   :-
          plp
          plx
          jmp   _sf_success
wait:     phx                   ; note 8-bit mode!
          ldx   #$00
:         dex
          bne   :-
          plx
          dex
          bne   wait
          rts
          .a16
          .i16
.endif
.endproc

.proc     _sf_post_init
          plx
          ; Here we make a vocabulary definition for the gosxb dictionary
          ; that we defined at the beginning of this file.
          ENTER
          ONLIT  LAST_gosxb
          SLIT   "GOSXB"
          .dword dVOCAB
          .dword LAST           ; now set the head of the vocabulary to the
          .dword drXT           ; last word defined in the neon816 dictionary
          .dword rBODY
          .dword STORE
          CODE
          jmp   _sf_success
.endproc

.proc     _sf_emit
          plx
          jsr   _popay
          phx
          php
          sep   #SHORT_A|SHORT_I
          .a8
          .i8
          lda   #$00            ; ensure VIA2 DDR A is set up for input
          sta   f:VIA2+VIA::DDRA
          tya
          sta   f:VIA2+VIA::ORA ; set output byte to be sent
:         lda   f:VIA2+VIA::IRB ; wait for FT245RL to be ready to transmit
          bit   #%00000001      ; b0 = TUSB_TXEB
          bne   :-
          lda   f:VIA2+VIA::IRB
          and   #%11111011      ; b2 = TUSB_WR
          tax
          ora   #%00000100
          sta   f:VIA2+VIA::ORB ; ensure FT245RL WR high
          lda   #$ff            ; set up DDR A for output
          sta   f:VIA2+VIA::DDRA  ; to present byte to send
          nop                   ; delay a few cycles
          txa
          sta   f:VIA2+VIA::ORB ; strobe FT245RL WR low
          lda   VIA2+VIA::IRA   ; get output byte back (we don't really need it)
	      xba
          lda   #$00
          sta   f:VIA2+VIA::DDRA  ; switch DDR A back to input
          xba
          plp
          .a16
          .i16
          plx
          jmp   _sf_success
.endproc

.proc     _sf_keyq
          lda   #$00
          tay                     ; anticipate false
          php
          sep   #SHORT_A
          .a8
          sta   f:VIA2+VIA::DDRA
          lda   f:VIA2+VIA::IRB
          bit   #%00000010
          bne   :+
          dey                     ; from $0000 to $FFFF
:         plp
          .a16
          tya
          plx
          jsr   _pushay
          jmp   _sf_success
.endproc

.proc     _sf_key
          php
          tay
          sep   #SHORT_A|SHORT_I
          .a8
          .i8
          lda   #$00
          sta   f:VIA2+VIA::DDRA  ; Ensure VIA2 DDR A is set up for input
:         lda   f:VIA2+VIA::IRB   ; wait for FT245RL to have data & be ready
          bit   #%00000010      ; b1 = TUSB_RXFB
          bne   :-
          lda   f:VIA2+VIA::IRB
          ora   #%00001000 ;b3 = TUSB_RDB
          tax
          and   #%11110111
          sta   f:VIA2+VIA::ORB   ; strobe FT245RL RD# low
          nop                   ;delay some cycles
          nop
          nop
          nop
          lda   f:VIA2+VIA::IRA   ; receive byte
          tay
          txa
          sta   f:VIA2+VIA::ORB   ; strobe FT245RL RD# high
          plp
          .a16
          .i16
          lda   #$0000
          plx
          jsr   _pushay
          jmp   _sf_success
.endproc

.proc     _sf_fcode
.if include_fcode
          ldy   #.loword(list)
          lda   #.hiword(list)
.else
          lda   #$0000
          tay
.endif
          plx
          jsr   _pushay
          jmp   _sf_success
.if include_fcode
list:
          .dword 0
.endif

.endproc

; SXB really can't do this when ROM is banked out.  Maybe restart Forth instead?
.proc     _sf_reset_all
          plx
          jmp   _sf_fail
.endproc

