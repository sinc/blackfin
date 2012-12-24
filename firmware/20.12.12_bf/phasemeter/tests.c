/*
void
welcome(
	void
)
{
	DEBUG("                                         ,8888oo.\r\n");
    DEBUG("                                          Y8888888o.\r\n");
    DEBUG("                                           Y888888888L\r\n");
    DEBUG("                                            Y8888888888L\r\n");
    DEBUG("                                             888888888888L\r\n");
    DEBUG("                                             d8888888888888.\r\n");
    DEBUG("                                             ]888888888888888.\r\n");
    DEBUG("                                             ]888888888PP''''\r\n");
    DEBUG("                                             ]8888888P'          .\r\n");
    DEBUG("    ,ooooo.                                  ]88888P    ,ooooooo88b.\r\n");
    DEBUG("   ,8888888p                                 ]8888P   ,8888888888888o\r\n");
    DEBUG("   d88P'888[ ooo'    oooo.  _oooo.  ooo  oop ]888P    `'' ,888P8888888o\r\n");
    DEBUG("  ,888 J88P J88P    d8P88  d88P888 ,88P,88P  `P''       ,88P' ,888888888L\r\n");
    DEBUG("  d888o88P' 888'   ,8P,88 ,88P 88P d88b88P    __    d88888[ _o8888888P8888.\r\n");
    DEBUG(" ,8888888. J88P    88'd8P d88  '' ,88888P    d8'   d888888888888888P   88PYb.\r\n");
    DEBUG(" d88P 888P 888'   d8P 88[,88P ,o_ d88888.   ,8P   d8888P'  88888P'    P'   ]8b_\r\n");
    DEBUG(",888']888'J88P   d888888 d88'J88',88Pd88b   JP   d888P     888P',op    ,   d88P\r\n");
    DEBUG("d8888888P d88bo.,88P'Y8P 888o88P d88']88b   d'  ,8P'_odb   ''',d8P  _o8P  ,P',,d8L\r\n");
    DEBUG("PPPPPPP' `PPPPP YPP  PPP `PPPP' <PPP `PPP  ,P   88o88888.  ,o888'  o888     d888888.\r\n");
    DEBUG("                                           d'  d888888888888888L_o88888L_,o888888888b.\r\n");
    DEBUG("                                          dP  d888888888888888888888888888888888888888o\r\n");
    DEBUG("                                        dd8' ,888888888888888888888888888888888888888888L\r\n");
    DEBUG("                                       d88P  d88888888888888888888888888888888888888888888.\r\n");
}
*/

void
testSDRAM(
	void
)
{
	volatile unsigned int *pDst = 0;
	int nIndex = 0;

	*pDst = 0x00000000; ++pDst;
	*pDst = 0x11112222; ++pDst;
	*pDst = 0x22223333; ++pDst;
	*pDst = 0x33334444; ++pDst;
	*pDst = 0x44445555; ++pDst;
	*pDst = 0x55556666; ++pDst;
	*pDst = 0x66667777; ++pDst;
	*pDst = 0x77778888; ++pDst;
	*pDst = 0x88889999; ++pDst;
	*pDst = 0x9999aaaa; ++pDst;
	*pDst = 0xaaaabbbb; ++pDst;
	*pDst = 0xbbbbcccc; ++pDst;
	*pDst = 0xccccdddd; ++pDst;
	*pDst = 0xddddeeee; ++pDst;
	*pDst = 0xeeeeffff; ++pDst;
	*pDst = 0xffff0000;
	
	for (nIndex = 0, pDst = 0; nIndex < 16; nIndex++) {
		DEBUG("data at address %X value %X\r\n", pDst+nIndex, *(pDst+nIndex));
	}
	
	DEBUG("write incrementing values to each SRAM location\r\n");
	for(nIndex = 0x12345678, pDst = (unsigned int *)SDRAM_START; pDst < (unsigned int *)(SDRAM_START + SDRAM_SIZE); pDst++, nIndex++ )
	{
		*pDst = nIndex;
	}
	
	DEBUG("verify incrementing values: ");
	for(nIndex = 0x12345678, pDst = (unsigned int *)SDRAM_START; pDst < (unsigned int *)(SDRAM_START + SDRAM_SIZE); pDst++, nIndex++ )
	{
		if( nIndex != *pDst )
		{
			DEBUG("fail at index %X value %X\r\n", pDst, *pDst);
			//return;
		}
	}
	DEBUG("well done! address %X\r\n", pDst);
	for (nIndex = 0; nIndex < 16; nIndex++) {
		DEBUG("data at address %X value %X\r\n", pDst-nIndex, *(pDst-nIndex));
	}
	DEBUG("write all FFFF's\r\n"); 
	for(nIndex = 0xFFFFFFFF, pDst = (unsigned int *)SDRAM_START; pDst < (unsigned int *)(SDRAM_START + SDRAM_SIZE); pDst++ )
	{
		*pDst = nIndex;
	}
	
	DEBUG("verify all FFFF's: ");
	for(nIndex = 0xFFFFFFFF, pDst = (unsigned int *)SDRAM_START; pDst < (unsigned int *)(SDRAM_START + SDRAM_SIZE); pDst++ )
	{
		if( nIndex != *pDst )
		{
			DEBUG("fail at index %X value %X\r\n", pDst, *pDst);
			//return;
		}
	}
	DEBUG("well done! address %X\r\n", pDst);
	DEBUG("write all AAAAAA's\r\n");
	for(nIndex = 0xAAAAAAAA, pDst = (unsigned int *)SDRAM_START; pDst < (unsigned int *)(SDRAM_START + SDRAM_SIZE); pDst++ )
	{
		*pDst = nIndex;
	}
	
	DEBUG("verify all AAAAA's: ");
	for(nIndex = 0xAAAAAAAA, pDst = (unsigned int *)SDRAM_START; pDst < (unsigned int *)(SDRAM_START + SDRAM_SIZE); pDst++ )
	{
		if( nIndex != *pDst )
		{
			DEBUG("fail at index %X value %X\r\n", pDst, *pDst);
			//return;
		}
	}
	DEBUG("well done! address %X\r\n", pDst);	
	DEBUG("write all 555555's\r\n"); 
	for(nIndex = 0x55555555, pDst = (unsigned int *)SDRAM_START; pDst < (unsigned int *)(SDRAM_START + SDRAM_SIZE); pDst++ )
	{
		*pDst = nIndex;
	}
	
	DEBUG("verify all 55555's: ");
	for(nIndex = 0x55555555, pDst = (unsigned int *)SDRAM_START; pDst < (unsigned int *)(SDRAM_START + SDRAM_SIZE); pDst++ )
	{
		if( nIndex != *pDst )
		{
			DEBUG("fail at index %X value %X\r\n", pDst, *pDst);
			//return;
		}
	}
	DEBUG("well done! address %X\r\n", pDst);
}
