//Template of this testbench from the lab7_autograder_check
module lab7_check_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;

  lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

  initial forever begin
    KEY[0] = 1; #5;
    KEY[0] = 0; #5;
  end

  initial begin
    err = 0;
	 		SW[9:0] = 9'b000100011;
	 
    KEY[1] = 1'b0; // reset asserted
    // check if program from Figure 8 in Lab 7 handout can be found loaded in memory
    if (DUT.MEM.mem[0] !== 16'b1101000000001000) begin err = 1; $display("FAILED: mem[0] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[1] !== 16'b0110000000000000) begin err = 1; $display("FAILED: mem[1] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[2] !== 16'b0110000001000000) begin err = 1; $display("FAILED: mem[2] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[3] !== 16'b1100000001101010) begin err = 1; $display("FAILED: mem[3] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[4] !== 16'b1101000100001001) begin err = 1; $display("FAILED: mem[4] wrong; please set data.txt using Figure 6"); $stop; end
    if (DUT.MEM.mem[5] !== 16'b0110000100100000) begin err = 1; $display("FAILED: mem[5] wrong; please set data.txt using Figure 6"); $stop; end
	 if (DUT.MEM.mem[6] !== 16'b1000000101100000) begin err = 1; $display("FAILED: mem[6] wrong; please set data.txt using Figure 6"); $stop; end
	 if (DUT.MEM.mem[7] !== 16'b1110000000000000) begin err = 1; $display("FAILED: mem[7] wrong; please set data.txt using Figure 6"); $stop; end

    #10; // wait until next falling edge of clock
    KEY[1] = 1'b1; 

    #10; // waiting for RST state to cause reset of PC

    // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end
	
	//MOV R0, SW_BASE
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing LDR R0, [R0]

    if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing LDR R2, [R0]

    if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h8) begin err = 1; $display("FAILED: R0 should be 8."); $stop; end  

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 3 *after* executing LDR R2, [R0]

    if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h0140) begin err = 1; $display("FAILED: R0 should be 0x0140. Looks like your LDR isn't working."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 4 *after* executing MOV R3, R2, LSL1
	
		
    if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    //The value here is wrong. Should be whatever values are input from switches. I think.
    if (DUT.CPU.DP.REGFILE.R2 !== 16'b0000000000100011) begin err = 1; $display("FAILED: R2 should be 32 when SW5 is on."); $stop; end

	 //Performing left shift on an empty register.
	 @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
	  if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end
    //The value here is wrong. Should be whatever values are input from switches. I think.
    if (DUT.CPU.DP.REGFILE.R3 !== 16'b0000000001000110) begin err = 1; $display("FAILED: R3 should be R2 value leftshifted."); $stop; end
	 
	 @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 5 *after* executing MOV R1, LEDR_BASE

    if (DUT.CPU.PC !== 9'h6) begin err = 1; $display("FAILED: PC should be 6."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'h9) begin err = 1; $display("FAILED: R1 should be 9."); $stop; end
	 
	 @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 6 *after* executing LDR R1, [R1]

    if (DUT.CPU.PC !== 9'h7) begin err = 1; $display("FAILED: PC should be 6."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'h0100) begin err = 1; $display("FAILED: R1 should be 0100."); $stop; end
	 
	 //Try to store value of 64 into address 256. Not in the range of RAM so displayed on LEDs 
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 7 *after* executing STR R3, [R1]
   
    if (DUT.CPU.PC !== 9'h8) begin err = 1; $display("FAILED: PC should be 7."); $stop; end
    if (DUT.MEM.mem[256] !== 16'hx) begin err = 1; $display("FAILED: mem[256] wrong; looks like your STR isn't working"); $stop; end

    // NOTE: if HALT is working, PC won't change again...

    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule
