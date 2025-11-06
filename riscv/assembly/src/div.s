.macro DEBUG_PRINT reg
csrw 0x800, \reg
.endm
	
.text
.global div              # Export the symbol 'div' so we can call it from other files
.type div, @function
div:
    addi sp, sp, -32     # Allocate stack space

    # store any callee-saved register you might overwrite
    sw   ra, 28(sp)      # Function calls would overwrite
    sw   s0, 24(sp)      # If t0-t6 is not enough, can use s0-s11 if I save and restore them
    # ...

    # do your work
    beqz a1, 1f
    li   t0, 0
    li   t1, 0
    mv   t2, a0
    li   t3, 1
    slli t3, t3, 31
    mv   t4, a1

0:  srl  t5, t2, 31
    slli t1, t1, 1
    or   t1, t1, t5
    slli t2, t2, 1

    bltu t1, t4, 2f
    sub  t1, t1, t4
    or   t0, t0, t3

2:  srli t3, t3, 1
    bnez t3, 0b

    mv   a0, t0
    mv   a1, t1
    j    3f

1:  li    a0, 0
    li    a1, 0

3:
    # example of printing inputs a0 and a1
    DEBUG_PRINT a0
    DEBUG_PRINT a1

    # load every register you stored above
    lw   ra, 28(sp)
    lw   s0, 24(sp)
    # ...
    addi sp, sp, 32      # Free up stack space
    ret

