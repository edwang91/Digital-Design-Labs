/*******************************************************************************
Copyright (c) 2012, Stanford University
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
   must display the following acknowledgement:
   This product includes software developed at Stanford University.
4. Neither the name of Stanford Univerity nor the
   names of its contributors may be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY STANFORD UNIVERSITY ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL STANFORD UNIVERSITY BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*******************************************************************************/

// TicTacToe
// Generates a move for X in the game of tic-tac-toe
// Inputs:
//   xin, oin - (9-bit) current positions of X and O.
// Out:
//   oout - (9-bit) one hot position of next O.
//
// Inputs and outputs use a board mapping of:
//
//   0 | 1 | 2 
//  ---+---+---
//   3 | 4 | 5 
//  ---+---+---
//   6 | 7 | 8 
//
// The top-level circuit instantiates strategy modules that each generate
// a move according to their strategy and a selector module that selects
// the highest-priority strategy module with a move.
//
// The win strategy module picks a space that will win the game if any exists.
//
// The block strategy module picks a space that will block the opponent
// from winning.
//
// The empty strategy module picks the first open space - using a particular
// ordering of the board.
//-----------------------------------------------------------------------------

// The following module, RArb, is combinational logic.  The input is a set
// of "requests" r -- one request per bit of r.  The output "g" is a set of
// grant signals.  If "r" is not all zeros, then a single bit of "g" will be
// set to 1.  Which bit?  The bit of "g" that will be set to 1 will be the
// bit that is in the same position as the first bit of "r" that is set to 
// 1 starting from the highest index bit position in "r".
//
// Note that r is declared as "input [n-1:0]".  This means it contains "n" 
// bits with index values from n-1 for the leftmost bit down to 0 for the
// right most bit.  By default n is set to 8, but we can change n when we
// instantiate the RArb module.  For example, using the notation "RArb #(9)"
// we change n to 9 when we instantiate RArb inside the module Empty.
//
// Suppose now that input r = 8'b00101111. Then, the bit with highest index,
// bit 7, has a value of 1'b0 and the bit with lowest index has value 1'b1.
// The output "g" will be 8'b00100000.  You may want to create a small 
// testbench script and simulating just this module with different input 
// values until you are sure you understand how the output "g" depends upon 
// the input "r".
//
// The textbook describes the this module in Chapter 8 (Figure 8.31).
// This module takes inputs of positions and the output priority. Highest priority output that 
// has not yet been played will be outputed by module
module RArb(r, g) ;
  parameter n=8 ;
  input  [n-1:0] r ;
  output [n-1:0] g ;
  wire   [n-1:0] c = {1'b1,(~r[n-1:1] & c[n-1:1])} ;
  assign g = r & c ;
endmodule // RArb

//Figure 9.12
module TicTacToe(xin, oin, xout) ;
  input [8:0] xin, oin ;
  output [8:0] xout ;
  wire [8:0] win, block, empty, adj ;

  TwoInArray winx(xin, oin, win) ;           // win if we can
  TwoInArray blockx(oin, xin, block) ;       // try to block o from winning
  PlayAdjacentEdge playAdjacent(xin, oin, adj) ;	// play adjacents if going for corner double win
  Empty      emptyx(~(oin | xin), empty) ;   // otherwise pick empty space
  Select4    comb(win, block, adj, empty, xout) ; // pick highest priority (Win > block > [play adjacents] > empty space)
endmodule // TicTacToe

//Figure 9.13: detects all the ways to play
module TwoInArray(ain, bin, cout) ;
  input [8:0] ain, bin ;
  output [8:0] cout ;

  wire [8:0] rows, cols ;
  wire [2:0] ddiag, udiag ;

  // check each row
  TwoInRow topr(ain[2:0],bin[2:0],rows[2:0]) ;		// Each instance of TwoInRow determines whether player A has 2 squares out of 3 in a row
  TwoInRow midr(ain[5:3],bin[5:3],rows[5:3]) ;		// eg. midr detects if there are 2 in a row in the middle row
  TwoInRow botr(ain[8:6],bin[8:6],rows[8:6]) ;

  // check each column
  TwoInRow leftc({ain[6],ain[3],ain[0]}, 		// ditto for columns	{ain[6],ain[3],ain[0]} corresponds to input [2:0] ain of module input
                  {bin[6],bin[3],bin[0]}, 
                  {cols[6],cols[3],cols[0]}) ;		// curly braces concatenates buses corresponding to boxes of
  TwoInRow midc({ain[7],ain[4],ain[1]}, 		// specific rows/cols/diags together to determine if 2 of same
                  {bin[7],bin[4],bin[1]}, 		// type exists in said cell
                  {cols[7],cols[4],cols[1]}) ;
  TwoInRow rightc({ain[8],ain[5],ain[2]}, 
                  {bin[8],bin[5],bin[2]}, 
                  {cols[8],cols[5],cols[2]}) ;

  // check both diagonals
  TwoInRow dndiagx({ain[8],ain[4],ain[0]},{bin[8],bin[4],bin[0]},ddiag) ;		// ditto for diagonals
  TwoInRow updiagx({ain[6],ain[4],ain[2]},{bin[6],bin[4],bin[2]},udiag) ;

  //OR together the outputs
  assign cout = rows | cols | 
         {ddiag[2],1'b0,1'b0,1'b0,ddiag[1],1'b0,1'b0,1'b0,ddiag[0]} |			// OR statement determines all possible positions where
         {1'b0,1'b0,udiag[2],1'b0,udiag[1],1'b0,udiag[0],1'b0,1'b0} ;			// player A can get 3 in a row
endmodule // TwoInArray

//Figure 9.14
module TwoInRow(ain, bin, cout) ;
  input [2:0] ain, bin ;
  output [2:0] cout ;

  assign cout[0] = ~bin[0] & ~ain[0] & ain[1] & ain[2] ; 	//eg. 1st expression checks if neither A or B has played pos. 0
  assign cout[1] = ~bin[1] & ain[0] & ~ain[1] & ain[2] ;	// AND that A has played at 1 and 2 (the 2 squares to the right)
  assign cout[2] = ~bin[2] & ain[0] & ain[1] & ~ain[2] ;
endmodule // TwoInRow

//Figure 9.15:	pick a good spot to move if a win is not iminent and block is not needed
module Empty(in, out) ;
  input [8:0] in ;
  output [8:0] out ;

  RArb #(9) ra({in[4],in[0],in[2],in[6],in[8],in[3],in[1],in[5],in[7]},			// EDIT: switch order of in[1] and in[3] so that it prioritizes left adjacent
          {out[4],out[0],out[2],out[6],out[8],out[3],out[1],out[5],out[7]}) ;	// this instance specifies the order of priority of positions to play starting with middle
