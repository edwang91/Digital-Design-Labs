// This module will perform different operations on 2 16-bit inputs from registers and output
// the 16-bit result. ALUop is 2-bit input of what operation to perform. Z is 1 bit output.
module ALU(Ain, Bin, ALUop, out, Z);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output [15:0] out;
    output Z;
    
    reg [15:0] out;
	 reg Z;
    
    always @* begin 
        case (ALUop)
            2'b00: out = Ain + Bin;
            2'b01: out = Ain - Bin;
            2'b10: out = Ain & Bin;
            2'b11: out = ~Bin;
            default: out = 16'bx;
        endcase
        if (out == 16'b0)
            Z = 1'b1;
        else
            Z = 1'b0;
    end  
endmodule