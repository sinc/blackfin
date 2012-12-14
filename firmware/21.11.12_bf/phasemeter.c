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
#include "Timer_ISR.h"
#include "ADF4351.h"

//defines
#define STRINGSIZE 512

#define SDRAM_START  0x00000000	// start address of SDRAM
#define SDRAM_SIZE	 0x02000000	// size of SDRAM in bytes (32 MB)

#define DEBUG(str, ...)							\
	do {										\
		sprintf(g_bStrbuf, str, ##__VA_ARGS__);	\
		sendBuf(g_bStrbuf); }					\
	while(0)
	

//globals
char g_bStrbuf[STRINGSIZE];

inline
void
initPLL(
	void
)
{
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

inline
void
initSDRAM(
	void
)
{
	*pEBIU_SDRRC = 0x07A7;		//SDRAM Refresh Rate Control Register
	//SDRAM Memory Bank Control Register
	*pEBIU_SDBCTL = EBCAW_10 |	// 10 bit addressing column
					EBSZ_32  |	// 32 Mb of SDRAM
					EBE;		// SDRAM enable
	//SDRAM Memory Global Control Register
	*pEBIU_SDGCTL   = ~CDDBG  & // Control disable during bus grant off 
	                  ~FBBRW  & // Fast back to back read to write off   
	                  ~EBUFE  & // External buffering enabled off 
	                  ~SRFS   & // Self-refresh setting off 
	                  ~PSM    & // Powerup sequence mode (PSM) first
	                  ~EMREN  & // Extended mode register enabled off
	                  PUPSD   | // Powerup start delay (PUPSD) on 
	                  TCSR    | // Temperature compensated self-refresh at 85
	                  PSS     | // Powerup sequence start enable (PSSE) on 
	                  TWR_2   | // Write to precharge delay TWR = 2 (14-15 ns) 
	                  TRCD_3  | // RAS to CAS delay TRCD =3 (15-20ns) 
	                  TRP_3   | // Bank precharge delay TRP = 3 (15-20ns) 
	                  TRAS_6  | // Bank activate command delay TRAS = 6 ~44 ns
	                  PASR_B0 | // Partial array self refresh Only SDRAM Bank0  
	                  CL_3    | // CAS latency 
	                  SCTLE; 	// SDRAM clock enable
	ssync();
}

inline
void
initSPI(
	void
)
{
	*pSPI_BAUD = 0x13B;		//200 kHz
	*pSPI_CTL = SPE | SZ | SIZE | MSTR | (TIMOD & 1);
	ssync();
}

inline
void
initUART(
	void
)
{
    *pUART_LCR |= DLAB;		// Enable access to DLL and DLH registers
	*pUART_DLL = 0x9A;		//19200
	*pUART_DLH = 0x01;
	*pUART_LCR &= ~DLAB;	// clear DLAB bit
	*pUART_LCR = 0x03;
	*pUART_IER = (ELSI|ERBFI);
    *pUART_GCTL = UCEN;		// Enable UART clock
    ssync();
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

unsigned int
spiRead8(
	unsigned int address
)
{
	unsigned int data = 0;
	*pFIO_FLAG_T = PF2;
	ssync();
	//send read command
	*pSPI_TDBR = 0x03;
  	while(!((*pSPI_STAT) & RXS));
  	data = *pSPI_RDBR;
  	//send first address byte
  	*pSPI_TDBR = (address >> 16) & 0xFF;
	while(!((*pSPI_STAT) & RXS));
	data = *pSPI_RDBR;
	//send second address byte
	*pSPI_TDBR = (address >> 8) & 0xFF;
	while(!((*pSPI_STAT) & RXS));
	data = *pSPI_RDBR;
	//send third address byte
	*pSPI_TDBR = address & 0xFF;
	while(!((*pSPI_STAT) & RXS));
	data = *pSPI_RDBR;
	//send dummy
	*pSPI_TDBR = 0;
	while(!((*pSPI_STAT) & RXS));
	data = *pSPI_RDBR;
	*pFIO_FLAG_T = PF2;
	ssync();
	return data;
}

void
ADFWrite32(
	unsigned int reg
)
{
	unsigned int data = 0;
	*pFIO_FLAG_T = PF1;
	ssync();
	*pSPI_TDBR = (reg >> 16) & 0xFFFF;
  	while(!((*pSPI_STAT) & RXS));
  	data = *pSPI_RDBR;
	*pSPI_TDBR = reg & 0xFFFF;
  	while(!((*pSPI_STAT) & RXS));
  	data = *pSPI_RDBR;
	*pFIO_FLAG_T = PF1;
	ssync();
	*pFIO_FLAG_T = PF3;
	ssync();
	*pFIO_FLAG_T = PF3;
	ssync();
}


void
initADF(
	void
)
{
	ADFWrite32(0x009A8000);
	ADFWrite32(0x80080009);
	ADFWrite32(0x00004E42);
	ADFWrite32(0x000004B3);
	ADFWrite32(0x0095003C);
	ADFWrite32(0x00580005);
}

void
main(
)
{
	unsigned int addr;
	
	sysreg_write(reg_SYSCFG, 0x32);		//Initialize System Configuration Register
	
	initPLL();
	initSDRAM();
	Init_Timers();
	Init_Timer_Interrupts();
	initUART();
	initSPI();
		
	*pFIO_DIR = PF0 | PF1 | PF3;
	*pFIO_FLAG_S = PF0 | PF1;
	*pFIO_FLAG_C = PF3;
	ssync();
	
	initADF();
	while (1) {
		//for (i = 0; i < 256; i++) {
		//	putChar(i & 0xFF);
		//}
	}
}
