//No load input needed, replace with load_ir wire. No s needed(?).
//Here in is the read_data.
module cpu(clk, reset, in, out, mem_addr, mem_cmd, halt);
    input clk, reset;
    input [15:0] in;					//The in is the mdata to datapath and read_data to FSM, which is outputted from the RAM.
    output [15:0] out;
	 output [8:0] mem_addr;		//Output to the RAM and equality comparator.
	 output [1:0] mem_cmd;
	 output halt;
    
	 //Wire declarations to make connections
    wire [15:0] reg_to_dec, sximm5, sximm8, mdata;
	 wire [8:0] next_pc, PC, data_to_mem_addr;
	 wire [7:0] PC_indata;
	 wire [3:0] vsel;
	 wire [2:0] opcode, readnum, writenum, statusOut, nsel, cond;
	 wire [1:0] ALUop, shift, mem_cmd;
	 //new wire load_sx for adding PC + sxim8
	 wire asel, bsel, loada, loadb, loadc, loads, write, load_ir, load_PC, addr_sel, load_addr, reset_PC, stats, load_sx, load_r7, N, V, Z;
	 
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
	 assign PC_indata = PC[7:0];
	
	//instantiation for data address
	 load_enable_reg #(9) data_addr(clk, out[8:0], load_addr, data_to_mem_addr);
	 
	 
	 //No changes needed
	 instruction_decoder #(16) decode(reg_to_dec, nsel, opcode, ALUop, sximm5, sximm8, shift, readnum, writenum, cond);
	 
	 //in is the mdata.
	 datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, in, sximm8, sximm5, PC_indata, statusOut, out);
	 
	 //Changes made. In goes to the FSM.
	 fsm FSM(clk, reset, opcode, ALUop, stats, vsel, asel, bsel, nsel, loada, loadb, loadc, loads, write, load_ir, load_PC, mem_cmd, addr_sel, load_addr, reset_PC, load_sx, halt, load_r7);
	 
	 //The bottom MUX in figure 2.
	 general_2MUX #(9) addrMUX(addr_sel, data_to_mem_addr, PC, mem_addr);

	 
	  /* added input signal for load and datapathout (R7) */
     toPC to_pc(load_r7, out[8:0], load_sx, sximm8[8:0], PC, reset_PC, next_pc);
	 
	 //Instantiation of the status comparator
	 statusComp comparestats(N, Z, V, cond, stats);
	
endmodule


//Module for PC mux
module toPC(load_r7, r7_in, load_sx, sxim8, PC, reset_pc, next_pc);
	input load_sx, reset_pc, load_r7;
	input [8:0] sxim8, PC, r7_in;
	output [8:0] next_pc;
	
	wire [8:0] pc_added, r7mux_out, loop_back;
	
	//Always increment by 1 for PC.
	assign loop_back = PC + 9'b000000001;
	
	//Mux for deciding whether to send R7 value to PC or not.
    general_2MUX #(9) loadR7(load_r7, loop_back, r7_in, r7mux_out);
	
	//Decides whether to add 8 bit sign extend or not to. If so, subtract 1 from PC to account for an extra +1.
	assign pc_added = load_sx ? (r7mux_out + sxim8 - 9'b000000001) : r7mux_out;
	
	//MUX for deciding PC reset.
	general_2MUX #(9) loadMux(reset_pc, pc_added, 9'b0, next_pc);
	
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
	