endmodule // Empty									

//Figure 9.16:	this module selects best strategy from Empty to win game
module Select4(a, b, c, d, out) ;			// input c for playAdjacentEdge instant
  input [8:0] a, b, c, d;						// input d for Empty instant
  output [8:0] out ;
  wire [35:0] x ;
  
  RArb #(36) ra({a,b,c,d},x) ;				// Instantiation of RArb here is modified to include the output of PlayAdjacentEdge in
														// priority list as 3rd highest after winning and blocking.

  assign out = x[35:27] | x[26:18] | x[17:9] | x[8:0] ;			// Boolean expression determines which is the optimal move.
endmodule // Select4

//Similar algorithm to TwoInRow module. Determines all possible moves should 2 opposite corners be played by same type.
module PlayAdjacentEdge(ain, bin, out);
	input [8:0] ain, bin;
	output [8:0] out;
	
	reg [8:0] out;
	
	// Checking inputs of current positions of player A and B.
	always @* begin
		// If either A or B occupy any 2 opposite corners then Boolean exp. = 1
		case((ain[0] & ain[8] | ain[2] & ain[6]) | (bin[0] & bin[8] | bin[2] & bin[6]))
			1: out = 9'b000111000;			// module will output a set of adjacent positions to play
			default: out = 0;					// otherwise it will not output any positions 
		endcase
	end
endmodule

//Edit up to here

//Figure 9.18
module TestTic ;
  reg [8:0] xin, oin ;
  wire [8:0] xout, oout ;

  TicTacToe dut(xin, oin, xout) ;
  TicTacToe opponent(oin, xin, oout) ;

  initial begin
    // all zeros, should pick middle
    xin = 0 ; oin = 0 ; 
    #100 $display("%b %b -> %b", xin, oin, xout) ;
    // can win across the top
    xin = 9'b101 ; oin = 0 ; 
    #100 $display("%b %b -> %b", xin, oin, xout) ;
    // near-win: can't win across the top due to block
    xin = 9'b101 ; oin = 9'b010 ; 
    #100 $display("%b %b -> %b", xin, oin, xout) ;
    // block in the first column
    xin = 0 ; oin = 9'b100100 ; 
    #100 $display("%b %b -> %b", xin, oin, xout) ;
    // block along a diagonal
    xin = 0 ; oin = 9'b010100 ; 
    #100 $display("%b %b -> %b", xin, oin, xout) ;
    // start a game - x goes first
    oin = 9'b100000001 ; xin = 9'b000010000 ; 
    repeat (6) begin
      #100
      $display("%h %h %h", {xin[0],oin[0]},{xin[1],oin[1]},{xin[2],oin[2]}) ;
      $display("%h %h %h", {xin[3],oin[3]},{xin[4],oin[4]},{xin[5],oin[5]}) ;
      $display("%h %h %h", {xin[6],oin[6]},{xin[7],oin[7]},{xin[8],oin[8]}) ;
      $display(" ") ;
      xin = (xout | xin) ; 
      #100 
      $display("%h %h %h", {xin[0],oin[0]},{xin[1],oin[1]},{xin[2],oin[2]}) ;
      $display("%h %h %h", {xin[3],oin[3]},{xin[4],oin[4]},{xin[5],oin[5]}) ;
      $display("%h %h %h", {xin[6],oin[6]},{xin[7],oin[7]},{xin[8],oin[8]}) ;
      $display(" ") ;
      oin = (oout | oin) ;
    end
  end
endmodule



			 
		
	
	