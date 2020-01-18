/* Quartus II 64-Bit Version 14.1.0 Build 186 12/03/2014 SJ Web Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Ign)
		Device PartName(SOCVHPS) MfrSpec(OpMask(0));
	P ActionCode(Cfg)
		Device PartName(5CSEMA5F31) Path("C:/CPEN 211 LABS/CPEN 211 lab 1/lab1_synth/output_files/") File("lab1_top.sof") MfrSpec(OpMask(1) SEC_Device(EPCQ128) Child_OpMask(1 0));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
