module tri_state_tb();
	reg [15:0] dout_sim;
	reg load_sim;
	wire [15:0] read_data_sim;
	

	
	tri_state #(16) DUT(.load(load_sim), .in(dout_sim), .out(read_data_sim));

	initial begin 
		dout_sim = 16'b1101000000000101;
		load_sim = 0;
		#10;
		load_sim = 1;
		#10;
		$stop;
	end
endmodule