/*++

Copyright (c) 2012 RPHIS

Module Name:

    uart.c 

Abstract:

    Firmware for UART

Environment:

    kernel mode

Notes:
	
Revision History:

    20/12/12: created

--*/

//includes
#include <cdefBF532.h>
#include "uart.h"
#include "Timer_ISR.h"

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
sendCharBuf(
	char *buf
)
{
	while (*buf) {
		putChar(*buf);
		++buf;
	}
}

int
sendBuf(
	char *pbBuffer,
	int length
)
{
	while (length-- && putChar(*pbBuffer))
		++pbBuffer;
	return length == 0;
}