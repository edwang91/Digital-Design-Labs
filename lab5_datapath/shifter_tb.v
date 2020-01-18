//Testbench for shifter module
module shifter_tb();
	reg [15:0] sim_in;
	reg [1:0] sim_shift;
	reg err;
	wire [15:0] sim_sout;
	
	shifter DUT(
		.in(sim_in),
		.shift(sim_shift),
		.sout(sim_sout)
	);
	
	shifter test(sim_in, sim_shift, sim_sout);
	
	// Error check task for expected sout to actual sout.
	task error_check;
		input [15:0] expected_sout;
		input [15:0] actual_sout;
		
		begin
			if (shifter_tb.DUT.sout !== expected_sout) 
				err = 1'b1;
				
			$display("Expected a value of %b, actual value of %b", expected_sout, actual_sout);
		end
	endtask
	
	initial begin
		err = 1'b0;
	
		//Assign a value to in, do nothing.
		sim_in = 16'b1100100100011001;
		sim_shift = 2'b00;
		#5;
		error_check(16'b1100100100011001, sim_sout);
		
		//Assign value to in, shift right by 1 and set MSB to 0.
		sim_in = 16'b1100100100011001;
		sim_shift = 2'b10;
		#5;
		error_check(16'b0110010010001100, sim_sout);
		
		//Assign a value to in, shift right by 1 and set MSB to in[15].
		sim_in = 16'b1100100100011001;
		sim_shift = 2'b11;
		#5;
		error_check(16'b1110010010001100, sim_sout);
		
		// Shift left
		sim_in = 16'b1100100100011001;
		sim_shift = 2'b01;
		#5;
		error_check(16'b1001001000110010, sim_sout);
	end
endmodule