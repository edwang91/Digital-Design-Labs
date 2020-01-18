module FSM_tb();
	
	`define SW 3
	`define SWAIT 3'b000
	`define SDEC 3'b001
	`define SWRITE 3'b010
	`define SP 3'b011
	`define SSTATUS 3'b101
	`define SC 3'b110
	
	reg clk_sim, reset_sim, s_sim, err;
	reg [2:0] opcode_sim;
	reg [1:0] op_sim;
	wire w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim; 
	wire [3:0] vsel_sim;
	wire [2:0] nsel_sim;
	wire [7:0] PC_sim;
	wire [15:0] mdata_sim;
	
	FSM DUT(clk_sim, reset_sim, s_sim, opcode_sim, op_sim, w_sim, vsel_sim, asel_sim, bsel_sim, 
				nsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, PC_sim, mdata_sim);
	
	//Don't need to check mdata and PC since they are assigned 0s for lab 6 only.
	task error_check;
		input [14:0] expected_outputs;
		input [14:0] actual_outputs;
		
		begin 
			if (expected_outputs !== actual_outputs)
				err = 1'b1;
			$display("The output should be %b, and it was %b", expected_outputs, actual_outputs);
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
		//First test the outputs for MOV Rn #<im8>
		opcode_sim = 3'b110;
		op_sim = 2'b10;
		s_sim = 0;		//Start is 0 so do nothing on next clock cycle.
		reset_sim = 0;
		#10;				//Clk rising edge at 5 seconds.
		error_check(15'b100000000000000, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		s_sim = 1;		//Update state to decode
		#10;				//clk rising edge at 15 seconds.
		error_check(15'b000000000100100, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;				//Clk rising edge at 25 seconds.
		error_check(15'b000000010001001, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;				//Clk rising edge at 35 sec. Should be back in wait stage now.
		error_check(15'b100000000000000, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		
		
		//FIRST TEST DONE. Second test for MOV Rd, Rm{<sh_op>}.
		opcode_sim = 3'b110;
		op_sim = 2'b00;
		s_sim = 1;
		
		#10;		//clk rising at 45 sec. Now in decode stage
		error_check(16'b000000000100100, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//Clk rising at 55 sec. Now loading to Register B
		error_check(15'b010010000100100, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//Clk rising at 65 sec. Now load the ALU'd result to Register C.
		error_check(15'b000001000001000, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//Clk rising at 75 sec. Now write the value back to Rd.
		error_check(15'b000000010001010, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//Clk rising at 85 sec. Now back to wait stage.
		error_check({1'b1, 14'b0}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		//SECOND TEST DONE. Third test for ADD Rd, Rn, Rm{<sh_op>}
		opcode_sim = 3'b101;
		op_sim = 2'b0;
		s_sim = 1;
		
		#10;		//clk rising at 95 sec. Go to decode.
		error_check({9'b0, 6'b100100}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 105 sec. Now writing to reg B.
		error_check(15'b000010000001100, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 115 sec. Now writing to reg A.
		error_check(15'b000100000001001, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 125 sec. Now writing result to reg C.
		error_check(15'b000001000001000, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 135 sec. Now writing back to Rd.
		error_check(15'b000000010001010, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 145 sec. Back to wait stage.
		error_check({1'b1, 14'b0}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		
		//THIRD TEST DONE. 4th test for CMP Rn, Rm{<sh_op>}
		opcode_sim = 3'b101;
		op_sim = 2'b01;
		s_sim = 1;
		
		#10;		//clk rising at 155 sec. Decode stage.
		error_check({9'b0, 6'b100100}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 165 sec. Read to reg B.
		error_check(15'b000010000001100, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 175 sec. Read to reg A.
		error_check(15'b000100000001001, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 185 sec. load to c
		error_check(15'b000001000001000, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 195 sec. load to status
		error_check(15'b000000100001000, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 205 sec. Back to wait.
		error_check({1'b1, 14'b0}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		
		//4TH TEST DONE. 5th test for AND Rd, Rn, Rm{<sh_op>}.
		opcode_sim = 3'b101;
		op_sim = 2'b10;
		s_sim = 1;
		
		#10;		//Clk rising at 205 sec. Decode.
		error_check({9'b0, 6'b100100}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 215. Write to reg B.
		error_check({15'b000010000001100}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 225. Write to reg A.
		error_check({15'b000100000001001}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 225. Write result to reg C.
		error_check({15'b000001000001000}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 235. Writeback to Rd.
		error_check({15'b000000010001010}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//clk rising at 245. Wait.
		error_check({1'b1, 14'b0}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		
		//5TH TEST DONE. 6th test for MVN Rd, Rm{<sh_op>}.
		opcode_sim = 3'b101;
		op_sim = 2'b11;
		s_sim = 1;
		
		#10;		//Clk rising at 245. Decode.
		error_check({9'b0, 6'b100100}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//Clk rising at 255. Store Rm to Reg B.
		error_check(15'b000010000001100, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//Clk rising at 265. Store result in reg C.
		error_check(15'b000001000001000, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//Clk rising at 275. Write back to Rd.
		error_check(15'b000000010001010, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		#10;		//Clk rising at 285. Wait.
		error_check({1'b1, 14'b0}, {w_sim, asel_sim, bsel_sim, loada_sim, loadb_sim, loadc_sim, loads_sim, write_sim, vsel_sim, nsel_sim});
		
		//6TH TEST DONE.
		
		$stop;
	end
endmodule