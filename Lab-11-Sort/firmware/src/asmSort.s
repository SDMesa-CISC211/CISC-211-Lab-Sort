/*** asmSort.s   ***/
#include <xc.h>
.syntax unified

@ Declare the following to be in data memory
.data
.align    

@ Define the globals so that the C code can access them
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Katie Wingert"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

@ Tell the assembler that what follows is in instruction memory    
.text
.align

/********************************************************************
function name: asmSwap(inpAddr,signed,elementSize)
function description:
    Checks magnitude of each of two input values 
    v1 and v2 that are stored in adjacent in 32bit memory words.
    v1 is located in memory location (inpAddr)
    v2 is located at mem location (inpAddr + M4 word size)
    
    If v1 or v2 is 0, this function immediately
    places -1 in r0 and returns to the caller.
    
    Else, if v1 <= v2, this function 
    does not modify memory, and returns 0 in r0. 

    Else, if v1 > v2, this function 
    swaps the values and returns 1 in r0

Inputs: r0: inpAddr: Address of v1 to be examined. 
	             Address of v2 is: inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: size: number of bytes for each input value.
                  Valid values: 1, 2, 4
                  The values v1 and v2 are stored in
                  the least significant bits at locations
                  inpAddr and (inpAddr + M4 word size).
                  Any bits not used in the word may be
                  set to random values. They should be ignored
                  and must not be modified.
Outputs: r0 returns: -1 If either v1 or v2 is 0
                      0 If neither v1 or v2 is 0, 
                        and a swap WAS NOT made
                      1 If neither v1 or v2 is 0, 
                        and a swap WAS made             
             
         Memory: if v1>v2:
			swap v1 and v2.
                 Else, if v1 == 0 OR v2 == 0 OR if v1 <= v2:
			DO NOT swap values in memory.

NOTE: definitions: "greater than" means most positive number
********************************************************************/     
.global asmSwap
.type asmSwap,%function     
asmSwap:

    /* YOUR asmSwap CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
    
    CMP R2, 2 /*compare the size of the values to 2*/
    BLT byteLoad /*if less than 2, the values are bytes so branch to byteLoad*/
    BGT wordLoad /*if greater than 2, the values are words so branch to wordLoad*/
    /*else if not less than or greater than 2, program will naturally flow to halfwordLoad*/
    
    halfwordLoad:
    CMP R1, 1 /*compare sign value to 1*/
    LDRSHEQ R4, [R0] /*if sign value is equal to 1, do a signed halfword load from address in R0 to R4*/
    LDRSHEQ R5, [R0, 4] /*calculates address in R0 plus 4 bytes, then signed halfword loads from this calculated address to R5*/
    LDRHNE R4, [R0] /*if sign value is not equal to 0, do an unsigned halfword load from address in R0 to R4*/
    LDRHNE R5, [R0, 4] /*calculates address in R0 plus 4 bytes, then unsigned halfword loads from this calculated address to R5*/
    b checkIfSwapDone /*branch to checkIfSwapDone*/
    
    byteLoad:
    CMP R1, 1 /*compare sign value to 1*/
    LDRSBEQ R4, [R0] /*if sign value is equal to 1, do a signed byte load from address in R0 to R4*/
    LDRSBEQ R5, [R0, 4] /*calculates address in R0 plus 4 bytes, then signed byte loads from this calculated address to R5*/
    LDRBNE R4, [R0] /*if sign value is not equal to 0, do an unsigned byte load from address in R0 to R4*/
    LDRBNE R5, [R0, 4] /*calculates address in R0 plus 4 bytes, then unsigned byte loads from this calculated address to R5*/
    b checkIfSwapDone /*branch to checkIfSwapDone*/
    
    wordLoad:
    LDR R4, [R0] /*word load from address in R0 to R4*/
    LDR R5, [R0, 4] /*calculates address in R0 plus 4 bytes, then word loads from this calculated address to R5*/
    /*program will nautrally flow to checkIfSwapDone so no branch neccessary*/
    
    checkIfSwapDone:
    CMP R4, 0 /*compare the first value to 0, which indicates the end of the array*/
    MOVEQ R0, -1 /*if this value is 0, return -1 in R0 to indicate to asmSort that no swap occured*/
    BEQ swapDone /*branch to swapDone*/
    CMP R5, 0 /*compare the second value to 0*/
    MOVEQ R0, -1 /*if this value is 0, return -1 in R0*/
    BEQ swapDone /*branch to swapDone*/
    CMP R1, 0 /*compare the sign value to 0*/
    BEQ unsignedSwapCheck /*if 0, branch to unsignedSwapCheck*/
    
    signedSwapCheck:
    CMP R4, R5 /*compare the two values pulled from the array*/
    MOVLE R0, 0 /*if the left signed value is less than or equal to the right signed value, no swap needs to occur, so return 0 in R0*/
    BLE swapDone /*if the left signed value is less than or equal to the right signed value, branch to swapDone*/
    BGT swap /*else, branch to swap*/

    unsignedSwapCheck:
    CMP R4, R5 /*compare the two values pulled from the array*/
    MOVLS R0, 0 /*if the left value is less than or equal to the right value, no swap needs to occur, so return 0 in R0*/
    BLS swapDone /*if the left value is less than or equal to the right value, branch to swapDone*/
    /*else, program will naturally flow to swap so no branch needs to occur*/
    
    swap:
    CMP R2, 2 /*compare the size to 2*/
    STRHEQ R5, [R0] /*if the size is 2, halfword store the array value stored in R5 to the address in R0*/
    STRHEQ R4, [R0, 4] /*if the size is 2, calculate the address in R0 plus 4 bytes, then halfword store the array value in R4 to the calculated address*/
    STRBLT R5, [R0] /*if the size is less than 2, byte store the array value stored in R5 to the address in R0*/
    STRBLT R4, [R0, 4] /*if the size is less than 2, calculate the address in R0 plus 4 bytes, then byte store the array value in R4 to the calculated address*/
    STRGT R5, [R0] /*if the size is greater than 2, word store the array value stored in R5 to the address in R0*/
    STRGT R4, [R0, 4] /*if the size is greater than 2, calculate the address in R0 plus 4 bytes, then word store the array value in R4 to the calculated address*/
    MOV R0, 1
  
    swapDone:
    pop {r4-r11,LR}
    mov pc, lr  
    /* YOUR asmSwap CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */
    
    
