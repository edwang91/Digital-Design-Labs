//This module is for the tri-state driver.
//Code from slide 45 of slideset 8
module tri_state(load, in, out);
	parameter n = 16;
	input load;
	input [n-1:0] in;
	output [n-1:0] out;
	wire [n-1:0] out;
	// If load is 1, continue driving the signal, else disconnect the wire.
	assign out = load ? in : 1'bz;
	
endmodule