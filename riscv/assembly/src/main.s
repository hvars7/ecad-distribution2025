.macro DEBUG_PRINT reg
csrw 0x800, \reg
.endm
	
.text
.global main              # Export the symbol 'main' so we can call it from other files
.type main, @function
main:
    addi sp, sp, -32     # Allocate stack space

    # store on the stack any callee-saved register you might overwrite
    sw   ra, 28(sp)      # Function calls would overwrite


# *** Do some work ***
   # Set inputs: a0 = numerator (N), a1 = denominator (D)
    li   a0, 32          # N = 32
    li   a1, 3           # D = 3

    # Call your division routine
    call div             # on return: a0 = Q, a1 = R

    # Print results (sim environment reads CSR 0x800)
    DEBUG_PRINT a0       # expect Q = 10
    DEBUG_PRINT a1       # expect R = 2
    
    # test2 7 / 32 = 0 r 7
    li a0, 7
    li a1, 32
    call div
    DEBUG_PRINT a0    # 0
    DEBUG_PRINT a1    # 7

    # test3 15 / 15 = 1 r 0
    li a0, 15
    li a1, 15
    call div
    DEBUG_PRINT a0    # 1
    DEBUG_PRINT a1    # 0

    # test4 0 / 9 = 0 r 0
    li a0, 0
    li a1, 9
    call div
    DEBUG_PRINT a0    # 0
    DEBUG_PRINT a1    # 0

    # test5 Divide-by-zero: 100 / 0 -> 0 (rem 0)
    li a0, 100
    li a1, 0
    call div
    DEBUG_PRINT a0    # 0
    DEBUG_PRINT a1    # 0

    # test6 Large unsigned: 0xFFFFFFFF / 2 = 2147483647 r 1
    li a0, -1          # 0xFFFFFFFF
    li a1, 2
    call div
    DEBUG_PRINT a0     # 2147483647
    DEBUG_PRINT a1     # 1
    

# *** End useful work ***


    # A function's return value is stored in a0
    # on exit. The simulator environment
    # regards a return value of 0 as 'success',
    # so return that as we don't have errors to
    # report
    addi a0, zero, 0 

    # load from the stack every register you stored above
    lw   ra, 28(sp)

    addi sp, sp, 32      # Free up stack space
    ret

