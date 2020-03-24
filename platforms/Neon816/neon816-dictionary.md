# -

Updated: 2020-03-23 20:21:18 -0700

## $KBDRESET

_( -- )_ send reset command to PS/2 keyboard

## DUMPEDID

_( -- )_ dump display EDID data, first 256 bytes.

## GETRTC

_( -- day hour minutes seconds ms us )_ get RTC

## I2C2!

_( byte -- )_ write byte to I2C2.

## I2C2@

_( -- byte )_ receive byte from I2C2, do not send ack.

## I2C2@+

_( -- byte )_ receive byte from I2C2, send ack.

## I2C2START

_( -- )_ start I2C2 communication.

## I2C2STOP

_( -- )_ stop I2C2 communication.

## PS2K!

_( byte -- )_ write byte to PS/2 keyboard port.

## PS2K?

_( -- f )_ f is true if data waiting at PS/2 keyboard port.

## PS2K@

_( -- byte )_ read byte from PS/2 keyboard port.

## PS2KEY

_( -- c )_ wait for keypress on PS/2 port, c is the character typed.

## PS2M!

_( byte -- )_ write byte to PS/2 mouse port.

## PS2M?

_( -- f )_ f is true if data waiting at PS/2 mouse port.

## PS2M@

_( -- byte )_ read byte from PS/2 keyboard port.

## PS2RAW

_( -- code f )_ read raw keycode from PS/2 port.
code is keycode, either xx or E0xx, f is true if break.

## SETRTC

_( day hour minutes seconds ms us -- )_ set RTC

## SPI2!

_( byte -- )_ write byte to SPI2.

## SPI2@

_( -- byte )_ fetch byte from SPI2.

## SPI2INIT

_( -- )_ initialize SPI2.

## SPI2START

_( -- )_ start SPI2 communication.

## SPI2STOP

_( -- )_ stop SPI2 communication.

## VDC!

_( offset word -- )_ write word to VDC at offset

## VDCC!

_( offset byte -- )_ write byte to VDC at offset

## VDCC@

_( offset -- byte )_ read byte from VDC at offset

## VIDSTART

## VIDSTOP

## VMODELINE

