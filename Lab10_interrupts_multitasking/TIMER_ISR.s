.include "address_map_arm.s"

//Timer routine will increment a global variable and display result on red LEDs
.global TIMER_ISR

TIMER_ISR: 
	LDR R0, =MPCORE_PRIV_TIMER		//base address of priv_timer port
	LDR R1, [R0, #0xC]			//read edge capture register
	MOV R2, #0xF
	STR R2, [R0, #0xC]			//clear the interrupt
	LDR R7, =LEDR_BASE			//base address of LEDR
	LDR R3, =data				//R3 gets address of global variable
	MOV R6, R3				//Copy address to R5
	LDR R3, [R3]				//Load value onto R3
	ADD R3, R3, #1				//Increment value by 1
	STR R3, [R7]				//Display incremented value on LEDs
	STR R3, [R6]				//Store the changed value


END_TIMER_ISR:
	BX LR


data:
.word 5

.end

