# t0 = base của mảng
# t1 = số phần tử của mảng
# t2 = i (index vòng ngoài - đếm số lần lặp)
# t3 = j (index vòng trong)
# t4 = offset - di chuyển đến các phần tử trong mảng (&arr[i] = t0 + t4*i) 
# t5 = giá trị arr[j]
# t6 = giá trị arr[j+1]

    .data
arr: .word 5, 2, 4, 3, 1
n: .word 5

space: .byte 32, 0

    .text
    .globl main
main:
    # Load data
    la t0, arr
    lw t1, n        # t1 = n
    addi t1, t1, 1   # t1 = n-1
    li t2, 0        # Vòng ngoài i = 0 -> n-1

outer_loop:
    bge t2, t1, print_result # i >= n
    add t4, t0, x0           # t4 = &arr[0]
    li t3, 0                 # Vòng trong j = 0 -> n-1

inner_loop:
    bge t3, t1, next_outer  # j >= n
    slli t4, t3, 2          # offset = j*4
    add t4, t0, t4          # t4 = &arr[j] = base + offset
    
    lw t5, 0(t4)            # arr[j]
    lw t6, 4(t4)            # arr[j+1]
    ble t5, t6, no_swap     # t5 < t6 -> no_swap

    # swap arr[j] và arr[j+1]
    sw t6, 0(t4)
    sw t5, 4(t4)

no_swap:
    addi t3, t3, 1
    j inner_loop

next_outer:
    addi t2, t2, 1
    j outer_loop

print_result:
    la t0, arr
    li t2, 1

print_loop:
    bge t2, t1, exit
    lw a1, 0(t0)
    li a0, 1
    ecall

    la a1, space
    li a0, 4
    ecall

    addi t0, t0, 4
    addi t2, t2, 1
    j print_loop

exit:
    li a0, 10
    ecall
