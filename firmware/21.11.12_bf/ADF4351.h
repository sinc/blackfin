/*++

Copyright (c) 2012 RPHIS

Module Name:

    adf4351.h 

Abstract:

    Firmware for PLL

Environment:

    kernel mode

Notes:
	ADF4351 driver
	
Revision History:

    18/04/11: created

--*/
#ifndef __ADF4351_H__
#define __ADF4351_H__

//Registers
typedef union {
	 struct {
		unsigned int reserved: 1;
		unsigned int INT: 16;
		unsigned int FRAC: 12;
		unsigned int controlBits: 3;
	};
	unsigned long value;
} R0;

typedef union {
	struct {
		unsigned int reserved: 3;
		unsigned int phaseAdjust: 1;
		unsigned int prescaler: 1;
		unsigned int phase: 12;
		unsigned int modulusValue: 12;
		unsigned int controlBits: 3;
	};
	unsigned long value;
} R1;

typedef union {
	struct {
		unsigned int reserved: 1;
		unsigned int lowNoiseAndSpurMod: 2;
		unsigned int mixOut: 3;
		unsigned int refDoubler: 1;
		unsigned int refDiv2: 1;
		unsigned int RCounter: 10;
		unsigned int doubleBuffer: 1;
		unsigned int chargePumpCurrentSet: 4;
		unsigned int LDF: 1;
		unsigned int LDP: 1;
		unsigned int PDPolarity: 1;
		unsigned int powerDown: 1;
		unsigned int CPThreeState: 1;
		unsigned int counterReset: 1;
		unsigned int ControlBits: 3;
	};
	unsigned long value;
} R2;

typedef union {
	struct {
		unsigned int reserved: 8;
		unsigned int bandSelectClockMode: 1;
		unsigned int ABP: 1;
		unsigned int chargeCancel: 1;
		unsigned int reserved: 2;
		unsigned int CSR: 1;
		unsigned int reserved: 1;
		unsigned int clockDivMode: 2;
		unsigned int clockDividerValue: 12;
		unsigned int ControlBits: 3;
	};
	unsigned long value;
} R3;

typedef union {
	struct {
		unsigned int reserved: 8;
		unsigned int feedbackSelect: 1;
		unsigned int RFDividerSelect: 3;
		unsigned int bandSelectClockDivider: 8;
		unsigned int VCOPowerDown: 1;
		unsigned int MTLD: 1;
		unsigned int AUXOutputSelect: 1;
		unsigned int AUXOutputPower: 2;
		unsigned int RFOutputEnable: 1;
		unsigned int OutputPower: 2;
		unsigned int ControlBits: 3;
	};
	unsigned long value;
} R4;

typedef union {
	struct {
		unsigned int reserved: 8;
		unsigned int LDPinMode: 2;
		unsigned int reserved: 1;
		unsigned int reserved: 2;
		unsigned int reserved: 16;
		unsigned int ControlBits: 3;
	};
	unsigned long value;
} R5;

//macros

#ifdef __cplusplus
extern "C"
{
#endif /*__cplusplus*/

#ifdef __cplusplus
}
#endif /*__cplusplus*/
#endif /*__ADF4351_H__*/