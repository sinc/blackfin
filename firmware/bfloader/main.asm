;CodeVisionAVR C Compiler V1.24.4 Standard
;(C) Copyright 1998-2004 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com
;e-mail:office@hpinfotech.com

;Chip type           : ATmega16
;Program type        : Application
;Clock frequency     : 12,000000 MHz
;Memory model        : Small
;Optimize for        : Size
;(s)printf features  : int, width
;(s)scanf features   : int, width
;External SRAM size  : 0
;Data Stack size     : 256 byte(s)
;Heap size           : 0 byte(s)
;Promote char to int : No
;char is unsigned    : Yes
;8 bit enums         : Yes
;Enhanced core instructions    : On
;Automatic register allocation : On

	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU GICR=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __se_bit=0x40
	.EQU __sm_mask=0xB0
	.EQU __sm_adc_noise_red=0x10
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0xA0
	.EQU __sm_ext_standby=0xB0

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __CLRD1S
	LDI  R30,0
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+@1)
	LDI  R31,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+@2)
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+@3)
	LDI  R@1,HIGH(@2+@3)
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+@1
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	LDS  R22,@0+@1+2
	LDS  R23,@0+@1+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@2,@0+@1
	.ENDM

	.MACRO __GETWRMN
	LDS  R@2,@0+@1
	LDS  R@3,@0+@1+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+@1
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	LDS  R24,@0+@1+2
	LDS  R25,@0+@1+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+@1,R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	STS  @0+@1+2,R22
	STS  @0+@1+3,R23
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+@1,R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+@1,R@2
	STS  @0+@1+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	ICALL
	.ENDM


	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	CALL __GETW1PF
	ICALL
	.ENDM


	.MACRO __CALL2EN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	CALL __EEPROMRDW
	ICALL
	.ENDM


	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CLR  R0
	ST   Z+,R0
	ST   Z,R0
	.ENDM

	.MACRO __CLRD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CLR  R0
	ST   Z+,R0
	ST   Z+,R0
	ST   Z+,R0
	ST   Z,R0
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R@1
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOV  R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOV  R30,R0
	.ENDM

	.CSEG
	.ORG 0

	.INCLUDE "main.vec"
	.INCLUDE "main.inc"

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  GICR,R31
	OUT  GICR,R30
	OUT  MCUCR,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,13
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(0x400)
	LDI  R25,HIGH(0x400)
	LDI  R26,0x60
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;STACK POINTER INITIALIZATION
	LDI  R30,LOW(0x45F)
	OUT  SPL,R30
	LDI  R30,HIGH(0x45F)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(0x160)
	LDI  R29,HIGH(0x160)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x160
;       1 /*++
;       2 
;       3 Copyright (c) 2012 RPHIS
;       4 
;       5 Module Name:
;       6 
;       7     main.c 
;       8 
;       9 Abstract:
;      10 
;      11     Firmware for Blackfin loader
;      12 
;      13 Environment:
;      14 
;      15     kernel mode
;      16 
;      17 Notes:
;      18 	SPI memory driver
;      19     Chip type           : ATmega16
;      20     Program type        : Application
;      21     Clock frequency     : 12,000000 MHz
;      22     Memory model        : Small
;      23     External SRAM size  : 0
;      24     Data Stack size     : 256
;      25 	
;      26 Revision History:
;      27 
;      28     09/11/12: created
;      29 
;      30 --*/
;      31 
;      32 #include <mega16.h>
;      33 #include <stdio.h>
;      34 #include <delay.h>
;      35 
;      36 #define CY  SREG.0
;      37 #define SCK PORTC.1
;      38 #define SI  PINC.3
;      39 #define SO  PORTC.2
;      40 #define CS  PORTC.0
;      41 
;      42 #define PRGE    PIND.3
;      43 #define PRGSET  PORTD.5
;      44 #define RESET   PORTC.5
;      45 #define LNE     PORTC.4
;      46 
;      47 #define SPI_TX(cnt, count, data)				\
;      48 	do { for (cnt = 0; cnt < (count); ++cnt) { 	\
;      49 	    (data) <<= 1;							\
;      50 	    SO = CY;								\
;      51 	    SCK = 1;								\
;      52 	    #asm("nop");							\
;      53 		SCK = 0; }								\
;      54 	} while(0)
;      55 
;      56 #define RXB8    1
;      57 #define TXB8    0
;      58 #define UPE     2
;      59 #define OVR     3
;      60 #define FE      4
;      61 #define UDRE    5
;      62 #define RXC     7
;      63 
;      64 #define FRAMING_ERROR		(1 << FE)
;      65 #define PARITY_ERROR		(1 << UPE)
;      66 #define DATA_OVERRUN		(1 << OVR)
;      67 #define DATA_REGISTER_EMPTY	(1<< UDRE)
;      68 #define RX_COMPLETE			(1 << RXC)
;      69 
;      70 #define RX_BUFFER_LEN 128
;      71 
;      72 //enums
;      73 typedef enum {
;      74     LC_ERASE			= 0x10,
;      75     LC_LOAD				= 0x11,
;      76 	LC_RESET_CHIP		= 0x12,
;      77 	LC_BLANK_CHECKING	= 0x13,
;      78 	LC_READ				= 0x14
;      79 } loaderCommands;
;      80 
;      81 //globals
;      82 unsigned char g_pbRxBuffer[RX_BUFFER_LEN];
_g_pbRxBuffer:
	.BYTE 0x80
