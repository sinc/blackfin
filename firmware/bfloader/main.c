/*++

Copyright (c) 2012 RPHIS

Module Name:

    main.c 

Abstract:

    Firmware for Blackfin loader

Environment:

    kernel mode

Notes:
	SPI memory driver
    Chip type           : ATmega16
    Program type        : Application
    Clock frequency     : 12,000000 MHz
    Memory model        : Small
    External SRAM size  : 0
    Data Stack size     : 256
	
Revision History:

    09/11/12: created

--*/

#include <mega16.h>
#include <stdio.h>
#include <delay.h>

#define CY  SREG.0
#define SCK PORTC.1
#define SI  PINC.3
#define SO  PORTC.2
#define CS  PORTC.0

#define PRGE    PIND.3
#define PRGSET  PORTD.5
#define RESET   PORTC.5
#define LNE     PORTC.4

#define SPI_TX(cnt, count, data)				\
	do { for (cnt = 0; cnt < (count); ++cnt) { 	\
	    (data) <<= 1;							\
	    SO = CY;								\
	    SCK = 1;								\
	    #asm("nop");							\
		SCK = 0; }								\
	} while(0)

#define RXB8    1
#define TXB8    0
#define UPE     2
#define OVR     3
#define FE      4
#define UDRE    5
#define RXC     7

#define FRAMING_ERROR		(1 << FE)
#define PARITY_ERROR		(1 << UPE)
#define DATA_OVERRUN		(1 << OVR)
#define DATA_REGISTER_EMPTY	(1<< UDRE)
#define RX_COMPLETE			(1 << RXC)

#define RX_BUFFER_LEN 128

//enums
typedef enum {
    LC_ERASE			= 0x10,
    LC_LOAD				= 0x11,
	LC_RESET_CHIP		= 0x12,
	LC_BLANK_CHECKING	= 0x13,
	LC_READ				= 0x14
} loaderCommands;

//globals
unsigned char g_pbRxBuffer[RX_BUFFER_LEN];
unsigned char g_bRxBuffWritePosition = 0; 
unsigned char g_bRxBuffReadPosition = 0;
unsigned int g_uRxCount = 0;

interrupt [USART_RXC]
void
usart_rx_isr(
    void
)
/*++
   USART Receiver interrupt service routine
--*/
{
    char status, data;
    status = UCSRA;
    data = UDR;
    if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN)) == 0) {    
        g_pbRxBuffer[g_bRxBuffWritePosition] = data;
        ++g_uRxCount;
        if (++g_bRxBuffWritePosition == RX_BUFFER_LEN) {
            g_bRxBuffWritePosition = 0;
        }
    };
}

void
flushRxBuffer(
)
{
    #asm("cli");
    g_uRxCount = 0;
    g_bRxBuffWritePosition = 0;
	g_bRxBuffReadPosition = 0;
    #asm("sei");   
}

char
receiveByte(
)
{
    char result;
    while (g_uRxCount <= g_bRxBuffReadPosition);
    result = g_pbRxBuffer[g_bRxBuffReadPosition];
    if (++g_bRxBuffReadPosition == RX_BUFFER_LEN) {
        g_bRxBuffReadPosition = 0;
        g_uRxCount -= RX_BUFFER_LEN;
    }
    return result;
}
 
inline
void
init(
)
{
    PORTA=0x00;
    DDRA=0x00; 
    PORTB=0x00;
    DDRB=0x00;
    
    PORTC=0x00;
    DDRC=0x37;  //3B

    PORTD=0x00;
    DDRD=0x70;

    TCCR0=0x00;
    TCNT0=0x00;
    OCR0=0x00;
   
    TCCR1A=0x00;
    TCCR1B=0x00;
    TCNT1H=0x00;
    TCNT1L=0x00;
    ICR1H=0x00;
    ICR1L=0x00;
    OCR1AH=0x00;
    OCR1AL=0x00;
    OCR1BH=0x00;
    OCR1BL=0x00;

    ASSR=0x00;
    TCCR2=0x00;
    TCNT2=0x00;
    OCR2=0x00;

    MCUCR=0x00;
    MCUCSR=0x00;
   
    TIMSK=0x00;

    // USART initialization
    // Communication Parameters: 8 Data, 1 Stop, No Parity
    // USART Receiver: On
    // USART Transmitter: On
    // USART Mode: Asynchronous
    // USART Baud rate: 19200
    UCSRA=0x00;
    UCSRB=0x98;
    UCSRC=0x86;
    UBRRH=0x00;
    UBRRL=0x26;

    ACSR=0x80;
    SFIOR=0x00;
    
    SCK = 0;
    PRGSET = 1;
    LNE = 1;
	RESET = 0;
}

