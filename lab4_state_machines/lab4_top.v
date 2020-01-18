//Define number signals
`define stateW 7
`define start6 7'b0000010
`define state5 7'b0010010
`define state3 7'b0110000
`define state4 7'b0011001
`define finish0 7'b1000000

//The top module that instantiates Run_cycle
module lab4_top(SW,KEY,HEX0);
  input [9:0] SW;
  input [3:0] KEY;
  output [6:0] HEX0;

  wire CLOCK;
  wire RESET;
  wire change_dir;
  wire [6:0] HEX0;
  
  // Reverse the logic so that button not pressed outputs a 0.
  assign CLOCK = ~KEY[0];
  assign RESET = ~KEY[1];
  assign change_dir = SW[0];
  
  // Instantiates the module that drives the cycling.
  Run_cycle go(CLOCK, RESET, change_dir, HEX0);
endmodule

//NOTE: the overall logic structure of this module (line 31-60) was from powerpoint 5 slide 37
//This module is the main module that drives the cycle.
module Run_cycle(clk, reset, switch, out_state);
	input clk, reset, switch;
	output [6:0] out_state;
	
	reg [6:0] out_state;
	
	wire [6:0] reset_state, current_state;
	reg [6:0] next_state;
	
	//This instantiation updates the display when at rising edge of clk. Changes current_state value to reset_state value
	vDFF #(`stateW) assignState(clk, reset_state, current_state);
	
	// if reset button is pressed the next state will be reset to start.
	// otherwise it will still be the next state in the cycle, determined by combinational logic in always block.
	assign reset_state = reset ? `start6 : next_state;
	
		// Combinational logic for checking what current state is and the direction and
	// outputting appropriate next state.
	always @* begin
		// case block checking the current state and testing the switch for direction for
		// next output. Meanwhile, current output will be displayed
		case (current_state)
			`start6: {next_state, out_state} = {(switch ? `state5 : `finish0), `start6};
			`state5: {next_state, out_state} = {(switch ? `state3 : `start6), `state5};
			`state3: {next_state, out_state} = {(switch ? `state4 : `state5), `state3};
			`state4: {next_state, out_state} = {(switch ? `finish0 : `state3), `state4};
			`finish0: {next_state, out_state} = {(switch ? `start6 : `state4), `finish0};
			default: {next_state, out_state} = 7'bxxxxxxx;
		endcase
	end
endmodule



//NOTE: This module was taken from slide 35 of slideset 5 powerpoint.
//This module defines a flip-flop, which is necessary for the design of
//the FSM and creates the loop.
module vDFF(clk, ins, outs);
	parameter n = 1;
	input clk;
	input [n-1:0] ins;
	output [n-1:0] outs;
	
	reg [n-1:0] outs;
	
	always @(posedge clk)				// At the rising edge of clk, the output will be the input.
		outs = ins;

endmodule