;      83 unsigned char g_bRxBuffWritePosition = 0; 
;      84 unsigned char g_bRxBuffReadPosition = 0;
;      85 unsigned int g_uRxCount = 0;
;      86 
;      87 interrupt [USART_RXC]
;      88 void
;      89 usart_rx_isr(
;      90     void
;      91 )
;      92 /*++
;      93    USART Receiver interrupt service routine
;      94 --*/
;      95 {

	.CSEG
_usart_rx_isr:
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
;      96     char status, data;
;      97     status = UCSRA;
	ST   -Y,R17
	ST   -Y,R16
;	status -> R16
;	data -> R17
	IN   R16,11
;      98     data = UDR;
	IN   R17,12
;      99     if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN)) == 0) {    
	MOV  R30,R16
	ANDI R30,LOW(0x1C)
	BRNE _0x3
;     100         g_pbRxBuffer[g_bRxBuffWritePosition] = data;
	MOV  R26,R4
	LDI  R27,0
	SUBI R26,LOW(-_g_pbRxBuffer)
	SBCI R27,HIGH(-_g_pbRxBuffer)
	ST   X,R17
;     101         ++g_uRxCount;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	__ADDWRR 6,7,30,31
;     102         if (++g_bRxBuffWritePosition == RX_BUFFER_LEN) {
	INC  R4
	LDI  R30,LOW(128)
	CP   R30,R4
	BRNE _0x4
;     103             g_bRxBuffWritePosition = 0;
	CLR  R4
;     104         }
;     105     };
_0x4:
_0x3:
;     106 }
	LD   R16,Y+
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
;     107 
;     108 void
;     109 flushRxBuffer(
;     110 )
;     111 {
_flushRxBuffer:
;     112     #asm("cli");
	cli
;     113     g_uRxCount = 0;
	CLR  R6
	CLR  R7
;     114     g_bRxBuffWritePosition = 0;
	CLR  R4
;     115 	g_bRxBuffReadPosition = 0;
	CLR  R5
;     116     #asm("sei");   
	sei
;     117 }
	RET
