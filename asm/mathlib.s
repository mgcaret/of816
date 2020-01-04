
; Math Library - I don't reinvent the wheel here for multiplication, division, etc.
; others have done great work before me and I credit them when I know who did it.

; 32-bit signed comparison
; C and Z reflect same comparision results as CMP instruction
.proc     _stest32
          lda   STACKBASE+6,x
          eor   STACKBASE+2,x
          bpl   samesign
          lda   STACKBASE+2,x       ; Kelvin's excellent solution
          sec
          rol
          rts
samesign: lda   STACKBASE+6,x
          cmp   STACKBASE+2,x
          bcc   :+                  ; less than or not equal, done
          bne   :+
          lda   STACKBASE+4,x
          cmp   STACKBASE+0,x
:         rts
.endproc

.proc     _invertay
          pha
          tya
          eor   #$FFFF
          tay
          pla
          eor   #$FFFF
          rts
.endproc

.proc     _negateay
          pha
          tya
          eor   #$FFFF
          clc
          adc   #$0001
          tay
          pla
          eor   #$FFFF
          adc   #$0000
          rts
.endproc

.proc     _invert
          lda   STACKBASE+0,x
          eor   #$FFFF
          sta   STACKBASE+0,x
          lda   STACKBASE+2,x
          eor   #$FFFF
          sta   STACKBASE+2,x
          rts
.endproc

.proc     _negate
          jsr   _invert
          inc   STACKBASE+0,x
          bne   :+
          inc   STACKBASE+2,x
:         rts
.endproc

.proc     _dinvert
          jsr   _invert
          lda   STACKBASE+4,x
          eor   #$FFFF
          sta   STACKBASE+4,x
          lda   STACKBASE+6,x
          eor   #$FFFF
          sta   STACKBASE+6,x
          rts
.endproc

.proc     _dnegate
          jsr   _dinvert
          inc   STACKBASE+4,x
          bne   :+
          inc   STACKBASE+6,x
          bne   :+
          inc   STACKBASE+0,x
          bne   :+
          inc   STACKBASE+2,x
:         rts
.endproc

.proc     _2abs
          bit   STACKBASE+2,x
          bpl   :+
          jsr   _negate
:         jsr   _swap
          ; fall-through
.endproc

.proc     _abs
          bit   STACKBASE+2,x
          bpl   :+
          jsr   _negate
:         rts          
.endproc

.proc     _signum
          ldy   #$FFFF
          lda   STACKBASE+2,x
          bpl   :+
          sty   STACKBASE+2,x
          bra   done
:         iny
          stz   STACKBASE+2,x
          ora   STACKBASE+0,x
          beq   done
          iny
done:     sty   STACKBASE+0,x
          rts
.endproc

; 32-bit unsigned multiplication with 64-bit result
; right-shifting version by dclxvi
; scratch in YR, YR+2 (preserved)
.proc     _umult
N         = YR
          lda   N+2
          pha
          lda   N
          pha
          lda   #$00
          sta   N
          ldy   #32
          lsr   STACKBASE+6,x
          ror   STACKBASE+4,x
l1:       bcc   l2
          clc
          sta   N+2
          lda   N
          adc   STACKBASE+0,x
          sta   N
          lda   N+2
          adc   STACKBASE+2,x
l2:       ror
          ror   N
          ror   STACKBASE+6,x
          ror   STACKBASE+4,x
          dey
          bne   l1
          sta   STACKBASE+2,x
          lda   N
          sta   STACKBASE+0,x
          pla
          sta   N
          pla
          sta   N+2
          rts
.endproc

; 64-bit divided by 32-bit with 32-bit quotient and remainder
; Adapted from Garth's routine, just like everyone else :-)
; carry set if divison by zero or overflow
; ( d n -- r q )
; d.hi = stack(4,6), d.low = stack(8,10), n=stack(0,2)
.proc     _umdivmod
CARRY     = YR
SCRATCH   = YR+2
.if 1 ; shortcut 32-bit by 32-bit division
          lda   STACKBASE+4,x
          ora   STACKBASE+6,x
          beq   _udivmod32          ; go do faster 32-bit divide
.endif
          lda   SCRATCH
          pha
          lda   CARRY
          pha
          sec                       ; first, check for overflow and division by 0
          lda   STACKBASE+4,x
          sbc   STACKBASE+0,x
          lda   STACKBASE+6,x
          sbc   STACKBASE+2,x
          bcs   overflow
          lda   #33                 ; 32 bits + 1
          sta   XR
loop:     rol   STACKBASE+8,x
          rol   STACKBASE+10,x
          dec   XR
          beq   done
          rol   STACKBASE+4,x
          rol   STACKBASE+6,x
          stz   CARRY
          rol   CARRY
          sec
          lda   STACKBASE+4,x
          sbc   STACKBASE+0,x
          sta   SCRATCH
          lda   STACKBASE+6,x
          sbc   STACKBASE+2,x
          tay
          lda   CARRY
          sbc   #0
          bcc   loop
          lda   SCRATCH
          sta   STACKBASE+4,x
          sty   STACKBASE+6,x
          bra   loop
overflow: sec
          bra   done1
done:     clc
          inx                       ; drop
          inx
          inx
          inx
