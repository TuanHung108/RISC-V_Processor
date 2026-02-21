    .data
# Ma trận dầu vòa (2x3)
A: .word 1, 2, 3, 4, 5, 6
B: .word 6, 5, 4, 3, 2, 1
m: .word 2 # hàng
n: .word 3 # cột

# Ma trận đầu ra (2x3 = 6 word = 24 byte)
C: .space 24

space: .byte 32, 0      # " "
newline: .byte 10, 0    # "\n"

    .text
    .globl main
main:
    # Thực hiện cộng ma trận
    la t0, A    # t0 = &A[0]
    la t1, B    # t1 = &B[0]
    la t2, C    # t2 = &C[0]
    li t3, 6    # i = 6

sum_loop:
    beq t3, x0, print_result # i = 0 -> print_result
    
    lw t4, 0(t0)    # t4 = A[i]
    lw t5, 0(t1)    # t5 = B[i]
    add t6, t4, t5  # t6 = t4 + t5
    sw t6, 0(t2)    # &C[i] = t6

    addi t0, t0, 4
    addi t1, t1, 4
    addi t2, t2, 4
    addi t3, t3, -1
    j sum_loop

print_result:
    la t2, C # trỏ t2 lại về địa chỉ của C[0]
    li t3, 0 # index of elements

row_loop:
    li t4, 0 # chỉ số cột

col_loop:
    lw a1, 0(t2) # a0 = C[i]
    li a0, 1     # print integer
    ecall

    la a1, space # In khoảng trắng
    li a0, 4     # print string
    ecall

    addi t2, t2, 4
    addi t3, t3, 1
    addi t4, t4, 1

    lw t0, n
    blt t4, t0, col_loop # mỗi hàng 3 phần tử

    la a1, newline # xuống dòng sau khi đủ 3 phần tử ở mỗi hàng
    li a0, 4
    ecall

    lw t5, m
    lw t6, n
    mul t1, t5, t6
    blt t3, t1, row_loop

exit:
    li a0, 10
    ecall