;     118 
;     119 char
;     120 receiveByte(
;     121 )
;     122 {
_receiveByte:
;     123     char result;
;     124     while (g_uRxCount <= g_bRxBuffReadPosition);
	ST   -Y,R16
;	result -> R16
_0x5:
	MOV  R30,R5
	__GETW2R 6,7
	LDI  R31,0
	CP   R30,R26
	CPC  R31,R27
	BRSH _0x5
;     125     result = g_pbRxBuffer[g_bRxBuffReadPosition];
	MOV  R30,R5
	LDI  R31,0
	SUBI R30,LOW(-_g_pbRxBuffer)
	SBCI R31,HIGH(-_g_pbRxBuffer)
	LD   R16,Z
;     126     if (++g_bRxBuffReadPosition == RX_BUFFER_LEN) {
	INC  R5
	LDI  R30,LOW(128)
	CP   R30,R5
	BRNE _0x8
;     127         g_bRxBuffReadPosition = 0;
	CLR  R5
;     128         g_uRxCount -= RX_BUFFER_LEN;
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	__SUBWRR 6,7,30,31
;     129     }
;     130     return result;
_0x8:
	MOV  R30,R16
	LD   R16,Y+
	RET
;     131 }
;     132  
;     133 inline
;     134 void
;     135 init(
;     136 )
;     137 {
_init:
;     138     PORTA=0x00;
	LDI  R30,LOW(0)
	OUT  0x1B,R30
;     139     DDRA=0x00; 
	OUT  0x1A,R30
;     140     PORTB=0x00;
	OUT  0x18,R30
;     141     DDRB=0x00;
	OUT  0x17,R30
;     142     
;     143     PORTC=0x00;
	OUT  0x15,R30
;     144     DDRC=0x37;  //3B
	LDI  R30,LOW(55)
	OUT  0x14,R30
;     145 
;     146     PORTD=0x00;
	LDI  R30,LOW(0)
	OUT  0x12,R30
;     147     DDRD=0x70;
	LDI  R30,LOW(112)
	OUT  0x11,R30
;     148 
;     149     TCCR0=0x00;
	LDI  R30,LOW(0)
	OUT  0x33,R30
;     150     TCNT0=0x00;
	OUT  0x32,R30
;     151     OCR0=0x00;
	OUT  0x3C,R30
;     152    
;     153     TCCR1A=0x00;
	OUT  0x2F,R30
;     154     TCCR1B=0x00;
	OUT  0x2E,R30
;     155     TCNT1H=0x00;
	OUT  0x2D,R30
;     156     TCNT1L=0x00;
	OUT  0x2C,R30
;     157     ICR1H=0x00;
	OUT  0x27,R30
;     158     ICR1L=0x00;
	OUT  0x26,R30
;     159     OCR1AH=0x00;
	OUT  0x2B,R30
;     160     OCR1AL=0x00;
	OUT  0x2A,R30
;     161     OCR1BH=0x00;
	OUT  0x29,R30
;     162     OCR1BL=0x00;
	OUT  0x28,R30
;     163 
;     164     ASSR=0x00;
	OUT  0x22,R30
;     165     TCCR2=0x00;
	OUT  0x25,R30
;     166     TCNT2=0x00;
	OUT  0x24,R30
;     167     OCR2=0x00;
	OUT  0x23,R30
;     168 
;     169     MCUCR=0x00;
	OUT  0x35,R30
;     170     MCUCSR=0x00;
	OUT  0x34,R30
;     171    
;     172     TIMSK=0x00;
	OUT  0x39,R30
;     173 
;     174     // USART initialization
;     175     // Communication Parameters: 8 Data, 1 Stop, No Parity
;     176     // USART Receiver: On
;     177     // USART Transmitter: On
;     178     // USART Mode: Asynchronous
;     179     // USART Baud rate: 19200
;     180     UCSRA=0x00;
	OUT  0xB,R30
;     181     UCSRB=0x98;
	LDI  R30,LOW(152)
	OUT  0xA,R30
;     182     UCSRC=0x86;
	LDI  R30,LOW(134)
	OUT  0x20,R30
;     183     UBRRH=0x00;
	LDI  R30,LOW(0)
	OUT  0x20,R30
;     184     UBRRL=0x26;
	LDI  R30,LOW(38)
	OUT  0x9,R30
;     185 
;     186     ACSR=0x80;
	LDI  R30,LOW(128)
	OUT  0x8,R30
;     187     SFIOR=0x00;
	LDI  R30,LOW(0)
	OUT  0x30,R30
;     188     
;     189     SCK = 0;
	CBI  0x15,1
;     190     PRGSET = 1;
	SBI  0x12,5
;     191     LNE = 1;
	SBI  0x15,4
;     192 	RESET = 0;
	CBI  0x15,5
;     193 }
	RET
