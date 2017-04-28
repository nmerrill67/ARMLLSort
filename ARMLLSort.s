; CISC260 HW5 Nate Merrill, Problem 5

.equ SWI_Open, 0x66         ;open a file 
.equ SWI_Close,0x68         ;close a file
.equ SWI_PrChr,0x00         ; Write an ASCII char to Stdout 
.equ SWI_PrStr, 0x69        ; Write a null-ending string 
.equ SWI_PrInt,0x6b         ; Write an Integer 
.equ SWI_RdInt,0x6c         ; Read an Integer from a file 
.equ Stdout, 1              ; Set output target to be Stdout 
.equ SWI_Exit, 0x11         ; Stop execution 
.equ SWI_Malloc, 0x12       ; Allocate heap memory
.equ SWI_Free, 0x13         ; free that memory!

@ ******************* main function *******************************@

LLSort:

    mov r5, #0          ; NULL pointer for head node
    
    ldr r0, =inFileName ; file name string
    mov r1, #0          ; 0 for reading
    swi SWI_Open        ; open the file

    mov r3, r0          ; store the file handle in r3

    mov r0, #Stdout
    ldr r1, =originalOrderMsg
    swi SWI_PrStr

    bl readLoop

    swi SWI_Close

    mov r2, r5		; curr pointer is the  head first

    mov r0, #Stdout
    ldr r1, =sortedList
    swi SWI_PrStr

    mov r7, r5		; return the head pointer

    swi SWI_Free        ; DeAllocate All Heap Memory

    swi SWI_Exit

@ ********************* IO Stuff *********************************** @

readLoop:

    mov r0, r3          ; put the file handle back in r0
    swi SWI_RdInt       ; read the int from file

    bcs endReached      ; Check for the end of the file

    mov r1, r0          ; store int in r1 and r9
    mov r8, r0

    mov r0, #1
    swi SWI_PrInt    ; print that int!

    ldr r1, =space
    swi SWI_PrStr

    sub sp, sp, #4	; remember where we were
    str	lr, [sp, #4]

    bl insertLoop

    b readLoop

endReached:

    mov r0, #Stdout         
    ldr r1, =endOfFileMsg 
    swi SWI_PrStr

    mov pc, lr

    

@ ************* Storing Nodes ********************* @

insertLoop:
    cmp r5, #0
    bleq insertHead     ; list is empty

    ldr r4, [r2, #0]    ; data from curr

    cmp r8, r4          ; compare the new data (r8)
    blle insertFront
    blge checkInsert
    b insertLoop        ; loop back
    mov pc, lr		; back to readLoop

checkInsert:
    
    ldr r4, [r2, #4]	; next pointer
    ldr r4, [r4]	; next data (dereferenced)
    
    cmp r8, r4		; if less than, insert (already greater than)
    blle insertNode


insertHead:

    mov r0, #8
    swi SWI_Malloc     ; Allocate 8 bytes, puts address in r0
    str r8, [r0, #0]	; Store the data 
    mov r1, #0          ; null ptr
    str r1, [r0, #4]     ; store the nullptr in the node
    mov  r5, r0         ; Move the address of head to r5

    mov  r2, r5		; r2 is curr. The head is now curr

    add sp, sp, #4
    ldr lr, [sp, #0]
    sub lr, lr, #4	; Go back to the beginning of the readLoop 

    mov pc, lr

insertFront:

    mov r0, #8
    swi SWI_Malloc     ; Allocate 8 bytes, puts address in r0
    str r8, [r0, #0]	; Store the data

    mov r1, r5	; get the pointer to the head, make it the next for the new head
    str r1, [r0, #4]     ; store the next ptr in the node

    mov r5, r0		; the  new head pointer
    mov r2, r5		;  new curr
    
    add sp, sp, #4
    ldr lr, [sp, #0]
    sub lr, lr, #4	; Go back to the beginning of the readLoop 

    mov pc, lr

insertBack:

    mov r0, #8
    swi SWI_Malloc     ; Allocate 8 bytes, puts address in r0
    str r8, [r0, #0]	; Store the data


    str r1, [r0, #4]     ; store the next ptr in the node
    
    add sp, sp, #4
    ldr lr, [sp, #0]
    sub lr, lr, #4	; Go back to the beginning of the readLoop 

    mov pc, lr

insertNode: 

    mov r0, #8
    swi SWI_Malloc     ; Allocate 8 bytes, puts address in r0

    

    str r8, [r0, #0]	; Store the data

    ldr r4, [r2, #4]	; the next ptr that we want to insert in front of
    str r4, [r0, #4]     ; store the next ptr in the node

    str r0, [r2, #4]    ; store the new address in the prev    

    add sp, sp, #4
    ldr lr, [sp, #0]
    sub lr, lr, #4	; Go back to the beginning of the readLoop 

    mov pc, lr
    
@ *********************** String Stuff ********************* @

space:
    .asciz  "->"            

inFileName:
    .asciz  "Test.dat"

endOfFileMsg:
    .asciz  "\n ...End of file\n"

originalOrderMsg:
    .asciz "The original order in the file: \n"

sortedListMsg:
    .asciz "\nSorted list:\n