FEATURES {
	STARTADDRESS: default = $2000;
}

MEMORY {
	RAM: start = $2000, size = $9E00, file = %O;
	ZP: start = $0000, size = $100;
}

SEGMENTS {
	FStartup: load=RAM, type=rw;
	FSystem: load=RAM, type=ro;
	FCode: load=RAM, type=ro, optional=yes;
	ZEROPAGE: load=ZP, type=bss;
}
