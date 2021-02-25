////////////////////////
//                    //
// Project Submission //
//                    //
////////////////////////

// Partner1: Shihao Shen, A15425727
// Partner2: Zhetai Zhou, (Student ID here)

////////////////////////
//                    //
//       main         //
//                    //
////////////////////////

LDA 	X0, array
LDA 	X1, arraysize
LDUR 	X1, [X1, #0]
BL		RedRecursion

LDA 	X0, array
LDA 	X1, arraySize
LDUR	X1, [X1, #0]
BL	    printList
STOP

////////////////////////
//                    //
//       FindM        //
//                    //
////////////////////////
FindM:
    // X0: N
    // Return value at X0: the largest power of 2 less than X0

    // INSERT YOUR CODE HERE
	SUBI	SP, SP, #16
	STUR	LR, [SP, #0]
	
	ADDI 	X12, XZR, #1
	ADDI	X11, XZR, #1
while:
	CMP		X12, X0
	B.GE	exit_FindM
	ADD		X11, XZR, X12
	LSL		X12, X11, #1
	B		while
	
exit_FindM:
	ADD		X0, XZR, X11
	LDUR	LR, [SP, #0]
	ADDI 	SP, SP, #16
	BR LR 
    
////////////////////////
//                    //
//      RedLoop       //
//                    //
////////////////////////
RedLoop:
    // X0: base address of the (sub)list
    // X1: size of the (sub)list
    // X2: the largest power of 2 less than x1
    
	// INSERT YOUR CODE HERE
	SUBI	SP, SP, #16
	STUR	LR, [SP, #0]
	
	ADDI	X11, XZR, #0	// Set X11 to i
	SUB		X12, X1, X2		// N - M
	SUBI	X12, X12, #1	// Set X12 to N-M-1
for:
	CMP		X11, X12
	B.GT	exit_RedLoop	// exit for loop if i > N-M-1
	ADD		X3, X11, XZR	// index i for swap function
	ADD		X4, X11, X2		// index i + M for swap function
	LSL		X13, X3, #3		// 8 * i
	LSL		X14, X4, #3		// 8 * (i+M)
	ADD		X13, X0, X13	// address of a[i]
	ADD		X14, X0, X14	// address of a[i+M]
	LDUR	X15, [X13, #0]  // a[i]
	LDUR	X16, [X14, #0]	// a[i+M]
	CMP		X15, X16
	B.GT	Swap
	ADDI	X11, X11, #1	// i++
	B		for
	
Swap:
	STUR	X15, [X14, #0]
	STUR	X16, [X13, #0]
	ADDI	X11, X11, #1	// i++
	B		for

exit_RedLoop:
	LDUR	LR, [SP, #0]
	ADDI 	SP, SP, #16
	BR LR
    
////////////////////////
//                    //
//    RedRecursion    //
//                    //
////////////////////////
RedRecursion:
    // X0: base address of the (sub)list
    // X1: size of the (sub)list

    // INSERT YOUR CODE HERE
	SUBI	SP, SP, #64
	STUR	LR, [SP, #0]
	
	CMPI	X1, #1
	B.LE	exit_RR
	STUR	X0, [SP, #24]	// Caller's responsibility: save X0
	ADD		X0, XZR, X1		// Input for FindM: X0 to be N
	BL 		FindM
	ADD		X2, XZR, X0		// Input for RedLoop: X2 to be M
	LDUR	X0, [SP, #24]	// Caller's responsibility: load back X0
	BL		RedLoop
	
	STUR	X0, [SP, #16]	// Caller's responsibility: save X0
	STUR	X1, [SP, #8]	// Caller's responsibility: save sublist size N
	STUR	X2, [SP, #48]	// Caller's responsibility: save M
	ADD		X1, XZR, X2		// Input for RedRecursion: M in X2 stored before
	BL		RedRecursion
	LDUR	X0, [SP, #16]	// Caller's responsibility: load back X0
	LDUR	X1, [SP, #8]	// Caller's responsibility: load back N
	LDUR	X2, [SP, #48]	// Caller's responsibility: load back M
	
	STUR	X0, [SP, #40]	// Caller's responsibility: save X0
	STUR	X1, [SP, #32]	// Caller's responsibility: save sublist size N
	STUR	X2, [SP, #56]	// Caller's responsibility: save M
	SUB		X1, X1, X2		// Input 2 for RedRecursion: N - M
	LSL		X12, X2, #3		// 8 * M
	ADD		X0, X0, X12		// Input 1 for RedRecursionaddress of a[M]
	BL		RedRecursion
	LDUR	X0, [SP, #40]	// Caller's responsibility: load back X0
	LDUR	X1, [SP, #32]	// Caller's responsibility: load back size N
	LDUR	X2, [SP, #56]	// Caller's responsibility: load back M

exit_RR:
	LDUR	LR, [SP, #0]
	ADDI 	SP, SP, #64
	BR LR 
    
////////////////////////
//                    //
//      BLueLoop      //
//                    //
////////////////////////
BLueLoop:
    // X0: base address of the (sub)list
    // X1: size of the (sub)list
    // X2: the largest power of 2 less than X1
    
    // INSERT YOUR CODE HERE
	
	BR LR 

////////////////////////
//                    //
//    BLueRecursion   //
//                    //
////////////////////////
BLueRecursion:
    // X0: base address of the (sub)list
    // X1: size of the (sub)list

    // INSERT YOUR CODE HERE
	
	BR LR 
    
////////////////////////
//                    //
//     printList      //
//                    //
////////////////////////
printList:
    // X0: base address
    // X1: length of the array

	MOV X2, XZR
	ADDI X5, XZR, #32
	ADDI X6, XZR, #10
printList_loop:
    CMP X2, X1
    B.EQ printList_loopEnd
    LSL X3, X2, #3
    ADD X3, X3, X0
	LDUR X4, [X3, #0]
    PUTINT X4
    PUTCHAR X5
    ADDI X2, X2, #1
    B printList_loop
printList_loopEnd:    
    PUTCHAR X6
    BR LR