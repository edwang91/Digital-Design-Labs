module fsm(clk, reset, opcode, op, vsel, asel, bsel, nsel, loada, loadb, loadc, loads, write, load_ir, load_PC, mem_cmd, addr_sel, load_addr, reset_PC);
	
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
	input reset, clk; 
	input [2:0] opcode;
	input [1:0] op;
	output asel, bsel, loada, loadb, loadc, loads, write, load_ir, load_PC, addr_sel, load_addr, reset_PC;
	output [1:0] mem_cmd;
	output [3:0] vsel;
	output [2:0] nsel;		//Used as a sel for a 3 input multiplexer 
	
	wire [4:0] current_state;
	wire [4:0] next_state_reset; 
	reg [4:0] next_state;
	reg [1:0] mem_cmd;
	reg asel, bsel, loada, loadb, loadc, loads, write, load_ir, load_PC, addr_sel, load_addr, reset_PC;
	reg [3:0] vsel;
	reg [2:0] nsel;
	
	//Check for reset signal
	assign next_state_reset = reset ? `SRESET : next_state;
	
	//STILL NEED TO ADD OTHER COMMAND SETS
	always @* begin
		casex({current_state, reset, opcode, op})
		
		//State changes from reset when reset is 0, otherwise stays in reset.
			{`SRESET, 6'b1xxxxx}: begin 
				next_state = `SRESET;
				reset_PC = 1;
				load_PC = 1;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
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
			end
			
			//If reset is 0, go to IF1
			{`SRESET, 6'b0xxxxx}: begin 
				next_state = `SIF1;
				reset_PC = 1;
				load_PC = 1;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 0;
				nsel = 3'b0;
			end
			//State for IF1: address is stored in PC here and sent to the instruction memory (RAM).
			//Transitions to IF2 no matter what.
			{`SIF1, 6'b0xxxxx}: begin
				next_state = `SIF2;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 1;
				mem_cmd = `MREAD;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 0;
				nsel = 3'b0;
			end
			
			//State for IF2: instruction at address specified by PC reg is now available at dout of memory RAM.
			//Waiting for memory.
			{`SIF2, 6'b0xxxxx}: begin
				next_state = `SUPDATE;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 1;
				addr_sel = 1;
				mem_cmd = `MREAD;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 0;
				nsel = 3'b0;
			end
			
			//UpdatePC state: updates the PC to the address of next instruction. Then begin transition to decoding.
			{`SUPDATE, 6'b0xxxxx}: begin
				next_state = `SDEC;
				reset_PC = 0;
				load_PC = 1;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 0;
				nsel = 3'b0;
			end
			
			//First MOV: state decodes straight to write.
			{`SDEC, 6'b011010}: begin 
				next_state = `SWRITE;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 1;
				vsel = 4'b0100;
				nsel = 3'b001;		//Decode the immediate value im8
			end
			
			//Other state change to decoder: next state will always be write to reg B or A
			//starting at the DEC state and onwards, all the newly added outputs should be off.
			{`SDEC, 6'b011000}, {`SDEC, 6'b010111}: begin
				next_state = `SP;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0100;
				nsel = 3'b100;		
			end
			
						//Decode instruction for LDR and STR
			{`SDEC, 6'b001100}, {`SDEC, 6'b010000}: begin
				next_state = `SA;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 1;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;	
			end
			
			//Decode state going straight to SHALT.
			{`SDEC, 6'b011100}: begin
				next_state = `SHALT;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0000;
				nsel = 3'b000;	
			end
			
			//SHALT state stays here until reset is asserted, then go to reset state.
			{`SHALT, 6'b0xxxxx}: begin
				next_state = reset ? `SRESET : `SHALT;
				reset_PC = 1;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0000;
				nsel = 3'b000;	
			end
			
			
			//other MOV and NOT: moving a shifted value from Rm to reg B
			{`SP, 6'b011000}, {`SP, 6'b110111}: begin
				next_state = `SC;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 1;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0100;
				nsel = 3'b100;		//Read value from Rm to Register B
			end
			
					//If subtracting, only output the 3bit status.
			{`SP, 6'b010101}: begin
				next_state = `SSTATUS;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 1;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b100;			
			end
			

			
			//SA state for new instructions	
			{`SA, 6'b001100}, {`SA, 6'b010000}: begin
				next_state = `SC;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 1;			//Add the 5 bit sign extended value.
				loada = 1;
				loadb = 0;
				loadc = 0;			
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;
			end
			
			//SC state for the LDR instruction and STR.
			{`SC, 6'b001100}, {`SC, 6'b010000}: begin
				next_state = `SLOADADDR;					//Next step load into the data address, or if asel is 1 meaning second cycle: write to RAM
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 1;	
				
				asel = 0;
				bsel = 1;
				loada = 0;
				loadb = 0;
				loadc = 1;		//loadc to 1 to write to reg C
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b000;			
			end
			
			//Second loadc state. Different outputs. Transitions straight to RAM state.
			{`SC2, 6'b010000}: begin
				next_state = `SRAM;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;	
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 1;		//loadc to 1 to write to reg C
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b000;	
			end
			
			//Loading into data address for LDR.
			{`SLOADADDR, 6'b001100}: begin
				next_state = `SRAM;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MREAD;			//Set command to read.
				load_addr = 1;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;		
				loads = 0; 
				write = 0;
				vsel = 4'b1000;		//Set so that data_pathin will be the mdata.
				nsel = 3'b010;			//Save memory to R[Rd]
			end
			
			//load into data address for STR.
			{`SLOADADDR, 6'b010000}: begin
				next_state = `SP;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;			//no reading in this state for STR
				load_addr = 1;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;		
				loads = 0; 
				write = 0;
				vsel = 4'b1000;		//Set so that data_pathin will be the mdata.
				nsel = 3'b010;			//Save memory to R[Rd]
			end
			
			//Loading to reg B for STR.
			{`SP, 6'b010000}: begin
				next_state = `SC2;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 1;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b1000;
				nsel = 3'b010;	
			end
			
			//RAM state for LDR
			{`SRAM, 6'b001100}: begin
				next_state = `SWRITE;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MREAD;			//Set command to read.
				load_addr = 1;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;		
				loads = 0; 
				write = 0;
				vsel = 4'b1000;		//Set so that data_pathin will be the mdata.
				nsel = 3'b010;			
			end
			
			//Ram state for STR.
			{`SRAM, 6'b010000}: begin
				next_state = `SIF1;
					reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MWRITE;			//Set command to write.
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;		
				loads = 0; 
				write = 0;
				vsel = 4'b1000;		//Set so that data_pathin will be the mdata.
				nsel = 3'b010;	
			end
			
			//SWRITE state for new instructions
			{`SWRITE, 6'b001100}: begin
				next_state = `SIF1;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MREAD;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 1;
				vsel = 4'b1000;
				nsel = 3'b010;
			end
			
			//Storing into register B for STR instruction after data address state. Transition to second loadC state.
			{`SP, 6'b010000}: begin
				next_state = `SC2;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 1;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0100;
				nsel = 3'b010;	
			end
			
			//All instructions from register B goes to register C except NOT
			{`SP, 6'b0xxxxx}: begin
				next_state = `SC;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 1;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0100;
				nsel = 3'b100;		//Read value from Rm to Register B
			end
			
			//Instructions that require use of reg A. 
			{`SDEC, 6'b0101xx}: begin
				next_state = `SA;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;			
			end
			
						//reg A regardless of instruction type, go on to store in reg B:
			{`SA, 6'b0xxxxx}: begin
				next_state = `SP;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 1;
				loadb = 0;
				loadc = 0;			
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;
			end
	
			
						//Else for all other ALU instructions transistion to reading to reg C.
			{`SA, 6'b0101xx}: begin
				next_state = `SP;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 1;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;		//Other value in reg A from Rn
			end
			
			//keep asel = 1 when copying
			{`SC, 6'b011000}: begin
				next_state = `SWRITE;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 1;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 1;		//loadc to 1 to write to reg C
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b000;			
			end
			
						//From reg C: write back to regfile. Writeback to Rd
			{`SC, 6'b0xxxxx}: begin
				next_state = `SWRITE;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 1;		//loadc to 1 to write to reg C
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b000;			
			end
			
			

			
			//In Reg A state:
			{`SSTATUS, 6'b010101}: begin
				next_state = `SIF1;			//Done
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 1; 			//Turn on loads to output the status
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b000;
			end
			

						//First MOV: write into Rn
			{`SWRITE, 6'b011010}: begin 
				next_state = `SIF1;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MNONE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 4'b0001;
				nsel = 3'b001;			//write into Rn
			end

			//Every other write stage that is not first MOV instruction 
			{`SWRITE, 6'b0xxxxx}: begin
				next_state = `SIF1;
				reset_PC = 0;
				load_PC = 0;
				load_ir = 0;
				addr_sel = 0;
				mem_cmd = `MWRITE;
				load_addr = 0;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 1;
				vsel = 4'b0001;			//Set vsel to 0 so the writeback mux takes writeback value
				nsel = 3'b010;		//Writeback to Rd address
			end
			
			//Default settings
			default: begin
				next_state = 4'bx;
				reset_PC = 1'bx;
				load_PC = 1'bx;
				load_ir = 1'bx;
				addr_sel = 0;
				mem_cmd = 4'bx;
				load_addr = 1'bx;
				
				asel = 0;
				bsel = 0;
				loada = 0;
				loadb = 0;
				loadc = 0;
				loads = 0; 
				write = 0;
				vsel = 0;
				nsel = 3'b0;
			end
		endcase
	end
	
	//Update the state at the rising edge of clk.
	vDFF #(`SW) updateState(clk, next_state_reset, current_state);
	


endmodule
	
	