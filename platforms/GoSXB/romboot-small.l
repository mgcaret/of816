# This config is for an unbanked 32K ROM @0x8000 in bank 0

MEMORY {
    MAINMEM: start = $0000, size=$10000;
	ROM: start = $8000, size = $8000, fillval=$FF, file = %O;
	ZP: start = $0000, size = $100;
}

SEGMENTS {
    ROMBOOT: load=ROM, run=ROM, start=$FF00, type=ro;
    VECTORS: load=ROM, run=ROM, start=$FFE0, type=ro;
}
