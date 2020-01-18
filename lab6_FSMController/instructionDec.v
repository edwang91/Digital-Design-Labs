module instruction_decoder(regout, nsel, opcode, ALUop, sximm5, sximm8, shift, readnum, writenum);
    parameter n = 1;
    input [15:0] regout;
    input [2:0] nsel;
    output [2:0] opcode;
    
    output [1:0] ALUop;
    output [15:0] sximm5;
    output [15:0] sximm8;
    output [1:0] shift;
    output [2:0] readnum;
    output [2:0] writenum;
    
    wire [2:0] Rn;
    wire [2:0] Rd;
    wire [2:0] Rm;
    wire [2:0] Rout;
    
    wire [4:0] imm5;
    wire [7:0] imm8;
    
	 //Assigning bits of instruction input from instruction reg to different wire connections to the FSM and datapath.
    assign opcode = regout[15:13];
    assign ALUop =  regout[12:11];
    assign shift = regout [4:3];
    assign imm5 = regout[4:0];
    assign imm8 = regout[7:0];
    
	 //Perform sign extension on 5 and 8 bit values to 16 bit signed values to be passed to datapath.
    SignExtend #(5,16) se1(imm5,sximm5);
    SignExtend #(8,16) se2(imm8,sximm8);
    
	 //Defining more bits of instruction input for the different addresses (if necessary.)
    assign Rn = regout[10:8];
    assign Rd = regout[7:5]; 
    assign Rm = regout[2:0];
    
	 //Instantiate a mux to select readnum and writenum outputs.
    Mux3 #(3) mx1(Rn,Rd,Rm,nsel,Rout);
    
	 //Output the same value for readnum and writenum to datapath. FSM will dictate which one to use.
    assign readnum = Rout;
    assign writenum = Rout;
endmodule

//Module SignExtend from Dally pg. 222
//Module performs sign extension of a given input.
module SignExtend(a, b) ; 
    parameter n=2 ;
    parameter m=4 ; 
    
    input [n-1:0] a ; 
    output [m-1:0] b ;
    
    assign b = {{n{a[n-1]}},a};
endmodule
 
//Mux module for selecting the readnum and writenum values based on the 3-bit 1 hot nsel.
module Mux3(a2,a1,a0,s,b);
    parameter k=1;
    input [k-1:0] a0,a1,a2;
    input [2:0] s;
    output [k-1:0] b;
    wire [k-1:0] b = ({k{s[2]}} & a0) |
                      ({k{s[1]}} & a1) |
                      ({k{s[0]}} & a2);
endmodule