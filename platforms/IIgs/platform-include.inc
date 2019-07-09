; System page 0 stuff; note, address absolute
_BASL     = $28                   ; line base address (updated by firmware)
; System varaibles, address absolute
_CH       = $57B                  ; cursor horizontal position
_CV       = $5FB                  ; cursor vertical position
; these don't seem to be respected by the Pascal 1.1 interface and keep
; getting reset to their default values
_WL       = $20                   ; window left
_WW       = $21                   ; window width
_WT       = $22                   ; window top
_WB       = $23                   ; window bottom


; System firmware routines
IDRoutine = $FE1F                 ; identify IIgs
Reset     = $FA62                 ; reset handler
Scroll    = $FC70                 ; scroll up

; These are at page 3
DPSAVE    = $300                  ; save direct page reg for native calls
SPSAVE    = DPSAVE+2              ; save stack pointer for native cxalls
CON_RD    = SPSAVE+2              ; Pascal Read for slot 3
CON_WR    = CON_RD+2              ; Pascal Write for slot 3
CON_ST    = CON_WR+2              ; Pascal Status for slot 3
ECALL     = CON_ST+2              ; address of routine to call in emulation mode
AREG      = ECALL+2               ; temporary A register storage for native calls
ESCMODE   = AREG+2                ; ESC mode for OF terminal emu
ESCACC    = ESCMODE+2             ; accumulator for OF terminal emu
ESCNUM1   = ESCACC+2              ; first number of two-number ESC code
MNUM2     = ESCNUM1+2             ; factor for converting numbers
UserId    = MNUM2+2               ; UserId for toolbox calls that need it

PwrByte   = $3F4                  ; Reset vector check byte

MLI       = $BF00                 ; ProDOS 8 MLI
ToolCall  = $E10000               ; Entry for IIgs ToolBox calls
IOBufs    = $1000                 ; space for file buffers
IOBuf_Cnt = 3
Blk_Buf   = $1C00                 ; block buffer
PPad      = $0F00                 ; scracthpad for making parameter lists for P8
RWBuf     = $0E00

; Hardware
STO80_OFF = $C000                 ; turn off 80 store
STO80_ON  = $C001                 ; turn on 80 store
TXTPAGE1  = $C054                 ; set text page 1
TXTPAGE2  = $C055                 ; set text page 2

.macro    Tool callnum
          ldx   #callnum
          jsl   f:ToolCall
.endmacro

.macro    _TLStartUp
          Tool $201
.endmacro

.macro    _TLShutDown
          Tool $301
.endmacro

.macro    _NewHandle
          Tool $902
.endmacro

.macro    _MMStartUp
          Tool $202
.endmacro

.macro    _GetNewId
          Tool $2003
.endmacro

.macro    _MTStartUp
          Tool $203
.endmacro

.macro    _DisposeHandle
          Tool $1002
.endmacro

.macro    _DisposeAll
          Tool $1102
.endmacro

.macro    _MMShutDown
          Tool $302
.endmacro

.macro    _SysFailMgr
          Tool $1503
.endmacro

.macro    _Err  msg
          .local okay, die
          bcc   okay
          pha
          .ifblank msg
          pea   $0000
          pea   $0000
          .else
          pea   .hiword(msg)
          pea   .loword(msg)
          bra   die
          .byte .strlen(msg),msg
          .endif
die:      _SysFailMgr
okay:
.endmacro

