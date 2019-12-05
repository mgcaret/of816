.p816
.a16
.i16
.include  "macros.inc"
.include  "./Neon816-hw.inc"
.import   _Forth_initialize
.import   _Forth_ui
.import   _system_interface

.pushseg
.segment  "FStartup"
.proc     startup
          clc
          xce
          phk
          plb
          rep   #SHORT_A|SHORT_I
          .a16
          .i16
          lda   #$0000            ; direct page for Forth
          tcd
          lda   #.hiword(Neon_RAM1+$020000) ; top of dictionary memory
          pha
          lda   #.loword(Neon_RAM1+$020000)
          pha
          lda   #.hiword(Neon_RAM1+$010000) ; bottom of dictionary
          pha
          lda   #.loword(Neon_RAM1+$010000)
          pha
          lda   #$0400            ; first usable stack cell (relative to direct page)
          pha
          lda   #$0204            ; last usable stack cell+1 (relative to direct page)
          pha
          lda   #$01EF            ; return stack first usable byte
          pha
          lda   #.hiword(_system_interface)
          pha
          lda   #.loword(_system_interface)
          pha
          jsl   _Forth_initialize
          jsl   _Forth_ui
          jmp   startup
.endproc
.popseg
