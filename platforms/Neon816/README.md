
# Neon816

This is a port to Lenore Byron's [Neon816](https://hackaday.io/project/164325-neon816) system.  The Neon816 Developer Edition ships with a small 16-bit Forth.

OF816 for the Neon816 is configured to run as an alternative firmware out of bank $20.  With a little ajustment, it could be configured to run out of bank $21 (but starting it is an excercise for the reader).

It configures the MMU and serial port like NeonFORTH does.  The direct page, stack, and return stack occupy the first $400 bytes of RAM.

To build OF816 for the Neon816, change to the platform directory and run
``build.sh``. It will output a 64K binary named ``of816-neon.bin`` that can be flashed into the Neon's firmware.  See below for installation instructions.

## Port Features

Hopefully this section will be filled up with stuff that works like Lenore's
Forth.  See the [Neon816 Manual](https://cdn.hackaday.io/files/1643257030480800/sysmanual.pdf).  But right now, it's just a bare port with no system-specific extensions.

## Installation

**THIS WILL OVERWRITE THE NEON'S ORIGINAL FIRMWARE.**

**IT IS STRONGLY RECOMMENDED YOU BACK UP THE ORIGINAL FIRMWARE**

**READ _ALL_ OF THE FOLLOWING BEFORE PROCEEDING AND DO NOT PROCEED IF ANY OF THIS MAKES YOU UNCOMFORTABLE**

After building the firmware image, the image must be converted to Intel Hex format.  I like the bin2hex tool found [here](https://grumpf.hope-2000.org) (page is in German). Build the ``bin2hex`` binary and execute:  ``bin2hex of816-neon.bin > of816-neon.hex`` 

Once you have the .hex file, you will need to use the [Neon firmware loader](https://hackaday.io/project/164325-neon816) to install the image.  This requires an FTDI cable connected to the 3.3V UART header on the Neon816 system board.

To back up the original firmware, you will need to add an additional command routine to neonprog.cpp (add it after the write command):

```
   else if(!strcmp(cmd,"dumprom")) {
        char* fn=strtok(nullptr," ");
        char buf[0x40];
        if(!fn) return;
        auto st=Releaser(
            fopen(fn,"w"),
            [](auto f){if(f) fclose(f);});
        if(!st) {
            printf("Could not open file\n");
            return;
        }
        for (int addr=0x200000; addr<0x220000; addr+=sizeof(buf)) {
            writeHex(addr>>16,2); writeChar(':');
            writeHex(addr,4); writeChar('#');
            for (int i=0; i<sizeof(buf); i++) {
                writeChar('@');
                unsigned char c=readByte();
                buf[i]=c;
            }
            fwrite(&buf, sizeof(buf), 1, st);
            printf("%08X\n",addr);
        }
    }
```

then start neonprog with ``neonprog /dev/ttyUSBx`` (replace device with actual serial device for FTDI cable.

From within neonprog, execute ``dumprom backup.bin`` to save an image of both ROM banks to ``backup.bin``.

Once the backup has finished (it will take a while), you can proceed to the installation of OF816 with ``flash of816-neon.hex``.  This will also take a while.  When it is done, reset your Neon and OF816 should start.

## Restoring the Original NeonFORTH Firmware

Since the Neon (at the time of this writing) only ships with the first bank of flash occupied, first, split your backup with ``split backup.bin``.  This will output two files, ``xaa`` and ``xab`` that are bank $20 and bank $21, respectively.  Then run ``hex2bin xaa > neonforth.hex``.  You can then flash this with neonprog using ``flash neonforth.hex``.   Once it's done, reset your Neon and you should see the original firmware running.
