; Platform support library for Neon816
; 
.include  "./Neon816-hw.inc"

PLATF_DP  = DP_END
KEYMODS   = PLATF_DP              ; keyboard modifiers, 16 bits
                                  ;   b15 = left shift
                                  ;   b14 = right shift
                                  ;   b7  = left ctrl
                                  ;   b6  = right ctrl
                                  ;   these 3 are same  position as set LED command:
                                  ;   b2  = scroll lock (reserved)
                                  ;   b1  = num lock (reserved)
                                  ;   b0  = caps lock
PS2DEVS   = KEYMODS+2             ; b15=ran b1=mouse, b0=keyboard

; Neon816 dictionary, a bit of a different approach than the other ports
; This will get set up by the post init function of the system interface
; The system interface functions are after this dictionary.

; Note that most of the words are based on words found in NeonFORTH and
; are not subject to the OF816 license terms, but rather any terms that
; Lenore Byron places on them.

dstart "neon816"
dchain H_FORTH                    ; Make branch off the word FORTH

; H: ( byte -- ) write byte to PS/2 keyboard port.
dword     PS2K_STORE,"PS2K!"
          jsr   _popay
          tya
          jsr   ps2k_write
          NEXT
eword

; H: ( -- f ) f is true if data waiting at PS/2 keyboard port.
dword     PS2K_QUERY,"PS2K?"
          jsr   ps2k_ready
ret:      ldy   #$0000
          bcc   :+
          dey
:         tya
          PUSHNEXT
eword

; H: ( -- byte ) read byte from PS/2 keyboard port.
dword     PS2K_FETCH,"PS2K@"
          jsr   ps2k_read
          jsr   _pusha
          NEXT
eword

; H: ( -- c ) wait for keypress on PS/2 port, c is the character typed.
dword     PS2KEY,"PS2KEY"
          jsr   ps2_keyin
          jsr   _pusha
          NEXT
eword

; H: ( -- code f ) read raw keycode from PS/2 port.
; H: code is keycode, either xx or E0xx, f is true if break.
dword     PS2KRAW,"PS2KRAW"
          jsr   ps2_readcode
          php
          jsr   _pusha
          ldy   #$00
          plp
          bcc   :+
          dey
:         tya
          PUSHNEXT
eword

; H: ( byte -- ) write byte to PS/2 mouse port.
dword     PS2M_STORE,"PS2M!"
          jsr   _popay
          tya
          jsr   ps2m_write
          NEXT
eword

; H: ( -- f ) f is true if data waiting at PS/2 mouse port.
dword     PS2M_QUERY,"PS2M?"
          jsr   ps2m_ready
          bra   PS2K_QUERY::ret
eword

; H: ( -- byte ) read byte from PS/2 keyboard port.
dword     PS2M_FETCH,"PS2M@"
          jsr   ps2m_read
          jsr   _pusha
          NEXT
eword

; H: ( -- xmov ymov buttons ) read mouse relative movement
; expects mouse to be in remote mode
dword     PS2MRAW,"PS2MRAW"
          lda   #$0000
          tay
          jsr   _pushay           ; 8 X movement
          jsr   _pushay           ; 4 Y movement
          jsr   _pushay           ; 0 buttons
          lda   #$00EB            ; "read data"
          jsr   ps2m_command
          bne   :++               ; not what we expected, return zeros
          jsr   ps2m_read         ; buttons, sign bits, overflow bits, etc.
          tay                     ; we need it a few times
          and   #$000F            ; buttons and "always 1" bit
          sta   STACKBASE+0
          jsr   ps2m_read         ; X movement
          sta   STACKBASE+8
          jsr   ps2m_read         ; Y movement
          sta   STACKBASE+4
          tya
          and   #%00010000        ; X sign bit
          beq   :+
          lda   #$FFFF
          sta   STACKBASE+9,x
          sta   STACKBASE+10,x
:         tya
          and   #%00100000        ; Y sign bit
          beq   :+
          lda   #$FFFF
          sta   STACKBASE+5,x
          sta   STACKBASE+6,x
:         NEXT
eword

