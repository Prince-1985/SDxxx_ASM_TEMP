;============================================================
;	Project:		SD028_ASM_TEMP
;	FILE:			SD028_ASM_TEMP.asm
;  	Target:  		SD028
;	Author:			Arthur (Lu Hungche)
;	Date:			2020/03/11
;------------------------------------------------------------
;	Description:	For SD028 Template
;
;------------------------------------------------------------
; History:
; Ver  | dd-mmm-yyyy |  Who  | Description of changes
; =====|=============|=======|===============================
;  0.1 | 11 Mat 2020 |Arthur | Original Release.
; -----|-------------|-------|-------------------------------
;  0.2 |
; -----|-------------|-------|-------------------------------
;============================================================

;==================== Project Include ====================
Include	"SD062.INC"

;================ General Purpose Register ===============
	TMP0	== 0x50
	TMP1	== 0x51
	TMP2	== 0x52
	TMP3	== 0x53
	TMP4	== 0x54
	TMP5	== 0x55

;================ Interrupt Vector Table =================
	ORG		0x0002
		JMP	_Int_EXINT
	ORG		0x0004
		JMP	_Int_ICINT
	ORG		0x000A
		JMP	_Int_CMP1INT
	ORG		0x000E
		JMP	_Int_CMP2INT
	ORG		0x0010
		JMP	_Int_ADINT
	ORG		0x0018
		JMP	_Int_CMP3INT
	ORG		0x003A
		JMP	_Int_SHINT
	ORG		0x003C
		JMP	_Int_TM1INT
	ORG		0x003E
		JMP	_Int_TM2INT
	ORG		0x0040
		JMP	_Int_TM1OFINT
	ORG		0x0042
		JMP	_Int_TXTMINT

	JMP JMP_FAIL	;0x0046
	JMP JMP_FAIL	;0x0047
	JMP JMP_FAIL	;0x0048
	JMP JMP_FAIL	;0x0049
	JMP JMP_FAIL	;0x004A
	JMP JMP_FAIL	;0x004B
	JMP JMP_FAIL	;0x004C
	JMP JMP_FAIL	;0x004D
	JMP JMP_FAIL	;0x004E
	JMP JMP_FAIL	;0x004F


;==================== Main Function ======================
	ORG 	0x0000
	JMP 	MAIN

	ORG		0x0050
MAIN:
	CALL	SYS_INIT
	CALL	GPIO_INIT
	CALL	RAM_TABLE
	CALL 	IAP_WRITE
	CALL	IAP_RAED


;====================== Backgroung =======================
BACK_GROUND_LOOP:
	SBANK	0
	NOP
	JMP		BACK_GROUND_LOOP

JMP_FAIL:
	SBANK	0
	JMP		JMP_FAIL
	
;================== Jmp Sub Function ==================
	SYS_INIT:	
		SBANK	0
		BS		CPUS
		BS		IDLE
		RET
		
	GPIO_INIT:
		SBANK	0
		CLR		P5
		MOV		A,@0x00
		MOV		IOCR5,A
		RET
		
	RAM_TABLE:
		MOV		A,@0x80		; Write Start SRAM
		MOV		RSR,A
		GBANK	0
		MOV		A,@0x69		; SRAM(0x0085)
		MOV		IAR,A
		INC		RSR
		MOV		A,@0x69
		MOV		IAR,A
		INC		RSR		
		MOV		A,@0x00
		XOR		A,IAR		; INC(0x80),UNTIL(0xC0)
		JBS		Z
		JMP		$-9
		RET
		
	IAP_WRITE:
		SBANK	1
		MOV		A,@0x00
		MOV		TBWAL,A
		MOV		A,@0x0C
		MOV		TBWAH,A
		MOV		A,@0x01
		MOV		TBWCR,A
		MOV		A,@0x01
		MOV		TBWCR,A
		MOV		A,@0xB4
		MOV		FLKR,A
		TBWR
		RET

	IAP_RAED:
		GBANK	1
		MOV		A,@0x80
		MOV		TMP4,A
		MOV		A,@0x00
		MOV		TMP3,A			
		TEXT1:
		MOV		A,TMP4
		MOV		RSR,A
		SBANK	1
		MOV		A,TMP3	; Set ROM Pointer
		MOV		TBPTL,A
		MOV		A,@0x0C
		MOV		TBPTH,A
		TBRDA	TMP5	; A(LowByte),TMP5(HiByte)
		MOV		IAR,A
		INC		RSR
		MOV		A,TMP5
		MOV		IAR,A
		INC		TMP3
		INC		TMP4
		INC		TMP4
		MOV		A,TMP4
		XOR		A,@0xFE
		JBS		Z
		JMP		TEXT1
		RET


;============== Interrupt Service Routine ================
	;================================
	_Int_EXINT:
		SBANK	0
		BC		EXSF0
		BC		EXSF1
		RETI
	;================================
	_Int_ICINT:
		SBANK	0
		BC		P5ICSF
		RETI
	;================================
	_Int_CMP1INT:
		SBANK	0
		JBS 	CMP1SF
		JMP 	JMP_FAIL
		BC		CMP1SF
		RETI
	;================================
	_Int_CMP2INT:
		SBANK	0
		JBS 	CMP2SF
		JMP 	JMP_FAIL
		BC		CMP2SF
		RETI
	;================================
	_Int_ADINT:
		SBANK	0
		JBS 	ADSF
		JMP 	JMP_FAIL
		BC		ADSF
		RETI
	;================================
	_Int_CMP3INT:
		SBANK	0
		JBS 	CMP3SF
		JMP 	JMP_FAIL
		BC		CMP3SF
		RETI

	;================================
	_Int_SHINT:
		SBANK	0
		JBS 	SHSF
		JMP 	JMP_FAIL
		BC		SHSF
		RETI
	;================================
	_Int_TM1INT:
		SBANK	0
		BC		TM1DASF
		BC		TM1DBSF
		RETI
	;================================
	_Int_TM2INT:
		SBANK	0
		BC		TM2DASF
		BC		TM2DBSF
		RETI
	;================================
	_Int_TM1OFINT:
		SBANK	0
		JBS 	TM1OFSF
		JMP 	JMP_FAIL
		BC		TM1OFSF
		RETI
	;================================
	_Int_TXTMINT:
		SBANK	0
		BC		TXDSF
		BC		TXCSF
		RETI

ORG		0x0C00
	DW	0x1234
	DW	0x1234
	DW	0x1234
	DW	0x1234



