; Platform support library for WDC W65C816SXB
; 
; This serves as a "reference" implementation.
; 
; This file should define any equates that are platform specific, and may be used to
; define the system interface functions if it is not supplied elsewhere.
;
; Generally the system interface is used for console I/O
; and other such things.  The function code is given in the A register, the Y register
; has the Forth stack depth, and X is the Forth stack pointer vs the direct page.
; THE X REGISTER MUST REFLECT PROPER FORTH STACK POINTER UPON RETURN!
;
; The interface function is called with the Forth direct page and return stack in effect.
; Function codes $0000-$7FFF are reserved to be defined for use by Forth.  Codes $8000-
; $FFFF may be used by the system implementator for system-specific functions.
;
; The system interface must implement functions marked as mandatory.
; System interface functions shall RTL with the expected stack effects, AY=0, and
; carry clear if successful; or shall RTL with a code for THROW in AY and carry set on
; failure.  A safe throw code for console I/O is -21 (unsupported operation).
;
; Stack cells are 2 words/4 bytes/32 bits, and the stack pointer points to the top of
; the stack.  If the system interface is defined here, the stack manipulation functions
; defined in interpreter.s may be used.  If defined elsewhere, you are on your own for
; ensuring correct operation on the stack.
;
; The system interface functions may use the direct page ZR bytes $00-$03, if they need
; more than that they can use something reserved elsewhere via long addressing or 
; by temporarily changing the direct page.
;
; Here are the function codes, expected stack results, and descriptions
;
; $0000 ( -- ) pre initialize platform - called before Forth initialization, to be used
;       for initialization that must take place before Forth initialization.
; $0001 ( -- ) post initialize platform - called after Forth initialization, to be used
;       for initialization that must take place after Forth initialization.
; $0002 ( char -- ) emit a character to the console output.  This function should
;       implement the control sequences described in IEEE 1275-1994 (a subset of the
;       ANSI terminal standard).  For serial devices, this may be assumed.
; $0003 ( -- f ) f is true if the console input has a character waiting
; $0004 ( -- char ) read a character from the console (blocking)
; $0005 ( -- addr ) return pointer to list of FCode modules to evaluate.  If pointer is
;       0, none are evaluated.  List should be 32-bit pointers ending in 0.
;       this is never called if FCode support is not included.  When this is implemented
;       the system will trust that there is FCode there and not look for a signature.
; $0006 ( -- ) perform RESET-ALL, restart the system as if reset button was pushed

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

.proc     _system_interface
          ;wdm 3
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
.if 1
          plx
          jmp   _sf_success     ; assume WDC monitor already did it
.else
          ; set up TIDE interface, the same way WDC does it
          php
          sep   #SHORT_A|SHORT_I
          .a8
          .i8
          lda   #$00
          sta   VIA2+VIA::ACR
          lda   #$00
          sta   VIA2+VIA::PCR
          lda   #%00011000      ; b3 = TUSB_RDB; b4 = ???
          sta   VIA2+VIA::ORB
          lda   #%00011100      ; set PB2, PB3, PB4 as outputs
          sta   VIA2+VIA::DDRB
          lda   #$00
          sta   VIA2+VIA::DDRA
          lda   VIA2+VIA::IRB
          pha
          and   #%11101111      ; b4 = ???
          sta   VIA2+VIA::ORB
          ldx   #$5d
          jsr   wait
          pla
          sta   VIA2+VIA::ORB
          lda   #%00100000      ; b5 = TUSB_PWRENB
:         bit   VIA2+VIA::IRB   ; wait for USB configuration
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
          tya
          ldx   #$00            ; ensure VIA2 DDR A is set up for input
          stx   VIA2+VIA::DDRA
          sta   VIA2+VIA::ORA   ; set output byte to be sent
          lda   #%00000001      ; b0 = TUSB_TXEB
:         bit   VIA2+VIA::IRB   ; wait for FT245RL to be ready to transmit
          bne   :-
          lda   VIA2+VIA::IRB
          and   #%11111011      ; b2 = TUSB_WR
          tax
          ora   #%00000100
          sta   VIA2+VIA::ORB   ; ensure FT245RL WR high
          lda   #$ff            ; set up DDR A for output
          sta   VIA2+VIA::DDRA  ; to present byte to send
          nop                   ; delay a few cycles
          nop
          stx   VIA2+VIA::ORB   ; strobe FT245RL WR low
          lda   VIA2+VIA::IRA   ; ???
          ldx   #$00
          stx   VIA2+VIA::DDRA  ; switch DDR A back to input
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
          sta   VIA2+VIA::DDRA
          lda   #%00000010
          bit   VIA2+VIA::IRB
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
          sta   VIA2+VIA::DDRA  ; Ensure VIA2 DDR A is set up for input
          lda   #%00000010      ; b1 = TUSB_RXFB
:         bit   VIA2+VIA::IRB   ; wait for FT245RL to have data & be ready
          bne   :-
          lda   VIA2+VIA::IRB
          ora   #%00001000 ;b3 = TUSB_RDB
          tax
          and   #%11110111
          sta   VIA2+VIA::ORB   ; strobe FT245RL RD# low
          nop                   ;delay some cycles
          nop
          nop
          nop
          ldy   VIA2+VIA::IRA   ; receive byte
          stx   VIA2+VIA::ORB   ; strobe FT245RL RD# high
          plp
          .a16
          .i16
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

; SXB really can't do this when ROM is banked out.  Maybe restart Forth instead?
.proc     _sf_reset_all
          plx
          jmp   _sf_fail
.endproc

; Read ROM, virtual address $bb00xxxx in WR, length in XR, destination in YR
; where bb is the ROM bank number (0-3) and xxxx is the physical address in the ROM.
; This routine will be moved into RAM in order to read the contents of the ROM.
.proc     _sxb_readrom
          php                   ; save register size & interrupt state
          sei                   ; disable IRQs since we are switching the ROM
          sep   #SHORT_A
          .a8
          lda   VIA2+VIA::PCR   ; save existing PCR
          pha
          lda   WR+3            ; get bank #
          ror
          php
          ror
          lda   #$00
          bcs   :+
          ora   #%11000000
:         plp
          bcs   :+
          ora   #%00001100
:         sta   VIA2+VIA::PCR
          ldy   XR
lp:       dey
          bmi   done
          lda   [WR],y
          sta   [YR],y
          bra   lp
done:     pla
          sta   VIA2+VIA::PCR   ; restore PCR
          plp                   ; restore register size & interrupt state
          .a16
          rtl                   ; note long return
.endproc
