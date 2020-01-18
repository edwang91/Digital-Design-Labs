// This is the datapath module which will create the datapath by instantiating all the other modules begin
// the combinational building blocks.
module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, datapath_in, Z_out, datapath_out);
	input clk, vsel, loada, loadb, asel, bsel, loadc, loads, write;
	input [2:0] readnum, writenum;
	input [1:0] shift, ALUop;
	input [15:0] datapath_in;
	output Z_out;
	output [15:0] datapath_out;
	
	// Wire declarations between modules.
	wire [15:0] data_out_reg, data_to_regfile, data_to_shifter, data_to_operandsA, data_to_operandsB;
	wire [15:0] data_to_ALUA, data_to_ALUB, data_to_c, data_back, datapath_out;
	wire Z;
	
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
	operandMux Bmux(data_to_operandsB, {11'b0, datapath_in[4:0]}, bsel, data_to_ALUB);
	
	// Datapath through ALU. Z output to statusreg and data_to_c to register C.
	ALU compute(data_to_ALUA, data_to_ALUB, ALUop, data_to_c, Z);
	
	// Datapath through statusreg and outputs the 1-bit z_out.
	statusReg status(Z, clk, loads, Z_out);
	
	// Datapath through register C and output to both out and back to writebackMux.
	pipelineRegs C(data_to_c, loadc, clk, data_back);
	
	// Output datapath_out gets same value as the data being written back.
	assign datapath_out = data_back;
	
	// Datapath back to the writebackMux.
	writebackMux writeback(datapath_in, data_back, vsel, data_to_regfile);
	
endmodule
	

// This module is the writeback multiplexer
module writebackMux(datapath_in, datapath_back, vsel, data_out);
	input vsel;
	input [15:0] datapath_in, datapath_back;
	output [15:0] data_out;
	
	reg [15:0] data_out;
	
	// Depending on vsel, the output will either be the output of ALU fed back 
	// from register C or it will be an outside input.
	always @* begin
		case (vsel)
			0: data_out = datapath_back;
			1: data_out = datapath_in;
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
module statusReg(Z, clk, loads, Z_out);
		input Z, loads, clk;
		output Z_out;
		
		reg Z_out;
		wire next_Z;
		
		assign next_Z = loads ? Z : Z_out;			//Determines the next output based on loads
		
		//Update the output at the rising edge of clk.
		always @(posedge clk) 
			Z_out <= next_Z;
endmodule