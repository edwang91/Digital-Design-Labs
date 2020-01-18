MOV R6, stack_begin
LDR R6, [R6]
MOV R4, result
MOV R3, switch_base
LDR R3, [R3]
LDR R1, [R3]
STR R3, [R4]
MOV R0, #1
MOV R2, #9
BL leaf_example
STR R0, [R4]
MOV R5, led_base
LDR R5, [R5]
STR R0, [R5]
HALT
leaf_example:
STR R4, [R6]
STR R5, [R6, #-1]
ADD R4, R0, R1
MOV R5, #1
ADD R4, R4, R5
MOV R0, R4
LDR R5, [R6, #-1]
LDR R4, [R6]
BX R7
stack_begin:
	.word 0xFF
result:
	.word 0xCCCC
led_base:
	.word 0x0100
switch_base:
	.word 0x0140