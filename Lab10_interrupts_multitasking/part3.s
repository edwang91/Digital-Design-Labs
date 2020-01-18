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
				
				
			IDLE:
				LDR R4, =CHAR_FLAG
				LDR R6, [R4]			//Read char_flag
				CMP R6, #1
				BEQ READ_CHAR			//Read the character buffer into R0
				B IDLE
				
			LOOP:
				WAIT: LDR R3, [R1, #0xC] 	// read timer status
				CMP R3, #0
				BNE WAIT 					// wait for timer to expire
				STR R3, [R1, #0xC] 			// reset timer flag bit
				B LOOP


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
    			CMP		R5, #MPCORE_PRIV_TIMER_IRQ
    			BEQ			TIMER_ISR

			
	Check_KEYS:		//Check if the keys or JTAG is the one who caused the interrupt.
			CMP R5, #JTAG_IRQ			//Check if JTAG caused interrupt
			BEQ JTAG_ISR
			
			CMP R5, #KEYS_IRQ
			
	UNEXPECTED:	BNE		UNEXPECTED    			//Stop here if interrupted

			BL KEY_ISR		//Go to KEY_ISR if it was the keys who interrupted.

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
	LDR R1, =0xFF201000
	LDR R2, [R1]		//load data register contents
	LDR R3, =CHAR_BUFFER
	STR R2, [R3]		//Store the character to char buffer
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
	LDR R7, =LEDR_BASE			//base address of LEDR
	LDR R3, =data				//R3 gets address of global variable
	MOV R6, R3				//Copy address to R5
	LDR R3, [R3]				//Load value onto R3
	ADD R3, R3, #1				//Increment value by 1
	STR R3, [R7]				//Display incremented value on LEDs
	STR R3, [R6]				//Store the changed value

END_TIMER_ISR:
	BL EXIT_IRQ

data:
.word 5

CHAR_BUFFER:
	.asciz "\ntest\n>"

CHAR_FLAG:
	.word 0

				.end   

