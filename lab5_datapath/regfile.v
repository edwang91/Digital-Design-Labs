// This module is for the register file which contains 8 registers that each can store a 16-bit number.
//NOTE: write -> SW[0], writenum, readnum -> SW[3:1], clk -> KEY[0].
module regfile(data_in, writenum, write, readnum, clk, data_out);
	input [15:0] data_in;
	input [2:0] writenum, readnum;
	input write, clk;
	output [15:0] data_out;
	
	wire [15:0] data_out;
	
	wire [7:0] hot_write_position;
	wire [7:0] hot_read_position;
	
	// Each wire here represents the 16-bit value stored in the corresponding register. TBD by the vDDFE module.
	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
	
	//Instatiations to the decoders to decode write positions and read positions to 1-hot
	Decode writing(writenum, hot_write_position);
	Decode reading(readnum, hot_read_position);
	
	//Next, we need to find a way to use 1-bit write and 1-hot write position to determine which register to store data_in in.
	//Make 8 instances of vDDFE module, each one is a register holding a 16 bit value.
	vDDFE STORE0(clk, hot_write_position[0] & write, data_in, R0);
	vDDFE STORE1(clk, hot_write_position[1] & write, data_in, R1);
	vDDFE STORE2(clk, hot_write_position[2] & write, data_in, R2);
	vDDFE STORE3(clk, hot_write_position[3] & write, data_in, R3);
	vDDFE STORE4(clk, hot_write_position[4] & write, data_in, R4);
	vDDFE STORE5(clk, hot_write_position[5] & write, data_in, R5);
	vDDFE STORE6(clk, hot_write_position[6] & write, data_in, R6);
	vDDFE STORE7(clk, hot_write_position[7] & write, data_in, R7);
	
	//Instance of dataoutMux that which will take as inputs all the value_stored values and select which to output
	//depending on the value of select, which is the 1-hot read position.
	
	DataoutMux pickValue(R0, R1, R2, R3, 
								R4, R5, R6, R7, hot_read_position, data_out);
	
endmodule

// Probably be making 8 instantiations of this for each of the 8 registers
// This module is an individual register that stores a 16-bit number
// The code for this module is from slide 7 of lab5 examples slide.
module vDDFE(clk, load, indata, outdata);
	parameter n = 16;		// width
	input clk, load;
	input [n-1:0] indata;
	output [n-1:0] outdata;
	reg [n-1:0] outdata;
	wire [n-1:0] nextdata;
	
	// this decides whether to write the data to this register and output it to the next MUX or not on rising edge of clk
	assign nextdata = load ? indata : outdata;
	
	// At the rising edge of clk update the output data (or not) appropriately based on the assign statement above
	always @(posedge clk)
		outdata = nextdata;
endmodule

// This module is the decoder block for writing
// Inputs binary position to write to, and outputs the 1-hot code for it
// Code from pg. 152 of Dally textbook
module Decode(binpos, hotpos);
	input [2:0] binpos;
	output [7:0] hotpos;
	reg [7:0] hotpos;
	
	//Decoding the binary position to 1-hot code.
	always @* begin
		case (binpos)
			0: hotpos = 8'b00000001;
			1: hotpos = 8'b00000010;
			2: hotpos = 8'b00000100;
			3: hotpos = 8'b00001000;
			4: hotpos = 8'b00010000;
			5: hotpos = 8'b00100000;
			6: hotpos = 8'b01000000;
			7: hotpos = 8'b10000000;
			default: hotpos = 8'bxxxxxxxx;
		endcase
	end
	
	// Converts the binary value to a 1-hot code
	//assign outpos = 1<<hotpos;
endmodule

// This module is the multiplexer that will choose which register to output the data_out from.
// From pg. 157 of Dally textbook
// Select: a 1-hot number decoded from binary register number.
// Inputs are all the 16-bit values stored in all 8 registers
// Outputs the appropriate 16-bit value stored in register specified by select.
module DataoutMux(outR0, outR1, outR2, outR3, outR4, outR5, outR6, outR7, select, out);
	
	input [15:0] outR0, outR1, outR2, outR3, outR4, outR5, outR6, outR7;
	input [7:0] select;
	output [15:0] out;
	reg [15:0] out;
	
	// Always checking for input changes
	always @* begin
		// This case statement determines which 16-bit stored value should be outputted based on what the select
		// 1-hot number is as this corresponds to the register that stores the outputted value. 
		case(select)
			8'b00000001: out = outR0;
			8'b00000010: out = outR1;
			8'b00000100: out = outR2;
			8'b00001000: out = outR3;
			8'b00010000: out = outR4;
			8'b00100000: out = outR5;
			8'b01000000: out = outR6;
			8'b10000000: out = outR7;
			default: out = {16{1'bx}};			//default value when it is not 1-hot will be random
		endcase
	end
endmodule