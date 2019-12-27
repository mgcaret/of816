# Note this linker config relies on the fact that bank 3
# in the output file has the same lower 16 bit addresses
# as the run location.  You can't use it to link relative
# code into bank 0 or bank 2

MEMORY {
    MAINMEM: start = $0000, size=$10000;
	ROM: start = $000000, size = $020000, fillval=$FF, file = %O;
	ZP: start = $0000, size = $100;
}

SEGMENTS {
    ROMBOOT: load=ROM, run=ROM, start=$1FF00, type=ro;
    VECTORS: load=ROM, run=ROM, start=$1FFE0, type=ro;
}