; detect PS/2 devices, return:
; b0=kbd present, b1=mouse present, b7 = always 1
hword     dPS2DET,"$PS2DET"
          ldy   PS2DEVS           ; you can't hotplug PS/2
          bne   done              ; so shortcut if we've done this already
          lda   #$8000            ; bit that is always set so we know we did it already
          pha
          ldy   #$00FF            ; PS/2 reset command
          tya
          jsr   ps2k_write        ; reset keyboard
          tya
          jsr   ps2m_write        ; reset mouse
          stz   KEYMODS           ; we reset that sucka
          lda   #500              ; wait some time for devices to reset
          jsr   _mswait
          lda   #500
          jsr   _mswait
          jsr   ps2k_ready        ; see if keyboard is ready
          bcs   :+
          lda   #250              ; give KB just a little more time
          jsr   _mswait
          jsr   ps2k_ready        ; and check again
:         bcc   :+                ; if not ready, do not flag it
          lda   #%1               ; otherwise, set the bit
          ora   1,s
          sta   1,s
:         jsr   ps2m_ready        ; now check on the mouse
          bcc   :+                ; if not there, we are done
          lda   #$F0              ; remote mode - turn off streaming
          jsr   ps2m_command
          lda   #%10              ; and flag present
          ora   1,s
          sta   1,s
:         ply
          sty   PS2DEVS
done:     lda   #$0000
          PUSHNEXT
eword

; H: ( day hour minutes seconds ms us -- ) set RTC
; The registers must be set starting with the microseconds and ending with the day
; when the day is written the clock registers are copied to the internal registers
dword     SETRTC,"SETRTC"
          txa
          clc
          adc   #20
          cmp   STK_TOP
          bcc   :+
          jmp   _stku_err
:         lda   STACKBASE+0,x
          sta   RTCus
          lda   STACKBASE+4,x
          sta   RTCms
          sep   #SHORT_A
          .a8
          lda   STACKBASE+8,x
          sta   RTCsec
          lda   STACKBASE+12,x
          sta   RTCmin
          lda   STACKBASE+16,x
          sta   RTChour
          rep   #SHORT_A
          .a16
          lda   STACKBASE+20,x
          sta   RTCday
          txa
          clc
          adc   #24
          tax
          NEXT
eword

; H: ( -- day hour minutes seconds ms us ) get RTC
; The registers must be read starting with the microseconds to copy the internal
; registers to the clock registers.
dword     GETRTC,"GETRTC"
          lda   #$0000
          tay
          jsr   _pushay
          jsr   _pushay
          jsr   _pushay
          jsr   _pushay
          jsr   _pushay
          jsr   _pushay
          lda   RTCus
          sta   STACKBASE+0,x
          lda   RTCms
          sta   STACKBASE+4,x
          sep   #SHORT_A
          .a8
          lda   RTCsec
          sta   STACKBASE+8,x
          lda   RTCmin
          sta   STACKBASE+12,x
          lda   RTChour
          sta   STACKBASE+16,x
          rep   #SHORT_A
          .a16
          lda   RTCday
          sta   STACKBASE+20,x
          NEXT
eword

.proc     _getms
          lda   RTCus             ; latch clock registers
          lda   RTCms             ; get ms
          rts
.endproc

; waits for up to 511 ms (ms timer is 0-999)
.proc     _mswait
          and   #$1FF
          beq   :++
          pha
          jsr   _getms
          and   #$1FF
          pha
:         jsr   _getms
          sec                     ; should we worry about 1 ms?
          sbc   1,s
          and   #$1FF
          cmp   3,s
          bcc   :-
          pla
          pla
:         rts
.endproc

; NOTE: sets short accumulator and leaves it that way on exit!
.proc     I2C2_busy_wait
          sep   #SHORT_A
nosep:
          .a8
:         lda   f:I2C2ctrl
          rol
          bcs   :-
          rts
          .a16
.endproc

; H: ( -- ) start I2C2 communication.
dword     I2C2START,"I2C2START"
          jsr   I2C2_busy_wait
          .a8
          lda   #$01
          sta   f:I2C2ctrl
          rep   #SHORT_A
          .a16
          NEXT
eword

; H: ( -- ) stop I2C2 communication.
dword     I2C2STOP,"I2C2STOP"
          jsr   I2C2_busy_wait
          .a8
          lda   #$02
          sta   f:I2C2ctrl
          rep   #SHORT_A
          .a16
          NEXT
eword

; H: ( byte -- ) write byte to I2C2.
dword     I2C2_STORE,"I2C2!"
          jsr   _popay
          jsr   I2C2_busy_wait
          .a8
          tya
          sta   f:I2C2io
          lda   #$08
          sta   f:I2C2ctrl
          rep   #SHORT_A
          .a16
          NEXT
