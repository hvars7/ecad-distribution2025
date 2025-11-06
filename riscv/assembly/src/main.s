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

