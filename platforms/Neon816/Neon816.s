.p816
.a16
.i16
.include  "macros.inc"
.import   _Forth_initialize
.import   _Forth_ui
.import   _system_interface

; Bank Map from FB posting by Lenore:
; 00 Bank Mapper (16 blocks of 4k each, configured via MMU)
; 08-0F Bus Controller Peripherals
; - 08 0000-003F MMU
; -- 00: 0-3 Unused, 4-7: Upper RAM bits
; -- 01: Bank
; - 09 FDC
; 10-1F Internal Bus Bridge
; 20-27 Flash ROM
; 28-3F Reserved for Flash
; 30-3F Reserved for Expansion Flash
; 40-47 Video RAM
; 48-7F Reserved for VRAM
; 80-87 RAM 1
; 88-8F RAM 2
; 90-FF Reserved for RAM

.pushseg
.segment  "FStartup"
.proc     startup
          clc
          xce
          rep   #SHORT_A|SHORT_I
          .a16
          .i16
          ; MMU setup, maybe.  Found at page $FF in Neon bank 0
          ldx   #$001C
          lda   #$8000
:         sta   f:$080000,x
          dex
          dex
          bpl   :-
          ; NeonFORTH does this, presumably to initialize the serial port
          sep   #SHORT_A          ; not necessary unless we were already native & long
          .a8
          lda   #$8D
          sta   f:$10000A
          lda   #$06
          sta   f:$10000B
          lda   #$00
          sta   f:$10000C
          rep   #SHORT_A|SHORT_I
          .a16
          .i16
          lda   #$0000            ; direct page for Forth
          tcd
          lda   #.hiword($0A0000)   ; top of dictionary memory
          pha
          lda   #.loword($0A0000)
          pha
          lda   #.hiword($090000)   ; bottom of dictionary
          pha
          lda   #.loword($090000)
          pha
          lda   #$0200            ; first usable stack cell (relative to direct page)
          pha
          lda   #$0100            ; last usable stack cell+1 (relative to direct page)
          pha
          lda   #$03FF            ; return stack first usable byte
          pha
          lda   #.hiword(_system_interface)
          pha
          lda   #.loword(_system_interface)
          pha
          jsl   _Forth_initialize
          jsl   _Forth_ui
          brk
          .byte $00
.endproc
.popseg
