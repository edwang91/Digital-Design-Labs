module load_enable_reg(clk, in, load, out);
	parameter n = 16;
	input clk, load;
	input [n-1:0] in;
	output [n-1:0] out;
	
	wire [n-1:0] next_out;
	wire [n-1:0] out;
	
	//Load the input as the next value to send to decoder if load is 1.
	assign next_out = load ? in : out;
	
	//Update the output on rising edge of clk.
	vDFF #(n) inState(clk, next_out, out);
	
endmodule