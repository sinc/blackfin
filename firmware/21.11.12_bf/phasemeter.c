/*++

Copyright (c) 2012 RPHIS

Module Name:

    phasemeter.c 

Abstract:

    Firmware for PLL

Environment:

    kernel mode

Notes:
	
Revision History:

    21/11/12: created

--*/

//include
#include <stdio.h>
#include <cdefBF532.h>
#include <sysreg.h>
#include <ccblkfn.h>
#include "Timer_ISR.h"

//defines
#define STRINGSIZE 512

#define DEBUG(x, str)				\
	do {							\
		sprintf(g_bStrbuf, str);	\
		sendBuf(g_bStrbuf); }		\
	while(0)
	

//globals
char g_bStrbuf[STRINGSIZE];

inline
void
initUART(
	void
)
{
    *(pUART_LCR) |= DLAB;	// Enable access to DLL and DLH registers
	*pUART_DLL = 0x9A;		//19200
	*pUART_DLH = 0x01;
	*(pUART_LCR) &= ~DLAB;	// clear DLAB bit
	*pUART_LCR = 0x03;
	*pUART_IER = (ELSI|ERBFI);
    *pUART_GCTL = UCEN;		// Enable UART clock
}

inline
void
initPLL(
	void
)
{
	sysreg_write(reg_SYSCFG, 0x32);		//Initialize System Configuration Register
	*pSIC_IWR = 0x1;		//pll wakeup
	//CLKIN is 27 MHz
	*pPLL_CTL = 0x9C00;		// DF = 0, MSEL is 14, which gives:	VCO of 378 MHz (27*14=378)
	*pPLL_DIV = 0x03;		// SSEL is 3, which gives:	SCLK of 126 MHz (378/3=126)
							// CSEL is 0, which gives:	CCLK of 378 MHz (378/1=378)	
	ssync();
	*pVR_CTL = 0xDB;		//1.2 V
	ssync();
	idle();					//wait while pll not lock
}

int
putChar(
	const char cVal
)
{
	int nStatus = 0;
	unsigned int nTimer = SetTimeout(1000);
	if(((unsigned int)-1) != nTimer) {	
		do { 
			if((*pUART_LSR & THRE)) {
				*pUART_THR = cVal;
				nStatus = 1;
				break; //return 1;
				//asm("nop;");  
			}
		}while(!IsTimedout(nTimer));
	}
	ClearTimeout(nTimer);
	return nStatus;
}

int
getChar(
	char *const cVal
)
{
	int nStatus = 0;
	unsigned int nTimer = SetTimeout(1000);
	if(((unsigned int)-1) != nTimer) {
		do { 
			if(DR == (*pUART_LSR & DR)) { 
				*cVal = *pUART_RBR;
				nStatus = 1;
				break; //return 1;		
				//asm("nop;");  
			}
		}while(!IsTimedout(nTimer));
	}
	ClearTimeout(nTimer);
	return nStatus;
}

void
sendBuf(
	char *buf
)
{
	while (*buf) {
		putChar(*buf);
		++buf;
	}
}

void
welcome(
	void
)
{
	DEBUG(1,"                                         ,8888oo.\r\n");
    DEBUG(1,"                                          Y8888888o.\r\n");
    DEBUG(1,"                                           Y888888888L\r\n");
    DEBUG(1,"                                            Y8888888888L\r\n");
    DEBUG(1,"                                             888888888888L\r\n");
    DEBUG(1,"                                             d8888888888888.\r\n");
    DEBUG(1,"                                             ]888888888888888.\r\n");
    DEBUG(1,"                                             ]888888888PP''''\r\n");
    DEBUG(1,"                                             ]8888888P'          .\r\n");
    DEBUG(1,"    ,ooooo.                                  ]88888P    ,ooooooo88b.\r\n");
    DEBUG(1,"   ,8888888p                                 ]8888P   ,8888888888888o\r\n");
    DEBUG(1,"   d88P'888[ ooo'    oooo.  _oooo.  ooo  oop ]888P    `'' ,888P8888888o\r\n");
    DEBUG(1,"  ,888 J88P J88P    d8P88  d88P888 ,88P,88P  `P''       ,88P' ,888888888L\r\n");
    DEBUG(1,"  d888o88P' 888'   ,8P,88 ,88P 88P d88b88P    __    d88888[ _o8888888P8888.\r\n");
    DEBUG(1," ,8888888. J88P    88'd8P d88  '' ,88888P    d8'   d888888888888888P   88PYb.\r\n");
    DEBUG(1," d88P 888P 888'   d8P 88[,88P ,o_ d88888.   ,8P   d8888P'  88888P'    P'   ]8b_\r\n");
    DEBUG(1,",888']888'J88P   d888888 d88'J88',88Pd88b   JP   d888P     888P',op    ,   d88P\r\n");
    DEBUG(1,"d8888888P d88bo.,88P'Y8P 888o88P d88']88b   d'  ,8P'_odb   ''',d8P  _o8P  ,P',,d8L\r\n");
    DEBUG(1,"PPPPPPP' `PPPPP YPP  PPP `PPPP' <PPP `PPP  ,P   88o88888.  ,o888'  o888     d888888.\r\n");
    DEBUG(1,"                                           d'  d888888888888888L_o88888L_,o888888888b.\r\n");
    DEBUG(1,"                                          dP  d888888888888888888888888888888888888888o\r\n");
    DEBUG(1,"                                        dd8' ,888888888888888888888888888888888888888888L\r\n");
    DEBUG(1,"                                       d88P  d88888888888888888888888888888888888888888888.\r\n");
}

void
main(
)
{
	int i;
	initPLL();
	Init_Timers();
	Init_Timer_Interrupts();
	initUART();
	
	*pFIO_DIR = 0x01;
	*pFIO_FLAG_D = 0x01;
	*pFIO_FLAG_S = 0x01;
	welcome();
	while (1) {
		//for (i = 0; i < 256; i++) {
		//	putChar(i & 0xFF);
		//}
	}
}
