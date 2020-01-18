//Code from pg.16 figure 17 of de1soc pdf. Sends a character to JTAG and the character to send is in R0.
.global PUT_JTAG
    PUT_JTAG:
        LDR R1, =0xFF201000 // JTAG UART base address
        LDR R2, [R1, #4] // read the JTAG UART control register
        LDR R3, =0xFFFF
        ANDS R2, R2, R3 // check for write space
        BEQ END_PUT // if no space, ignore the character
        STR R0, [R1] // send the character
        
    END_PUT:
        BX LR
.end