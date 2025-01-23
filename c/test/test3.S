// Sum of Squares
.global main 

.data
    # Define the data section with two numbers
    n: .word 50
    m: .word 25

.text
main:
    addi sp, sp, -4
    sw ra, 0(sp)

    lw a0, n
    lw a1, m
    call sum_of_squares
    li t0, 0x00100000
    li t1, 1
    sw a0, 0(t0)
    sw t1, 4(t0)

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

sum_of_squares:
    # Check if n (a0) is less than or equal to zero
    bgt a0, x0, recurse_case # __ A01 __

zero_case:
    # If n ≤ 0, return m (a1)
    add a0, a1, x0
    jalr x0, ra, 0 # __ A02 __

recurse_case:
    # Save caller-saved registers on the stack
    add t0, a0, x0           # t0 = a0 (copy n)
    addi sp, sp, -12         # Allocate stack space __ A03 __
    sw a1, 0(sp)             # Save a1 (m)
    sw t0, 4(sp)             # Save t0 (n)
    sw ra, 8(sp)             # Save return address __ A04 __

    # Call the square function
    jal ra, square # __ A05 __

    # Restore registers and stack
    lw a1, 0(sp)             # Restore a1 (m)
    lw t0, 4(sp)             # Restore t0 (n)
    lw ra, 8(sp)             # Restore return address __ A06 __
    addi sp, sp, 12          # Deallocate stack space __ A07 __

    # Update m = m + n^2
    add a1, a1, a0

    # Decrement n: a0 = n - 1
    addi a0, t0, -1

    # Recursive call to sum_of_squares
    addi sp, sp, -4          # Allocate stack space for ra __ A08 __
    sw ra, 0(sp)             # Save return address
    jal ra, sum_of_squares # __ A09 __
    lw ra, 0(sp)             # Restore return address
    addi sp, sp, 4           # Deallocate stack space __ A10 __

    # Return from the function
    jalr x0, ra, 0 # __ A11 __

# Function: square
# Computes the square of an integer (a0 = n), returns result in a0
square:
    addi sp, sp, -8         # Allocate stack space
    sw ra, 0(sp)            # Save return address __ A13 __

    add t0, x0, x0          # t0 = 0 (accumulator for the result)
    add t1, a0, x0          # t1 = a0 (copy of n, multiplicand)
    add t2, a0, x0          # t2 = a0 (copy of n, multiplier)

square_loop:
    andi t3, t2, 1          # Check the lowest bit of t2 (t2 & 1) __ A14 __
    beq t3, x0, skip_add    # If the bit is 0, skip addition
    add t0, t0, t1          # Accumulate: t0 += t1

skip_add:
    sll t1, t1, 1           # Left shift t1 (multiply by 2) __ A15 __
    srl t2, t2, 1           # Right shift t2 (divide by 2) __ A16 __
    bne t2, x0, square_loop # Repeat loop if t2 is not zero __ A17 __

square_end:
    add a0, t0, x0          # Move result to a0

    lw ra, 0(sp)            # Restore return address __ A18 __
    addi sp, sp, 8          # Deallocate stack space
    jalr x0, ra, 0          # Return from function __ A19 __