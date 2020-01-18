module fsm(clk, reset, opcode, op, stats, vsel, asel, bsel, nsel, loada, loadb, loadc, loads, write, load_ir, load_PC, mem_cmd, addr_sel, load_addr, reset_PC, load_sx, halt, load_r7);
	
	//Unused: s
	
	//Added extra bit to state definitions to accomodate extra states needed to replace wait
	`define SW 5
	`define SRESET 5'b00000
	`define SIF1 5'b01000
	`define SIF2 5'b01100
	`define SUPDATE 5'b01110
	`define SDEC 5'b00001
	`define SWRITE 5'b00010
	`define SP 5'b00011
	`define SA 5'b00111
	`define SSTATUS 5'b00101
	`define SC 5'b00110
	`define SLOADADDR 5'b00100
	`define SRAM 5'b01111
	`define SHALT 5'b01010
	`define SC2 5'b10110
	
	`define MW 2
	`define MNONE 2'b00
	`define MREAD 2'b10
	`define MWRITE 2'b01
	
	//Outputs are all the leftover inputs to datapath not covered by instruction decoder. input s not needed.
	input reset, clk, stats; 
	input [2:0] opcode;
	input [1:0] op;
	output asel, bsel, loada, loadb, loadc, loads, write, load_ir, load_PC, addr_sel, load_addr, reset_PC, load_sx, halt, load_r7;
	output [1:0] mem_cmd;
	output [3:0] vsel;
	output [2:0] nsel;		//Used as a sel for a 3 input multiplexer 
	
	wire [4:0] p;
	wire [4:0] next_state_reset; 
	reg [4:0] next_state;
	reg [1:0] mem_cmd;
	reg asel, bsel, loada, loadb, loadc, loads, write, load_ir, load_PC, addr_sel, load_addr, reset_PC, load_sx, halt, load_r7;
	reg [3:0] vsel;
	reg [2:0] nsel;
	
	//Check for reset signal
	assign next_state_reset = reset ? `SRESET : next_state;
	
	//STILL NEED TO ADD OTHER COMMAND SETS
	always @* begin
		casex({p, reset, opcode, op, stats})
		
		//State changes from reset when reset is 0, otherwise stays in reset.
			{`SRESET, 7'b1xxxxxx}: begin 
				next_state = `SRESET;
				reset_PC = 1;
				load_PC = 1;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				//NEW signals.
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 0;
				nsel = 3'b0;
				halt = 0;
			end
			
			//If reset is 0, go to IF1
			{`SRESET, 7'b0xxxxxx}: begin 
				next_state = `SIF1;
				reset_PC = 1;
				load_PC = 1;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 0;
				nsel = 3'b0;
				halt = 0;
			end
			
			//State for IF1: address is stored in PC here and sent to the instruction memory (RAM).
			//Transitions to IF2 no matter what.
			{`SIF1, 7'b0xxxxxx}: begin
				next_state = `SIF2;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 1;
				mem_cmd = `MREAD;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b1000;
				nsel = 3'b0;
				halt = 0;
			end
			
			//State for IF2: instruction at address specified by PC reg is now available at dout of memory RAM.
			//Waiting for memory.
			{`SIF2, 7'b0xxxxxx}: begin
				next_state = `SUPDATE;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 1;
				addr_sel = 1;
				mem_cmd = `MREAD;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b1000;
				nsel = 3'b0;
				halt = 0;
			end
			
			//UpdatePC for BL
			{`SUPDATE, 7'b001011x}: begin
				next_state = `SDEC;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 1;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b1000;
				nsel = 3'b0;
				halt = 0;
			end
			
			//UpdatePC state: updates the PC to the address of next instruction. Then begin transition to decoding.
			{`SUPDATE, 7'b0xxxxxx}: begin
				next_state = `SDEC;
				reset_PC = 0;
				load_PC = 1;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b1000;
				nsel = 3'b0;
				halt = 0;
			end

			
			//Decode for new branch instructions.
			
			//First MOV: state decodes straight to write.
			{`SDEC, 7'b011010x}: begin 
				next_state = `SWRITE;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 1;
				vsel = 4'b0100;
				nsel = 3'b001;		//Decode the immediate value im8
				halt = 0;
			end
			
			//Other state change to decoder: next state will always be write to reg B or A
			//starting at the DEC state and onwards, all the newly added outputs should be off.
			{`SDEC, 7'b011000x}, {`SDEC, 7'b010111x}: begin
				next_state = `SP;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0100;
				nsel = 3'b100;		
				halt = 0;
			end
			
			//DECODE for BX instruction.
			{`SDEC, 7'b001000x}: begin
				next_state = `SP;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b010;		
				halt = 0;
			end
			
						//Decode instruction for LDR and STR
			{`SDEC, 7'b001100x}, {`SDEC, 7'b010000x}: begin
				next_state = `SA;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 1;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b1000;
				nsel = 3'b001;	
				halt = 0;
			end
			
			//Decode state going straight to SHALT.
			{`SDEC, 7'b011100x}: begin
				next_state = `SHALT;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 1;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0000;
				nsel = 3'b000;	
				halt = 1;
			end
			
			//All branch instructions for if conditions
			{`SDEC, 7'b0001001}: begin
				next_state = `SRAM;
				reset_PC = 0;
				load_PC = 1;		//Perform the PC + 1 part.
				load_ir = 0;
				addr_sel = 1;
				mem_cmd = `MREAD;		//Read the new address into RAM to obtain instruction at that point.
				load_addr = 0;
				load_sx = 1;			// Since we are executing the if statements, set load_sx to 1.
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0000;
				nsel = 3'b000;	
				halt = 0;
			end
			
			//All branch instructions for else conditions
			{`SDEC, 7'b0001000}: begin
				next_state = `SRAM;
				reset_PC = 0;
				load_PC = 0;		
				load_ir = 0;
				addr_sel = 1;
				mem_cmd = `MREAD;		//Read the new address into RAM to obtain instruction at that point.
				load_addr = 0;
				load_sx = 0;			// Since we are executing the else statements, set load_sx to 0, don't add signx.
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0000;
				nsel = 3'b000;	
				halt = 0;
			end
			
			//SDEC for BL/BLX
			{`SDEC, 7'b001011x}: begin
				next_state = `SWRITE;
				reset_PC = 0;
				load_PC = 1;		
				load_ir = 0;
				addr_sel = 1;
				mem_cmd = `MNONE;		
				load_addr = 0;
				load_sx = 0;			// Since we are executing the else statements, set load_sx to 0, don't add signx.
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;			//write the PC value into R7.
				vsel = 4'b0010;	//Set datapath_in is PC.
				nsel = 3'b001;	
				halt = 0;
			end
			
			//SWrite for BL
			{`SWRITE, 7'b001011x}: begin
				next_state = `SRAM;
				reset_PC = 0;
				load_PC = 1;		//PC + sxim8 + 1
				load_ir = 0;
				addr_sel = 1;
				mem_cmd = `MREAD;
				load_addr = 0;
				load_sx = 1;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 1;			//write the PC value into R7.
				vsel = 4'b0010;	//Set datapath_in is PC.
				nsel = 3'b001;	
				halt = 0;
			end
			
			//SRAM for BL
			{`SRAM, 7'b001011x}: begin
				next_state = `SIF1;
				reset_PC = 0;
				load_PC = 0;		
				load_ir = 0;
				addr_sel = 1;
				mem_cmd = `MREAD;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;			
				vsel = 4'b0010;	//Set datapath_in is PC.
				nsel = 3'b000;	
				halt = 0;
			end
			
			//SHALT state stays here until reset is asserted, then go to reset state.
			{`SHALT, 7'b0xxxxxx}: begin
				next_state = reset ? `SRESET : `SHALT;
				reset_PC = 1;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0000;
				nsel = 3'b000;	
				halt = 1;
			end
			
			
			//other MOV and NOT: moving a shifted value from Rm to reg B
			{`SP, 7'b011000x}, {`SP, 7'b110111x}: begin
				next_state = `SC;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 1;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0100;
				nsel = 3'b100;		//Read value from Rm to Register B
				halt = 0;
			end
			
			//SP for BX instruction
			{`SP, 7'b001000x}: begin
				next_state = `SC;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 1;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b010;		//Read value from Rm to Register B
				halt = 0;
			end
			
					//If subtracting, only output the 3bit status.
			{`SP, 7'b010101x}: begin
				next_state = `SSTATUS;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 1;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b100;		
			   halt = 0;	
			end
			

			
			//SA state for new instructions	
			{`SA, 7'b001100x}, {`SA, 7'b010000x}: begin
				next_state = `SC;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 1;			//Add the 5 bit sign extended value.
				loada = 1;
				loadb = 0;
				loadc = 0;			
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;
				halt = 0;
			end
			
			//SC state for the LDR instruction and STR.
			{`SC, 7'b001100x}, {`SC, 7'b010000x}: begin
				next_state = `SLOADADDR;					//Next step load into the data address, or if asel is 1 meaning second cycle: write to RAM
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 1;	
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 1;
				loada = 0;
				loadb = 0;
				loadc = 1;		//loadc to 1 to write to reg C
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;	
		      halt = 0;		
			end
			
			//LOADc state for BX instruction.
			{`SC, 7'b001000x}: begin
				next_state = `SRAM;
				reset_PC = 0;
				load_PC = 0;		//Update PC with value from Rd.
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MREAD;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 1;
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 1;
				loads = 0;
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b010;
				halt = 0;
			end
			
			//Second loadc state. Different outputs. Transitions straight to RAM state.
			{`SC2, 7'b010000x}: begin
				next_state = `SRAM;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 1;
				mem_cmd = `MNONE;
				load_addr = 0;	
				load_sx = 0;
				load_r7 = 0;
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 1;		//loadc to 1 to write to reg C
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b000;	
				halt = 0;
			end
			
			//Loading into data address for LDR.
			{`SLOADADDR, 7'b001100x}: begin
				next_state = `SRAM;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MREAD;			//Set command to read.
				load_addr = 1;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;		
				loads = 0; 
				write = 0;
				vsel = 4'b1000;		//Set so that data_pathin will be the mdata.
				nsel = 3'b010;			//Save memory to R[Rd]
				halt = 0;
			end
			
			//load into data address for STR.
			{`SLOADADDR, 7'b010000x}: begin
				next_state = `SP;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MWRITE;			//no reading in this state for STR
				load_addr = 1;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;		
				loads = 0; 
				write = 0;
				vsel = 4'b1000;		//Set so that data_pathin will be the mdata.
				nsel = 3'b010;			//Save memory to R[Rd]
				halt = 0;
			end
			
			//Loading to reg B for STR.
			{`SP, 7'b010000x}: begin
				next_state = `SC2;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 1;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b1000;
				nsel = 3'b010;	
				halt = 0;
			end
			
			//RAM state for BX instruction
			{`SRAM, 7'b001000x}: begin
				reset_PC = 0;
				next_state = `SIF1;
				load_PC = 1;
				load_ir = 0;
				addr_sel = 1;				//Read the instruction set in PC.
				mem_cmd = `MREAD;			//Set command to read.
				load_addr = 0;
				load_sx = 0;
				load_r7 = 1;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;		
				loads = 0; 
				write = 0;
				vsel = 4'b1000;		//Set so that data_pathin will be the mdata.
				nsel = 3'b010;		
			   halt = 0;	
			end
			
			//RAM state for LDR and new branch instructions.
			{`SRAM, 7'b001100x}, {`SRAM, 7'b000100x}: begin
				next_state = `SWRITE;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MREAD;			//Set command to read.
				load_addr = 1;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;		
				loads = 0; 
				write = 0;
				vsel = 4'b1000;		//Set so that data_pathin will be the mdata.
				nsel = 3'b010;		
			   halt = 0;	
			end
			
			//Ram state for STR.
			{`SRAM, 7'b010000x}: begin
				next_state = `SIF1;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MWRITE;			//Set command to write.
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;		
				loads = 0; 
				write = 0;
				vsel = 4'b1000;		//Set so that data_pathin will be the mdata.
				nsel = 3'b010;	
				halt = 0;
			end
			
			//SWRITE state for new instructions
			{`SWRITE, 7'b001100x}, {`SWRITE, 7'b000100x}: begin
				next_state = `SIF1;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MREAD;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 1;
				vsel = 4'b1000;
				nsel = 3'b010;
				halt = 0;
			end
			
			//Storing into register B for STR instruction after data address state. Transition to second loadC state.
			{`SP, 7'b010000x}: begin
				next_state = `SC2;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 1;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0100;
				nsel = 3'b010;	
				halt = 0;
			end
			
			//All instructions from register B goes to register C except NOT
			{`SP, 7'b0xxxxxx}: begin
				next_state = `SC;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 1;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0100;
				nsel = 3'b100;		//Read value from Rm to Register B
				halt = 0;
			end
			
			//Instructions that require use of reg A. 
			{`SDEC, 7'b0101xxx}: begin
				next_state = `SA;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;		
			   halt = 0;	
			end
			
						//reg A regardless of instruction type, go on to store in reg B:
			{`SA, 7'b0xxxxxx}: begin
				next_state = `SP;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 1;
				loadb = 0;
				loadc = 0;			
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;
				halt = 0;
			end
	
			
						//Else for all other ALU instructions transistion to reading to reg C.
			{`SA, 7'b0101xxx}: begin
				next_state = `SP;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 1;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;		//Other value in reg A from Rn
				halt = 0;
			end
			
			//keep asel = 1 when copying
			{`SC, 7'b011000x}: begin
				next_state = `SWRITE;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 1;		//loadc to 1 to write to reg C
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b000;			
				halt = 0;
			end
			
						//From reg C: write back to regfile. Writeback to Rd
			{`SC, 7'b0xxxxxx}: begin
				next_state = `SWRITE;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 1;		//loadc to 1 to write to reg C
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b000;		
		   	halt = 0;	
			end
			
			

			
			//In Reg A state:
			{`SSTATUS, 7'b010101x}: begin
				next_state = `SIF1;			//Done
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 1; 			//Turn on loads to output the status
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b000;
				halt = 0;
			end
			

						//First MOV: write into Rn
			{`SWRITE, 7'b011010x}: begin 
				next_state = `SIF1;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;			//write into Rn
				halt = 0;
			end

			//Every other write stage that is not first MOV instruction 
			{`SWRITE, 7'b0xxxxxx}: begin
				next_state = `SIF1;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MWRITE;
				load_addr = 0;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 1;
				vsel = 4'b0001;			//Set vsel to 0 so the writeback mux takes writeback value
				nsel = 3'b010;		//Writeback to Rd address
				halt = 0;
			end
			
			//Default settings
			default: begin
				next_state = 4'bx;
				reset_PC = 1'b1;
				load_PC = 1'bx;
				load_ir = 1'bx;
				addr_sel = 0;
				mem_cmd = 2'bx;
				load_addr = 1'bx;
				load_sx = 0;
				load_r7 = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 0;
				nsel = 3'b0;
				halt = 0;
			end
		endcase
	end
	
	//Update the state at the rising edge of clk.
	vDFF #(`SW) updateState(clk, next_state_reset, p);
	


endmodule
	
	