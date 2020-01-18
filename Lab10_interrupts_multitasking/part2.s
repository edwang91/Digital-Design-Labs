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
				
				//Part 2 1): implementing timer interrupt. Some code taken from pg. 5 figure 5 of de1_sco.pdf file
				LDR R1, =0xFFFEC600 		// MPCore private timer base address. Value at this address is the Load value
				LDR R3,=100000000				// Load value = 200*10^6 * 200MHz / 2 = load value = 10^6
				STR R3, [R1]				// Write the load value to timer load register
				MOV R3, #0b111				//Set bits I, A, and E all to 1. Set prescalar to 255
				STR R3, [R1, #0x8]			//Write to the control register (private timer base address + 8)
			LOOP:
				WAIT: LDR R3, [R1, #0xC] 	// read timer status
				CMP R3, #0
				BNE WAIT 					// wait for timer to expire
				STR R3, [R1, #0xC] 			// reset timer flag bit
				B LOOP
				
IDLE:
				B 			IDLE									// main program simply idles

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
			BNE Check_KEYS
    			BL			TIMER_ISR
			BL EXIT_IRQ
		


			
	Check_KEYS:		//Check if the timer is the one who caused the interrupt.
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

				.end   
