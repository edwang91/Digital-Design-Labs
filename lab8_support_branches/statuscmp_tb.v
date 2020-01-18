module statuscmp_tb();
	reg N, Z, V;
	reg [2:0] cond;
	wire out;
	
	statusComp DUT(.N(N), .V(V), .Z(Z), .cond(cond), .out(out));
	
	initial begin 
		Z = 1;
		cond = 3'b001;
		#10;
		cond = 3'b010;
		#10;
		Z = 0;
		#10;
		V = 1;
		cond = 3'b011;
		#10;
		
	end
endmodule