;     194 
;     195 inline
;     196 void
;     197 spiWriteEnable(
;     198 )
;     199 {
_spiWriteEnable:
;     200     char i, command = 6;   //write enable
;     201 	CS = 0;
	ST   -Y,R17
	ST   -Y,R16
;	i -> R16
;	command -> R17
	LDI  R17,6
	CBI  0x15,0
;     202 	SPI_TX(i, 8, command);
	LDI  R16,LOW(0)
_0xD:
	CPI  R16,8
	BRSH _0xE
	CALL SUBOPT_0x0
	SBI  0x15,1
	nop
	CBI  0x15,1
	SUBI R16,-LOW(1)
	RJMP _0xD
_0xE:
;     203 	CS = 1;
	SBI  0x15,0
;     204 }
	LD   R16,Y+
	LD   R17,Y+
	RET
;     205 
;     206 inline
;     207 void
;     208 spiWrite8(
;     209 	long address,
;     210 	char data
;     211 )
;     212 {
;     213 	char i, command = 2;
;     214 	CS = 0;
;	address -> Y+3
;	data -> Y+2
;	i -> R16
;	command -> R17
;     215 	address <<= 8;
;     216 	SPI_TX(i, 8, command);
;     217 	SPI_TX(i, 24, address);
;     218 	SPI_TX(i, 8, data);
;     219 	CS = 1;
;     220 	delay_us(100);
;     221 }
;     222 
;     223 inline
;     224 void
;     225 spiWriteBlock(
;     226 	long address,
;     227 	char *pBlock,
;     228 	char blockSize
;     229 )
;     230 {
_spiWriteBlock:
;     231 	char i, b, command = 2, dt;
;     232 	CS = 0;
	CALL __SAVELOCR4
;	address -> Y+7
;	*pBlock -> Y+5
;	blockSize -> Y+4
;	i -> R16
;	b -> R17
;	command -> R18
;	dt -> R19
	LDI  R18,2
	CBI  0x15,0
;     233 	address <<= 8;
	__GETD2S 7
	LDI  R30,LOW(8)
	CALL __LSLD12
	__PUTD1S 7
;     234 	SPI_TX(i, 8, command);
	LDI  R16,LOW(0)
_0x25:
	CPI  R16,8
	BRSH _0x26
	LSL  R18
	CALL SUBOPT_0x1
	SBI  0x15,1
	nop
	CBI  0x15,1
	SUBI R16,-LOW(1)
	RJMP _0x25
_0x26:
;     235 	SPI_TX(i, 24, address);
	LDI  R16,LOW(0)
_0x2B:
	CPI  R16,24
	BRSH _0x2C
	__GETD1S 7
	CALL __LSLD1
	__PUTD1S 7
	CALL SUBOPT_0x1
	SBI  0x15,1
	nop
	CBI  0x15,1
	SUBI R16,-LOW(1)
	RJMP _0x2B
_0x2C:
;     236 	for (b = 0; b < blockSize; ++b) {
	LDI  R17,LOW(0)
_0x2E:
	LDD  R30,Y+4
	CP   R17,R30
	BRSH _0x2F
;     237 		dt = *(pBlock + b);
	MOV  R30,R17
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	LDI  R31,0
	ADD  R26,R30
	ADC  R27,R31
	LD   R19,X
;     238 		SPI_TX(i, 8, dt);
	LDI  R16,LOW(0)
_0x34:
	CPI  R16,8
	BRSH _0x35
	LSL  R19
	CALL SUBOPT_0x1
	SBI  0x15,1
	nop
	CBI  0x15,1
	SUBI R16,-LOW(1)
	RJMP _0x34
_0x35:
;     239 	}
	SUBI R17,-LOW(1)
	RJMP _0x2E
_0x2F:
;     240 	CS = 1;
	SBI  0x15,0
;     241 	delay_us(100);
	__DELAY_USW 300
;     242 }
	CALL __LOADLOCR4
	ADIW R28,11
	RET
