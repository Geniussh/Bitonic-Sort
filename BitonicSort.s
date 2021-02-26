////////////////////////
//                    //
//       main         //
//                    //
////////////////////////

// Test FindM
ADDI     X0, XZR, #32
BL       FindM
PUTINT   X0
ADDI     X0, XZR, #10
PUTCHAR  X0

// Original List
LDA      X0, array
LDA      X1, arraysize
LDUR     X1, [X1, #0]
BL       printList

// Bitonic Sort
LDA      X0, array
LDA      X1, arraysize
LDUR     X1, [X1, #0]
BL       BLueRecursion    

// Sorted List
LDA      X0, array
LDA      X1, arraysize
LDUR     X1, [X1, #0]
BL       printList
STOP

////////////////////////
//                    //
//       FindM        //
//                    //
////////////////////////
FindM:
    // X0: N
    // Return value at X0: the largest power of 2 less than X0
	
	// X11 - X12: temporary register

	// Callee's responsibility
	SUBI    SP, SP, #16		// Set up stack pointer, allocate 16 bits of memory in stack
	STUR    LR, [SP, #0]	// Store LR to SP[0]
	
	ADDI    X12, XZR, #1	// Iterator for the while loop, starting from 1
	ADDI    X11, XZR, #1	// Previous value of X12, to be returned at X0

while:
	CMP     X12, X0			// Compare current M with N
	B.GE    exit_FindM		// If M is larger then return previous M stored in X11
	ADD     X11, XZR, X12	// Update X11
	LSL     X12, X11, #1	// Double X12 for the next possible M value
	B       while			// Re-enter while loop
	
exit_FindM:
	ADD     X0, XZR, X11	// Return previous M stored in X11
	
	// Callee's responsibility
	LDUR    LR, [SP, #0]	// Restore LR from SP[0]
	ADDI    SP, SP, #16		// Restore SP to original value, free the current stack
	BR      LR 				// Return to caller
    
////////////////////////
//                    //
//      RedLoop       //
//                    //
////////////////////////
RedLoop:
    // X0: base address of the (sub)list
    // X1: size of the (sub)list
    // X2: the largest power of 2 less than x1
	
	// X11 - X16: temporary register
    
	// Callee's responsibility
	SUBI    SP, SP, #16		// Set up stack pointer, allocate 16 bits of memory in stack
	STUR    LR, [SP, #0]	// Store LR to SP[0]
	
	ADDI    X11, XZR, #0	// Set X11 to i
	SUB     X12, X1, X2		// Set X12 to N - M
	SUBI    X12, X12, #1	// Set X12 to N-M-1
	
for:
	CMP	    X11, X12		// Compare i with N-M-1
	B.GT    exit_RedLoop	// Exit for loop if i > N-M-1
	ADD	    X13, X11, XZR	// index i for swap
	ADD	    X14, X11, X2	// index i + M for swap
	LSL	    X13, X13, #3	// 8 * i
	LSL	    X14, X14, #3	// 8 * (i+M)
	ADD	    X13, X0, X13	// address of a[i]
	ADD	    X14, X0, X14	// address of a[i+M]
	LDUR    X15, [X13, #0]  // Set X15 to be a[i]
	LDUR    X16, [X14, #0]	// Set X16 to be a[i+M]
	CMP	    X15, X16		// Compare a[i] and a[i+M]
	B.GT    Swap			// if a[i] > a[i+M] then swap
	ADDI    X11, X11, #1	// i++
	B	    for				// re-enter for loop
	
Swap:
	STUR    X15, [X14, #0]	// Store a[i] to the original location of a[i+M]
	STUR    X16, [X13, #0]	// Store a[i+M] to the original location of a[i]
	ADDI    X11, X11, #1	// i++
	B       for				// re-enter for loop

exit_RedLoop:
	// Callee's responsibility
	LDUR    LR, [SP, #0]	// Restore LR from SP[0]
	ADDI    SP, SP, #16		// Restore SP to original value, free the current stack
	BR      LR				// Return to caller
    
////////////////////////
//                    //
//    RedRecursion    //
//                    //
////////////////////////
RedRecursion:
    // X0: base address of the (sub)list
    // X1: size of the (sub)list

	// Callee's responsibility
	SUBI    SP, SP, #64		// Set up stack pointer, allocate 64 bits of memory in stack
	STUR    LR, [SP, #0]	// Store LR to SP[0]
	
	CMPI    X1, #1			// Comapre N with 1
	B.LE    exit_RR			// Only continue if N > 1
	STUR    X0, [SP, #24]	// Caller's responsibility: save X0
	ADD	    X0, XZR, X1		// Input for FindM: X0 to be N
	BL      FindM			// Call FindM(N)
	ADD	    X2, XZR, X0		// Input for RedLoop: X2 to be M
	LDUR    X0, [SP, #24]	// Caller's responsibility: load back X0
	BL      RedLoop			// Call RedLoop(a, N, M)
	
	STUR    X0, [SP, #16]	// Caller's responsibility: save X0
	STUR    X1, [SP, #8]	// Caller's responsibility: save sublist size N
	STUR    X2, [SP, #48]	// Caller's responsibility: save M
	ADD	    X1, XZR, X2		// Input for RedRecursion: M in X2 stored before
	BL	    RedRecursion	// Call RedRecursion(a, M)
	LDUR    X0, [SP, #16]	// Caller's responsibility: load back X0
	LDUR    X1, [SP, #8]	// Caller's responsibility: load back N
	LDUR    X2, [SP, #48]	// Caller's responsibility: load back M
	
	STUR    X0, [SP, #40]	// Caller's responsibility: save X0
	STUR    X1, [SP, #32]	// Caller's responsibility: save sublist size N
	STUR    X2, [SP, #56]	// Caller's responsibility: save M
	SUB     X1, X1, X2		// Input 2 for RedRecursion: N - M
	LSL     X12, X2, #3		// 8 * M
	ADD	    X0, X0, X12		// Input 1 for RedRecursion: address of a[M]
	BL      RedRecursion	// Call RedRecursion(a[M], N-M)
	LDUR    X0, [SP, #40]	// Caller's responsibility: load back X0
	LDUR    X1, [SP, #32]	// Caller's responsibility: load back size N
	LDUR    X2, [SP, #56]	// Caller's responsibility: load back M

exit_RR:
	// Callee's responsibility
	LDUR    LR, [SP, #0]	// Restore LR from SP[0]
	ADDI    SP, SP, #64		// Restore SP to original value, free the current stack
	BR      LR 				// Return to caller
    
////////////////////////
//                    //
//      BLueLoop      //
//                    //
////////////////////////
BLueLoop:
    // X0: base address of the (sub)list
    // X1: size of the (sub)list
    // X2: the largest power of 2 less than X1
	
	// X11 - X16: temporary register
    
    // Callee's responsibility
	SUBI    SP, SP, #16		// Set up stack pointer, allocate 16 bits of memory in stack
	STUR    LR, [SP, #0]	// Store LR to SP[0]
	
	ADDI    X11, XZR, #2	// Set X11 to 2
	MUL     X11, X11, X2	// Set X11 to 2 * M
	SUB	    X11, X11, X1	// Set X11 to i = 2 * M - N
	SUBI    X12, X2, #1		// Set X12 to M-1
for_BlueLoop:
	CMP	    X11, X12		// Compare i with N-M-1
	B.GT    exit_BlueLoop	// exit for loop if i > N-M-1
	ADD	    X13, X11, XZR	// index i for swap 
	ADDI    X14, XZR, #2	// Set X14 to 2
	MUL	    X14, X14, X2	// Set X14 to 2 * M
	SUB	    X14, X14, X13	// Set X14 to 2 * M - i
	SUBI    X14, X14, #1	// X14: index 2M - i - 1 for swap
	LSL	    X13, X13, #3	// Set X13 to 8 * i
	LSL	    X14, X14, #3	// Set X14 to 8 * (2M - i - 1)
	ADD	    X13, X0, X13	// address of a[i]
	ADD	    X14, X0, X14	// address of a[i+M]
	LDUR    X15, [X13, #0]  // a[i]
	LDUR    X16, [X14, #0]	// a[i+M]
	CMP	    X15, X16		// Swap if a[i] > a[i+M]
	B.GT    Swap_BlueLoop	// Call Swap
	ADDI    X11, X11, #1	// i++
	B       for_BlueLoop	// re-enter for loop
	
Swap_BlueLoop:
	STUR    X15, [X14, #0]	// Store a[i] to the original location of a[i+M]
	STUR    X16, [X13, #0]	// Store a[i+M] to the original location of a[i]
	ADDI    X11, X11, #1	// i++
	B       for_BlueLoop	// re-enter for loop

exit_BlueLoop:
	// Callee's responsibility
	LDUR    LR, [SP, #0]	// Restore LR from SP[0]
	ADDI    SP, SP, #16		// Restore SP to original value, free the current stack
	BR      LR				// Return to caller

////////////////////////
//                    //
//    BLueRecursion   //
//                    //
////////////////////////
BLueRecursion:
    // X0: base address of the (sub)list
    // X1: size of the (sub)list

    // Callee's responsibility
	SUBI    SP, SP, #64		// Set up stack pointer, allocate 64 bits of memory in stack
	STUR    LR, [SP, #0]	// Store LR to SP[0]
	
	CMPI    X1, #1			// Compare N with 1
	B.LE    exit_BR			// Only continue if N > 1
	STUR    X0, [SP, #8]	// Caller's responsibility: save X0
	ADD	    X0, XZR, X1		// Input for FindM: X0 to be N
	BL      FindM			// Call FindM(N)
	ADD	    X2, XZR, X0		// Input for BlueLoop: X2 to be M
	LDUR    X0, [SP, #8]	// Caller's responsibility: load back X0
	
	STUR    X0, [SP, #16]	// Caller's responsibility: save X0
	STUR    X1, [SP, #24]	// Caller's responsibility: save sublist size N
	STUR    X2, [SP, #32]	// Caller's responsibility: save M
	ADD	    X1, XZR, X2		// Input for BlueRecursion: M in X2 stored before
	BL      BlueRecursion	// Call BlueRecursion(a, M)
	LDUR    X0, [SP, #16]	// Caller's responsibility: load back X0
	LDUR    X1, [SP, #24]	// Caller's responsibility: load back size N
	LDUR    X2, [SP, #32]	// Caller's responsibility: load back M
	
	STUR    X0, [SP, #40]	// Caller's responsibility: save X0
	STUR    X1, [SP, #48]	// Caller's responsibility: save sublist size N
	STUR    X2, [SP, #56]	// Caller's responsibility: save M
	SUB	    X1, X1, X2		// Input 2 for BlueRecursion: N - M
	LSL     X12, X2, #3		// 8 * M
	ADD     X0, X0, X12		// Input 1 for BlueRecursion: address of a[M]
	BL      BlueRecursion	// Call BlueRecursion(a[M], N-M)
	LDUR    X0, [SP, #40]	// Caller's responsibility: load back X0
	LDUR    X1, [SP, #48]	// Caller's responsibility: load back size N
	LDUR    X2, [SP, #56]	// Caller's responsibility: load back M
	
	BL      BlueLoop		// Call BlueLoop(a, N, M)
	
	STUR    X0, [SP, #16]	// Caller's responsibility: save address X0
	STUR    X1, [SP, #24]	// Caller's responsibility: save sublist size N
	STUR    X2, [SP, #32]	// Caller's responsibility: save M
	ADD     X1, XZR, X2		// Input for RedRecursion: M in X2 stored before
	BL      RedRecursion	// Call RedRecursion(a, M)
	LDUR    X0, [SP, #16]	// Caller's responsibility: load back address X0
	LDUR    X1, [SP, #24]	// Caller's responsibility: load back size N
	LDUR    X2, [SP, #32]	// Caller's responsibility: load back M
	
	STUR    X0, [SP, #40]	// Caller's responsibility: save address X0
	STUR    X1, [SP, #48]	// Caller's responsibility: save sublist size N
	STUR    X2, [SP, #56]	// Caller's responsibility: save M
	SUB	    X1, X1, X2		// Input 2 for RedRecursion: N - M
	LSL     X12, X2, #3		// 8 * M
	ADD     X0, X0, X12		// Input 1 for RedRecursion: address of a[M]
	BL      RedRecursion	// Call RedRecursion(a[M], N-M)
	LDUR    X0, [SP, #40]	// Caller's responsibility: load back address X0
	LDUR    X1, [SP, #48]	// Caller's responsibility: load back size N
	LDUR    X2, [SP, #56]	// Caller's responsibility: load back M

exit_BR:
	// Callee's responsibility
	LDUR    LR, [SP, #0]	// Restore LR from SP[0]
	ADDI    SP, SP, #64		// Restore SP to original value, free the current stack
	BR      LR				// Return to caller
    
////////////////////////
//                    //
//     printList      //
//                    //
////////////////////////
printList:
    // X0: base address
    // X1: length of the array

	MOV     X2, XZR
	ADDI    X5, XZR, #32
	ADDI    X6, XZR, #10
printList_loop:
    CMP     X2, X1
    B.EQ    printList_loopEnd
    LSL     X3, X2, #3
    ADD     X3, X3, X0
	LDUR    X4, [X3, #0]
    PUTINT  X4
    PUTCHAR X5
    ADDI    X2, X2, #1
    B       printList_loop
printList_loopEnd:    
    PUTCHAR X6
    BR      LR