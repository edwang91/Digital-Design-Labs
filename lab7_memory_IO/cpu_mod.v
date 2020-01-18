//No load input needed, replace with load_ir wire. No s needed(?).
//Here in is the read_data.
module cpu(clk, reset, in, out, N, V, Z, mem_addr, mem_cmd);
    input clk, reset;
    input [15:0] in;					//The in is the mdata to datapath and read_data to FSM, which is outputted from the RAM.
    output [15:0] out;
	 output [8:0] mem_addr;		//Output to the RAM and equality comparator.
	 output [1:0] mem_cmd;
    output N, V, Z;
    
	 //Wire declarations to make connections
    wire [15:0] reg_to_dec, sximm5, sximm8, mdata;
	 wire [8:0] next_pc, PC, data_to_mem_addr;
	 wire [3:0] vsel;
	 wire [2:0] opcode, readnum, writenum, statusOut, nsel;
	 wire [1:0] ALUop, shift, mem_cmd;
	 wire asel, bsel, loada, loadb, loadc, loads, write, load_ir, load_PC, addr_sel, load_addr, reset_PC;
	 
	 //Assign corresponding bits of statusOut to N, V, and Z.
	 assign N = statusOut[2];
	 assign V = statusOut[1];
	 assign Z = statusOut[0];
	 
	 //Module instantiations
	 //Add 2 more inputs: load_ir, read_data = in.
	 //Instantiation for the insruction register, program counter, and data address regs.
	 load_enable_reg #(16) instruction_register(clk, in, load_ir, reg_to_dec);
	
	//Instantiation for PC. Updates the PC when appropriate.
	 load_enable_reg #(9) pc(clk, next_pc, load_PC, PC);
	
	//instantiation for data address
	 load_enable_reg #(9) data_addr(clk, out[8:0], load_addr, data_to_mem_addr);
	 
	 
	 //No changes needed
	 instruction_decoder #(16) decode(reg_to_dec, nsel, opcode, ALUop, sximm5, sximm8, shift, readnum, writenum);
	 
	 //in is the mdata.
	 datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, in, sximm8, sximm5, PC[7:0], statusOut, out);
	 
	 //Changes made. In goes to the FSM.
	 fsm statemachine(clk, reset, opcode, ALUop, vsel, asel, bsel, nsel, loada, loadb, loadc, loads, write, load_ir, load_PC, mem_cmd, addr_sel, load_addr, reset_PC);
	 
	 //The bottom MUX in figure 2.
	 general_2MUX #(9) addrMUX(addr_sel, data_to_mem_addr, PC, mem_addr);
	 //The middle MUX in figure 2.
	 PCMUX selPC(reset_PC, PC, 9'b0, next_pc);
	 
	 
	
endmodule

//Module for PC mux
module PCMUX(sel, in0, in1, out);
	input sel;
	input [8:0] in0, in1;
	output [8:0] out;
	
	assign out = sel ? in1 : (in0 + 9'b000000001);
endmodule

//Module defining other small MUXes that will be added in CPU.
module general_2MUX(sel, in0, in1, out);
	parameter n = 9;
	input sel;
	input [n-1:0] in0, in1;
	output [n-1:0] out;
	
	//Perform the binary selection.
	assign out = sel ? in1 : in0;
endmodule
	