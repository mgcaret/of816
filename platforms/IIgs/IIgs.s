.p816
.a8
.i8
.include  "platform-config.inc"
.include  "macros.inc"
.include  "equates.inc"
.include  "platform-include.inc"
.import   _Forth_initialize
.import   _Forth_ui
.import   _system_interface

.pushseg
.segment  "FStartup"
; In the IIgs we enter here at $2000 in emulation mode from ProDOS 8
          bra   startup
MasterId: .word 0
;UserId:   .word 0                ; Now in page 3
BankLoad: .word 0
Bnk0Hnd:  .dword 0
Bnk1Hnd:  .dword 0
DataHnd:  .dword 0

.proc     startup
          sec
          jsr   IDRoutine
          bcc   :+
          jmp   quit
:         lda   #$C3
          sta   CON_RD+1
          sta   CON_WR+1
          sta   CON_ST+1
          sta   ECALL+1
          lda   $C30D
          sta   ECALL
          lda   $C30E
          sta   CON_RD
          lda   $C30F
          sta   CON_WR
          lda   $C310
          sta   CON_ST
          ldx   #$00
          jsr   (ECALL,x)
          lda   #'0'
          sta   $800
          clc
          xce
          rep   #SHORT_A|SHORT_I
          .a16
          .i16
          phk
          plb
          jsr   _prep_tools       ; get the GS toolbox ready to use
          pea   $0000             ; now let's ask for memory for the data space
          pea   $0000             ; result space
          lda   #.hiword(data_space_size)
          pha
          lda   #.loword(data_space_size)
          pha
          lda   f:UserId
          pha
          lda   #%1100000000001100 ; locked, unpurgeable, page-align, may cross banks
          pha
          pea   $0000
          pea   $0000
          _NewHandle
          ply                     ; low byte
          plx                     ; high byte
          _Err
          sty   DataHnd           ; save the handle for later deref
          stx   DataHnd+2
          ; now we can start the Forth initialization
          ; we need to set direct page and then push the remaining initialization
          ; parameters onto the (system) return stack.
          lda   #$0800            ; direct page for Forth
          tcd
          sty   ZR                ; put DataHnd in ZR for deref
          stx   ZR+2
          lda   #$0000            ; top of data space, will store later
          pha
          pha
          ldy   #$0000
          lda   [ZR],y            ; dereferenced low byte
          tax
          clc
          adc   #.loword(data_space_size)
          sta   1,s               ; update top of data space low word
          iny
          iny
          lda   [ZR],y            ; dereferenced high byte
          pha
          adc   #.hiword(data_space_size)
          sta   5,s               ; update top of data space high word
          phx
          lda   #$0300            ; first usable stack cell (relative to direct page)
          pha                     ; $800 + $0300 = $0B00
          lda   #$0100            ; last usable stack cell+1 (relative to direct page)
          pha                     ; $800 + $0100 = $0900
          lda   #$0DFF            ; return stack first usable byte
          pha
          lda   #.hiword(_system_interface)
          pha
          lda   #.loword(_system_interface)
          pha
          lda   #'1'
          sta   $800
          jsl   _Forth_initialize
          lda   #'2'
          sta   $800
          jsl   _Forth_ui
          lda   #'3'
          sta   $800
          ; When Forth returns, BYE was executed, clean up and quit
          lda   #$0000            ; restore direct page to page 0
          tcd
          .if 0
          lda   f:UserId
          pha
          _DisposeAll
          .else
          ldx   DataHnd+2         ; dispose of our data space
          ldy   DataHnd
          phx
          phy
          _DisposeHandle
          .endif
          _Err
          lda   f:UserId
          pha
          _MMShutDown             ; Shut down memory manager
quit:     sec                     ; exit back to P8 or GS/OS
          xce
          .a8
          .i8
          jsr   MLI
          .byte $65
          .addr p_QUIT
          brk
          .byte $00
p_QUIT:   .byte 4
          .byte 0
          .addr 0
          .byte 0
          .addr 0
.endproc
          .a16
          .i16


; Thanks to Dagen Brock for this, adapted from:
; https://github.com/digarok/gslib/blob/master/source/p8_tools.s
.proc     _prep_tools
          stz   MasterId          ; Clear Master ID
          _TLStartUp              ; start Tool Locator
          pha                     ; result space
          _MMStartUp              ; start Memory Manager
          pla                     ; User ID
          bcs   :+
          brl   MM_OK
:         _MTStartUp              ; start Misc Tools
          pha                     ; result space
          pea   $1000             ; b15-12 $1 = Application
          _GetNewId               ; get a new user ID
          pla
          sta   MasterId          ; save it
          pha                     ; result space
          pha
          pea   $0000             ; block size ($0000B800)
          pea   $B800
          lda   MasterId
          pha                     ; User ID
          pea   $C002             ; attributes (locked, fixed, unmovable)
          pea   $0000             ; location ($00000800)
          pea   $0800
          _NewHandle
          ply                     ; get handle for bank 0
          plx
          _Err
          sty   Bnk0Hnd
          stx   Bnk0Hnd+2
          pha                     ; now do bank 1
          pha
          pea   $0000
          pea   $B800
          lda   MasterId
          pha
          pea   $C002
          pea   $0001
          pea   $0800
          _NewHandle
          ply                     ; get handle for bank 1
          plx
          _Err
          sty   Bnk1Hnd
          stx   Bnk1Hnd+2
          pha                     ; result space
          _MMStartUp
          pla
          _Err
MM_OK:    sta   f:UserId
          rts
.endproc

.popseg