;     243 
;     244 inline
;     245 char
;     246 spiRead8(
;     247 	long address
;     248 )
;     249 {
_spiRead8:
;     250 	char i, command = 3, result = 0;
;     251 	CS = 0;
	CALL __SAVELOCR3
;	address -> Y+3
;	i -> R16
;	command -> R17
;	result -> R18
	LDI  R17,3
	LDI  R18,0
	CBI  0x15,0
;     252 	address <<= 8;
	__GETD2S 3
	LDI  R30,LOW(8)
	CALL __LSLD12
	__PUTD1S 3
;     253 	SPI_TX(i, 8, command);
	LDI  R16,LOW(0)
_0x3A:
	CPI  R16,8
	BRSH _0x3B
	CALL SUBOPT_0x0
	SBI  0x15,1
	nop
	CBI  0x15,1
	SUBI R16,-LOW(1)
	RJMP _0x3A
_0x3B:
;     254 	SPI_TX(i, 24, address);
	LDI  R16,LOW(0)
_0x40:
	CPI  R16,24
	BRSH _0x41
	__GETD1S 3
	CALL __LSLD1
	__PUTD1S 3
	CALL SUBOPT_0x1
	SBI  0x15,1
	nop
	CBI  0x15,1
	SUBI R16,-LOW(1)
	RJMP _0x40
_0x41:
;     255 	for (i = 0; i < 8; ++i) {
	LDI  R16,LOW(0)
_0x43:
	CPI  R16,8
	BRSH _0x44
;     256 		SCK = 1;
	SBI  0x15,1
;     257 		result <<= 1;
	LSL  R18
;     258 		if (SI)
	SBIC 0x13,3
;     259 			++result;
	SUBI R18,-LOW(1)
;     260 		SCK = 0;
	CBI  0x15,1
;     261 	}
	SUBI R16,-LOW(1)
	RJMP _0x43
_0x44:
;     262 	CS = 1;
	SBI  0x15,0
;     263 	return result;
	MOV  R30,R18
	CALL __LOADLOCR3
	ADIW R28,7
	RET
;     264 }
;     265 
;     266 inline
;     267 char
;     268 spiReadStatus(
;     269 )
;     270 {
;     271     char i, res = 5;
;     272 	CS = 0;
;	i -> R16
;	res -> R17
;     273 	SPI_TX(i, 8, res);
;     274 	for (i = 0; i < 8; ++i) {
;     275 		SCK = 1;
;     276 		res <<= 1;
;     277 		if (SI)
;     278 			++res;
;     279 		SCK = 0;
;     280 	}
;     281 	CS = 1;
;     282     return res;
;     283 }
;     284 
;     285 inline
;     286 void
;     287 spiChipErase(
;     288 )
;     289 {
_spiChipErase:
;     290     char i, command = 0x62;
;     291 	CS = 0;
	ST   -Y,R17
	ST   -Y,R16
;	i -> R16
;	command -> R17
	LDI  R17,98
	CBI  0x15,0
;     292 	SPI_TX(i, 8, command);
	LDI  R16,LOW(0)
_0x54:
	CPI  R16,8
	BRSH _0x55
	CALL SUBOPT_0x0
	SBI  0x15,1
	nop
	CBI  0x15,1
	SUBI R16,-LOW(1)
	RJMP _0x54
_0x55:
;     293 	CS = 1;
	SBI  0x15,0
;     294 	delay_ms(5000);
	LDI  R30,LOW(5000)
	LDI  R31,HIGH(5000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
;     295 }
	LD   R16,Y+
	LD   R17,Y+
	RET
;     296 
;     297 inline
;     298 char
;     299 spiBlankChecking(
;     300 )
;     301 {
_spiBlankChecking:
;     302 	long addr = 0;
;     303 	for (; addr < 65536 && spiRead8(addr) == 0xFF; ++addr) ;
	SBIW R28,4
	LDI  R24,4
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0x56*2)
	LDI  R31,HIGH(_0x56*2)
	CALL __INITLOCB
;	addr -> Y+0
_0x58:
	__GETD2S 0
	__CPD2N 0x10000
	BRGE _0x5A
	CALL SUBOPT_0x2
	CPI  R30,LOW(0xFF)
	BREQ _0x5B
_0x5A:
	RJMP _0x59
_0x5B:
	__GETD1S 0
	__SUBD1N -1
	__PUTD1S 0
	RJMP _0x58
_0x59:
;     304 	return addr == 65536;
	__GETD2S 0
	__GETD1N 0x10000
	CALL __EQD12
	ADIW R28,4
	RET
;     305 }
;     306 
;     307 inline
;     308 void
;     309 resetBlackfin(
;     310 )
;     311 {
_resetBlackfin:
;     312 	LNE = 0;		//load enable  
	CBI  0x15,4
;     313 	DDRC = 0x30;	//disable program spi
	LDI  R30,LOW(48)
	OUT  0x14,R30
;     314 	UCSRB=0x00;		//disable uart
	LDI  R30,LOW(0)
	OUT  0xA,R30
;     315 	RESET = 0;		//reset
	CBI  0x15,5
;     316     delay_ms(1000);	//delay
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
;     317     RESET = 1;		//starting Blackfin
	SBI  0x15,5
;     318 }
	RET
