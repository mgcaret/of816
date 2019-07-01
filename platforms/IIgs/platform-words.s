
; TODO: implement indirect values, this will help with all kinds of things
; including making these mutable

; H: ( -- u ) cursor line #
dword     LINEn,"LINE#"
          ENTER
          ONLIT _CV
          .dword CFETCH
          EXIT
eword

; H: ( -- u ) cursor line #
dword     COLUMNn,"COLUMN#"
          ENTER
          ONLIT _CH
          .dword CFETCH
          EXIT
eword

; H: ( -- u ) memory manager user ID for this process
dword     dGS_USERID,"$GS-USERID"
          ENTER
          ONLIT UserId
          .dword WFETCH
          EXIT
eword

; H: ( i*n i tbyte1 j tbyte2 tool# -- j*n ) call IIgs toolbox
; tbyte1,2, each bit reflects size of the param, 0=word, 1=long
; tbyte1 = params in, tbyte 2 = params out
; WR=tool# ZR=results types XR+2=results count
; XR=counter,YR=param types (used in loops)
dword     dGS_TOOLCALL,"$GS-TOOLCALL"          
          jsr   _popwr            ; ( ... i*n i tbyte1 j tbyte2 ) -> tool# get tool #
          jsr   _popay            ; ( ... i*n i tbyte1 j ) -> tbyte2 get results types
          sty   ZR                ; save in ZR and YR
          sty   YR
          sta   ZR+2
          sta   YR+2
          jsr   _popay            ; ( ... i*n i tbyte1 ) -> j get results count
          sty   XR+2              ; save in XR and XR+2
          sty   XR
          tya                     ; now make space for results
          beq   doparms           ; if zero, no results expected
l0:       pea   $0000             ; each param is at least a word
          lsr   YR+2
          ror   YR
          bcc   :+
          pea   $0000             ; make it a long if carry set
:         dec   XR
          bne   l0
doparms:  jsr   _popyr            ; ( ... i*n i ) -> tbyte1 get param types into YR
          jsr   _popay            ; ( ... i*n )  -> i get param count
          sty   XR
          tya
          sta   f:$2fe
          beq   docall            ; if none, leave stack alone
l1:       jsr   _popay            ; otherwise, pop all the i*n
          lsr   YR+2              ; get type
          ror   YR
          bcc   :+                ; if carry clear, not a long
          pha                     ; if carry set, push high word
:         phy                     ; push low word
          dec   XR
          bne   l1
docall:   stx   WR+2              ; save stack
          ldx   WR                ; Tool #
          jsl   f:ToolCall
          ldx   WR+2
          sta   WR                ; result code if error
          rol   WR+2              ; carry->bit 0 of WR+2
          lda   XR+2              ; results count
          beq   done              ; if none, do nothing
l2:       lda   #$0000            ; clear high word
          ply                     ; get low word
          lsr   ZR+2              ; now see if it's a long
          ror   ZR
          bcc   :+                ; nope, no high word to get
          pla                     ; yes, get high word
:         jsr   _pushay
          dec   XR+2
          bne   l2
done:     lsr   WR+2              ; was there an error?
          bcc   :+                ; nope, all good
          ldy   WR                ; otherwise get error code
          lda   #$0000
          jmp   _throway          ; and throw it
:         NEXT
eword

dword     uTotalMem,"_TOTALMEM"
          ENTER
          ONLIT 0                 ; # params
          ONLIT 0                 ; Param types
          ONLIT 1                 ; # of results
          ONLIT %1                ; Result types (1=long)
          ONLIT $1D02             ; Tool #
          .dword dGS_TOOLCALL
          EXIT
eword

dword     uReadBParam,"_READBPARAM"
          ENTER
          ONLIT 1                 ; # params
          ONLIT %0                ; Param types
          ONLIT 1                 ; # of results
          ONLIT %0                ; Result types (1=long)
          ONLIT $0C03             ; Tool #
          .dword dGS_TOOLCALL
          EXIT
eword

dword     uReadTimeHex,"_READTIMEHEX"
          ENTER
          ONLIT 0                 ; # params
          ONLIT 0                 ; Param types
          ONLIT 4                 ; # of results
          ONLIT %0000             ; Result types (1=long)
          ONLIT $0D03             ; Tool #
          .dword dGS_TOOLCALL
          EXIT
eword

dword     uReadAsciiTime,"_READASCIITIME"
          ENTER
          ONLIT 1                 ; # params
          ONLIT %1                ; Param types
          ONLIT 0                 ; # of results
          ONLIT 0                 ; Result types (1=long)
          ONLIT $0F03             ; Tool #
          .dword dGS_TOOLCALL
          EXIT
eword

dword     uFWEntry,"_FWENTRY"
          ENTER
          ONLIT 4                 ; # params
          ONLIT %0000             ; Param types
          ONLIT 4                 ; # of results
          ONLIT %0000             ; Result types (1=long)
          ONLIT $2403             ; Tool #
          .dword dGS_TOOLCALL
          EXIT
eword

dword     uSysBeep,"_SYSBEEP"
          ENTER
          ONLIT 0                 ; # params
          ONLIT 0                 ; Param types
          ONLIT 0                 ; # of results
          ONLIT 0                 ; Result types (1=long)
          ONLIT $2C03             ; Tool #
          .dword dGS_TOOLCALL
          EXIT
eword

dword     uSysFailMgr,"_SYSFAILMGR"
          ENTER
          ONLIT 2                 ; # params
          ONLIT %10               ; Param types
          ONLIT 0                 ; # of results
          ONLIT 0                 ; Result types (1=long)
          ONLIT $1503             ; Tool #
          .dword dGS_TOOLCALL
          EXIT
eword

dword     dP8_CALL,"$P8-CALL"
          jsr   _popwr            ; buffer address (in bank 0)
          jsr   _popay            ; call number
          tya
          ldy   WR
          stx   WR
          jsr   _p8_call          ; go make the call
          ldx   WR
          tay
          beq   :+
          lda   #$0001
          jmp   _throway
:         NEXT
eword

dword     dP8_BUFS,"$P8-BUFS"
          FCONSTANT IOBufs
eword

dword     dP8_nBUFS,"$P8-#BUFS"
          FCONSTANT IOBuf_Cnt
eword

dword     dP8_PPAD,"$P8-PPAD"
          FCONSTANT PPad
eword

dword     dP8_RWBUF,"$P8-RWBUF"
          FCONSTANT RWBuf
eword

dword     dP8_BLKBUF,"$P8-BLKBUF"
          FCONSTANT Blk_Buf
eword

          



