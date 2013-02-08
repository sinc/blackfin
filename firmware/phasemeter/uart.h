/*++

Copyright (c) 2012 RPHIS

Module Name:

    uart.h 

Abstract:

    Firmware for UART

Environment:

    kernel mode

Notes:
	
Revision History:

    20/12/12: created

--*/
#ifndef __UART_H__
#define __UART_H__

#ifdef __cplusplus
extern "C" {
#endif	/*__cplusplus*/

int putChar(const char cVal);
int getChar(char *const cVal);
void sendCharBuf(char *buf);
int sendBuf(char *pbBuffer, int length);

#ifdef __cplusplus
}
#endif /*__cplusplus*/

#endif /*__UART_H__*/

