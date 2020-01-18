//Testbench module for datapath.
module datapath_tb();
//input output declarations
	reg sim_clk, sim_loada, sim_loadb, sim_asel, sim_bsel, sim_loadc, sim_loads, sim_write;
	reg [2:0] sim_readnum, sim_writenum;
	reg [3:0] sim_vsel;
	reg [1:0] sim_shift, sim_ALUop;
	reg [15:0] sim_mdata, sim_sximm8, sim_sximm5;
	reg [7:0] sim_PC;
	reg err;
	wire [2:0] sim_statusOut;
	wire [15:0] sim_datapath_out;
	
	datapath DUT(
		.clk(sim_clk),
		.readnum(sim_readnum),
		.vsel(sim_vsel),
		.loada(sim_loada),
		.loadb(sim_loadb),
		.shift(sim_shift),
		.asel(sim_asel),
		.bsel(sim_bsel),
		.ALUop(sim_ALUop),
		.loadc(sim_loadc),
		.loads(sim_loads),
		.writenum(sim_writenum),
		.write(sim_write),
		.mdata(sim_mdata),
		.sximm8(sim_sximm8),
		.sximm5(sim_sximm5),
		.PC(sim_PC),
		.statusOut(sim_statusOut),
		.datapath_out(sim_datapath_out)
	);
	
	//Task for error checks
	task error_check;
		input [15:0] expected_datapath_out;
		input [15:0] actual_datapath_out;
		
		begin 
			if (datapath_tb.DUT.datapath_out !== expected_datapath_out)
				err = 1'b1;
				$display("The output was %b. Expected %b.", actual_datapath_out, expected_datapath_out);
			end
	endtask
	
	//Task for checking errors in status registers.
	task status_errorcheck;
		input [2:0] expected_status;
		input [2:0] actual_status;
		
		begin
			if (datapath_tb.DUT.statusOut !== expected_status)
				err = 1'b1;
				$display("The output was %b. Expected %b.", actual_status, expected_status);
		end
	endtask
	
	//Clk cycle loop
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
	
	//Testing
	initial begin
		//FIRST TEST: take value of 7 and store in R0, take value of 2 and store in R1.
		//Add value in R1 (2) to the value in R0 shifted left by 1 bit (14) and store the sum
		//in R2. ie. 2 + 14 = 16
		
		//set everything to off. Avoid inferred latches
		sim_loada = 0;
		sim_loadb = 0;
		sim_asel = 0;
		sim_bsel = 0;
		sim_loadc = 0;
		sim_loads = 0;
		sim_shift = 0;
		sim_ALUop = 2'b00;
		sim_readnum = 3'b000;			//defaults representing switches in off position
		
		//Get the writeback MUX to take input value from sign-extended value, not writeback value.
		sim_vsel = 4'b0100;
		
		//Datapath in is 7.
		sim_sximm8 = 16'b0000000000000111;
		sim_writenum = 3'b000;			//Write value 7 into R0.
		sim_write = 1;
		#10;									//Clk rising edge at 5 seconds.
		sim_write = 0;						//Turn off write switch
		
		//7 written into R0 now.
		//Next write 2 into R1.
		
		sim_sximm8 = 16'b0000000000000010;
		sim_writenum = 3'b001;
		sim_write = 1;
		#10;								//Clk rising edge at 15 seconds.
		
		sim_write = 0;					//Switch write off.
		//2 written into R1 now.
		
		//Next: read this value in R0 into register B to prepare for shifting. Read not synced to clk.
		sim_readnum = 3'b000;		//Read from R0.
		sim_loadb = 1;					//Read value and store in register B.
		#10;								//Clk rising edge at 25 seconds.
		sim_loadb = 0;
		
		//2 written into register B now.
		
		//Next read value in R1 into register A.
		sim_readnum = 3'b001;
		sim_loada = 1;
		#10;							//Clk rising edge at 35 seconds.
		sim_loada = 0;
		
		//Next pass the values to ALU. Value in register B also needs a left shift.
		sim_shift = 2'b01;				//Shift set to 1.
		sim_asel = 0;
		sim_bsel = 0;						//No alternative operations needed here.
		sim_ALUop = 2'b00;				//Set ALU to addition.
		sim_loadc = 1;						//After ALU performs the operation, passes the output to register C.
		sim_loads = 0;						//Read output of the status block.
		#10;									//Clk rising edge at 45 seconds.
		
		//Output should appear on screen here.
		
		error_check(16'b0000000000010000, sim_datapath_out);
		
		
		//Next step: writeback the result and store in R2.
		sim_vsel = 4'b0001;
		sim_writenum = 3'b010;
		sim_write = 1;
		#10;								//Clk rising edge at 55 seconds.
		sim_write = 0;
		
		//Next output this value at R2 to check if it was stored.
		sim_readnum = 3'b010;
		sim_loadb = 1;				//Store in register B.
		sim_loada = 1;				//Store in register A.
		sim_bsel = 0;
		sim_shift = 2'b00;		//No shifting
		sim_asel = 0;				
		#10;							//Clk rising edge at 65 seconds
		
		//Next add both values in register A and B and send to register C. Value should be that of R2 doubled.
		sim_ALUop = 2'b00;
		sim_loadc = 1;
		#10; 							//Clk rising edge at 75 seconds
		
		//Value should be displayed on the screen now.
		error_check(16'b0000000000100000, sim_datapath_out);
		
		
		
		//NEXT TEST: Test the status registers.
		//Get the writeback MUX to take input value from sign-extended value, not writeback value.
		sim_vsel = 4'b0100;
		
		//Datapath in is 7.
		sim_sximm8 = 16'b0000000000000111;
		sim_writenum = 3'b000;			//Write value 7 into R0.
		sim_write = 1;
		#10;									//Clk rising edge at 85 seconds.
		sim_write = 0;						//Turn off write switch
		
		//7 written into R0 now.
		//Next write 2 into R1.
		
		sim_sximm8 = 16'b0000000000000010;
		sim_writenum = 3'b001;
		sim_write = 1;
		#10;								//Clk rising edge at 95 seconds.
		
		sim_write = 0;					//Switch write off.
		//2 written into R1 now.
		
		//Next: read this value in R0 into register B to prepare for shifting. Read not synced to clk.
		sim_readnum = 3'b000;		//Read from R0.
		sim_loadb = 1;					//Read value and store in register A.
		#10;								//Clk rising edge at 105 seconds.
		sim_loadb = 0;
		
		//2 written into register B now.
		
		//Next read value in R1 into register A.
		sim_readnum = 3'b001;
		sim_loada = 1;
		#10;							//Clk rising edge at 115 seconds.
		sim_loada = 0;
		
		//Next pass the values to ALU. Value in register B also needs a left shift.
		sim_shift = 2'b01;				//Shift set to 1.
		sim_asel = 0;
		sim_bsel = 0;						//No alternative operations needed here.
		sim_ALUop = 2'b01;				//Set ALU to subtraction.
		sim_loadc = 1;						
		sim_loads = 1;						//Read output of the status block.
		#10;									//Clk rising edge at 125 seconds.
		
		//Output should appear on screen here.
		
		status_errorcheck(3'b100, sim_statusOut);
		
		
		
		//NEXT check the overflow signal.
		sim_vsel = 4'b0100;
		
		sim_sximm8 = {1'b1,15'b0};
		sim_writenum = 3'b011;				//write to R3
		sim_write = 1;
		#10;										//Clk rising edge at 135 seconds.
		sim_write = 0;						
		
		sim_sximm8 = {16'b0};
		sim_writenum = 3'b100;					//Write to R4
		sim_write = 1;
		#10;										//clk rising edge at 145 seconds.
		sim_write = 0;
		
		sim_readnum = 3'b011;				//read from R3
		sim_loadb = 1;								//store in reg B
		#10;										//clk rising edge at 155 seconds
		sim_loadb = 0;
		
		sim_readnum = 3'b100;				//read from R4
		sim_loada = 1;							//store in reg A
		#10;										//clk rising edge at 165 seconds
		sim_loada = 0;
		
		sim_shift = 2'b0;
		sim_asel = 0;
		sim_bsel = 0;						//No alternative operations needed here.
		sim_ALUop = 2'b01;				//Set ALU to subtraction.
		sim_loadc = 1;						
		sim_loads = 1;						//Read output of the status block.
		#10;									//Clk rising edge at 175 seconds.
		
		status_errorcheck(3'b110, sim_statusOut);
		
		//END of test
		$stop;
	end
endmodule
		
		
		
		
	