done1:    pla
          sta   CARRY
          pla
          sta   SCRATCH
          bcs   :+                  ; leave stack intact if exception
          jmp   _swap1
:         rts
.endproc

; 32-bit by 32-bit division
; assumes that the second stack entry is zero
; ( d n -- r q ) where d.hi is zero e.g. ( n1 0 n2 -- r q )
; d.hi = stack(4,6) = 0, d.low = n1 = stack(8,10), n2 = stack(0,2)
.proc     _udivmod32
          lda   #32
          sta   XR
l1:       asl   STACKBASE+8,x       ; shift high bit of n1 into r
          rol   STACKBASE+10,x      ; clearing the low bit for q
          rol   STACKBASE+4,x       ; r.lo
          rol   STACKBASE+6,x       ; r.hi
          lda   STACKBASE+4,x       ; r.lo
          sec                       ; trial subraction
          sbc   STACKBASE+0,x       ; n2.lo
          tay                       ; save low word
          lda   STACKBASE+6,x       ; r.hi
          sbc   STACKBASE+2,x       ; n2.hi
          bcc   l2                  ; subtraction succeeded?
          sta   STACKBASE+6,x       ; r.hi yes, save result
          sty   STACKBASE+4,x       ; r.lo
          inc   STACKBASE+8,x       ; n1.lo and record a 1 in the quotient
l2:       dec   XR                  ; next bit
          bne   l1
          inx                       ; kill of top stack item
          inx
          inx
          inx
          clc                       ; this *never* overflows
          jmp   _swap1
.endproc

; ( d n -- ud u )
.proc     _dnabs
          lda   STACKBASE+2,x     ; take absolute value of n1
          bpl   :+
          jsr   _negate
:         lda   STACKBASE+6,x     ; take absolute value of d
          bpl   :+
dtneg:    inx
          inx
          inx
          inx
          jsr   _dnegate
          dex
          dex
          dex
          dex
:         rts
.endproc
_dtucknegate = _dnabs::dtneg

.proc     _smdivrem
          lda   STACKBASE+6,x     ; save dividend sign in MSW of high cell of d
          pha
          eor   STACKBASE+2,x     ; compute result sign and save
          pha
          jsr   _dnabs            ; take absolute value of arguments
          jsr   _umdivmod
          bcs   overflow          ; overflow
          pla                     ; see if we should negate quotient
          bpl   :+
          jsr   _negate           ; make it negative
:         pla                     ; get dividend sign
          bpl   :+
tneg:     inx                     ; negate remainder if it should be negative
          inx
          inx
          inx
          jsr   _negate
          dex
          dex
          dex
          dex
:         clc
          rts
overflow: pla                     ; carry is set, pla does not affect it
          pla
          rts
.endproc
_tucknegate = _smdivrem::tneg

.proc     _fmdivmod
          stz   WR
          lda   STACKBASE+2,x
          bpl   :+
          dec   WR
          jsr   _dnabs
:         lda   STACKBASE+6,x
          bpl   :+
          lda   STACKBASE+0,x
          clc
          adc   STACKBASE+4,x
          sta   STACKBASE+4,x
          lda   STACKBASE+2,x
          adc   STACKBASE+6,x
          sta   STACKBASE+6,x
:         jsr   _umdivmod
          bcs   :+
          bit   WR
          bpl   :+
          jsr   _tucknegate       ; clears carry
:         rts
.endproc

; adapted from Lee Davidson routine
; ( u1 -- u1 u2 ) u1 = closest integer <= square root, u2 = remainder
; number popped into WR,WR+2
; remainder on stack, offsets 0,2
; root on stack, offsets 4,6
; temp in YR
; counter in XR
.proc     _sqroot
          jsr   _peekwr           ; get number into WR
          jsr   _stackdecr        ; make room for remainder
          lda   #16               ; pairs of bits
          sta   XR                ; counter
          lda   #$0000
          sta   STACKBASE+0,x     ; init remainder
          sta   STACKBASE+2,x
          sta   STACKBASE+4,x     ; init root
          sta   STACKBASE+6,x

lp:       asl   STACKBASE+4,x     ; root = root * 2
          asl   WR                ; now shift 2 bits of number into remainder
          rol   WR+2
          rol   STACKBASE+0,x
          rol   STACKBASE+2,x
          asl   WR
          rol   WR+2
          rol   STACKBASE+0,x
          rol   STACKBASE+2,x
          lda   STACKBASE+4,x     ; copy root into temp
          sta   YR
          lda   STACKBASE+6,x     ; (a bit shorter than immediate load)
          sta   YR+2
          sec                     ; +1
          rol   YR                ; temp = temp * 2 + 1
          rol   YR+2
          lda   STACKBASE+2,x     ; compare remainder with partial
          cmp   YR+2
          bcc   next              ; skip sub if remainder smaller
          bne   subtr             ; but do it if equal
          lda   STACKBASE+0,x     
          cmp   YR
          bcc   next              ; same deal
subtr:    lda   STACKBASE+0,x     ; subtract partial from remainder
          sbc   YR
          sta   STACKBASE+0,x
          lda   STACKBASE+2,X
          sbc   YR+2
          sta   STACKBASE+2,x
          inc   STACKBASE+4,x     ; no need to increment high word, always zero
next:     dec   XR
          bne   lp
          rts
.endproc





