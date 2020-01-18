// This is the datapath module which will create the datapath by instantiating all the other modules begin
// the combinational building blocks.
module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, mdata, sximm8, sximm5, PC, statusOut, datapath_out);
	input clk, loada, loadb, asel, bsel, loadc, loads, write;
	input [2:0] readnum, writenum;
	input [3:0] vsel;
	input [1:0] shift, ALUop;
	input [7:0] PC;
	input [15:0] mdata, sximm8, sximm5;
	output [2:0] statusOut;
	output [15:0] datapath_out;
	
	// Wire declarations between modules.
	wire [15:0] data_out_reg, data_to_regfile, data_to_shifter, data_to_operandsA, data_to_operandsB;
	wire [15:0] data_to_ALUA, data_to_ALUB, data_to_c, data_back, datapath_out;
	wire Z, N, V;
	
	// Datapath through the register file.
	regfile REGFILE(data_to_regfile, writenum, write, readnum, clk, data_out_reg);
	
	// Datapath from register file to pipeline register A. Output straight to operandMux.
	// Other datapath to pipeline register B. Outputs to a shifter first before to operandMux.
	pipelineRegs Aregs(data_out_reg, loada, clk, data_to_operandsA);
	pipelineRegs Bregs(data_out_reg, loadb, clk, data_to_shifter);
	
	// Datapath through a shifter. Outputs data to operandMux.
	shifter SHIFT(data_to_shifter, shift, data_to_operandsB);
	
	// Datapath through the 2 operandMux.
	operandMux Amux(data_to_operandsA, 16'b0, asel, data_to_ALUA);
	
	
	//EDIT SECOND INPUT TO sximm5
	operandMux Bmux(data_to_operandsB, sximm5, bsel, data_to_ALUB);
	
	// Datapath through ALU. Z output to statusreg and data_to_c to register C.
	ALU compute(data_to_ALUA, data_to_ALUB, ALUop, data_to_c, Z, N, V);
	
	// Datapath through statusreg and outputs the 3-bit status.
	statusReg status(Z, N, V, clk, loads, statusOut);
	
	// Datapath through register C and output to both out and back to writebackMux.
	pipelineRegs C(data_to_c, loadc, clk, data_back);
	
	// Output datapath_out gets same value as the data being written back.
	assign datapath_out = data_back;
	
	// Datapath back to the writebackMux.
	writebackMux writeback(mdata, sximm8, {8'b0, PC}, data_back, vsel, data_to_regfile);
	
endmodule
	
	
	
	

// This module is the writeback multiplexer
// EDIT THIS. CHANGE THE NUMBER OF INPUTS.
// DONE
module writebackMux(mdata, sximm8, zeros_PC, C, vsel, data_out);
	input [3:0] vsel;
	input [15:0] mdata, sximm8, C, zeros_PC;
	output [15:0] data_out;
	
	reg [15:0] data_out;
	
	// Depending on vsel, the output will either be the output of ALU fed back 
	// from register C or it will be an outside input.
	//Edited to fit new vsel.
	always @* begin
		case (vsel)
			4'b0001: data_out = C;
			4'b0010: data_out = zeros_PC;
			4'b0100: data_out = sximm8;
			4'b1000: data_out = mdata;
			default: data_out = 16'bx;
		endcase
	end
endmodule




//This module is for the load_enabled pipeline registers.
//Code from slide 7 of lab5 examples slideset.
module pipelineRegs(data_in, load, clk, data_out);
	input [15:0] data_in;
	input load, clk;
	output [15:0] data_out;
	
	reg [15:0] data_out;
	wire [15:0] next_out;
	
	assign next_out = load ? data_in : data_out;		//Depending on the load, the output to operandMux will either be same or updated
	
	//On the rising edge of clk update the data_out to appropriate value based on load.
	always @(posedge clk) 
		data_out <= next_out;
endmodule
	
//This module is for the source operand MUX which will allow more complex operations other than
//addition and subtraction.
module operandMux(data_in, alternate_data, sel, out);
	input [15:0] data_in, alternate_data;
	input sel;
	output [15:0] out;
	
	reg [15:0] out;
	
	//Determines which data set to output to ALU.
	always @* begin
		case (sel)
			0: out = data_in;
			1: out = alternate_data;
			default: out = 16'bx;
		endcase
	end
endmodule

//This module is for the status register, which is load-enabled.
module statusReg(Z, N, V, clk, loads, statusOut);
		input Z, loads, clk, N, V;
		output [2:0] statusOut;
		reg [2:0] statusOut;
		wire [2:0] next_statusOut;
		
		//Output is a 3 bit signal where bit 2 indicates negative, bit 1 indicates overflow
		//and bit 0 indicates 0 value from ALU.
		assign next_statusOut = loads ? {N, V, Z} : statusOut;			//Determines the next output based on loads
		
		//Update the output at the rising edge of clk.
		always @(posedge clk) 
			statusOut = next_statusOut;
endmodule