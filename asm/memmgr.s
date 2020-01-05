
; Memory allocation library

; Structure is a linked list beginning at HIMEM and ending at MEM_TOP
; when HIMEM=MEM_TOP, nothing is allocated
; where each entry in the list is <next(4)><flag+chk(2)><space>
; flag+chk is a 16-bit item whose top bit is 1 for in-use, 0 if free
; at some point, the remainder of the word are the low bits of the address of this
; block header in order to serve as a check for heap corruption

; Allocation is selectable from first-fit or best fit (see below) for extant free blocks
; Freeing the bottom block moves HIMEM up.  Adjacent free blocks are combined.


; Tunables
SPLIT_THRESH = 8                  ; if block can be split and remainder have this many
                                  ; bytes + 6 bytes header, split it
MIN_BRK     = $400                ; minimum break between DHERE and HIMEM in pages

; Constants
HDR_SIZE    = 6

; Allocate XR bytes, return carry set+pointer in AY if successful
; or carry clear+AY=0 if unsuccessful
; trashes WR (has copy of pointer to the block header) and YR
; This uses a first-fit algorithm.  If the selected block has at  bytes
; remaining after the allocation, the block will be split with the remaining
; space (less 4 bytes) put into the newly following block
.proc     _alloc
          jsr   _chk_himem
          bcs   grow
          jsr   _find_free
          bcs   grow
          ; reuse, y = 4, A = existing flag word
          ora   #$8000
          sta   [WR],y
          jsr   _split            ; split block if possible
          bra   _rtn_ptr
grow:     jsr   _grow_heap
          bcs   :+
          ldy   #$0004
          lda   #$8000
          sta   [WR],y
          bra   _rtn_ptr
:         lda   #$00
          tay
          clc
          rts
.endproc

.proc     _rtn_ptr
          lda   WR
          clc
          adc   #.loword(HDR_SIZE)
          tay
          lda   WR+2
          clc
          adc   #.hiword(HDR_SIZE)
          sec
          rts
.endproc

.proc     _split
          jsr   _blksize
          lda   YR                ; YR = YR(size)-XR(requested size) = remaining space
          sec
          sbc   XR
          sta   YR
          lda   YR+2
          sbc   XR+2
          sta   YR+2
          lda   YR                ; now see if it's big enough to split
          sec
          sbc   #.loword(SPLIT_THRESH+HDR_SIZE)
          ldy   YR+2
          sbc   #.hiword(SPLIT_THRESH+HDR_SIZE)
          bmi   done              ; do not split, it's too small
          lda   WR                ; set YR to be a pointer to the child block
          clc                     ; YR = WR+XR+6
          adc   XR
          sta   YR
          lda   WR+2
          adc   XR+2
          sta   YR+2
          lda   YR                ; (now account for header of parent block)
          clc
          adc   #.loword(HDR_SIZE)
          sta   YR
          lda   YR+2
          adc   #.hiword(HDR_SIZE)
          sta   YR+2              ; ok now YR points to child block
          ldy   #$04              ; first mark child block free
          lda   #$0000            ; by zeroing its flags
          sta   [YR],y
          dey                     
          dey                     ; y = $02
          lda   [WR],y            ; then copy high word next block pointer of parent
          sta   [YR],y            ; into high word next block pointer of child
          dey                     
          dey                     ; y = $00
          lda   [WR],y            ; and then do low word next block pointer
          sta   [YR],y            ; copy to child
          lda   YR                ; then set parent next block pointer to child
          sta   [WR],y            ; low word
          iny
          iny                     ; y = $02
          lda   YR+2              ; high word
          sta   [WR],y
done:     rts
.endproc

; Load SV_HIMEM into WR and compare to MEM_TOP
; return carry set if MEM_TOP >= SV_HIMEM
; carry clear, otherwise
.proc     _chk_himem
          ldy   #SV_HIMEM
          lda   [SYSVARS],y
          sta   WR
          iny
          iny
          lda   [SYSVARS],y
          sta   WR+2
          ; fall-through
.endproc

; See if WR is at (or above) MEM_TOP
; Z and C reflect usual meanings
.proc     _chktop
          lda   WR+2
          cmp   MEM_TOP+2
          bne   :+
          lda   WR
          cmp   MEM_TOP
:         rts
.endproc

