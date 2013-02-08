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
#include "uart.h"

//defines
#define kStringSize 512
#define kADCChannels 1
#define kSamplesCount 512

#define SDRAM_START  0x00000000	// start address of SDRAM
#define SDRAM_SIZE	 0x02000000	// size of SDRAM in bytes (32 MB)

#define DEBUG(str, ...)							\
	do {										\
		sprintf(g_bStrbuf, str, ##__VA_ARGS__);	\
		sendCharBuf(g_bStrbuf); }				\
	while(0)

//structures
struct sDMADescriptor{
	struct sDMADescriptor *nextDescriptor;
	volatile short *startAddress;
};
typedef struct sDMADescriptor DMADescriptor;

//globals
char g_bStrbuf[kStringSize];
volatile short g_psPPIRxBuffer[kADCChannels * kSamplesCount * 2];
// set up DMA descriptors (sequence = 1st half, then second half, then repeat)
// small descriptor model, only start address needs to be fetched
DMADescriptor g_RxSecond;
DMADescriptor g_RxFirst = { &g_RxSecond, g_psPPIRxBuffer };
DMADescriptor g_RxSecond = { &g_RxFirst, (g_psPPIRxBuffer + kADCChannels * kSamplesCount * 2) };
volatile int g_iCompleteRecieve = 0;
volatile int g_iPingPongFlag = 0;

//interrupts
EX_INTERRUPT_HANDLER(PPI_RX_Isr)
{		
	g_iPingPongFlag = (g_iPingPongFlag + 1) & 1;
	g_iCompleteRecieve = 1;
	// confirm interrupt handling ( NO Error Handling is implemented!)
	*pDMA0_CONFIG &= ~FLOW;
	*pDMA0_IRQ_STATUS |= 0x0001;	// Write 1 to clear
	*pFIO_FLAG_T = PF0;
	ssync();
}

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
	*pUART_IER = (ELSI | ERBFI);
    *pUART_GCTL = UCEN;		// Enable UART clock
    ssync();
}

inline
void
initPPI(
	void
)
{
	*pPPI_CONTROL = 0x3800 | FLD_SEL | PORT_CFG | XFR_TYPE;
	*pPPI_DELAY   = 0x0000;
	*pPPI_COUNT   = kADCChannels * kSamplesCount;
	*pPPI_FRAME   = kADCChannels * kSamplesCount;
	// configure PPI DMA ( channel 0)
	// disable DMA transfer and enable large descriptor mode 1d mode (word size = 16bit)
	*pDMA0_CONFIG = FLOW | 0x0400 | DI_EN | WDSIZE_16 | WNR;
	*pDMA0_NEXT_DESC_PTR = (&g_RxFirst);
	*pDMA0_X_MODIFY = kADCChannels * 2;
	*pDMA0_X_COUNT = kSamplesCount;
	// enable DMA (PPI not enabled yet)
	*pDMA0_CONFIG = *pDMA0_CONFIG | DMAEN;
	ssync();
	// enable PPI
	*pPPI_CONTROL |= PORT_EN;
	ssync();
	// configure interrupts
	register_handler(ik_ivg8, PPI_RX_Isr);		// assign ISR to interrupt vector
	//*pSIC_IAR1 =  0x00000001;
	*pSIC_IMASK |= DMA0_IRQ;					// enable PPI (DMA0) interrupt
}

void
main(
)
{
	int interruptLatch, i;
	char key[] = { 0xFA, 0xCE, 0xCA, 0xFE }; 

	sysreg_write(reg_SYSCFG, 0x32);		//Initialize System Configuration Register

	*pFIO_DIR = PF0 | PF1;	//other as inputs
	*pFIO_FLAG_S = PF0;
	ssync();
	
	initPLL();
	initSDRAM();
	Init_Timers();
	Init_Timer_Interrupts();
	initUART();
	initPPI();
	
	while (1) {
		//asm("cli %0;" : "=d" (interruptLatch)); asm("ssync;");
		if (g_iCompleteRecieve) {
			g_iCompleteRecieve = 0;
			sendBuf(key, 4);
			sendBuf((char *)g_psPPIRxBuffer, kSamplesCount * kADCChannels * 2);
			sendBuf(key, 4);
			//while(1);
		}
		//asm("sti %0;" : : "d" (interruptLatch)); asm("ssync;");
	}
}
