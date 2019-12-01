# Neon816

This is a port to Lenore Byron's [Neon816](https://hackaday.io/project/164325-neon816)
system.  The Neon816 Developer Edition ships with a small 16-bit Forth.

At the time of commit 91af87fa4e42dced1d22d3cb620e84e6edb91817, OF816 for the Neon816
is configured to run out of any available ROM bank at starting address $0000.  It configures
the MMU hopefully like NeonFORTH does, sets the data stack from $0000-$01FF and the return stack from $0200-$03FF.  It hopefully also configures the serial port.

To build OF816 for the Neon816, change to the platform directory and run
build.sh. It will output a binary named "forth" that can be started at address $0000 of the
bank it is loaded into. 

At this point nothing further can be done until we have the ability to use the debug port to
load OF816 into the flash ROM.

## Port Features

Hopefully this section will be filled up with stuff that works like Lenore's
Forth.  See the [Neon816 Manual](https://cdn.hackaday.io/files/1643257030480800/sysmanual.pdf)