eword

; H: ( -- byte ) receive byte from I2C2, send ack.
dword     I2C2_FETCH_ACK,"I2C2@+"
          jsr   I2C2_busy_wait
          .a8
          lda   #$44
dofetch:  sta   f:I2C2ctrl
          jsr   I2C2_busy_wait::nosep
          lda   f:I2C2io
          rep   #SHORT_A
          .a16
          and   #$00FF
          jsr   _pusha
          NEXT
eword

; H: ( -- byte ) receive byte from I2C2, do not send ack.
dword     I2C2_FETCH,"I2C2@"
          jsr   I2C2_busy_wait
          .a8
          lda   #$04
          bra   I2C2_FETCH_ACK::dofetch
          .a16
eword

; H: ( offset byte -- ) write byte to VDC at offset
dword     VDC_C_STORE,"VDCC!"
          jsr   _popay            ; pop offset
          phy                     ; save low word
          jsr   _popay            ; pop value to write
          pla                     ; get offset back
          phx                     ; save SP
          tax                     ; offset to x reg
          sep   #SHORT_A          ; whew! that was fun!
          .a8
          tya                     ; value to A
          sta   f:VDCbase,x
          rep   #SHORT_A
          .a16
          plx                     ; restore SP
          NEXT
eword

; H: ( offset -- byte ) read byte from VDC at offset
dword     VDC_C_FETCH,"VDCC@"
          jsr   _popay            ; pop offet
          phx                     ; save SP
          tya
          tax
          sep   #SHORT_A          ; whew! that was fun!
          .a8
          lda   f:VDCbase,x
          rep   #SHORT_A
          .a16
          plx                     ; restore SP
          and   #$00FF
          jsr   _pusha
          NEXT
eword

; H: ( offset word -- ) write word to VDC at offset
dword     VDC_STORE,"VDC!"
          jsr   _popay            ; again! again! again!
          phy
          jsr   _popay
          pla
          phx
          tax
          tya
          sta   f:VDCbase,x
          rep   #SHORT_A
          .a16
          plx                     ; restore SP
          NEXT
eword

dword     VIDSTART,"VIDSTART"
          ENTER
          ONLIT $0799
          ONLIT $10
          .dword VDC_STORE
          ONLIT $0839
          ONLIT $12
          .dword VDC_STORE
          ONLIT $03C7
          ONLIT $14
          .dword VDC_STORE
          ONLIT $041E
          ONLIT $16
          .dword VDC_STORE
          ONLIT $0257
          ONLIT $18
          .dword VDC_STORE
          ONLIT $0258
          ONLIT $1A
          .dword VDC_STORE
          ONLIT $025C
          ONLIT $1C
          .dword VDC_STORE
          ONLIT $0272
          ONLIT $1E
          .dword VDC_STORE
vid_on:   ONLIT $92
:         .dword ZERO
          .dword VDC_C_STORE
          .dword ZERO
          .dword VDC_C_FETCH
          .dword IF
          .dword :-               ; branch if false
          .dword I2C2START
          ONLIT $70
          .dword I2C2_STORE
          ONLIT $08
          .dword I2C2_STORE
          ONLIT $B9
          .dword I2C2_STORE
          .dword I2C2STOP
          EXIT
eword

dword     VMODELINE,"VMODELINE"
          ENTER
          .dword TWO
          .dword MINUS
          ONLIT  $1E
          .dword VDC_STORE
          .dword DECR
          ONLIT  $1C
          .dword VDC_STORE
          .dword DECR
          ONLIT  $1A
          .dword VDC_STORE
          .dword DECR
          ONLIT  $18
          .dword VDC_STORE
          .dword TWO
          .dword MINUS
          ONLIT  $16
          .dword VDC_STORE
          .dword DECR
          ONLIT  $14
          .dword VDC_STORE
          .dword DECR
          ONLIT  $12
          .dword VDC_STORE
          .dword DECR
          ONLIT  $10
          .dword VDC_STORE
          JUMP   VIDSTART::vid_on
eword

dword     VIDSTOP,"VIDSTOP"
          ENTER
          .dword I2C2START
          ONLIT $70
          .dword I2C2_STORE
          ONLIT $08
          .dword I2C2_STORE
          ONLIT $FE
          .dword I2C2_STORE
          .dword I2C2STOP
          .dword ZERO
          .dword ZERO
          .dword VDC_C_STORE
          EXIT
