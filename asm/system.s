; Main Forth system stuff.   System variable declaration/initialization, system init,
; etc.

; System variable numbers
; Be sure to update initialization table, below
DEF_SYSVAR 0, SV_STATE            ; STATE
DEF_SYSVAR 1, SV_BASE             ; BASE
DEF_SYSVAR 2, SV_OLDHERE          ; (old here for exception during definition)
DEF_SYSVAR 3, SV_CURRENT          ; $CURRENT
DEF_SYSVAR 4, SV_NLINE            ; #LINE
DEF_SYSVAR 5, SV_NOUT             ; #OUT
DEF_SYSVAR 6, SV_dCIB             ; $CIB
DEF_SYSVAR 7, SV_PIN              ; >IN
DEF_SYSVAR 8, SV_NIN              ; #IN
DEF_SYSVAR 9, SV_SPAN             ; SPAN
DEF_SYSVAR 10, SV_dPPTR           ; $PPTR
DEF_SYSVAR 11, SV_HIMEM           ; for alloc-mem & free-mem
DEF_SYSVAR 12, SV_CSBUF           ; current interpretation temp string buffer
DEF_SYSVAR 13, SV_SBUF0           ; interpretation temp string buffer 1 of 2
DEF_SYSVAR 14, SV_SBUF1           ; interpretation temp string buffer 2 of 2
DEF_SYSVAR 15, SV_SOURCEID        ; Input source ID, 0 = console, -1 = EVALUATE
DEF_SYSVAR 16, SV_dTIB            ; terminal input buffer
DEF_SYSVAR 17, SV_dCSDEPTH        ; Control-flow stack depth for temporary definitions
DEF_SYSVAR 18, SV_dSAVEHERE       ; saved HERE for temporary definitions
DEF_SYSVAR 19, SV_pTMPDEF         ; pointer to memory allocated for temp def
DEF_SYSVAR 20, SV_FORTH_WL        ; Forth wordlist
DEF_SYSVAR 21, SV_FORTH_WL_XT     ; Pointer to the "FORTH" word
DEF_SYSVAR 22, SV_ENV_WL          ; last environmental word
DEF_SYSVAR 23, SV_ENV_WL_XT       ; pointer to "$ENV?" word
DEF_SYSVAR 24, SV_dORDER          ; Pointer to search order list
DEF_SYSVAR 25, SV_dCURDEF         ; $CURDEF pointer to current colon, noname, etc. def
.if include_fcode
DEF_SYSVAR 26, SV_FCODE_IP        ; FCode IP
DEF_SYSVAR 27, SV_FCODE_END       ; FCode end, if true FCode evaluator will stop
DEF_SYSVAR 28, SV_FCODE_SPREAD    ; Current FCode spread
DEF_SYSVAR 29, SV_FCODE_OFFSET    ; if true, offsets are 16 bits
DEF_SYSVAR 30, SV_FCODE_FETCH     ; XT of FCode fetch routine, usually C@
DEF_SYSVAR 31, SV_FCODE_TABLES    ; Pointer to FCode table pointers
DEF_SYSVAR 32, SV_FCODE_LAST      ; Last FCode# in NEW-, NAMED-, or EXTERNAL-TOKEN
DEF_SYSVAR 33, SV_FCODE_DEBUG     ; whether FCode debugging is enabled
.endif

.proc     _jtab
init:     jmp   __initialize
ui:       jmp   __ui
.endproc
.export _Forth_jmptab = _jtab
.export _Forth_initialize = _jtab::init
.export _Forth_ui = _jtab::ui

; Table of initialization values for system variables
.proc     SVARINIT
          .dword 0                ; STATE 0
          .dword 16               ; BASE 4
          .dword 0                ; OLDHERE 8 for exception during definition
          .dword 0                ; $CURRENT - WID of the compiler word list
          .dword 0                ; #LINE 16
          .dword 0                ; #OUT 20
          .dword 0                ; $CIB 24
          .dword 0                ; >IN 28
          .dword 0                ; #IN 32
          .dword 0                ; SPAN 36
          .dword 0                ; $PPTR 40
          .dword 0                ; HIMEM 44 - for alloc-mem and free-mem
          .dword 0                ; CSBUF
          .dword 0                ; SBUF0
          .dword 0                ; SBUF1
          .dword 0                ; SOURCEID
          .dword 0                ; $TIB
          .dword 0                ; $CSDEPTH
          .dword 0                ; $SAVEHERE
          .dword 0                ; $>TMPDEF
          .dword LAST_forth       ; Forth wordlist
          .dword FORTH            ; "FORTH" word xt
          .dword LAST_env         ; environmental query wordlist
          .dword ENVIRONMENTQ     ; "ENVIRONMENT?" xt
          .dword 0                ; search order pointer, if zero always uses Forth wordlist
          .dword 0                ; $CURDEF
