; Platform support library for Neon816
; 

cpu_clk   = 14000000

; Serial Port Hardware
ser_stat  = $100009             ; read: b0 set if data waiting, b3 set if still sending data
ser_io    = $100008             ; read: receive data. write: send data


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
          plx
          jmp   _sf_success     ; we'll see what we need to do
.endproc

.proc     _sf_post_init
          plx
          jmp   _sf_success
.endproc

.proc     _sf_emit
          plx                   ; get forth SP
          jsr   _popay          ; grab the top item
          phx                   ; and save new SP
          sep   #SHORT_A
          .a8
          tya
          sta   f:ser_io
:         lda   f:ser_stat
          bit   #$08
          bne   :-
          rep   #SHORT_A
          .a16
          plx
          jmp   _sf_success
.endproc

.proc     _sf_keyq
          ldy   #$0000          ; anticipate false
          sep   #SHORT_A
          .a8
          lda   f:ser_stat      ; b0=1 if data ready
          ror
          bcc   :+
          iny
:         rep   #SHORT_A
          .a16
          tya
          plx
          jsr   _pushay
          jmp   _sf_success
.endproc

.proc     _sf_key
          sep   #SHORT_A
          .a8
:         lda   f:ser_stat
          ror
          bcc   :-
          lda   f:ser_io
          rep   #SHORT_A
          .a16
          and   #$00FF
          tay
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

; TODO....
.proc     _sf_reset_all
          plx
          jmp   _sf_fail
.endproc
