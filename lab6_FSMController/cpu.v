module cpu(clk, reset, s, load, in, out, N, V, Z, w);
    input clk, reset, s, load;
    input [15:0] in;
    output [15:0] out;
    output N, V, Z, w;
    
	 //Wire declarations to make connections
    wire [15:0] reg_to_dec, sximm5, sximm8, mdata;
	 wire [7:0] PC;
	 wire [3:0] vsel;
	 wire [2:0] opcode, readnum, writenum, statusOut, nsel;
	 wire [1:0] ALUop, shift;
	 wire asel, bsel, loada, loadb, loadc, loads, write;
	 
	 //Assign corresponding bits of statusOut to N, V, and Z.
	 assign N = statusOut[2];
	 assign V = statusOut[1];
	 assign Z = statusOut[0];
	 
	 //Module instantiations
	 instruction_register pass(clk, in, load, reg_to_dec);
	 
	 instruction_decoder decode(reg_to_dec, nsel, opcode, ALUop, sximm5, sximm8, shift, readnum, writenum);
	 
	 datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, mdata, sximm8, sximm5, PC, statusOut, out);
	 
	 FSM statemachine(clk, reset, s, opcode, ALUop, w, vsel, asel, bsel, nsel, loada, loadb, loadc, loads, write, PC, mdata);

endmodule