FEATURES {
	STARTADDRESS: default = $200000;
}

MEMORY {
	ROM: start = $200000, size = $10000, file = %O;
	ZP: start = $0000, size = $100;
}

SEGMENTS {
	FStartup: load=ROM,type=ro;
	FSystem: load=ROM, type=ro;
	FCode: load=ROM, type=ro, optional=yes;
	ZEROPAGE: load=ZP, type=bss;
}