eword

; H: ( -- ) dump display EDID data, first 256 bytes.
dword     DUMPEDID,"DUMPEDID"
dump_size = $0100
          ENTER
          ONLIT dump_size
          .dword ALLOC            ; buffer for downloaded EDID data
          .dword I2C2START
          ONLIT  $A0
          .dword I2C2_STORE
          .dword ZERO
          .dword I2C2_STORE
          .dword I2C2START
          ONLIT  $A1
          .dword I2C2_STORE
          ONLIT  dump_size
          .dword ZERO
          .dword _DO
:         .dword I2C2_FETCH_ACK
          .dword OVER
          .dword IX
          .dword PLUS
          .dword CSTORE
          .dword ONE
          .dword _PLOOP
          .dword :-
          .dword UNLOOP
          .dword I2C2_FETCH       ; NeonFORTH displays this
          .dword I2C2STOP
          .dword DUP
          ONLIT  dump_size
          .dword DUMP
          ONLIT  dump_size
          .dword FREE
          EXIT
eword

; H: ( -- ) initialize SPI2.
dword     SPI2INIT,"SPI2INIT"
          sep   #SHORT_A
          .a8
          lda   #$00
          sta   f:SPI2ctrl
          sta   f:SPI2ctrl2
          lda   #$05
          sta   f:SPI2ctrl3
          rep   #SHORT_A
          .a16
          NEXT
eword

; H: ( -- ) start SPI2 communication.
dword     SPI2START,"SPI2START"
          sep   #SHORT_A
          .a8
          lda   #$01
          sta   f:SPI2ctrl
          rep   #SHORT_A
          .a16
          NEXT
eword

; H: ( -- ) stop SPI2 communication.
dword     SPI2STOP,"SPI2STOP"
          sep   #SHORT_A
          .a8
:         lda   f:SPI2ctrl
          and   #$40
          bne   :-
          sta   f:SPI2ctrl        ; note A=0
          rep   #SHORT_A
          .a16
          NEXT
eword

; NOTE: sets short accumulator and leaves it that way on exit!
.proc     SPI2_busy_wait
          sep   #SHORT_A
nosep:
          .a8
:         lda   f:SPI2ctrl
          rol
          bcs   :-
          rts
          .a16
.endproc

; H: ( byte -- ) write byte to SPI2.
dword     SPI2_STORE,"SPI2!"
          jsr   _popay
          jsr   SPI2_busy_wait
          .a8
          tya
          sta   f:SPI2io
          rep   #SHORT_A
          .a16
          NEXT
eword

; H: ( -- byte ) fetch byte from SPI2.
dword     SPI2_FETCH,"SPI2@"
          jsr   SPI2_busy_wait
          .a8
          lda   #$00
          sta   f:SPI2io
:         lda   f:SPI2ctrl
          bit   #$40
          bne   :-
          lda   f:SPI2io
          rep   #SHORT_A
          .a16
          and   #$00FF
          jsr   _pusha
          NEXT
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
          stz   KEYMODS
          stz   PS2DEVS
          plx
          jmp   _sf_success
.endproc


.scope    pStrings
  .proc   keyboard
          .byte "keyboard"
  .endproc
  .proc   mouse
          .byte "mouse"
  .endproc
  .proc   present
          .byte " present",$0d,$0a
  .endproc
.endscope

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
          .dword dPS2DET
          .dword ONE
          .dword LAND
          .dword _IF
          .dword :+
          ONLIT ::pStrings::keyboard
          ONLIT .sizeof(::pStrings::keyboard)
          .dword TYPE
		      ONLIT ::pStrings::present
          ONLIT .sizeof(::pStrings::present)
          .dword TYPE
:         .dword dPS2DET
          .dword TWO
          .dword LAND
          .dword _IF
          .dword :+
          ONLIT ::pStrings::mouse
          ONLIT .sizeof(::pStrings::mouse)
          .dword TYPE
		      ONLIT ::pStrings::present
          ONLIT .sizeof(::pStrings::present)
          .dword TYPE
:         CODE
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

; return carry set if data waiting at PS/2 keyboard port, clear otherwise
; destroys A
.proc     ps2k_ready
          sep   #SHORT_A
          .a8
          lda   f:PS2Kstat
          ror
          rep   #SHORT_A
          .a16
          rts
