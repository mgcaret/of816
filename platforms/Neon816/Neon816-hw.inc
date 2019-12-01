
cpu_clk   = 14000000

; *****************
; MMU
; *****************

NeonMMU   = $080000

; *****************
; I/O Ports
;
; Generally for the status ports, unless otherwise stated
; b3 = transmit buffer full (output is busy)
; b0 = receive buffer full (input is ready)
; *****************

SERio     = $100008
SERstat   = $100009
; Presumably baud and line setup
SERctrlA  = $10000A               ; NeonForth sets this to $8D
SERctrlB  = $10000B               ; ditto $06
SERctrlC  = $10000C               ; ditto $00

; MIDI ports
MIDIio    = $100020
MIDIstat  = $100021

; PS/2 Keyboard Port
PS2Kio    = $100022
PS2Kstat  = $100023

; PS/2 Mouse Port
PS2Mio    = $100024
PS2Mstat  = $100025

; *****************
; RTC
; *****************

RTCus     = $100100               ; 2 bytes
RTCms     = $100102               ; 2 bytes
RTCsec    = $100104               ; 1 byte
RTCmin    = $100105               ; 1 byte
RTChour   = $100106               ; 1 byte
RTCday    = $100108               ; 2 bytes

; *****************
; I2C
; *****************

I2C2io    = $100014
I2C2ctrl  = $100015               ; read: b3 = busy; write: $01 = start, $02 = stop, $04 = receive, $08 = send, $44 = receive/ack

; *****************
; SPI
; *****************

SPI2io    = $10001C
SPI2ctrl  = $10001D               ; read: b3 = tx busy, b2 = rx full; write: $01 = start, $00 = stop; init = $00
SPI2ctrl2 = $10001E               ; init = $00
SPI2ctrl3 = $10001F               ; init = $05


; *****************
; VDC
; *****************

VDCio     = $100120               ; read: 1 byte, write: 1 or 2 bytes

; *****************
; FDC
; *****************

FDCio     = $090004
FDCstat   = $090005               ; b7=0 = tx busy