inline
void
spiWriteEnable(
)
{
    char i, command = 6;   //write enable
	CS = 0;
	SPI_TX(i, 8, command);
	CS = 1;
}

inline
void
spiWrite8(
	long address,
	char data
)
{
	char i, command = 2;
	CS = 0;
	address <<= 8;
	SPI_TX(i, 8, command);
	SPI_TX(i, 24, address);
	SPI_TX(i, 8, data);
	CS = 1;
	delay_us(100);
}

inline
void
spiWriteBlock(
	long address,
	char *pBlock,
	char blockSize
)
{
	char i, b, command = 2, dt;
	CS = 0;
	address <<= 8;
	SPI_TX(i, 8, command);
	SPI_TX(i, 24, address);
	for (b = 0; b < blockSize; ++b) {
		dt = *(pBlock + b);
		SPI_TX(i, 8, dt);
	}
	CS = 1;
	delay_us(100);
}

inline
char
spiRead8(
	long address
)
{
	char i, command = 3, result = 0;
	CS = 0;
	address <<= 8;
	SPI_TX(i, 8, command);
	SPI_TX(i, 24, address);
	for (i = 0; i < 8; ++i) {
		SCK = 1;
		result <<= 1;
		if (SI)
			++result;
		SCK = 0;
	}
	CS = 1;
	return result;
}

inline
char
spiReadStatus(
)
{
    char i, res = 5;
	CS = 0;
	SPI_TX(i, 8, res);
	for (i = 0; i < 8; ++i) {
		SCK = 1;
		res <<= 1;
		if (SI)
			++res;
		SCK = 0;
	}
	CS = 1;
    return res;
}

inline
void
spiChipErase(
)
{
    char i, command = 0x62;
	CS = 0;
	SPI_TX(i, 8, command);
	CS = 1;
	delay_ms(5000);
}

inline
char
spiBlankChecking(
)
{
	long addr = 0;
	for (; addr < 65536 && spiRead8(addr) == 0xFF; ++addr) ;
	return addr == 65536;
}

inline
void
resetBlackfin(
)
{
	LNE = 0;		//load enable  
	DDRC = 0x30;	//disable program spi
	UCSRB=0x00;		//disable uart
	RESET = 0;		//reset
    delay_ms(1000);	//delay
    RESET = 1;		//starting Blackfin
}

void
main(
)
{
    char cmd, blockSize, exit = 0;
    long addr;

    init();
	#asm("sei")
    if (PRGE) {
#ifdef __DEBUG__
        printf("Program enable\r\n");
#endif  /*__DEBUG__*/
		do {
			cmd = receiveByte();
			switch(cmd) {
				case LC_ERASE:
				    spiWriteEnable();
					spiChipErase();
					putchar(0x55);	//ack
					break;
				case LC_LOAD:
					blockSize = receiveByte();
					addr = receiveByte();				//low address byte
					addr |= ((long)receiveByte()) << 8;	//high address byte
					flushRxBuffer();
					putchar(0x55);	//ack
					while (g_uRxCount < blockSize) ;
					spiWriteEnable();
					spiWriteBlock(addr, g_pbRxBuffer, blockSize);
					flushRxBuffer();
					putchar(0x55);	//ack
					break;
				case LC_RESET_CHIP:
					putchar(0x55);	//ack
					exit = 1;
					break;
				case LC_BLANK_CHECKING:
					putchar(spiBlankChecking()? 0x55: 0xff);
					break;
				case LC_READ:
					addr = receiveByte();				//low address byte
					addr |= ((long)receiveByte()) << 8;	//high address byte
					putchar(0x55);	//ack
					putchar(spiRead8(addr));
					break;
				default:
					flushRxBuffer();
					putchar(0xfe);	//error
					putchar(cmd);
					break;
			}
		} while (!exit);
    }
    else {
#ifdef __DEBUG__
        printf("Program disable\r\n");
#endif  /*__DEBUG__*/
        
    }
	#asm("cli");
    //idle mode
	resetBlackfin();
    //TODO: sleep mode after running blackfin
    while (1) {
    }
}
