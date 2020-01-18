.globl binary_search
binary_search:
	SUB sp, sp, #24		//adjust stack for 6 items
	STR R0, [sp,#20]
	STR lr, [sp,#16]		//save return address
	STR R2, [sp,#12]         //save startIndex argument
    STR R3, [sp,#8]         //save endIndex argument
    
    SUB R12, R3, R2             //(endIndex - startIndex)
    ADD R11, R2, R12, ASR #1     //middleIndex = startIndex + (endIndex - startIndex)/2
    STR R11, [sp,#4]            //save middleIndex
    ADD R8, R8, #1             //NumCalls++
    STR R8, [sp,#0]            //save NumCalls
    CMP R2, R3			// startIndex > endIndex?
    BGT L0                        //if R2 > R3 go to L0

    BLE L1 			//if R2 <= R3 go to L1 
      
L0: MVN R10, #1                    //Return -1
    ADD R10, R10, #1		   //2's complement
    LDR R8, [sp,#0]                //return from function, restore previous NumCalls argument
    LDR R11, [sp,#4]                //restore middleIndex local
    LDR R3, [sp,#8]                //restore endIndex argument
    LDR R2, [sp,#12]                //restore startIndex argument
    LDR lr, [sp,#16]                //restore return address
    ADD sp, sp, #24                //pop 6 things off stack
    MOV pc, lr                    //return to caller  
      

    
L1: MOV R7, R0                  //Copy pointer numbers 
    LDR R7, [R0, R11, LSL #2]    //R7 = numbers[middleIndex]
    CMP R7, R1                  //numbers[middleIndex] == key?
    BNE L2                      //if numbers[middleIndex] != key go to L2
    BEQ LE      		 //if numbers[middleIndex] == key go to LE

L2: CMP R7, R1                    
    BLT L3                        //if numbers[middleIndex] < key go to L3
    BGE L4			  //if numbers[middleIndex] > key go to L4

L3: ADD R2, R11, #1                //startIndex = middleIndex + 1
    BL binary_search                //Recursive call binary_search with startIndex argument set to middleIndex + 1
    B END
    
L4: SUB R3, R11, #1                //endIndex = middleIndex - 1
    BL binary_search              //Recursive call binary_search with endIndex argument set to middleIndex - 1
    B END
    
LE: MOV R10, R11                   //keyIndex = middleIndex
    B END
    
END: LDR R8, [sp,#0]                //return from function, restore previous NumCalls argument
     LDR R11, [sp,#4]                //restore middleIndex local
     LDR R3, [sp,#8]                //restore endIndex argument
     LDR R2, [sp,#12]                //restore startIndex argument
     LDR lr, [sp,#16]                //restore return address
     LDR R0, [sp,#20]
     ADD sp, sp, #24                //pop 6 things off stack
     RSB R9, R8, #0                //R9 = -NumCalls

     STR R9, [R0, R11, LSL #2]                  //numbers[middleIndex] = -NumCalls                  Broken here for 1007 try
     MOV R0, R10                    //Save the keyIndex return value
     MOV pc, lr                    //return to caller   
    
    