// This module shifts the 16 bit value by 1 bit in either direction.
module shifter(in, shift, sout);
    input [15:0] in;
    input [1:0] shift;
    output [15:0] sout;
    
    reg [15:0] sout;
    
    // Perform shift
    always @* begin
        // when shifting right, can set MSB to 0 or to the value of in[15]
         case (shift)
				2'b00: sout = in;
				2'b01: begin
							sout = in << 1;
							sout[0] = 1'b0;
						 end
				2'b10: begin
							sout = in >> 1;
							sout[15] = 1'b0;
						 end
				2'b11: begin
							sout = in >> 1;
							sout[15] = in[15];
						 end
			endcase
    end
endmodule