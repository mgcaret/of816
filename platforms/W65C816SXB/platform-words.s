; Platform support dictionary words for WDC W65C816SXB
;
; This file serves as a "reference implementation" for how to do this.

; ROM read. This will read from the SXB's flash ROM, from any bank.
; Requires memmgr.s to have the memory move routines and platform-lib.s to have
; _sxb_readrom
; Since we expect the Forth interpreter to be in the ROM, this works by copying the
; _sxb_readrom routine into allocated RAM and executing it from there using RTL tricks.
; H: ( rom_addr dest_addr size ) rom_addr is a 'virtual' address of bb00xxxx
dword     SXB_READROM,"$SXB-READROM"
          ENTER
          ONLIT _sxb_readrom      ; ( -- a-addr )
          ONLIT .sizeof(_sxb_readrom) ; ( a-addr -- a-addr u )
          .dword DUP              ; ( ... a-addr u u' )
          .dword ALLOC            ; ( ... a-addr1 u a-addr2 )
          .dword DUP              ; ( ... a-addr1 u a-addr2 a-addr2' )
          .dword PtoR             ; ( ... a-addr1 u a-addr2 )
          .dword SWAP             ; ( ... a-addr1 a-addr2 u )
          .dword MOVE             ; ( a-addr1 a-addr2 u -- ) move code into place
          .dword RCOPY            ; ( -- a-addr2' )
          CODE
          jsr   _popay            ; set up a JML to allocated routine
          sty   ZR+1
          sep   #SHORT_A
          .a8
          sta   ZR+3
          lda   #opJML
          sta   ZR
          rep   #SHORT_A
          .a16
          jsr   _popxr            ; pop read arguments from the stack
          jsr   _popyr            ; into the correct working registers
          jsr   _popwr
          jsl   f:_callzr         ; and call the allocated routine
          ENTER
          .dword RtoP             ; pull allocation off stack
          ONLIT .sizeof(_sxb_readrom)
          .dword FREE             ; and free it
          EXIT
eword

dword     dCPU_HZ,"$CPU_HZ"
          FCONSTANT cpu_clk
eword

.if include_fcode ; SXB stuff, should do different
dword     SXB_ROMLDR,"$SXB-ROMLDR"
          ENTER
          ONLIT :+
          .dword ONE
          .dword BYTE_LOAD
          EXIT
:         PLATFORM_INCBIN "fcode/romloader.fc"
eword
.endif
