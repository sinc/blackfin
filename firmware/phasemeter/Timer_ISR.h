#ifndef _TIMER_ISR_H_
#define _TIMER_ISR_H_

//--------------------------------------------------------------------------//
// Header files																//
//--------------------------------------------------------------------------//
#include <sys\exception.h>
#include <cdefBF532.h>

//--------------------------------------------------------------------------//
// Symbolic constants														//
//--------------------------------------------------------------------------//
#define TIMEOUT_PERIOD	0x00000400
#define IRQ_TIMER0		0x00010000

//--------------------------------------------------------------------------//
// Global variables															//
//--------------------------------------------------------------------------//

//--------------------------------------------------------------------------//
// Prototypes																//
//--------------------------------------------------------------------------//
void Init_Timers(void);
void Init_Timer_Interrupts(void);
//void Delay(const unsigned long ulMs);
//unsigned long GetTickCount(void);
unsigned int SetTimeout(const unsigned long ulTicks);
unsigned long ClearTimeout(const unsigned int nIndex);
bool IsTimedout(const unsigned int nIndex);
#endif //_TIMER_ISR_H_

