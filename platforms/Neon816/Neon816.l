FEATURES {
	STARTADDRESS: default = $200000;
}

MEMORY {
	ROM: start = $200000, size = $10000, fillval=$FF, file = %O;
	ZP: start = $0000, size = $100;
}

SEGMENTS {
	FStartup: load=ROM, type=ro, fillval=$00;
	FSystem: load=ROM, type=ro, fillval=$00;
	FCode: load=ROM, type=ro, fillval=$00, optional=yes;
	ROMBOOT: load=ROM, type=ro, offset=$FF00;
	VECTORS: load=ROM, type=ro, offset=$FFE0;
	ZEROPAGE: load=ZP, type=bss;
}

