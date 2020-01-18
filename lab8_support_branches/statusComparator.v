//Module compares status bits to decide what to do next. If out is 1, execute "if", otherwise go to "else"
module statusComp(N, Z, V, cond, out);
	input N, Z, V;
	input [2:0] cond;
	output out;
	
	reg out;
	
	always @* begin
		case (cond)
			3'b001: out = (Z == 1'b1) ? 1'b1 : 1'b0;
			3'b010: out = (Z == 1'b0) ? 1'b1 : 1'b0;
			3'b011: out = N ^ V ? 1'b1 : 1'b0;
			3'b100: out = (N ^ V | (Z == 1'b1)) ? 1'b1 : 1'b0;
			3'b000: out = 1'b1;			//For cond 000, don't care what status is, always set out to 1.
			default: out = 1'b0;
		endcase
	end
endmodule

			