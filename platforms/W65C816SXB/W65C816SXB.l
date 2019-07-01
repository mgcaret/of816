FEATURES {
	STARTADDRESS: default = $8000;
}

MEMORY {
	ROM: start = $8000, size = $7800, file = %O;
	ZP: start = $0000, size = $100;
}

SEGMENTS {
	FStartup: load=ROM,type=ro;
	FSystem: load=ROM, type=ro;
	FCode: load=ROM, type=ro, optional=yes;
	ZEROPAGE: load=ZP, type=bss;
}

