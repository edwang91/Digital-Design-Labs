module cpu_tb();

     reg clk_sim, reset_sim, err;
     reg [15:0] in_sim;
     wire [15:0] out_sim;
	 wire [8:0] mem_addr_sim;
	 wire [1:0] sim_mem_cmd;
     wire N_sim, V_sim, Z_sim;
	 
	 cpu DUT(.clk(clk_sim), .reset(reset_sim), .in(in_sim), .out(out_sim), .N(N_sim), .V(V_sim), .Z(Z_sim), .mem_addr(mem_addr_sim), .mem_cmd(sim_mem_cmd));
    
	 task error_check;
		input [15:0] expected_outputs;
		input [15:0] actual_outputs;
		
		begin 
			if (expected_outputs !== actual_outputs)
				err = 1'b1;
			$display("The output should be %b, and it was %b", expected_outputs, actual_outputs);
		end
	 endtask
	 
	 //task for status checking
	 task status_check;
		input [2:0] expected_status;
		input [2:0] actual_status;
		
		begin
			if (expected_status !== actual_status)
				err = 1'b1;
			$display("The output should be %b, and it was %b", expected_status, actual_status);
		end
	endtask
	 
	 //Begin clock cycles. 
	initial begin
		err = 1'b0;
	
		clk_sim = 0;
		#5;
		forever begin
			clk_sim = 1;
			#5;
			clk_sim = 0;
			#5;
		end
	end
	
	//Tests performed here.
	initial begin
	
		reset_sim = 1;
	
	#10;								//rising at 5
		
		//First test the outputs for ADD - ADD R2, R1, R0 (Positive Case). Testing for state transition from loada to loadb
		$display("First MOV Rd, Rm");
		reset_sim = 0;
		#10;							//rising at 15, in IF1.
		in_sim = 16'b1101000000000111;	//last 8 bits representing 7.
		#10;							//rising at 25, in IF2,										
		#10;							//rising at 35. in UPDATE
		#10;							//rising at 45		in decode
		#10;							//writing
		#10;							//go back to IF1.
		
		//Making sure value is stored in R1
		in_sim = 16'b1101000100000010;	//last 8 representing 2. in IF1 still.
		#10;							//rising at 55, go to IF2, 
		#10;							//rising at 75, UPDATE.
		#10;							//rising at 85, decode.
		#10;							//go to write.
		#10;							//go back to IF1.
		
		
		$display("Now start adding.");
		in_sim = 16'b1010000101001000;			//left shift the Rm value (R0 = 7) and add to R1 = 2 at Rn. Testing transitions from loading to A, B, and C reg
		#10;							//rising at 95, go to IF2
		#10;							//go to UPDATE
		#10;						//rising at 105, decode
		#50;						//rising at 115, load to reg A.
									//rising at 125, load to reg B.
									//rising at 135, load to reg C
									//rising at 145, write back to R2.
									//rising at 155, go back to IF1
	
		error_check({8'b0, 8'b00010000}, out_sim);
		
				$display("Now NOT R1 and store in R3");
		//Done adding and written back to R2. Check R1. Store NOT'ed value to R3. Checking general compatibility between FSM and DP
		in_sim = 16'b1011100001100001;			//NOT the original R1 value and store in R3.
		#10;							//rising at 165
		#10;							//rising at 175, decode
		#10;							//rising at 185
		#50;							//rising at 195, load to reg B. 
										//rising at 205, load result to reg C.
										//rising at 215, writeback result to R3
										//rising at 225, wait.
										//rising at 235
		error_check(16'b1111111111111101, out_sim);
		
		//Now try subtracting. Testing to make sure the loadC is not turned on. Loading to reg B should not transition to C
		$display("Now subtracting R1 value with R0 value.");
		
		in_sim = 16'b1010100100000000;			//Subtract R0 = 7 from R1 = 2
		#10;							//rising at 245
		#10;							//rising at 255, decode
		#10;							//rising at 265
		#50;							//rising at 275, read to Reg A
										//rising at 285, read to Reg B
										//rising at 295, pass to status reg
										//rising at 305, wait
										//rising at 315
		status_check(3'b100, {N_sim, V_sim, Z_sim});
		
		$display("Copy result of addition in R2 to R4 left shifted by 1.");
		in_sim = 16'b1100000010001010;				//Copy R2 = 16 to R4.
		#10;							//rising at 325
		#10;							//rising at 335, decode
		#10;							//rising at 345, read R2 value to reg B, set asel to 1.
		#50;							//rising at 355, add 0 to value and pass to reg C.
										//Rising at 365, writeback to R4
										//Rising at 375, wait.
										//Rising at 385
										//Rising at 395
		
		$display("AND the copied R4 value and the original R2 value. Store in R5");
		in_sim = 16'b1011001010100100;
		#10;							//Rising at 345
		#10;							//Rising at 355, decode
		#50;							//Rising at 365, read R2 value to reg A.
										//rising at 375, read R4 value to reg B.
										//rising at 385, perform AND and pass to reg C.
										//rising at 395, writeback to R5.
										//rising at 405, wait.
		error_check({8'b0, 8'b00100000}, out_sim);
	
		//SECOND TEST: try overwriting values.
		$display("Over writing R0.");
		in_sim = 16'b1101000001111111;		//store some huge number in R0 replacing 7.
		#10;							//rising at 415, in IF2,										
		#10;							//rising at 425. in UPDATE
		#10;							//rising at 435	in decode
		#10;							//writing
		#10;							//go back to IF1.
		
		$display("Subtracting R0 from R1.");
		in_sim = 16'b1010100100000000;
		#10;							//rising at 465
		#10;							//rising at 375, decode
		#10;							//rising at 385, read R2 value to reg B, set asel to 1.
		#50;							//rising at 395, add 0 to value and pass to reg C.
										//Rising at 405, writeback to R4
										//Rising at 415, wait.
										//Rising at 425
										//Rising at 435
		status_check(3'b100, {N_sim, V_sim, Z_sim});
		
		//Testing if FSM distinguishes between subtraction and adding negatives
		$display("Time to add negative numbers. ALU is not 01 so should still output an answer.");
		//Add a negative number.
		in_sim = 16'b1101000010001000;			//-8
		#10;							//rising at 445, in IF2,										
		#10;							//rising at 455. in UPDATE
		#10;							//rising at 465	in decode
		#10;							//writing
		#10;							//go back to IF1.
		
		//Add this negative 8 to the first add result, 4 in R2.
		in_sim = 16'b1010000010000010;			//store result in R4, overwriting the copied R2 value.
		#10;							//rising at 495
		#10;							//rising at 505, decode
		#10;							//rising at 515, read R2 value to reg B, set asel to 1.
		#50;							//rising at 525, add 0 to value and pass to reg C.
										//Rising at 535, writeback to R4
										//Rising at 545, wait.
										//Rising at 555
										//Rising at 565
		error_check(16'b1111111110011000, out_sim);
		
		$display("Resetting");
		
		reset_sim = 1;
		#10;						//rising edge at 575
		reset_sim = 0;
		
		//Testing state transitions between decode to write and decode to storing in pipelines
		in_sim = 16'b1101000001000000;		//set R0 to 64
		#10;							//rising at 585, in IF2,										
		#10;							//rising at 595. in UPDATE
		#10;							//rising at 605	in decode
		#10;							//writing
		#10;							//go back to IF1.
		
		//Now copy this value to R1 and AND it with R0 to confirm copy.
		in_sim = 16'b1100000000100000;
		#10;							//rising at 635
		#10;							//rising at 645, decode
		#10;							//rising at 655, read R2 value to reg B, set asel to 1.
		#50;							//rising at 665, add 0 to value and pass to reg C.
										//Rising at 675, writeback to R4
										//Rising at 685, wait.
										//Rising at 695
										//Rising at 705
		error_check({8'b0, 8'b01000000}, out_sim);
		
		//ANDing
		in_sim = 16'b1011000001000001;			//store result in R2.
		#10;							//rising at 715
		#10;							//rising at 725, decode
		#10;							//rising at 735, read R2 value to reg B, set asel to 1.
		#50;							//rising at 745, add 0 to value and pass to reg C.
										//Rising at 755, writeback to R4
										//Rising at 765, wait.
										//Rising at 775
										//Rising at 785
		error_check({8'b0, 8'b01000000}, out_sim);
		
		//Next, subtract R2 value with R0 value and update status.
		in_sim = 16'b1010100000000010;
		#10;							//rising at 795
		#10;							//rising at 805, decode
		#10;							//rising at 815, read R2 value to reg B, set asel to 1.
		#50;							//rising at 825, add 0 to value and pass to reg C.
										//Rising at 835, writeback to R4
										//Rising at 845, wait.
										//Rising at 855
										//Rising at 865
		status_check(3'b001, {N_sim, V_sim, Z_sim});
		
		//Changing a negative number to a positive
		in_sim = 16'b1101011010000111;		//store -7 in R6
		#10;							//rising at 875, in IF2,										
		#10;							//rising at 885. in UPDATE
		#10;							//rising at 895	in decode
		#10;							//writing
		#10;							//go back to IF1.
		
		in_sim = 16'b1011100011101110;		//NOT the value at R6 and store in R7
		#10;							//rising at 925
		#10;							//rising at 935, decode
		#10;							//rising at 945, read R2 value to reg B, set asel to 1.
		#50;							//rising at 955, add 0 to value and pass to reg C.
										//Rising at 965, writeback to R4
										//Rising at 975, wait.
										//Rising at 985
										//Rising at 995
		error_check({8'b0, 8'b11110001}, out_sim);
		
		
		$display("Resetting");
		
		reset_sim = 1;
		#10;						//rising edge at 955
		reset_sim = 0;
		
		//to do:
		//try ADD - 0 case (add 0 + 0 so Z bit should be 1)
		in_sim = 16'b1101000000000000;			//last 8 bits representing 0.
		#10;							//rising at 1005, in IF2,										
		#10;							//rising at 1015. in UPDATE
		#10;							//rising at 1025 in decode
		#10;							//writing
		#10;							//go back to IF1.
		
		
		//Making sure value is stored in R1.
		in_sim = 16'b1101000100000000;			//last 8 representing 0.
		#10;							//rising at 1055, in IF2,										
		#10;							//rising at 1065. in UPDATE
		#10;							//rising at 1075 in decode
		#10;							//writing
		#10;							//go back to IF1.
		
		$display("Now start adding.");
		in_sim = 16'b1010000101000000;	 //R0 added to R1 = 0 at Rn. Testing
		#10;							//rising at 1105
		#10;							//rising at 1115, decode
		#10;							//rising at 1125, read R2 value to reg B, set asel to 1.
		#50;							//rising at 1135, add 0 to value and pass to reg C.
										//Rising at 1145, writeback to R4
										//Rising at 1155, wait.
										//Rising at 1165
										//Rising at 1175
		status_check(3'b001, {N_sim, V_sim, Z_sim});
		error_check(16'b0, out_sim);
		
		//try MVN - all 0 case
		in_sim = 16'b1011100001100010;			//NOT the original R2 value and store in R3.
		#10;							//rising at 1185
		#10;							//rising at 1195, decode
		#10;							//rising at 1205, read R2 value to reg B, set asel to 1.
		#50;							//rising at 1215, add 0 to value and pass to reg C.
										//Rising at 1225, writeback to R4
										//Rising at 1235, wait.
										//Rising at 1245
										//Rising at 1255
		error_check(16'b1111111111111111, out_sim);
		
		//try MOV R1, R2 - copy this value back to R1, also shifting it right setting in[15] to 0
		in_sim = 16'b1100000000110010;
		#10;							//rising at 1265
		#10;							//rising at 1275, decode
		#10;							//rising at 1285, read R2 value to reg B, set asel to 1.
		#50;							//rising at 1295, add 0 to value and pass to reg C.
										//Rising at 1305, writeback to R4
										//Rising at 1315, wait.
										//Rising at 1325
										//Rising at 1335
		error_check(16'b0, out_sim);
		
		//try ANd with all 0 (R1)
		in_sim = 16'b1011000010100001;
		#10;							//rising at 1345
		#10;							//rising at 1355, decode
		#10;							//rising at 1365, read R2 value to reg B, set asel to 1.
		#50;							//rising at 1375, add 0 to value and pass to reg C.
										//Rising at 1385, writeback to R4
										//Rising at 1395, wait.
										//Rising at 1405
										//Rising at 1415
		error_check(16'b0, out_sim);
		
		$stop;
	end 
endmodule