/********************************************************************
function name: asmSort(startAddr,signed,elementSize)
function description:
    Sorts value in an array from lowest to highest.
    The end of the input array is marked by a value
    of 0.
    The values are sorted "in-place" (i.e. upon returning
    to the caller, the first element of the sorted array 
    is located at the original startAddr)
    The function returns the total number of swaps that were
    required to put the array in order in r0. 
    
         
Inputs: r0: startAddr: address of first value in array.
		      Next element will be located at:
                          inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: elementSize: number of bytes for each input value.
                          Valid values: 1, 2, 4
Outputs: r0: number of swaps required to sort the array
         Memory: The original input values will be
                 sorted and stored in memory starting
		 at mem location startAddr
NOTE: definitions: "greater than" means most positive number    
********************************************************************/     
.global asmSort
.type asmSort,%function
asmSort:   

    /* Note to Profs: 
     */

    /* YOUR asmSort CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}

    MOV R4, R0 /*mov address to R4 for use in walking through array*/
    MOV R5, R0 /*mov starting address to R5 for use in restarting the sort*/
    MOV R6, 0 /*Clear R6 to hold the temporary swap count*/
    MOV R7, 0 /*clear R7 to hold the final swap count*/
    
    bubbleSort:
    MOV R0, R4 /*mov address to R0 for sending to asmSwap*/
    BL asmSwap /*branch with link to asmSwap*/
    CMP R0, 0 /*compare the returned value of if a swap happened to 0*/
    BLT checkIfSortAgain /*if the returned value is less than 0, one of the values was 0 and this iteration of the bubbleSort is done*/
    ADDGT R6, R6, 1 /*if the returned value is greater than 0, a swap occured so add 1 to the temporary swap count*/
    ADD R4, R4, 4 /*increase the address by 4 bytes*/
    B bubbleSort /*loop back to bubbleSort*/
    
    checkIfSortAgain:
    CMP R6, 0 /*compare the temporary swap count to 0*/
    ADDGT R7, R7, R6 /*if the temporary swap count is greater than 0, add it to the final swap count*/
    MOVGT R6, 0 /*if the temporary swap count is greater than 0, set it to 0 for the next iteration of bubbleSort*/
    MOVGT R4, R5 /*if the temporary swap count is greater than 0, move the starting address stored in R5 to R4 for the next iteration of bubbleSort*/
    BGT bubbleSort /*if the temporary swap count is greater than 0, loop to bubbleSort*/

    MOV R0, R7 /*if the temporary swap count was not greater than 0, the array is fully sorted so the final swap count is moved to R0 for return to sender*/
	
    pop {r4-r11,LR}
    mov pc, lr	 /* asmSort return to caller */
    /* YOUR asmSort CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




