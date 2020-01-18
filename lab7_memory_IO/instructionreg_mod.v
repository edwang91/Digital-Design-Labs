module load_enable_reg(clk, in, load, to_dec);
	parameter n = 16;
	input clk, load;
	input [n-1:0] in;
	output [n-1:0] to_dec;
	
	wire [n-1:0] next_to_dec;
	reg [n-1:0] to_dec;
	
	//Load the input as the next value to send to decoder if load is 1.
	assign next_to_dec = load ? in : to_dec;
	
	//Update the output on rising edge of clk.
	always @(posedge clk) begin
		to_dec = next_to_dec;
	end
endmodule