; Move WR to the next block, assuming WR points to an existing block
; return via comparison with MEM_TOP
.proc     _nextblk
          ldy   #$00
          lda   [WR],y
          pha
          iny
          iny
          lda   [WR],y
          sta   WR+2
          pla
          sta   WR
          bra   _chktop
.endproc

; YR = [WR] - WR - 6
.proc     _blksize
          ldy   #$00
          lda   [WR],y
          sec
          sbc   WR
          sta   YR
          iny
          iny
          lda   [WR],y
          sbc   WR+2
          sta   YR+2
          lda   YR
          sec
          sbc   #$0006
          sta   YR
          lda   YR+2
          sbc   #$0000
          sta   YR+2
          rts
.endproc

.if 0 ; use first-fit if nonzero, best-fit if zero
; Find a free block of at least size XR
; if found, return with its address in WR and carry clear, YR is the block size, A
; is the contents of the flags word, and Y is 4
; otherwise carry set and WR should be equal to HIMEM
.proc     _find_free
          jsr   _chk_himem
          bcc   lp
          rts
next:     jsr   _nextblk
          bcs   done
lp:       jsr   _blksize
          lda   YR+2
          cmp   XR+2
          bne   :+
          lda   YR
          cmp   XR
:         bcc   next              ; too big
          ldy   #$04              ; got one, is it free?
          lda   [WR],y
          bmi   next              ; nope
          clc
done:     rts
.endproc
.else
; Find the best-fitting block of at least size XR
; if found, return with its address in WR and carry clear, YR is the block size, A
; is the contents of the flags word, and Y is 4
; otherwise carry set and WR should be equal to HIMEM
; trashes ZR, which holds the size of the best candidate so far
.proc     _find_free
          stz   ZR                ; zero out best fit size
          stz   ZR+2
          jsr   _chk_himem
          bcc   :+                ; if we have some heap, go see if anything free
          rts                     ; otherwise just return with carry set
:         pha                     ; make room on stack for "best" candidate
          pha
          bra   lp                ; enter loop
best:     lda   YR                ; save block in WR as best block
          sta   ZR                ; starting with size
          lda   YR+2
          sta   ZR+2
          lda   WR                ; then with address
          sta   1,s
          lda   WR+2
          sta   3,s
next:     jsr   _nextblk
          bcs   done              ; when we run out of blocks
lp:       ldy   #$04
          lda   [WR],y            ; is it free?
          bmi   next              ; nope, move on
          jsr   _blksize
          lda   YR+2
          cmp   XR+2
          bne   :+
          lda   YR
          cmp   XR
:         bcc   next              ; too big
          lda   ZR                ; do we have a best candidate so far?
          ora   ZR+2
          beq   best              ; no, make this one the best
          lda   ZR+2              ; yes, see if this one is better
          cmp   YR+2
          bne   :+
          lda   ZR
          cmp   YR
:         bcs   best              ; save as best (prefer higher blocks if =)
          bra   next              ; otherwise go to next block
done:     lda   ZR
          ora   ZR+2
          beq   none
          lda   ZR
          sta   YR
          lda   ZR+2
          sta   YR+2
          pla
          sta   WR
          pla
          sta   WR+2
          ldy   #$04
          lda   [WR],y
          clc
          rts
none:     pla                     ; drop the block pointer
          pla
          sec
          rts          
.endproc
.endif

; YR = WR-XR
.proc     _wr_minus_xr
          lda   WR
          sec
          sbc   XR
          sta   YR
          lda   WR+2
          sbc   XR+2
          sta   YR+2
          rts
.endproc

; Grow heap to store at least XR bytes.  Trashes WR and YR.
; return carry clear, HIMEM adjusted, and WR=new HIMEM if grow succeeded
; otherwise carry set and no changes to HIMEM
.proc     _grow_heap
          jsr   _chk_himem
          jsr   _wr_minus_xr    ; calculate bottom of reservation
          lda   YR              ; then subtract header size
          sec
          sbc   #.loword(HDR_SIZE)
          sta   YR
          lda   YR+2
          sbc   #.hiword(HDR_SIZE)
          sta   YR+2
          lda   DHERE           ; now compare to DHERE+minimum break
          clc
          adc   #.loword(MIN_BRK)
          tay
          lda   DHERE+2
          adc   #.hiword(MIN_BRK)
          cmp   YR+2
          bne   :+
          tya
          cmp   YR
