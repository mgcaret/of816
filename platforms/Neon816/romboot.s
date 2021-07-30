 .p816
.a16
.i16
.include  "macros.inc"
.include  "./Neon816-hw.inc"

.segment  "ROMBOOT"
.proc     romboot
          ; Go full native mode
          clc
          xce
          rep   #SHORT_A|SHORT_I
          .a16
          .i16
          lda   #$01FF
          tcs
          ; Set up MMU for bank 0 - map all but the top 4K to bank $80,
          ; leaving the top (MMU) page for ROM
          ldx   #$001C
          lda   #$8000
:         sta   f:NeonMMU,x
          dex
          dex
          bpl   :-
          jml   f:Neon_ROM        ; assume main firmware starts at $200000
.endproc

.segment  "VECTORS"
.proc     vectors
          ; native mode vectors
          .word $FFFF             ; FFE0 - reserved
          .word $FFFF             ; FFE2 - reserved
          .word $FFFF             ; FFE4 - COP
          .word .loword(romboot)  ; FFE6 - BRK - handle like reset for now
          .word $FFFF             ; FFE8 - ABORT
          .word $FFFF             ; FFEA - NMI
          .word $FFFF             ; FFEC - reserved
          .word $FFFF             ; FFEE - IRQ
          ; emulation mode vectors
          .word $FFFF             ; FFF0 - reserved
          .word $FFFF             ; FFF2 - reserved
          .word $FFFF             ; FFF4 - COP
          .word $FFFF             ; FFF6 - reserved
          .word $FFFF             ; FFF8 - ABORT
          .word $FFFF             ; FFFA - NMI
          .word .loword(romboot)  ; FFFC - RESET
          .word .loword(romboot)  ; FFFE - IRQ/BRK - handle like reset for now
.endproc