.endproc

; read data from PS/2 keyboard port, blocking
; returns byte in A
.proc     ps2k_read
          sep   #SHORT_A
          .a8
:         lda   f:PS2Kstat
          ror
          bcc   :-
          lda   f:PS2Kio
          rep   #SHORT_A
          .a16
          and   #$00FF
          rts
.endproc

; write data byte in A to PS/2 keyboard port
.proc     ps2k_write
          sep   #SHORT_A
          .a8
          sta   f:PS2Kio
:         lda   f:PS2Kstat
          bit   #$08
          bne   :-
          rep   #SHORT_A
          .a16
          rts
.endproc

.proc     ps2k_command
          jsr   ps2k_write
          jsr   ps2k_read
          cmp   #$00FA
          rts
.endproc

; return carry set if data waiting at PS/2 mouse port, clear otherwise
; destroys A
.proc     ps2m_ready
          sep   #SHORT_A
          .a8
          lda   f:PS2Mstat
          ror
          rep   #SHORT_A
          .a16
          rts
.endproc

; read data from PS/2 mouse port, blocking
; returns byte in A
.proc     ps2m_read
          sep   #SHORT_A
          .a8
:         lda   f:PS2Mstat
          ror
          bcc   :-
          lda   f:PS2Mio
          rep   #SHORT_A
          .a16
          and   #$00FF
          rts
.endproc

; write data byte in A to PS/2 mouse port
.proc     ps2m_write
          sep   #SHORT_A
          .a8
          sta   f:PS2Mio
:         lda   f:PS2Mstat
          bit   #$08
          bne   :-
          rep   #SHORT_A
          .a16
          rts
.endproc

.proc     ps2m_command
          jsr   ps2m_write
          lda   #10
          jsr   _mswait
          jsr   ps2m_read
          cmp   #$00FA
          rts
.endproc

; Keyboard translate tables
; unshifted and shifted codes
; if high bit set, jump to special handler routine

.proc     mktab                   ; 'main' scan codes'
          ; $00
          .byte $00,$00           ; none
          .byte $00,$00           ; F9
          .byte $00,$00           ; none
          .byte $00,$00           ; F5
          .byte $00,$00           ; F3
          .byte $00,$00           ; F1
          .byte $00,$00           ; F2
          .byte $00,$00           ; F12
          ; $08
          .byte $00,$00           ; none
          .byte $00,$00           ; F10
          .byte $00,$00           ; F8
          .byte $00,$00           ; F6
          .byte $00,$00           ; F4
          .byte $09,$09           ; Tab
          .byte '`','~'
          .byte $00,$00           ; none
          ; $10
          .byte $00,$00           ; none
          .byte $00,$00           ; left alt
          .byte $80,$80           ; left shift
          .byte $00,$00           ; none
          .byte $86,$86           ; left control
          .byte 'q','Q'
          .byte '1','!'
          .byte $00,$00           ; none
          ; $18
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte 'z','Z'
          .byte 's','S'
          .byte 'a','A'
          .byte 'w','W'
          .byte '2','@'
          .byte $00,$00           ; none
          ; $20
          .byte $00,$00           ; none
          .byte 'c','C'
          .byte 'x','X'
          .byte 'd','D'
          .byte 'e','E'
          .byte '4','$'
          .byte '3','#'
          .byte $00,$00           ; none
          ; $28
          .byte $00,$00           ; none
          .byte ' ',' '
          .byte 'v','V'
          .byte 'f','F'
          .byte 't','T'
          .byte 'r','R'
          .byte '5','S'
          .byte $00,$00           ; none
          ; $30
          .byte $00,$00           ; none
          .byte 'n','N'
          .byte 'b','B'
          .byte 'h','H'
          .byte 'g','G'
          .byte 'y','Y'
          .byte '6','^'
          .byte $00,$00           ; none
          ; $38
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte 'm','M'
          .byte 'j','J'
          .byte 'u','U'
          .byte '7','&'
          .byte '8','*'
          .byte $00,$00           ; none
          ; $40
          .byte $00,$00           ; none
          .byte ',','<'
          .byte 'k','K'
          .byte 'i','I'
          .byte 'o','O'
          .byte '0',')'
          .byte '9','('
          .byte $00,$00           ; none
          ; $48
          .byte $00,$00           ; none
          .byte '.','>'
          .byte '/','?'
          .byte 'l','L'
          .byte ';',':'
          .byte 'p','P'
          .byte '-','_'
          .byte $00,$00           ; none
          ; $50
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $27,'"'
          .byte $00,$00           ; none
          .byte '[','{'
          .byte '=','+'
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $58
          .byte $84,$84           ; caps lock
          .byte $82,$82           ; right shift
          .byte $0D,$0D           ; enter
          .byte ']','}'
          .byte $00,$00           ; none
          .byte '\','|'
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $60
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $08,$7F           ; backspace
          .byte $00,$00           ; none
          ; $68
          .byte $00,$00           ; none
          .byte '1','1'           ; keypad
          .byte $00,$00           ; none
          .byte '4','4'           ; keypad
          .byte '7','7'           ; keypad
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $70
          .byte '0','0'           ; keypad
          .byte '.','.'           ; keypad
          .byte '2','2'           ; keypad
          .byte '5','5'           ; keypad
          .byte '6','6'           ; keypad
          .byte '8','8'           ; keypad
          .byte $1B,$1B           ; escape
          .byte $00,$00           ; num lock
          ; $78
          .byte $00,$00           ; F11
          .byte '+','+'           ; keypad
          .byte '3','3'           ; keypad
          .byte '-','-'           ; keypad
          .byte '*','*'           ; keypad
          .byte '9','9'           ; keypad
          .byte $00,$00           ; scroll lock
          .byte $00,$00           ; none
          ; $80
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; F7
          .endproc

