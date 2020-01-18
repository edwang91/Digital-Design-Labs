//Based off lab8 stage 2 check.
module lab8_stage2_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;
  reg CLOCK_50;

  lab8_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);

  initial forever begin
    CLOCK_50 = 0; #5;
    CLOCK_50 = 1; #5;
  end
  wire break = (LEDR[8] == 1'b1);
  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted
    #10; // wait until next falling edge of clock
    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4
	 SW = 9'b000000111;
    while (~break) begin
      @(posedge (DUT.CPU.FSM.p == 20'h10000) or posedge break);  // wait until IF1 
      @(negedge CLOCK_50); // show advance to negative edge of clock
      $display("PC = %h", DUT.CPU.PC); 
    end
	 
	  KEY[1] = 1'b0; // reset asserted
    #10; // wait until next falling edge of clock
    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4
	 SW = 9'b000000110;
	 
	  while (~break) begin
      @(posedge (DUT.CPU.FSM.p == 20'h10000) or posedge break);  // wait until IF1 
      @(negedge CLOCK_50); // show advance to negative edge of clock
      $display("PC = %h", DUT.CPU.PC); 
    end
	 
    $stop;
  end
endmodule