:         bcs   done            ; would put us in the break, byebye
          lda   YR              ; move YR to WR
          sta   WR
          lda   YR+2
          sta   WR+2
          ldy   #$04            ; offset of flags          
          lda   #$0000
          sta   [WR],y          ; zero them (marked free)
          ldy   #SV_HIMEM+2     ; now get current HIMEM
          lda   [SYSVARS],y 
          pha                   ; save high byte on stack
          dey
          dey
          lda   [SYSVARS],y     ; low byte...
          ldy   #$00
          sta   [WR],y          ; use it to make link
          iny
          iny
          pla
          sta   [WR],y
          ldy   #SV_HIMEM+2     ; and set HIMEM to WR
          lda   WR+2
          sta   [SYSVARS],y
          dey
          dey
          lda   WR
          sta   [SYSVARS],y
          clc
done:     rts
.endproc

; Free memory pointed to by WR (at first byte of data, not marker)
; Also trashes XR and YR
; returns carry set if things went fine
; clear if double-free or freeing top of heap
.proc     _free
          lda   WR
          sec
          sbc   #.loword(HDR_SIZE)
          sta   WR
          lda   WR+2
          sbc   #.hiword(HDR_SIZE)
          sta   WR+2
          ldy   #$04
          lda   [WR],y
          bpl   bad
          and   #$7FFF
          sta   [WR],y
          jsr   _collect
          jsr   _shrink_heap
          sec
          rts
bad:      clc
          rts
.endproc

; Collect adjacent free blocks into larger blocks
; uses WR,XR,YR
.proc     _collect
          jsr   _chk_himem
          bcs   done
loop:     ldy   #$04
          lda   [WR],y
          and   #$8000
          beq   :+                ; this block is free, peek at the next block
next:     jsr   _nextblk          ; otherwise, it is used, move on
          bcc   loop
done:     rts
:         dey
          dey
          lda   [WR],y            ; get next block address into YR
          sta   YR+2
          dey
          dey
          lda   [WR],y
          sta   YR
          lda   YR+2
          cmp   MEM_TOP+2         ; and see if it is MEM_TOP
          bne   :+
          lda   YR
          cmp   MEM_TOP
:         bcs   done              ; if it is, we are done
          ldy   #$04              ; see if it is a free block
          lda   [YR],y
          and   #$8000
          bne   next              ; if not free, move on
          dey                     ; if free, eat it by copying its pointer to ours
          dey
          lda   [YR],y
          sta   [WR],y
          dey
          dey
          lda   [YR],y
          sta   [WR],y
          bra   loop              ; check this block *again* to roll up more
.endproc

; Shrink the heap by removing the first block, if it is free
.proc     _shrink_heap
loop:     jsr   _chk_himem
          bcs   done
          ldy   #$04              ; see if free
          lda   [WR],y
          and   #$8000
          bne   done              ; nope, it's used, we are done
          dey
          dey
          lda   [WR],y            ; get pointer high word
          pha                     ; save on stack
          dey
          dey
          lda   [WR],y            ; get low word
          ldy   #SV_HIMEM         ; and write it out to HIMEM making it the new HIMEM
          sta   [SYSVARS],y
          iny
          iny
          pla
          sta   [SYSVARS],y
          bra   loop              ; go check it again
done:     rts
.endproc

; Memory move routines
; move XR bytes of memory from [WR] to [YR]

; Move appropriately based on source and destination
.proc     _memmove
          lda   WR
          cmp   YR
          lda   WR+2
          sbc   YR+2
          ; now carry is set if WR >= YR, move down in that case, otherwise move up
          ; fall-through
.endproc

; Move up if carry clear, down if carry set
.proc     _memmove_c
          php
          lda   XR                ; first, pre-decrement XR
          bne   :+
          dec   XR+2
          bpl   :+
          plp
          rts                     ; nothing to move
:         dec   XR
          plp
          bcc   _memmove_up
          ; fall-through if carry set
.endproc

; adapted from 6502org.wikidot.com
.proc     _memmove_dn
fromh     = WR+2
froml     = WR
toh       = YR+2
tol       = YR
sizeh     = XR+2
sizel     = XR
md7       = ZR
          phx
          php
          lda   #$6B00            ; RTL
          sta   md7+2
          lda   #$0054            ; MVN
          sta   md7
          sep   #$21              ; 8-bit accumulator, set carry
          .a8  
          lda   fromh
          sta   md7+2
          lda   toh
          sta   md7+1
          lda   sizeh
          eor   #$80              ; set v if sizeh is zero, clear v otherwise
          sbc   #$01
          rep   #$30
          .a16
          .i16                    ; already should be...
          ldx   froml
          ldy   tol
          tya  
          cmp   froml
          bcc   md3               ; if y < x then $FFFF-x < $FFFF-y
          bra   md4
          .a8
