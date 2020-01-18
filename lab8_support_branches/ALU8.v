// This module will perform different operations on 2 16-bit inputs from registers and output
// the 16-bit result. ALUop is 2-bit input of what operation to perform. Z is 1 bit output.
module ALU(Ain, Bin, ALUop, out, Z, N, V);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output [15:0] out;
    output Z, N, V;
    
    reg [15:0] out;
	 reg Z, N, V;
	 wire nV;
	 //for module instance
	 wire [15:0] otherout;
    
	 //Checking for overflow only if adding or subtracting.
	 AddSub #(16) checkOverflow(Ain, Bin, ALUop[0], otherout, nV);
	 
    always @* begin 
        case (ALUop)
            2'b00: out = Ain + Bin;		
            2'b01: out = Ain - Bin; 		
            2'b10: out = Ain & Bin;
            2'b11: out = ~Bin;
            default: out = 16'bx;
        endcase
		  //Check for 0
        if (out == 16'b0)
            Z = 1'b1;
        else
            Z = 1'b0;
		  //Check for negative
		  if (out[15] == 1'b1)
				N = 1'b1;
		  else
				N = 1'b0;
		
		//Only signal for overflow if adding or subtracting.
		  if (ALUop !== 2'b00 && ALUop !== 2'b01)
				V = 1'b0;
		  else
				V = nV;
    end  
endmodule

// This module that checks for overflow is from SS6 slide 104.
// add a+b or subtract a-b, check for overflow
module AddSub(a, b, sub, s, ovf);
  parameter n = 16 ;
  input [n-1:0] a, b ;
  input sub ;           // subtract if sub=1, otherwise add
  output [n-1:0] s ;
  output ovf ;          // 1 if overflow
  wire c1, c2 ;         // carry out of last two bits
  wire ovf = c1 ^ c2 ;  // overflow if signs don't match

  // add non sign bits
  Adder1 #(n-1) ai(a[n-2:0], b[n-2:0]^{n-1{sub}}, sub, c1, s[n-2:0]) ;
  // add sign bits
  Adder1 #(1)   as(a[n-1], b[n-1]^sub, c1, c2, s[n-1]) ;
endmodule

// This module is from SS6 slide 89
// multi-bit adder - behavioral
module Adder1(a,b,cin,cout,s) ;
  parameter n = 8 ;
  input [n-1:0] a, b ;
  input cin ;
  output [n-1:0] s ;
  output cout ;
  wire [n-1:0] s;
  wire cout ;

  assign {cout, s} = a + b + cin ;
endmodule 