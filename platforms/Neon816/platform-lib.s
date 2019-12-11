; Platform support library for Neon816
; 
.include  "./Neon816-hw.inc"

; Neon816 dictionary, a bit of a different approach than the other ports
; This will get set up by the post init function of the system interface
; The system interface functions are after this dictionary.

; Note that most of the words are based on words found in NeonFORTH and
; are not subject to the OF816 license terms, but rather any terms that
; Lenore Byron places on them.

dstart "neon816"
dchain H_FORTH                   ; Make branch off the word FORTH

dword     PS2K_STORE,"PS2K!"
          jsr   _popay
          tya
          sep   #SHORT_A
          .a8
          sta   f:PS2Kio
:         lda   f:PS2Kstat
          bit   #$08
          bne   :-
          rep   #SHORT_A
          .a16
          NEXT
eword

dword     PS2K_QUERY,"PS2K?"
          ldy   #$0000
          sep   #SHORT_A
          .a8
          lda   f:PS2Kstat
          ror
          rep   #SHORT_A
          .a16
          bcc   :+
          dey
:         tya
          PUSHNEXT
eword

dword     PS2K_FETCH,"PS2K@"
          lda   #$0000
          sep   #SHORT_A
          .a8
:         lda   f:PS2Kstat
          ror
          bcc   :-
          lda   f:PS2Kio
          rep   #SHORT_A
          .a16
          tay
          lda   #$0000
          PUSHNEXT
eword

dword     PS2M_STORE,"PS2M!"
          jsr   _popay
          tya
          sep   #SHORT_A
          .a8
          sta   f:PS2Mio
:         lda   f:PS2Mstat
          bit   #$08
          bne   :-
          rep   #SHORT_A
          .a16
          NEXT
eword

dword     PS2M_QUERY,"PS2M?"
          ldy   #$0000
          sep   #SHORT_A
          .a8
          lda   f:PS2Mstat
          ror
          rep   #SHORT_A
          .a16
          bcc   :+
          dey
:         tya
          PUSHNEXT
eword

dword     PS2M_FETCH,"PS2M@"
          lda   #$0000
          sep   #SHORT_A
          .a8
:         lda   f:PS2Mstat
          ror
          bcc   :-
          lda   f:PS2Mio
          rep   #SHORT_A
          .a16
          tay
          lda   #$0000
          PUSHNEXT
eword

; this probably isn't fast enough to reliably set micro and milliseconds
dword     SETRTC,"SETRTC"
          ENTER
          ONLIT  RTCus
          .dword WSTORE
          ONLIT  RTCms
          .dword WSTORE
          ONLIT  RTCsec
          .dword CSTORE
          ONLIT  RTCmin
          .dword CSTORE
          ONLIT  RTChour
          .dword CSTORE
          ONLIT  RTCday
          .dword WSTORE
          EXIT
eword

dword     GETRTC,"GETRTC"
          ENTER
          ONLIT  RTCday
          .dword WFETCH
          ONLIT  RTChour
          .dword CFETCH
          ONLIT  RTCmin
          .dword CFETCH
          ONLIT  RTCsec
          .dword CFETCH
          ONLIT  RTCms
          .dword WFETCH
          ONLIT  RTCus
          .dword WFETCH
          EXIT
eword

dend

; and now for the system interface

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
          ; NeonFORTH does this, presumably to initialize the serial port
          ; The code from here to the EOC commment was adapted from code written by Lenore Byron
          sep   #SHORT_A
          .a8
          lda   #$8D
          sta   f:SERctrlA
          lda   #$06
          sta   f:SERctrlB
          lda   #$00
          sta   f:SERctrlC
          rep   #SHORT_A
          .a16
          ; EOC
          plx
          jmp   _sf_success
.endproc

.proc     _sf_post_init
          plx
          ; Here we make a vocabulary definition for the neon816 dictionary
          ; that we defined at the beginning of this file.
          ENTER
          ONLIT  LAST_neon816
          SLIT   "NEON816"
          .dword dVOCAB
          .dword LAST           ; now set the head of the vocabulary to the
          .dword drXT           ; last word defined in the neon816 dictionary
          .dword rBODY
          .dword STORE
          CODE
          jmp   _sf_success
.endproc

.proc     _sf_emit
          plx                   ; get forth SP
          jsr   _popay          ; grab the top item
          phx                   ; and save new SP
          ; The code from here to the EOC commment was adapted from code written by Lenore Byron
          sep   #SHORT_A
          .a8
          tya
          sta   f:SERio
:         lda   f:SERstat
          bit   #$08
          bne   :-
          rep   #SHORT_A
          .a16
          ; EOC
          plx
          jmp   _sf_success
.endproc

.proc     _sf_keyq
          ldy   #$0000          ; anticipate false
          ; The code from here to the EOC commment was adapted from code written by Lenore Byron
          sep   #SHORT_A
          .a8
          lda   f:SERstat       ; b0=1 if data ready
          ror
          bcc   :+
          iny
:         rep   #SHORT_A
          .a16
          ; EOC
          tya
          plx
          jsr   _pushay
          jmp   _sf_success
.endproc

.proc     _sf_key
          ; The code from here to the EOC commment was adapted from code written by Lenore Byron
          sep   #SHORT_A
          .a8
:         lda   f:SERstat
          ror
          bcc   :-
          lda   f:SERio
          rep   #SHORT_A
          .a16
          ; EOC
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

