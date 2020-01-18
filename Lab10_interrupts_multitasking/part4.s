//FIle was copied from interrupt_example.s
            .include	"address_map_arm.s"
            .include	"interrupt_ID.s"

/* ********************************************************************************
 * This program demonstrates use of interrupts with assembly language code. 
 * The program responds to interrupts from the pushbutton KEY port in the FPGA.
 *
 * The interrupt service routine for the pushbutton KEYs indicates which KEY has 
 * been pressed on the HEX0 display.
 ********************************************************************************/

				.section .vectors, "ax"

				B 			_start					// reset vector
				B 			SERVICE_UND				// undefined instruction vector
				B 			SERVICE_SVC				// software interrrupt vector
				B 			SERVICE_ABT_INST		// aborted prefetch vector
				B 			SERVICE_ABT_DATA		// aborted data vector
				.word 	0							// unused vector
				B 			SERVICE_IRQ				// IRQ interrupt vector
				B 			SERVICE_FIQ				// FIQ interrupt vector

				.text
				.global	_start
_start:		
				/* Set up stack pointers for IRQ and SVC processor modes */
				MOV		R1, #0b11010010					// interrupts masked, MODE = IRQ
				MSR		CPSR_c, R1							// change to IRQ mode
				LDR		SP, =A9_ONCHIP_END - 3			// set IRQ stack to top of A9 onchip memory
				/* Change to SVC (supervisor) mode with interrupts disabled */
				MOV		R1, #0b11010011					// interrupts masked, MODE = SVC
				MSR		CPSR, R1								// change to supervisor mode
				LDR		SP, =DDR_END - 3					// set SVC stack to top of DDR3 memory

				BL			CONFIG_GIC							// configure the ARM generic interrupt controller

				// write to the pushbutton KEY interrupt mask register
				LDR		R0, =KEY_BASE						// pushbutton KEY base address
				MOV		R1, #0xF								// set interrupt mask bits
				STR		R1, [R0, #0x8]						// interrupt mask register is (base + 8)

				// enable IRQ interrupts in the processor
				MOV		R0, #0b01010011					// IRQ unmasked, MODE = SVC
				MSR		CPSR_c, R0
				
				//Part3: configuring JTAG UART. Some code taken from pg. 15 of figure 17 of de1soc pdf file
				LDR R2, =0xFF201004
				MOV R4, #0b01
				STR R4, [R2]				//Set WE bit off and RE bit on

			//Part 2 1): implementing timer interrupt. Some code taken from pg. 5 figure 5 of de1_sco.pdf file
				LDR R1, =0xFFFEC600 		// MPCore private timer base address. Value at this address is the Load value
				LDR R3,=100000000				// Load value = 200*10^6 * 200MHz / 2 = load value = 10^6
				STR R3, [R1]				// Write the load value to timer load register
				MOV R3, #0b111				//Set bits I, A, and E all to 1. Set prescalar to 255
				STR R3, [R1, #0x8]			//Write to the control register (private timer base address + 8)	

	LOOP:
				WAIT: 
				LDR R3, [R1, #0xC] 	// read timer status
				CMP R3, #0
				BNE WAIT 					// wait for timer to expire
				STR R3, [R1, #0xC] 			// reset timer flag bit
				BL IDLE

			IDLE:
				LDR R4, =CHAR_FLAG
				LDR R6, [R4]			//Read char_flag
				CMP R6, #1
				BEQ READ_CHAR			//Read the character buffer into R0
				B IDLE

		

				
			//Part4 process 1
			PROC1:
				
				LDR R10, =LEDR_BASE
				MOV R6, #0				//count = 0
				LDR R1, =0xFFFEC600
				While:
				
					LDR R3, [R1, #0xC] 	// read timer status
					CMP R3, #1
					BEQ SERVICE_IRQ
					ADD R6, R6, #1		//count++
					STR R6, [R10]		//Display count on LEDs
					MOV R7, #0			//i = 0
					Do:
						ADD R7, R7, #1
						LDR R8, =3000000
						CMP R7, R8	
						BEQ While		//If i == LARGE_NUMBER go back to beginning of outer loop
						B Do			//Otherwise keep incrementing i.
		
			
				


/* Define the exception service routines */

/*--- Undefined instructions --------------------------------------------------*/
SERVICE_UND:
    			B SERVICE_UND 
 
/*--- Software interrupts -----------------------------------------------------*/
SERVICE_SVC:			
    			B SERVICE_SVC 

/*--- Aborted data reads ------------------------------------------------------*/
SERVICE_ABT_DATA:
    			B SERVICE_ABT_DATA 

/*--- Aborted instruction fetch -----------------------------------------------*/
SERVICE_ABT_INST:
    			B SERVICE_ABT_INST 
 
/*--- IRQ ---------------------------------------------------------------------*/
SERVICE_IRQ:
    			PUSH		{R0-R7, LR}
    
    			/* Read the ICCIAR from the CPU interface */
	    		LDR		R4, =MPCORE_GIC_CPUIF
    			LDR		R5, [R4, #ICCIAR]				// read from ICCIAR

FPGA_IRQ1_HANDLER:	
    			CMP		R5, #JTAG_IRQ
    			BEQ		JTAG_ISR

			
	Check_KEYS:		//Check if the keys or JTAG is the one who caused the interrupt.
			CMP R5, #KEYS_IRQ			//Check if keys caused interrupt
			BEQ KEY_ISR
			
			CMP R5, #MPCORE_PRIV_TIMER_IRQ
			
			

			BL TIMER_ISR		//Go to TIMER_ISR if it was the timer who interrupted.

EXIT_IRQ:
    			/* Write to the End of Interrupt Register (ICCEOIR) */
    			STR		R5, [R4, #ICCEOIR]			// write to ICCEOIR
    
    			POP		{R0-R7, LR}
    			SUBS		PC, LR, #4

/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:
    			B			SERVICE_FIQ 

//Other subroutines

//Subroutine called on in the IDLE loop that reads the character
READ_CHAR:
	LDR R0, =CHAR_BUFFER
	LDR R0, [R0]		//Load the value in char_buffer to R0
	BL PUT_JTAG
	LDR R1, =CHAR_FLAG
	LDR R2, [R1]
	MOV R2, #0
	STR R2, [R1]		//Change CHAR_FLAG to 0

	B IDLE

//Subroutine for writing the 8-bit ascii value into global variable and setting a flag
JTAG_ISR:
	LDR R0, =0xFF201000
	LDR R3, [R0]		//load data register contents
	LDR R4, =CHAR_BUFFER
	STR R3, [R4]		//Store the character to char buffer
	LDR R8, =CHAR_FLAG
	MOV R7, #1
	STR R7, [R8]		//Set charflag to 1
	
END_JTAG_ISR:
	BL EXIT_IRQ

TIMER_ISR: 
	LDR R0, =MPCORE_PRIV_TIMER		//base address of priv_timer port
	LDR R1, [R0, #0xC]			//read edge capture register
	MOV R2, #0xF
	STR R2, [R0, #0xC]			//clear the interrupt
	
	//Removed code for displaying value on LEDs part4
	LDR R7, =CURRENT_PID
	LDR R7, [R7]			//R7 keeps track of current_PID value
	
	CMP R7, #0
	BEQ SAVE_P0
	BNE SAVE_P1
	

END_TIMER_ISR:
	BL EXIT_IRQ

//Saving registers for Process 0
SAVE_P0:
	LDR R3, =PD_ARRAY
	STR R8, [R3, #0x20]			//Save the R8 value of P0 to corresponding PD address
	STR R9, [R3, #0x24]			//Save R9 to corresponding PD address
	STR R10, [R3, #0x28]		//Save R10 
	STR R11, [R3, #0x2C]
	STR R12, [R3, #0x30]
	
	//Saving the registers saved to IRQ stack to PD_array
	POP {R0-R7, LR}		//restore saved R0-R7 and LR
	LDR R9, =PD_ARRAY
	//Save R0-R7, lr to PD_array
	STR R0, [R9]
	STR R1, [R9, #0x04]
	STR R2, [R9, #0x08]
	STR R3, [R9, #0x0C]
	STR R4, [R9, #0x10]
	STR R5, [R9, #0x14]
	STR R6, [R9, #0x18]
	STR R7, [R9, #0x1C]
	
	//Save CPSR
	MRS R8, SPSR
	STR R8, [R9, #0x40]			//Save the CPSR value for process 0 into PD_array
	
//Save LR and PC
	STR LR, [R9, #0x38]
	STR LR, [R9, #0x3C]			//LR has the PC for interrupted program

	//Saving SP and LR requires a temporary switch to supervisor mode with interrupts disabled
	/* Change to SVC (supervisor) mode with interrupts disabled */
				MOV		R1, #0b11010011					// interrupts masked, MODE = SVC
				MSR		CPSR, R1								// change to supervisor mode
				LDR		SP, =DDR_END - 3					// set SVC stack to top of DDR3 memory
				
				//Update CURRENT_PID to 1 as we are switching from process 0 to 1
				LDR R0, =CURRENT_PID
				MOV R2, #1
				STR R2, [R0]
				
				STR SP, [R9, #0x34]

				



	//Load values of R0-R15 and CPSR from PD_ARRAY consponding to Process 1
	LDR R0, =PD_ARRAY		//R0 is a garbage value initially for process 1
	LDR R1, [R0, #0x48]		//Restore R0-R12 of process 1
	LDR R2, [R0, #0x4C]
	LDR R3, [R0, #0x50]
	LDR R4, [R0, #0x54]
	LDR R5, [R0, #0x58]
	LDR R6, [R0, #0x5C]
	LDR R7, [R0, #0x60]
	LDR R8, [R0, #0x64]
	LDR R9, [R0, #0x68]
	LDR R10, [R0, #0x6C]
	LDR R11, [R0, #0x70]
	LDR R12, [R0, #0x74]
	
	PUSH {R1}

	//LOad values of R13-R14
	LDR SP, [R0, #0x78]

	
	//Load PC and CPSR
		//Change to IRQ mode
		MOV		R1, #0b11010011					// interrupts masked, MODE = IRQ
		MSR		CPSR_c, R1							// change to IRQ mode
		LDR		SP, =A9_ONCHIP_END - 3			// set IRQ stack to top of A9 onchip memory

	LDR LR, [R0, #0x80]		//Load stored PC for Proc1 to LR
		
	MRS R2, CPSR			//move the restored CPSR into R2 and copy to SPSR
	MSR SPSR, R2
	
	
	POP {R1}
	
	SUBS PC, LR, #4
	


//Saving registers for Process 1
SAVE_P1:
	LDR R0, =PD_ARRAY
	STR R8, [R0, #0x64]			//Save the R8 value of P1 to corresponding PD address
	STR R9, [R0, #0x68]			//Save R9 to corresponding PD address
	STR R10, [R0, #0x6C]		//Save R10 
	STR R11, [R0, #0x70]
	STR R12, [R0, #0x74]
	
	//Saving the registers saved to IRQ stack to PD_array
	POP {R0-R7, LR}		//restore saved R0-R7 and LR
	LDR R9, =PD_ARRAY
	//Save R0-R7, lr to PD_array
	STR R0, [R9, #0x44]
	STR R1, [R9, #0x48]
	STR R2, [R9, #0x4C]
	STR R3, [R9, #0x50]
	STR R4, [R9, #0x54]
	STR R5, [R9, #0x58]
	STR R6, [R9, #0x5C]
	STR R7, [R9, #0x60]
	
	//Save CPSR
	MRS R8, SPSR
	STR R8, [R9, #0x40]			//Save the CPSR value for process 0 into PD_array
	
	
	//Saving SP and LR requires a temporary switch to supervisor mode with interrupts disabled
	/* Change to SVC (supervisor) mode with interrupts disabled */
				MOV		R1, #0b11010011					// interrupts masked, MODE = SVC
				MSR		CPSR, R1								// change to supervisor mode
				LDR		SP, =DDR_END - 3					// set SVC stack to top of DDR3 memory
	
		//Update CURRENT_PID to 0 as we are switching from process 1 to 0
				LDR R0, =CURRENT_PID
				MOV R2, #0
				STR R2, [R0]
	
				LDR R8, =PD_ARRAY

				STR SP, [R8, #0x74]
				STR LR, [R8, #0x78]
				STR LR, [R8, #0x7C]			//LR has the PC for interrupted program
				
	//Load values of R0-R15 and CPSR from PD_ARRAY consponding to Process 0
	LDR R0, =PD_ARRAY		
	LDR R1, [R0, #0x04]		//Restore R0-R12 of process 0
	LDR R2, [R0, #0x08]
	LDR R3, [R0, #0x0C]
	LDR R4, [R0, #0x10]
	LDR R5, [R0, #0x14]
	LDR R6, [R0, #0x18]
	LDR R7, [R0, #0x1C]
	LDR R8, [R0, #0x20]
	LDR R9, [R0, #0x24]
	LDR R10, [R0, #0x28]
	LDR R11, [R0, #0x2C]
	LDR R12, [R0, #0x30]
	
	//LOad values of R13-R14
	LDR SP, [R0, #0x34]
	

	PUSH {R1-R2}		//Save R1 and R2 to stack temporarily
	LDR R1, =PD_ARRAY
	LDR R0, [R1]	//Restore R0 in process 0

	
	//Load PC and CPSR
	//Change to IRQ mode
		MOV		R1, #0b11010011					// interrupts masked, MODE = IRQ
		MSR		CPSR_c, R1							// change to IRQ mode
		LDR		SP, =A9_ONCHIP_END - 3			// set IRQ stack to top of A9 onchip memory

	LDR R1, =PD_ARRAY

	LDR LR, [R1, #0x3C]


	MRS R2, CPSR			//move the restored CPSR into R2 and copy to SPSR
	MSR SPSR, R2
	POP {R1-R2}				//Restore R1 and R2
		
	SUBS PC, LR, #4


data:
.word 5

CHAR_BUFFER:
	.asciz "\ntest\n>"

CHAR_FLAG:
	.word 0
	
CURRENT_PID:
	.word 0

PD_ARRAY: .fill 17,4,0xDEADBEEF
	  .fill 13,4,0xDEADBEE1
	  .word 0x3F000000		//SP
	  .word 0					//LR
	  .word PROC1+4			//PC
	  .word 0x53				//CPSR (0x53 means IRQ enabled, mode = SVC)
				.end   

