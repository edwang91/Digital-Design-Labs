module FSM(clk, reset, s, opcode, op, w, vsel, asel, bsel, nsel, loada, loadb, loadc, loads, write, PC, mdata);
	
	`define SW 3
	`define SWAIT 3'b000
	`define SDEC 3'b001
	`define SWRITE 3'b010
	`define SP 3'b011
	`define SA 3'b111
	`define SSTATUS 3'b101
	`define SC 3'b110
	
	//Outputs are all the leftover inputs to datapath not covered by instruction decoder.
	input reset, clk, s;
	input [2:0] opcode;
	input [1:0] op;
	output w, asel, bsel, loada, loadb, loadc, loads, write;
	output [3:0] vsel;
	output [2:0] nsel;		//Used as a sel for a 3 input multiplexer
	output [7:0] PC; 
	output [15:0] mdata;
	
	wire [2:0] current_state;
	wire [2:0] next_state_reset; 
	reg [2:0] next_state;
	reg w, asel, bsel, loada, loadb, loadc, loads, write;
	reg [3:0] vsel;
	reg [2:0] nsel;
	
	//Check for reset signal
	assign next_state_reset = reset ? `SWAIT : next_state;
	
	always @* begin
		casex({current_state, s, opcode, op})
		
		//State changes from wait when s is 1
			{`SWAIT, 6'b1xxxxx}: begin 
				next_state = `SDEC;
				w = 1'b1;
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
			
			//If s is 0, stay at wait.
			{`SWAIT, 6'b0xxxxx}: begin 
				next_state = `SWAIT;
				w = 1'b1;
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
				w = 1'b0;
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
			{`SDEC, 6'b011000}, {`SDEC, 6'b010111}: begin
				next_state = `SP;
				w = 0;
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
			
			
			//other MOV and NOT: moving a shifted value from Rm to reg B
			{`SP, 6'b011000}, {`SP, 6'b110111}: begin
				next_state = `SC;
				w = 0;
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
				w = 0;
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
			
			//All instructions from register B goes to register C except NOT
			{`SP, 6'b0xxxxx}: begin
				next_state = `SC;
				w = 0;
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
				w = 0;
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
				w = 0;
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
				w = 0;
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
				w = 0;
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
				w = 0;
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
				next_state = `SWAIT;			//Done
				w = 0;
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
				next_state = `SWAIT;
				w = 0;
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
				next_state = `SWAIT;
				w = 0;
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
				next_state = 3'b0;
				w = 0;
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
	
	//	TEMPORARY ASSIGNMENTS FOR LAB 6 ONLY.
	assign PC = 8'b0;
	assign mdata = 16'b0;
endmodule
	
	