.if include_fcode
          .dword 0                ; $FCODE-IP
          .dword 0                ; $FCODE-END
          .dword 1                ; $FCODE-SPREAD
          .dword 0                ; $FCODE-OFFSET
          .dword dRBFETCH         ; $FCODE-FETCH
          FCROM fc_romtab         ; $FCODE-TABLES
          .dword $7FF             ; $FCODE-LAST last FCode# in NEW-, NAMED-, or EXTERNAL-TOKEN
          .dword 0                ; FCODE-DEBUG?
.endif
.endproc
SYSVAR_INIT SVARINIT              ; check size of initialize values

.proc     _call_sysif
          sta   ZR+2              ; save function #
          stx   ZR                ; calculate stack depth
          lda   STK_TOP
          sec
          sbc   ZR
          lsr
          lsr
          tay
          lda   SYSIF+2
          sep   #SHORT_A
          pha
          rep   #SHORT_A
          lda   SYSIF
          pha
          lda   ZR+2              ; get function #
          rtl
.endproc

; Enter with direct page register pointing to direct page reserved for the system
; with enough space for the variables in equates.inc
; and the following parameters on the '816 stack:
; system memory high (32-bit)
; system memory low (32-bit)
; stack top (16-bit) - this the bank 0 address just after first usable cell, relative to D
; stack bottom (16-bit) - this is the bank 0 address of the last usable cell, relative to D
; return stack top (16-bit) - return stack top, to be used by all routines
; except initialize
; system interface function (32-bit) - vector to basic I/O, etc.
; each stack must have at least 64 32-bit cells, a total of 256+ bytes each.
.proc     __initialize
          ; set up direct page
          pla                     ; first, save caller address
          sta   WR
          sep   #SHORT_A
          pla
          sta   WR+2
          rep   #SHORT_A
          pla                     ; get address of system interface function
          sta   SYSIF
          pla
          sta   SYSIF+2
          lda   SYSIF             ; we are going call it via RTL, so decrement
          bne   :+
          dec   SYSIF+2
:         dec   SYSIF
          pla
          sta   RSTK_TOP
          sta   RSTK_SAVE         ; really a placeholder for completeness
          pla
          sta   STK_BTM
          pla
          sta   STK_TOP
          pla
          sta   MEM_BTM
          sta   SYSVARS           ; sysvars at memory bottom
          pla
          sta   MEM_BTM+2
          sta   SYSVARS+2
          pla
          sta   MEM_TOP
          pla
          sta   MEM_TOP+2
          sep   #SHORT_A          ; restore caller address
          lda   WR+2
          pha
          rep   #SHORT_A
          lda   WR
          pha
          ; okay, direct page is set up from stack, do the rest of it
          tsc                     ; switch to Forth return stack
          sta   SYS_RSTK
          lda   RSTK_TOP
          tcs
          phb                     ; save data bank for caller
          phk
          plb                     ; make sure we can move SYSVARS & OF816
          lda   SYSVARS
          clc
          adc   #.sizeof(SVARINIT)
          sta   DHERE
          lda   SYSVARS+2
          adc   #$00
          sta   DHERE+2
          ldy   #0
:         lda   SVARINIT,y
          sta   [SYSVARS],y
          iny
          iny
          cpy   #.sizeof(SVARINIT)
          bcc   :-
          stz   CATCHFLAG
          ; Now do forth-based initialization
          ldx   STK_TOP
          lda   #SI_PRE_INIT
          jsl   _call_sysif       ; hope it works, because we don't check!
          ENTER
          .dword ddSYSINIT
          CODE
          ; Remaining platform init platform if needed
          lda   #SI_POST_INIT
          jsl   _call_sysif       ; carry flag propagates to RTL
          plb                     ; restore caller data bank
          lda   SYS_RSTK          ; and stack
          tcs
          rtl
.endproc

.proc     __ui
          tsc
          sta   SYS_RSTK
          ldx   STK_TOP
          jmp   __doquit
.endproc