.proc     ektab                   ; E0 scan codes
          ; $00
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $08
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $10
          .byte $00,$00           ; MM WWW search
          .byte $00,$00           ; right alt
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $88,$88           ; right control
          .byte $00,$00           ; MM prev track
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $18
          .byte $00,$00           ; MM WWW favorites
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; left GUI
          ; $20
          .byte $00,$00           ; MM WWW refresh
          .byte $00,$00           ; MM vol down
          .byte $00,$00           ; MM mute
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; right GUI
          ; $28
          .byte $00,$00           ; MM WWW stop
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; MM calculator
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; 'apps'
          ; $30
          .byte $00,$00           ; MM WWW forward
          .byte $00,$00           ; none
          .byte $00,$00           ; MM vol up
          .byte $00,$00           ; none
          .byte $00,$00           ; MM play/pause
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; ACPI power
          ; $38
          .byte $00,$00           ; MM WWW back
          .byte $00,$00           ; none
          .byte $00,$00           ; MM WWW home
          .byte $00,$00           ; MM stop
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; ACPI sleep
          ; $40
          .byte $00,$00           ; MM my computer
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $48
          .byte $00,$00           ; MM email
          .byte $00,$00           ; none
          .byte '/','/'           ; keypad
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; MM next track
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $50
          .byte $00,$00           ; MM select
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $58
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $0D,$0D           ; keypad 'enter'
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; ACPI wake
          .byte $00,$00           ; none
          ; $60
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $68
          .byte $00,$00           ; none
          .byte $00,$00           ; end
          .byte $00,$00           ; none
          .byte $08,$08           ; cursor left
          .byte $00,$00           ; home
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $70
          .byte $00,$00           ; insert
          .byte $7F,$7F           ; delete
          .byte $0A,$0A           ; cursor down
          .byte $00,$00           ; none
          .byte $15,$15           ; cursor right
          .byte $0B,$0B           ; cursor up
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          ; $78
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; page down
          .byte $00,$00           ; none
          .byte $00,$00           ; none
          .byte $00,$00           ; page up
.endproc

; Tables of routines for special make/break of keys (values > $80)
; kmktbl and kbktbl must match up.
.proc     kmktbl
          .addr mk_lshift-1       ; $80
          .addr mk_rshift-1       ; $82
          .addr mk_caps-1         ; $84
          .addr mk_lctrl-1        ; $86
          .addr mk_rctrl-1        ; $88
.endproc

.proc     kbktbl
          .addr bk_lshift-1       ; $80
          .addr bk_rshift-1       ; $82
          .addr bk_caps-1         ; $84
          .addr bk_lctrl-1        ; $86
          .addr bk_rctrl-1        ; $88
.endproc

.proc     mk_lshift
          lda   #%1000000000000000
          bra   makemod
.endproc