;     319 
;     320 void
;     321 main(
;     322 )
;     323 {
_main:
;     324     char cmd, blockSize, exit = 0;
;     325     long addr;
;     326 
;     327     init();
	SBIW R28,4
;	cmd -> R16
;	blockSize -> R17
;	exit -> R18
;	addr -> Y+0
	LDI  R18,0
	CALL _init
;     328 	#asm("sei")
	sei
;     329     if (PRGE) {
	SBIS 0x10,3
	RJMP _0x5C
;     330 #ifdef __DEBUG__
;     331         printf("Program enable\r\n");
;     332 #endif  /*__DEBUG__*/
;     333 		do {
_0x5E:
;     334 			cmd = receiveByte();
	CALL _receiveByte
	MOV  R16,R30
;     335 			switch(cmd) {
	MOV  R30,R16
;     336 				case LC_ERASE:
	CPI  R30,LOW(0x10)
	BRNE _0x63
;     337 				    spiWriteEnable();
	CALL _spiWriteEnable
;     338 					spiChipErase();
	CALL _spiChipErase
;     339 					putchar(0x55);	//ack
	CALL SUBOPT_0x3
;     340 					break;
	RJMP _0x62
;     341 				case LC_LOAD:
_0x63:
	CPI  R30,LOW(0x11)
	BRNE _0x64
;     342 					blockSize = receiveByte();
	CALL _receiveByte
	MOV  R17,R30
;     343 					addr = receiveByte();				//low address byte
	CALL SUBOPT_0x4
;     344 					addr |= ((long)receiveByte()) << 8;	//high address byte
;     345 					flushRxBuffer();
	CALL _flushRxBuffer
;     346 					putchar(0x55);	//ack
	CALL SUBOPT_0x3
;     347 					while (g_uRxCount < blockSize) ;
_0x65:
	MOV  R30,R17
	__GETW2R 6,7
	LDI  R31,0
	CP   R26,R30
	CPC  R27,R31
	BRLO _0x65
;     348 					spiWriteEnable();
	CALL _spiWriteEnable
;     349 					spiWriteBlock(addr, g_pbRxBuffer, blockSize);
	__GETD1S 0
	CALL __PUTPARD1
	LDI  R30,LOW(_g_pbRxBuffer)
	LDI  R31,HIGH(_g_pbRxBuffer)
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	CALL _spiWriteBlock
;     350 					flushRxBuffer();
	CALL _flushRxBuffer
;     351 					putchar(0x55);	//ack
	CALL SUBOPT_0x3
;     352 					break;
	RJMP _0x62
;     353 				case LC_RESET_CHIP:
_0x64:
	CPI  R30,LOW(0x12)
	BRNE _0x68
;     354 					putchar(0x55);	//ack
	CALL SUBOPT_0x3
;     355 					exit = 1;
	LDI  R18,LOW(1)
;     356 					break;
	RJMP _0x62
;     357 				case LC_BLANK_CHECKING:
_0x68:
	CPI  R30,LOW(0x13)
	BRNE _0x69
;     358 					putchar(spiBlankChecking()? 0x55: 0xff);
	CALL _spiBlankChecking
	CPI  R30,0
	BREQ _0x6A
	LDI  R30,LOW(85)
	RJMP _0x6B
_0x6A:
	LDI  R30,LOW(255)
_0x6B:
	ST   -Y,R30
	CALL _putchar
;     359 					break;
	RJMP _0x62
;     360 				case LC_READ:
_0x69:
	CPI  R30,LOW(0x14)
	BRNE _0x6E
;     361 					addr = receiveByte();				//low address byte
	CALL SUBOPT_0x4
;     362 					addr |= ((long)receiveByte()) << 8;	//high address byte
;     363 					putchar(0x55);	//ack
	CALL SUBOPT_0x3
;     364 					putchar(spiRead8(addr));
	CALL SUBOPT_0x2
	ST   -Y,R30
	CALL _putchar
;     365 					break;
	RJMP _0x62
;     366 				default:
_0x6E:
;     367 					flushRxBuffer();
	CALL _flushRxBuffer
;     368 					putchar(0xfe);	//error
	LDI  R30,LOW(254)
	ST   -Y,R30
	CALL _putchar
;     369 					putchar(cmd);
	ST   -Y,R16
	CALL _putchar
;     370 					break;
;     371 			}
_0x62:
;     372 		} while (!exit);
	CPI  R18,0
	BRNE _0x5F
	RJMP _0x5E
_0x5F:
;     373     }
;     374     else {
_0x5C:
;     375 #ifdef __DEBUG__
;     376         printf("Program disable\r\n");
;     377 #endif  /*__DEBUG__*/
;     378         
;     379     }
;     380 	#asm("cli");
	cli
;     381     //idle mode
;     382 	resetBlackfin();
	CALL _resetBlackfin
;     383     //TODO: sleep mode after running blackfin
;     384     while (1) {
_0x70:
;     385     }
	RJMP _0x70
;     386 }
	ADIW R28,4
