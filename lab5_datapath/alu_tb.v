//Testbench for ALU module
module ALU_tb();
	reg err;
	reg [15:0] sim_Ain, sim_Bin;
	reg [1:0] sim_ALUop;
	wire sim_z;
	wire [15:0] sim_out;
	
	ALU DUT(
		.Ain(sim_Ain),
		.Bin(sim_Bin),
		.ALUop(sim_ALUop),
		.out(sim_out),
		.Z(sim_z)
	);
	
	ALU testing(sim_Ain, sim_Bin, sim_ALUop, sim_out, sim_z);
	
	//Task for checking for unexpected outputs.
	task error_check;
		input [15:0] expected_out;
		input expected_z;
		input [15:0] actual_out;
		input actual_z;
		
		begin
			if (ALU_tb.DUT.out !== expected_out || ALU_tb.DUT.Z !== expected_z) 
				err = 1'b1;
				
			$display("Expected a value of %b for out and %b for z, actual value of %b out and %b for z", expected_out, expected_z, actual_out, actual_z);
		end
	endtask
	
	initial begin
		err = 1'b0;
	
		// Try adding the values.
		sim_Ain = 16'b0001100110010011;
		sim_Bin = 16'b1000010001101100;
		sim_ALUop = 2'b00;
		#5;
		error_check(16'b1001110111111111, 1'b0, sim_out, sim_z);
		
		// Try subtracting values.
		sim_Ain = 16'b1000001001100101;
		sim_Bin = 16'b1000001000100001;
		sim_ALUop = 2'b01;
		#5;
		error_check(16'b0000000001000100, 1'b0, sim_out, sim_z);
		
		// Try ANDing the values.
		sim_Ain = 16'b1000001001100101;
		sim_Bin = 16'b1000001000100001;
		sim_ALUop = 2'b10;
		#5;
		error_check(16'b1000001000100001, 1'b0, sim_out, sim_z);
		
		// Try NOTing the Bin value.
		sim_Bin = 16'b0001100110010011;
		sim_Ain = 16'b1000001000100001;
		sim_ALUop = 2'b11;
		#5;
		error_check(16'b1110011001101100, 1'b0, sim_out, sim_z);
		
		// Testing z signal
		sim_Ain = 16'b0001100110010011;
		sim_Bin = 16'b0001100110010011;
		sim_ALUop = 2'b01;
		#5;
		error_check(16'b0, 1'b1, sim_out, sim_z);
		
		// Testing addition of 2 big values
		sim_Ain = 16'b1000000000000000;
		sim_Bin = 16'b1000000000000000;
		sim_ALUop = 2'b00;
		#5;
		error_check(16'b0, 1'b1, sim_out, sim_z);
		
		// Try resulting negative values.
		sim_Ain = 16'b0000000000000010;
		sim_Bin = 16'b0000000000000100;
		sim_ALUop = 2'b01;
		#5;
		error_check(16'b1111111111111110, 1'b0, sim_out, sim_z);
		
	end
	
	
endmodule