.proc     mk_rshift
          lda   #%0100000000000000
          bra   makemod
.endproc

.proc     mk_caps
          lda   KEYMODS
          eor   #%1
          sta   KEYMODS
          ; fall-through to ps2_setLEDs
.endproc

.proc     ps2_setleds
          lda   #$ED              ; set LEDs command
          jsr   ps2k_command
          lda   KEYMODS
          and   #%111
          jsr   ps2k_command
          rts
.endproc

.proc     mk_lctrl
          lda   #%0000000010000000
          bra   makemod
.endproc

.proc     mk_rctrl
          lda   #%0000000001000000
          ;bra   makemod
.endproc

.proc     makemod
          tsb   KEYMODS
          rts
.endproc

.proc     bk_lshift
          lda   #%1000000000000000
          bra   breakmod
.endproc

.proc     bk_rshift
          lda   #%0100000000000000
          bra   breakmod
.endproc

.proc     bk_caps
          rts
.endproc

.proc     bk_lctrl
          lda   #%0000000010000000
          bra   breakmod
.endproc

.proc     bk_rctrl
          lda   #%0000000001000000
          ;bra   breakmod
.endproc

.proc     breakmod
          trb   KEYMODS
          rts
.endproc

; Read a code from the keyboard, return carry set if it was 'break' and clear
; if it was 'make'
.proc     ps2_readcode
          phy                     ; save Y
          ldy   #$0000            ; flag for break
          phy                     ; space for extended code byte
:         jsr   ps2k_read
          cmp   #$E1              ; pause/break annoyance
          beq   pausebrk
          cmp   #$E0              ; extended code?
          bne   :+
          xba
          sta   1,s               ; yes, put in upper byte on stack
          bra   :-                ; back to read
:         cmp   #$F0              ; break code?
          bne   :+
          iny                     ; yes, flag
          bra   :--               ; back to read
:         ora   1,s               ; if none of those, put in lower byte
          sta   1,s               ; inefficient but it works
          pla                     ; and get it off the stack
done:     cpy   #$01              ; set carry if break
          ply                     ; restore Y
          rts
pausebrk: pla
          ldy   #7
:         jsr   ps2k_read         ; drop 7 bytes
          dey
          bne   :-
          lda   #$E000            ; bogus scan code
          bra   done
.endproc

; get code from translate table for key code in A, return in A
; destroys y, returns 0000 if there is no translation
.proc     ps2_keytran
          pha
          and   #$00FF
          asl
          tay
          pla
          and   #$FF00
          cmp   #$E000
          beq   ext
          cpy   #.sizeof(mktab)
          bcs   bad
          lda   mktab,y
          bra   done
ext:      cpy   #.sizeof(ektab)
          bcs   bad
          lda   ektab,y
          bra   done
bad:      lda   #$0000
done:     cmp   #$0001
          rts
.endproc

; take translated code in A, apply keyboard modifiers, and return result in A
; if special, return carry set
.proc     ps2_keymod
          pha                     ; work with it on stack
          lda   KEYMODS
          and   #%1100000000000000 ; shift keys
          beq   :+
          lda   1,s
          xba
          sta   1,s
:         lda   1,s
          and   #$0080
          bne   :++               ; shortcut special
          lda   KEYMODS
          ror                     ; caps into carry
          bcc   :+
          lda   1,s
          and   #$00FF
          cmp   #'a'
          bcc   :+
          cmp   #'z'+1
          bcs   :+
          and   #$DF
          sta   1,s
:         lda   KEYMODS
          and   #%0000000011000000 ; ctrl keys
          beq   :+
          lda   1,s
          and   #%11111           ; make ctrl char
          sta   1,s
:         pla
          and   #$00FF
          cmp   #$0080
          rts
.endproc

; Wait for a valid key, when we get one, decode and return
.proc     ps2_keyin
:         php
:         plp
          jsr   ps2_readcode
          php
          jsr   ps2_keytran
          bcc   :-                ; carry is clear if no value for key
          jsr   ps2_keymod
          bcs   special
          plp
          bcs   :--               ; break code, wait for another
          rts
special:  and   #$007F
          tay
          lda   kmktbl,y
          plp
          bcc   :+                ; if make
          lda   kbktbl,y
:         jsr   :+
          bra   :---              ; for special, we go back to waiting
:         pha                     ; do RTS trick
          rts
.endproc