md1:      sta   sizeh
          eor   #$80              ; set v if sizeh is zero, clear v otherwise
          sbc   #$01
          cpx   #$0000
          bne   md2               ; if x is not zero, then y must be
          inc   md7+2
          rep   #$20
          .a16
          tya  
          bne   md4
          sep   #$20
          .a8
md2:      inc   md7+1
          rep   #$20
          .a16
md3:      txa
md4:      eor   #$FFFF            ; A xor $FFFF = $FFFF - a
          bvc   md5               ; branch if sizeh is nonzero
          cmp   sizel
          bcc   md6
          lda   sizel
md5:      clc  
md6:      pha  
          phb  
          jsl   f:_callzr
          plb  
          pla  
          eor   #$FFFF            ; a xor $FFFF = $FFFF - a = -1 - a
          adc   sizel
          sta   sizel             ; sizel = sizel - 1 - a
          sep   #$20
          .a8
          lda   sizeh             ; update high byte of size
          sbc   #$00
          bcs   md1
          plp
          .a16
          .i16
          plx
          rts
.endproc

.proc     _memmove_up
fromh     = WR+2
froml     = WR
toh       = YR+2
tol       = YR
sizeh     = XR+2
sizel     = XR
mu7       = ZR
          ; first convert start addresses to end addresses
          lda   WR
          clc
          adc   XR
          sta   WR
          lda   WR+2
          adc   XR+2
          sta   WR+2
          lda   YR
          clc
          adc   XR
          sta   YR
          lda   YR+2
          adc   XR+2
          sta   YR+2
          ; now start the move
          phx
          php
          lda   #$6B00            ; RTL
          sta   mu7+2
          lda   #$0044            ; MVP
          sta   mu7
          sep   #$21              ; 8-bit accumulator, set carry
          .a8
          lda   fromh
          sta   mu7+2
          lda   toh
          sta   mu7+1
          lda   sizeh
          eor   #$80              ; set v if sizeh is zero, clear v otherwise
          sbc   #$01
          rep   #$30
          .a16
          .i16
          ldx   froml
          ldy   tol
          tya  
          cmp   froml
          bcs   mu3
          bra   mu4
          .a8                     ; a is 8 bits when we branch to mu1!
mu1:      sta   sizeh
          eor   #$80              ; set v if size is zero, clear v otherwise
          sbc   #$01
          cpx   #$FFFF
          bne   mu2               ; if x is not $FFFF, then y must be
          dec   mu7+2
          rep   #$20
          .a16
          tya  
          cpy   #$FFFF
          bne   mu4
          sep   #$20
          .a8
mu2:      dec   mu7+1
          rep   #$20
          .a16
mu3:      txa
mu4:      bvc   mu5               ; branch if sizeh is nonzero
          cmp   sizel
          bcc   mu6
          lda   sizel
mu5:      clc  
mu6:      pha  
          phb  
          jsl   f:_callzr
          plb  
          pla  
          eor   #$FFFF            ; a xor $FFFF = $FFFF - a = -1 - a
          adc   sizel
          sta   sizel             ; sizel = sizel - 1 - a
          sep   #$20
          .a8
          lda   sizeh             ; update high byte of size
          sbc   #$00
          bcs   mu1
          plp
          .a16
          .i16
          plx
          rts
.endproc

.proc     _callzr
          sep   #SHORT_A
          .a8
          pha                     ; ( -- x )
          rep   #SHORT_A
          .a16
          pha                     ; ( x -- x x x )
          pha                     ; ( x x x -- x x x ah al )
          sep   #SHORT_A
          .a8
          lda   #$00              ; ZR is in bank 0
          sta   5,s               ; ( x x x ah al -- 0 x x ah al )
          rep   #SHORT_A
          .a16
          tdc
          dec   a
          clc
          adc   #.loword(ZR)      ; calculate actual location of ZR
          sta   3,s               ; ( 0 x x ah al -- 0 zrh zrl ah al )
          pla                     ; ( 0 zrh zrl ah al -- 0 zrh zrl )
          rtl                     ; ( 0 zrh zrl -- )
.endproc
