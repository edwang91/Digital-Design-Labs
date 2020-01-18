// Testbench module for regfile module.
module regfile_tb();
	reg err, sim_clk, sim_write;
	reg [15:0] sim_data_in;
	reg [2:0] sim_readnum, sim_writenum;
	wire [15:0] sim_data_out;
	
	regfile DUT(
		.data_in(sim_data_in),
		.writenum(sim_writenum),
		.write(sim_write),
		.readnum(sim_readnum),
		.clk(sim_clk),
		.data_out(sim_data_out)
	);
	
	regfile TEST(sim_data_in, sim_writenum, sim_write, sim_readnum, sim_clk, sim_data_out);
	
	// This task checks for any unexpected outputs and flags the first occurance with an error signal and 
	// signal will stay on for duration of testbench.
	task error_check;
		input [15:0] expected_out;
		input [15:0] actual_out;
		
		begin
			if (regfile_tb.DUT.data_out !== expected_out) 
				err = 1'b1;
				
			$display("Expected a value of %b, actual value of %b", expected_out, actual_out);
		end
	endtask
	
	// Keeps the clock cycles running at 5 second intervals between rising and falling edges.
	initial begin
		err = 1'b0;
	
		sim_clk = 0;
		#5;
		forever begin
			sim_clk = 1;
			#5;
			sim_clk = 0;
			#5;
		end
	end
	
	// This initial block will be the actual testing of values.
	initial begin
		
		//start by assigning values to sim_data_in, sim_write, sim_writenum, and sim_readnum.
		//Assign this number of data_in to R3 and read from R3.
		sim_data_in = 16'b1001001101100001;
		sim_write = 1'b1;
		sim_writenum = 3'b011;
		sim_readnum = 3'b011;
		#15;
		error_check(16'b1001001101100001, sim_data_out);
		
		//Assign this value of data_in to R4 and read the data stored at R3. Turn switch off. This should not change the output.
		//Clock is high.
		sim_data_in = 16'b0011111000010111;	
		sim_write = 1'b0;
		sim_writenum = 3'b100;
		sim_readnum = 3'b011;
		#5;
		error_check(16'b1001001101100001, sim_data_out);
		
		//Turn write back on. Clk is 0 again. Read from R4. Should not get any value as clk is 0 and the value
		//has not yet been written to R4.
		sim_write = 1'b1;
		sim_readnum = 3'b100;
		#5;
		error_check(16'bx, sim_data_out);
		
		//Try reading from R4 again. This time the correct value should be outputted as it is rising edge of clk
		//and so the value should have been written to R4.
		sim_readnum = 3'b100;
		#5;
		error_check(16'b0011111000010111, sim_data_out);
		
		//Clk is now 0 again. Try reading from R3 again. Read is not controlled by clk so value should be read.
		sim_readnum = 3'b011;
		#5;
		error_check(16'b1001001101100001, sim_data_out);
		
		$stop;
	end
endmodule