_0x73:
	RJMP _0x73

_getchar:
     sbis usr,rxc
     rjmp _getchar
     in   r30,udr
	RET
_putchar:
     sbis usr,udre
     rjmp _putchar
     ld   r30,y
     out  udr,r30
	ADIW R28,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES
SUBOPT_0x0:
	LSL  R17
	LDI  R30,1
	BRBS 0x0,PC+2
	LDI  R30,0
	CALL __BSTB1
	IN   R26,0x15
	BLD  R26,2
	OUT  0x15,R26
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES
SUBOPT_0x1:
	LDI  R30,1
	BRBS 0x0,PC+2
	LDI  R30,0
	CALL __BSTB1
	IN   R26,0x15
	BLD  R26,2
	OUT  0x15,R26
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x2:
	__GETD1S 0
	CALL __PUTPARD1
	JMP  _spiRead8

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES
SUBOPT_0x3:
	LDI  R30,LOW(85)
	ST   -Y,R30
	JMP  _putchar

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES
SUBOPT_0x4:
	CALL _receiveByte
	CLR  R31
	CLR  R22
	CLR  R23
	__PUTD1S 0
	CALL _receiveByte
	CLR  R31
	CLR  R22
	CLR  R23
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(8)
	CALL __LSLD12
	__GETD2S 0
	CALL __ORD12
	__PUTD1S 0
	RET

_delay_ms:
	ld   r30,y+
	ld   r31,y+
	adiw r30,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0xBB8
	wdr
	sbiw r30,1
	brne __delay_ms0
__delay_ms1:
	ret

__ORD12:
	OR   R30,R26
	OR   R31,R27
	OR   R22,R24
	OR   R23,R25
	RET

__LSLD12:
	TST  R30
	MOV  R0,R30
	MOVW R30,R26
	MOVW R22,R24
	BREQ __LSLD12R
__LSLD12L:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	DEC  R0
	BRNE __LSLD12L
__LSLD12R:
	RET

__LSLD1:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	RET

__EQD12:
	CP   R30,R26
	CPC  R31,R27
	CPC  R22,R24
	CPC  R23,R25
	LDI  R30,1
	BREQ __EQD12T
	CLR  R30
__EQD12T:
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

__BSTB1:
	CLT
	CLR  R0
	CPSE R30,R0
	SET
	RET

__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

__INITLOCB:
__INITLOCW:
	ADD R26,R28
	ADC R27,R29
__INITLOC0:
	LPM  R0,Z+
	ST   X+,R0
	DEC  R24
	BRNE __INITLOC0
	RET

;END OF CODE MARKER
__END_OF_CODE:
