; This is a stub ROM for the GoSXB emulator that will jump to $200000 upon
; reset, NMI, or BRK.
; For every other kind of interrupt, it causes GoSXB to exit.  If it happens
; to be running on real hardware, it will hang instead of exit.
; The purpose of this stub is to execute OF816 in ROM in bank $20.

.p816
.a16
.i16
.include  "macros.inc"

.segment  "ROMBOOT"
.proc     romboot
          jml   f:$200000
.endproc

.proc     emuirq
          pha
          lda   2,s
          and   #%00100000
          bne   romboot           ; if BRK, handle like we reset.
          pla                     ; in case we want to RTI or something in the future
          ; fall-through
.endproc

.proc     die
          wdm   $FF               ; GoSXB will exit
hang:     bra   hang              ; Anything else will hang
.endproc

.segment  "VECTORS"
.proc     vectors
          ; native mode vectors
          .word $FFFF             ; FFE0 - reserved
          .word $FFFF             ; FFE2 - reserved
          .word .loword(die)      ; FFE4 - COP
          .word .loword(romboot)  ; FFE6 - BRK
          .word .loword(die)      ; FFE8 - ABORT
          .word .loword(romboot)  ; FFEA - NMI
          .word $FFFF             ; FFEC - reserved
          .word .loword(die)      ; FFEE - IRQ
          ; emulation mode vectors
          .word $FFFF             ; FFF0 - reserved
          .word $FFFF             ; FFF2 - reserved
          .word .loword(die)      ; FFF4 - COP
          .word $FFFF             ; FFF6 - reserved
          .word .loword(die)      ; FFF8 - ABORT
          .word .loword(romboot)  ; FFFA - NMI
          .word .loword(romboot)  ; FFFC - RESET
          .word .loword(emuirq)   ; FFFE - IRQ/BRK
.endproc
