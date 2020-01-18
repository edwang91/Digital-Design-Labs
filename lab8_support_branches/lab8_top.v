module lab8_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);

	`define MW 2
	`define MNONE 2'b00
	`define MREAD 2'b10
	`define MWRITE 2'b01

  input CLOCK_50;
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR; 
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  
  wire [15:0] out, ir, dout, from_RAM, from_SW, read_data;
  wire [8:0] mem_addr_top;
  wire [1:0] mem_cmd_top;
  
  wire tri_sel, write, write_cmd, read_cmd, read_SW, write_LED, enableSW, loadLED, matchW, matchR, msel;
  
  //Instantiate CPU, KEY0 is for clk. KEY1 for reset.
  cpu CPU( .clk   (CLOCK_50), 
         .reset (~KEY[1]), 
         .in    (read_data),
         .out   (out),
         .mem_addr (mem_addr_top),
         .mem_cmd (mem_cmd_top),
			.halt (LEDR[8])
        );
	
	//Assign HEX5 so it displays status.


  	//Equality comparators checking for read or write commands and to determing msel.
	EqComp #(2) READ(`MREAD, mem_cmd_top, read_cmd);
	EqComp #(2) WRITE(`MWRITE, mem_cmd_top, write_cmd);
	EqComp #(1) OTHER(1'b0, mem_addr_top[8], msel);
	
	//Assign values to write and tri select appropriately.
	assign write = write_cmd & msel;
	assign tri_sel = read_cmd & msel;
  
	//Instantiation for interface.
   input_iface IN(CLOCK_50, SW, ir);
  
  //Dout of RAM fed into tri_state. If it is enabled read_data gets the value of dout.
  tri_state #(16) check(tri_sel, dout, from_RAM);
  
  // Instantiation of memory.
  RAM #(16, 8) MEM(CLOCK_50, mem_addr_top[7:0], mem_addr_top[7:0], write, out, dout);
  
  //Here, we check if whether it is time to use switches/LEDs.
	EqComp #(2) SWITCH_R(`MREAD, mem_cmd_top, read_SW);
	EqComp #(2) LED_W(`MWRITE, mem_cmd_top, write_LED);
	EqComp #(9) MAG_SW(9'b101000000, mem_addr_top, matchR);
	EqComp #(9) MAG_LED(9'b100000000, mem_addr_top, matchW);
	
	//If the address is h0140 and the mem_cmd is Read...
	assign enableSW = (read_SW & matchR) ? 1'b1 : 1'b0;
	//If the address is h0100 and the mem_cmd is write...
	assign loadLED = (write_LED & matchW) ? 1'b1 : 1'b0;
	
	//Instantiate tri_state for the switches.
	tri_state #(16) SWCHECK(enableSW, ir, from_SW);
	//Instantiate load register for the LEDs.
	load_enable_LED lights(CLOCK_50, loadLED, out[7:0], ~KEY[1], LEDR[7:0]);
	
	//Not using LED9 and 8.
	assign LEDR[9] = 1'b0;
	
	//Read_data into cpu will be from switches if address is h140, otherwise reads from RAM if less than h100.
	assign read_data = enableSW ? from_SW : from_RAM;
  
endmodule        

//Switch signals module from lab6_top file.
module input_iface(clk, SW, ir);
	input clk;
  input [9:0] SW;
  output [15:0] ir;
	
	wire [15:0] next_ir;
	
	assign next_ir[15:8] = 8'b0;
	assign next_ir[7:0] = SW[7:0];
	
	vDFF #(16) leds(clk, next_ir, ir);
	
endmodule         

//vDFF module from lab6_top file.
module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk)
    Q <= D;
endmodule

//Equality comparator module from slide 59 of slideset 6.
//We will instantiate this 3 times to decide if we are writing, reading and something else.
module EqComp(a, b, eq) ;
  parameter k=8;
  input  [k-1:0] a,b;
  output eq;
  reg   eq;

  always @* begin
	case(a==b)
		1'b1: eq = 1;
		default: eq = 0;
	endcase
end
  
endmodule

//LED register
module load_enable_LED(clk, load, in, reset, LEDS);
	input load, reset;
	input clk;
	input [7:0] in;
	output [7:0] LEDS;
	
	wire [7:0] next_LEDS_reset;
	wire [7:0] next;
	
	//Set LEDs to off.
	assign next_LEDS_reset = reset ? 7'b0 : next;
	//Set leds to match the value if appropriate.
	assign next = load ? in : LEDS;
	
	vDFF #(8) updateLED(clk, next_LEDS_reset, LEDS);
endmodule