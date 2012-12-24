/*****************************************************************************
**																			**
**	 Name: 	Timer_ISR.c													**	
**																			**
******************************************************************************

(C) Copyright 2006 - Analog Devices, Inc.  All rights reserved.

This software is proprietary and confidential.  By using this software you agree
to the terms of the associated Analog Devices License Agreement.  

Purpose:	Perform a POST timer interrupt test on the BF533 EZ-Kit Lite	

                                                                               

******************************************************************************/   
#include <ccblkfn.h>
#include "Timer_ISR.h"

#define MAX_NUM_COUNTDOWN_TIMERS 5

EX_INTERRUPT_HANDLER(Timer0_ISR);
//--------------------------------------------------------------------------//
// Variables																//
//--------------------------------------------------------------------------//
static volatile unsigned long g_ulTickCount;


typedef struct CountDownTimer_TAG
{
	bool m_IsActive;
	unsigned long m_ulTimeoutCounter;
}countdowntimer;

static countdowntimer sCountDownTimer[MAX_NUM_COUNTDOWN_TIMERS] = { {0,0},{0,0},{0,0},{0,0},{0,0} };

//--------------------------------------------------------------------------//
// Function:	Init_Timers													//
//																			//
// Parameters:	None														//
//																			//
// Return:		None														//
//																			//
// Description:	This function initialises Timer0 for PWM mode.				//
//
//              When clocked internally, the clock source is the
//				processor’s peripheral clock (SCLK). Assuming the
//              peripheral clock is running at 133 MHz, the maximum period
//              for the timer count is ((2^32-1) / 133 MHz) = 32.2 seconds.
//
//--------------------------------------------------------------------------//
void Init_Timers(void)
{
	*pTIMER0_CONFIG		= 0x0019;
	*pTIMER0_PERIOD		= TIMEOUT_PERIOD;
	*pTIMER0_WIDTH		= TIMEOUT_PERIOD/2;	// width = period/2 = 50% duty cycle
	*pTIMER_ENABLE		= 0x0001;
}

//--------------------------------------------------------------------------//
// Function:	Init_Timer_Interrupts												//
//																			//
// Parameters:	None														//
//																			//
// Return:		None														//
//																			//
// Description:	This function initialises the interrupts for Timer0
//--------------------------------------------------------------------------//
void Init_Timer_Interrupts(void)
{
	// assign core IDs to interrupts
	//*pSIC_IAR0 = 0xffffffff;
	//*pSIC_IAR1 = 0xffffffff;
	//*pSIC_IAR2 = 0xfffffff4;					// Timer0 -> ID4;

	// assign ISRs to interrupt vectors
	register_handler(ik_ivg11, Timer0_ISR);		// Timer0 ISR -> IVG 11

	// enable Timer0 interrupt
	*pSIC_IMASK |= IRQ_TIMER0;
}



//--------------------------------------------------------------------------//
// Function:	SetTimeout												//
//																			//
// Parameters:	ulTicks - number of ticks to count down														//
//																			//
// Return:		The index of the timer structure being used or
//				-1 if none are available.
//
// Description:	Set a value for a global timeout, return the timer
//
//--------------------------------------------------------------------------//
unsigned int SetTimeout(const unsigned long ulTicks)
{
	unsigned int uiTIMASK = cli();
	unsigned int n;

	// we don't care which countdown timer is used, so search for a free
	// timer structure
	for( n = 0;  n < MAX_NUM_COUNTDOWN_TIMERS; n++ )
	{
		if( false == sCountDownTimer[n].m_IsActive )
		{
			sCountDownTimer[n].m_IsActive = true;
			sCountDownTimer[n].m_ulTimeoutCounter = ulTicks;


			sti(uiTIMASK);
			return n;
		}
	}

	sti(uiTIMASK);
	return ((unsigned int)-1);
}

//--------------------------------------------------------------------------//
// Function:	ClearTimeout												//
//																			//
// Parameters:	the index of the countdown structure														//
//																			//
// Return:		the number of ticks left to count down
//
// Description:	Set a value for a global timeout, return the timer
//
//--------------------------------------------------------------------------//
unsigned long ClearTimeout(const unsigned int nIndex)
{
	unsigned int uiTIMASK = cli();
	unsigned long ulTemp = (unsigned int)(-1);

	if( nIndex < MAX_NUM_COUNTDOWN_TIMERS )
	{
		// turn off the timer
		ulTemp = sCountDownTimer[nIndex].m_ulTimeoutCounter;
		sCountDownTimer[nIndex].m_ulTimeoutCounter = 0;
		sCountDownTimer[nIndex].m_IsActive = false;
	}

	sti(uiTIMASK);
	return (ulTemp);
}

//--------------------------------------------------------------------------//
// Function:	IsTimedout												//
//																			//
// Parameters:	the index of the timer to check														//
//																			//
// Return:		1 if timeout value expired, 0 if timeout NOT expired		//
//																			//
// Description:	Checks to see if the timeout value has expired
//				                                                            //
//--------------------------------------------------------------------------//
bool IsTimedout(const unsigned int nIndex)
{
	unsigned int uiTIMASK = cli();
	if( nIndex < MAX_NUM_COUNTDOWN_TIMERS )
	{
		sti(uiTIMASK);
		return ( 0 == sCountDownTimer[nIndex].m_ulTimeoutCounter );
	}

	sti(uiTIMASK);
	return 0;// an invalid index should cause a hang wherever a timer is being used
}


//--------------------------------------------------------------------------//
// Function:	Timer0_ISR													//
//																			//
// Parameters:	None														//
//																			//
// Return:		None														//
//																			//
// Description:	This ISR is executed every time Timer0 expires.				//
//																			//
//--------------------------------------------------------------------------//
EX_INTERRUPT_HANDLER(Timer0_ISR)
{
	unsigned int n;
	// confirm interrupt handling
	*pTIMER_STATUS = 0x0001;
	ssync();

	g_ulTickCount++;

	// decrement each counter if it is non-zero
	for( n = 0;  n < MAX_NUM_COUNTDOWN_TIMERS; n++ )
	{
		if( 0 != sCountDownTimer[n].m_ulTimeoutCounter )
		{
			sCountDownTimer[n].m_ulTimeoutCounter--;
		}
	}
}