module cpu_tb();

     reg clk_sim, reset_sim, s_sim, load_sim, err;
     reg [15:0] in_sim;
     wire [15:0] out_sim;
     wire N_sim, V_sim, Z_sim, w_sim;
	 
	 cpu DUT(.clk(clk_sim), .reset(reset_sim), .s(s_sim), .load(load_sim), .in(in_sim), .out(out_sim), .N(N_sim), .V(V_sim), .Z(Z_sim), .w(w_sim));
    
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
	
		load_sim = 0;
		s_sim = 0;
		reset_sim = 1;

	
	#10;							//rising at 5

		s_sim = 0;
		
		//First test the outputs for ADD - ADD R2, R1, R0 (Positive Case). Testing for state transition from loada to loadb
		$display("First MOV Rd, Rm");

		#10;							//rising at 15. Go to wait.
		reset_sim = 0;
		in_sim = 16'b1101000000000111;			//last 8 bits representing 7.
		load_sim = 1;
		#10;							//rising at 25
		load_sim = 0;
		s_sim = 1;					
		#10; 							//rising at 35. go to decode
		s_sim = 0;
		#10;							//rising at 45. go to write
		
		#10;							//rising at 55		go back to wait
		
		//Making sure value is stored in R1.
		in_sim = 16'b1101000100000010;			//last 8 representing 2.
		load_sim = 1;
		#10;							//rising at 55.
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 65, decode
		s_sim = 0;
		#10;							//rising at 75, write.

		#10;							//rising at 85, go back to wait
		
		
		$display("Now start adding.");
		in_sim = 16'b1010000101001000;			//left shift the Rm value (R0 = 7) and add to R1 = 2 at Rn. Testing transitions from loading to A, B, and C regs.
		load_sim = 1;
		#10;							//rising at 95, 
		load_sim = 0;
		s_sim = 1;					
		#10;						//rising at 105, decode
		s_sim = 0;
		#50;						//rising at 115, load to reg A.
									//rising at 125, load to reg B.
									//rising at 135, load to reg C
									//rising at 145, write back to R2.
									//rising at 155, wait
	
		error_check({8'b0, 8'b00010000}, out_sim);
		
		$display("Now NOT R1 and store in R3");
		//Done adding and written back to R2. Check R1. Store NOT'ed value to R3. Checking general compatibility between FSM and DP
		in_sim = 16'b1011100001100001;			//NOT the original R1 value and store in R3.
		load_sim = 1;
		#10;							//rising at 165
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 175, decode
		s_sim = 0;
		#40;							//rising at 185, load to reg B. 
										//rising at 195, load result to reg C.
										//rising at 205, writeback result to R3
										//risingat 215, wait.
		error_check(16'b1111111111111101, out_sim);
		
		//Now try subtracting. Testing to make sure the loadC is not turned on. Loading to reg B should not transition to C
		$display("Now subtracting R1 value with R0 value.");
		
		in_sim = 16'b1010100100000000;			//Subtract R0 = 7 from R1 = 2
		load_sim = 1;
		#10;							//rising at 225
		load_sim = 0;				
		s_sim = 1;
		#10;							//rising at 235, decode
		s_sim = 0;
		#40;							//rising at 245, read to Reg A
										//rising at 255, read to Reg B
										//rising at 265, pass to status reg
										//rising at 275, wait
		status_check(3'b100, {N_sim, V_sim, Z_sim});
		
		$display("Copy result of addition in R2 to R4 left shifted.");
		in_sim = 16'b1100000010001010;				//Copy R2 = 16 to R4.
		load_sim = 1;
		#10;							//rising at 285
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 295, decode
		s_sim = 0;
		#40;							//rising at 305, read R2 value to reg B, set asel to 1.
										//rising at 315, add 0 to value and pass to reg C.
										//Rising at 325, writeback to R4
										//Rising at 335, wait.
		error_check({8'b0, 8'b00100000}, out_sim);
		
		$display("AND the copied R4 value and the original R2 value. Store in R5");
		in_sim = 16'b1011001010100100;
		load_sim = 1;
		#10;							//Rising at 345
		load_sim = 0;
		s_sim = 1;
		#10;							//Rising at 355, decode
		s_sim = 0;
		#50;							//Rising at 365, read R2 value to reg A.
										//rising at 375, read R4 value to reg B.
										//rising at 385, perform AND and pass to reg C.
										//rising at 395, writeback to R5.
										//rising at 405, wait.
		error_check({8'b0, 8'b00000000}, out_sim);
	
		//SECOND TEST: try overwriting values.
		$display("Over writing R0.");
		in_sim = 16'b1101000001111111;		//store some huge number in R0 replacing 7.
		load_sim = 1;
		#10;							//rising at 415.
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 425, decode
		s_sim = 0;
		#20;							//rising at 435, write value to R0.
										//rising at 445, wait.
		$display("Subtracting R0 from R1.");
		in_sim = 16'b1010100100000000;
		load_sim = 1;
		#10;							//rising at 455
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 465, decode
		s_sim = 0;
		#40;							//rising 475, Move R1 value to reg A
										//rising 485, move R0 value to reg B
										//rising 495, perform subtraction and update status reg.
										//rising 505, wait.
		status_check(3'b100, {N_sim, V_sim, Z_sim});
		
		//Testing if FSM distinguishes between subtraction and adding negatives
		$display("Time to add negative numbers. ALU is not 01 so should still output an answer.");
		//Add a negative number.
		in_sim = 16'b1101000010001000;			//-8 stored in R0
		load_sim = 1;
		#10;						//rising at 515
		load_sim = 0;
		s_sim = 1;
		#10;						//rising at 525, decode
		s_sim = 0;
		#20;						//rising at 535, write value to R0.
									//rising at 545, wait.
		
		//Add this negative 8 to the first add result, 16 in R2.
		in_sim = 16'b1010000010000010;			//store result in R4, overwriting the copied R2 value.
		load_sim = 1;							
		#10;						//rising edge at 555
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 565, decode
		s_sim = 0;
		#50;						//rising edge at 575, store R0 value in reg A
									//rising edge at 585, store R1 value in reg B
									//rising edge at 595, perform add, store result in reg C
									//rising edge at 605, writeback result to R4.
									//rising edge at 615, wait.
		error_check(16'b1111111110011000, out_sim);
		
		$display("Resetting");
		
		//Testing state transitions between decode to write and decode to storing in pipelines
		reset_sim = 1;
		#10;						//rising edge at 625
		reset_sim = 0;
		in_sim = 16'b1101000001000000;		//set R0 to 64
		load_sim = 1;
		#10;						//rising edge at 635
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 645, decode
		s_sim = 0;				
		#20;						//rising edge at 655, write to R0.
									//rising edge at 665, wait.
		//Now copy this value to R1 and AND it with R0 to confirm copy.
		in_sim = 16'b1100000000100000;
		load_sim = 1;
		#10;						//rising edge at 675
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 685, decode
		s_sim = 0;
		#40;						//rising edge at 695, pass value in R0 to reg B, setting asel = 1.
									//rising edge at 705, pass added to 0 result to reg C.
									//rising edge at 715, writeback to R1.
									//rising edget at 725, wait.
		error_check({8'b0, 8'b01000000}, out_sim);
		
		//ANDing
		in_sim = 16'b1011000001000001;			//store result in R2.
		load_sim = 1;
		#10;						//rising edge at 735
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 745, decode
		s_sim = 0;
		#50;						//rising edge at 755, R0 value to reg A.
									//rising edge at 765, R1 value to reg B.
									//rising edge at 775, result to reg C.
									//rising edge at 785, writeback to R2.
		error_check({8'b0, 8'b01000000}, out_sim);
		
		//Next, subtract R2 value with R0 value and update status.
		in_sim = 16'b1010100000000010;
		load_sim = 1;
		#10;						//rising edge at 795
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 805, decode
		s_sim = 0;
		#40;						//rising edge at 815, read R0 value to reg A
									//rising edge at 825, read R2 value to reg B
									//rising edge at 835, update status reg.
									//rising edge at 845, wait.
		status_check(3'b001, {N_sim, V_sim, Z_sim});
		
		//Changing a negative number to a positive
		in_sim = 16'b1101011010000111;		//store -7 in R6
		load_sim = 1;
		#10;						//rising edge at 855
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 865, decode
		s_sim = 0;
		#20;						//rising edge at 875, write to R6
									//rising edge at 885, wait
		
		in_sim = 16'b1011100011101110;		//NOT the value at R6 and store in R7
		load_sim = 1;
		#10;						//rising edge at 895
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 905, decode
		s_sim = 0;
		#40;						//rising edge at 915, store R6 value in reg B
									//rising edge at 925, NOT value and pass to reg C
									//rising edge at 935, writeback to R7
									//Rising edge at 945, wait.
		error_check({8'b0, 8'b11110001}, out_sim);
		
	 

	


		load_sim = 0;
		s_sim = 0;
		reset_sim = 1;

	
	#10;							//rising at 5

		s_sim = 0;
		
		//First test the outputs for ADD - ADD R2, R1, R0 (Positive Case). Testing for state transition from loada to loadb
		$display("First MOV Rd, Rm");

		#10;							//rising at 15. Go to wait.
		reset_sim = 0;
		in_sim = 16'b1101000000000111;			//last 8 bits representing 7.
		load_sim = 1;
		#10;							//rising at 25
		load_sim = 0;
		s_sim = 1;					
		#10; 							//rising at 35. go to decode
		s_sim = 0;
		#10;							//rising at 45. go to write
		
		#10;							//rising at 55		go back to wait
		
		//Making sure value is stored in R1.
		in_sim = 16'b1101000100000010;			//last 8 representing 2.
		load_sim = 1;
		#10;							//rising at 55.
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 65, decode
		s_sim = 0;
		#10;							//rising at 75, write.

		#10;							//rising at 85, go back to wait
		
		
		$display("Now start adding.");
		in_sim = 16'b1010000101001000;			//left shift the Rm value (R0 = 7) and add to R1 = 2 at Rn. Testing transitions from loading to A, B, and C regs.
		load_sim = 1;
		#10;							//rising at 95, 
		load_sim = 0;
		s_sim = 1;					
		#10;						//rising at 105, decode
		s_sim = 0;
		#50;						//rising at 115, load to reg A.
									//rising at 125, load to reg B.
									//rising at 135, load to reg C
									//rising at 145, write back to R2.
									//rising at 155, wait
	
		error_check({8'b0, 8'b00010000}, out_sim);
		
		$display("Now NOT R1 and store in R3");
		//Done adding and written back to R2. Check R1. Store NOT'ed value to R3. Checking general compatibility between FSM and DP
		in_sim = 16'b1011100001100001;			//NOT the original R1 value and store in R3.
		load_sim = 1;
		#10;							//rising at 165
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 175, decode
		s_sim = 0;
		#40;							//rising at 185, load to reg B. 
										//rising at 195, load result to reg C.
										//rising at 205, writeback result to R3
										//risingat 215, wait.
		error_check(16'b1111111111111101, out_sim);
		
		//Now try subtracting. Testing to make sure the loadC is not turned on. Loading to reg B should not transition to C
		$display("Now subtracting R1 value with R0 value.");
		
		in_sim = 16'b1010100100000000;			//Subtract R0 = 7 from R1 = 2
		load_sim = 1;
		#10;							//rising at 225
		load_sim = 0;				
		s_sim = 1;
		#10;							//rising at 235, decode
		s_sim = 0;
		#40;							//rising at 245, read to Reg A
										//rising at 255, read to Reg B
										//rising at 265, pass to status reg
										//rising at 275, wait
		status_check(3'b100, {N_sim, V_sim, Z_sim});
		
		$display("Copy result of addition in R2 to R4 left shifted by 1.");
		in_sim = 16'b1100000010000010;				//Copy R2 = 16 to R4.
		load_sim = 1;
		#10;							//rising at 285
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 295, decode
		s_sim = 0;
		#40;							//rising at 305, read R2 value to reg B, set asel to 1.
										//rising at 315, add 0 to value and pass to reg C.
										//Rising at 325, writeback to R4
										//Rising at 335, wait.
		error_check({8'b0, 8'b00010000}, out_sim);
		
		$display("AND the copied R4 value and the original R2 value. Store in R5");
		in_sim = 16'b1011001010100100;
		load_sim = 1;
		#10;							//Rising at 345
		load_sim = 0;
		s_sim = 1;
		#10;							//Rising at 355, decode
		s_sim = 0;
		#50;							//Rising at 365, read R2 value to reg A.
										//rising at 375, read R4 value to reg B.
										//rising at 385, perform AND and pass to reg C.
										//rising at 395, writeback to R5.
										//rising at 405, wait.
		error_check({8'b0, 8'b00010000}, out_sim);
	
		//SECOND TEST: try overwriting values.
		$display("Over writing R0.");
		in_sim = 16'b1101000001111111;		//store some huge number in R0 replacing 7.
		load_sim = 1;
		#10;							//rising at 415.
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 425, decode
		s_sim = 0;
		#20;							//rising at 435, write value to R0.
										//rising at 445, wait.
		$display("Subtracting R0 from R1.");
		in_sim = 16'b1010100100000000;
		load_sim = 1;
		#10;							//rising at 455
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 465, decode
		s_sim = 0;
		#40;							//rising 475, Move R1 value to reg A
										//rising 485, move R0 value to reg B
										//rising 495, perform subtraction and update status reg.
										//rising 505, wait.
		status_check(3'b100, {N_sim, V_sim, Z_sim});
		
		//Testing if FSM distinguishes between subtraction and adding negatives
		$display("Time to add negative numbers. ALU is not 01 so should still output an answer.");
		//Add a negative number.
		in_sim = 16'b1101000010001000;			//-8
		load_sim = 1;
		#10;						//rising at 515
		load_sim = 0;
		s_sim = 1;
		#10;						//rising at 525, decode
		s_sim = 0;
		#20;						//rising at 535, write value to R0.
									//rising at 545, wait.
		
		//Add this negative 8 to the first add result, 4 in R2.
		in_sim = 16'b1010000010000010;			//store result in R4, overwriting the copied R2 value.
		load_sim = 1;							
		#10;						//rising edge at 555
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 565, decode
		s_sim = 0;
		#50;						//rising edge at 575, store R0 value in reg A
									//rising edge at 585, store R1 value in reg B
									//rising edge at 595, perform add, store result in reg C
									//rising edge at 605, writeback result to R4.
									//rising edge at 615, wait.
		error_check(16'b1111111110011000, out_sim);
		
		$display("Resetting");
		
		//Testing state transitions between decode to write and decode to storing in pipelines
		reset_sim = 1;
		#10;						//rising edge at 625
		reset_sim = 0;
		in_sim = 16'b1101000001000000;		//set R0 to 64
		load_sim = 1;
		#10;						//rising edge at 635
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 645, decode
		s_sim = 0;				
		#20;						//rising edge at 655, write to R0.
									//rising edge at 665, wait.
		//Now copy this value to R1 and AND it with R0 to confirm copy.
		in_sim = 16'b1100000000100000;
		load_sim = 1;
		#10;						//rising edge at 675
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 685, decode
		s_sim = 0;
		#40;						//rising edge at 695, pass value in R0 to reg B, setting asel = 1.
									//rising edge at 705, pass added to 0 result to reg C.
									//rising edge at 715, writeback to R1.
									//rising edget at 725, wait.
		error_check({8'b0, 8'b01000000}, out_sim);
		
		//ANDing
		in_sim = 16'b1011000001000001;			//store result in R2.
		load_sim = 1;
		#10;						//rising edge at 735
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 745, decode
		s_sim = 0;
		#50;						//rising edge at 755, R0 value to reg A.
									//rising edge at 765, R1 value to reg B.
									//rising edge at 775, result to reg C.
									//rising edge at 785, writeback to R2.
		error_check({8'b0, 8'b01000000}, out_sim);
		
		//Next, subtract R2 value with R0 value and update status.
		in_sim = 16'b1010100000000010;
		load_sim = 1;
		#10;						//rising edge at 795
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 805, decode
		s_sim = 0;
		#40;						//rising edge at 815, read R0 value to reg A
									//rising edge at 825, read R2 value to reg B
									//rising edge at 835, update status reg.
									//rising edge at 845, wait.
		status_check(3'b001, {N_sim, V_sim, Z_sim});
		
		//Changing a negative number to a positive
		in_sim = 16'b1101011010000111;		//store -7 in R6
		load_sim = 1;
		#10;						//rising edge at 855
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 865, decode
		s_sim = 0;
		#20;						//rising edge at 875, write to R6
									//rising edge at 885, wait
		
		in_sim = 16'b1011100011101110;		//NOT the value at R6 and store in R7
		load_sim = 1;
		#10;						//rising edge at 895
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 905, decode
		s_sim = 0;
		#40;						//rising edge at 915, store R6 value in reg B
									//rising edge at 925, NOT value and pass to reg C
									//rising edge at 935, writeback to R7
									//Rising edge at 945, wait.
		error_check({8'b0, 8'b11110001}, out_sim);
		
		
		$display("Resetting");
		
		reset_sim = 1;
		#10;						//rising edge at 955
		reset_sim = 0;
		
		
		//to do:
		//try ADD - 0 case (add 0 + 0 so Z bit should be 1)
		#10;							//rising at 965. Go to wait.
		reset_sim = 0;
		in_sim = 16'b1101000000000000;			//last 8 bits representing 0.
		load_sim = 1;
		#10;							//rising at 975
		load_sim = 0;
		s_sim = 1;					
		#10; 							//rising at 985. go to decode
		s_sim = 0;
		#10;							//rising at 995. go to write
		
		#10;							//rising at 1005		go back to wait
		
		//Making sure value is stored in R1.
		in_sim = 16'b1101000100000000;			//last 8 representing 0.
		load_sim = 1;
		#10;							//rising at 1015.
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 1025, decode
		s_sim = 0;
		#10;							//rising at 1035, write.

		#10;							//rising at 1045, go back to wait
		
		$display("Now start adding.");
		in_sim = 16'b1010000101000000;	 //R0 added to R1 = 0 at Rn. Testing
		load_sim = 1;
		#10;							//rising at 1055, 
		load_sim = 0;
		s_sim = 1;					
		#10;						//rising at 1065, decode
		s_sim = 0;
		#50;						//rising at 1075, load to reg A.
									//rising at 1085, load to reg B.
									//rising at 1095, load to reg C
									//rising at 1105, write back to R2.
									//rising at 1115, wait
		status_check(3'b001, {N_sim, V_sim, Z_sim});
		error_check(16'b0, out_sim);
		
		//try MVN - all 0 case
		in_sim = 16'b1011100001100010;			//NOT the original R2 value and store in R3.
		load_sim = 1;
		#10;							//rising at 1125
		load_sim = 0;
		s_sim = 1;
		#10;							//rising at 1135, decode
		s_sim = 0;
		#40;							//rising at 1145, load to reg B. 
										//rising at 1155, load result to reg C.
										//rising at 1165, writeback result to R3
										//risingat 1175, wait.
		error_check(16'b1111111111111111, out_sim);
		
		//try MOV Rd, Rm - copy this value back to R1, also shifting it right setting in[15] to 0
		in_sim = 16'b1100000000110010;
		load_sim = 1;
		#10;						//rising edge at 1185
		load_sim = 0;
		s_sim = 1;
		#10;						//rising edge at 1195, decode
		s_sim = 0;
		#40;						//rising edge at 1205, pass value in R0 to reg B, setting asel = 1.
									//rising edge at 1215, pass added to 0 result to reg C.
									//rising edge at 1225, writeback to R1.
									//rising edget at 1235, wait.
		error_check(16'b0, out_sim);
		
		//try ANd with all 0 (R1)
		in_sim = 16'b1011000010100001;
		load_sim = 1;
		#10;							//Rising at 1245
		load_sim = 0;
		s_sim = 1;
		#10;							//Rising at 1255, decode
		s_sim = 0;
		#50;							//Rising at 1265, read R2 value to reg A.
										//rising at 1275, read R4 value to reg B.
										//rising at 1285, perform AND and pass to reg C.
										//rising at 1295, writeback to R5.
										//rising at 1305, wait.
		error_check(16'b0000000000000000, out_sim);
		
		$stop;
	end 
endmodule