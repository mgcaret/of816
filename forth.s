; Master build file for OF816

.p816
.a16
.i16

; System segment
.segment "FSystem"

.include "macros.inc"             ; System macros
.include "platform.inc"           ; Set up by the build script
.include "config.inc"             ; Configuration defines
.include "equates.inc"            ; Equates
.include "asm/system.s"           ; System interfacing
.include "asm/interpreter.s"      ; Inner interpreter & helpers
.include "asm/compiler.s"         ; Compiler helpers
.include "asm/mathlib.s"          ; Math library
.include "asm/memmgr.s"           ; Memory (heap) management library
.if .strlen(PLATFORM) > 0
  .include "platform-lib.s" ; Platform library
.endif
.include "asm/env-dictionary.s"   ; Environmental queries dictionary
.include "asm/forth-dictionary.s" ; Forth built-in dictionary

; FCode segment - to be potentially located in a different bank
.if include_fcode
  .pushseg
  .segment "FCode"
  .include "asm/fcode.s"
  .popseg
.endif
