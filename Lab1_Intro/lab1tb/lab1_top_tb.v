//All code from lab 1 pdf document.
module lab1_top_tb ();
	reg sim_LEFT_button;
	reg sim_RIGHT_button;
	reg [3:0] sim_A;
	reg [3:0] sim_B;
	wire [3:0] sim_result;
	
	// Connecting workbench signals to wires declared in lab1_top.
	lab1_top DUT (
		.not_LEFT_pushbutton(~sim_LEFT_button),
		.not_RIGHT_pushbutton(~sim_RIGHT_button),
		.A(sim_A),
		.B(sim_B),
		.result(sim_result)
	);
	
	initial begin
		
		//start by setting buttons to not pushed
		sim_LEFT_button = 1'b0;
		sim_RIGHT_button = 1'b0;
		
		//set both inputs to 0
		sim_A = 4'b0;
		sim_B = 4'b0;
		
		//wait 5 timesteps
		#5;
		
		//First try ANDing
		sim_LEFT_button = 1'b1;
		sim_A = 4'b1100;
		sim_B = 4'b1010;
		
		#5;
		
		//print values to modelsim command line
		$display("Output is %b, we expected %b", sim_result, (4'b1100 & 4'b1010));
		
		//try adding
		sim_LEFT_button = 1'b0;
		sim_RIGHT_button = 1'b1;
		sim_A = 4'b1100;
		sim_B = 4'b1010;
		#5;
		
		$display("Output is %b, we expected %b", sim_result, (4'b1100 + 4'b1010));
		
		//changing inputs
		sim_A = 4'b0001;
		sim_B = 4'b0011;
		#5;
		
		$display("Output is %b, we expected %b", sim_result, (4'b0001 + 4'b0011));
		
		//Go back to ANDing 
		sim_LEFT_button = 1'b1;
		sim_RIGHT_button = 1'b0;
		#5;
		
		$display("Output is %b, we expected %b", sim_result, (4'b0001 & 4'b0011));
		
		$stop;
	end
endmodule