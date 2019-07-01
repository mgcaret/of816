; *** Direct page equates ***
.pushseg
.zeropage
STACKBASE = $00                   ; normally 0
ZR        = $00                   ; 0 four scratch cells
WR        = ZR+4                  ; 4
XR        = WR+4                  ; 8
YR        = XR+4                  ; c
IP        = YR+4                  ; 10 instruction pointer
STK_BTM   = IP+4                  ; 14 lowest bank 0 address usable for stack
STK_TOP   = STK_BTM+2             ; 16 bank 0 address immediately after the upper stack cell
RSTK_TOP  = STK_TOP+2             ; 18 return stack top
SYS_RSTK  = RSTK_TOP+2            ; 1a system return stack pointer
DHERE     = SYS_RSTK+2            ; 1c HERE system variable
MEM_BTM   = DHERE+4               ; 20 System memory bottom
MEM_TOP   = MEM_BTM+4             ; 24 System memory top
SYSVARS   = MEM_TOP+4             ; 28 Pointer to system variables
RSTK_SAVE = SYSVARS+4             ; 2c return stack saved for current CATCH level
CATCHFLAG = RSTK_SAVE+2           ; 2e active catch counter
SYSIF     = CATCHFLAG+2           ; 30 system interface vector, 4 bytes
DP_END    = SYSIF+4               ; 34 must be last so platform libs can used DP
;TMP1      = SYSIF+4               ; 34 temp for ENTER
;DP_END    = TMP1+2                ; 36 must be last so platform libs can use DP
.popseg

; *** system interface function codes ***
SI_PRE_INIT  = $0000
SI_POST_INIT = $0001
SI_EMIT      = $0002
SI_KEYQ      = $0003
SI_KEY       = $0004
SI_GET_FCODE = $0005
SI_RESET_ALL = $0006

; *** Constants ***

opJSL     = $22
opJML     = $5C

c_bell    = $07
c_bs      = $08
c_cr      = $0D
c_lf      = $0A
c_page    = $0C
c_del     = $7F

; *** Processor ***

RESETV = $FFFC

; *** System Info ***
.define   VERSION "0.1"
