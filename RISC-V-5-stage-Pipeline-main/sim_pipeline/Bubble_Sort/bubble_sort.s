.data
array:  .word 5, 1, 4, 2, 8      # mảng cần sắp xếp
n:      .word 5                  # số phần tử

.text
.globl main

# Lệnh thực thi 
main:
    la   s0, 0x8   # s0 = địa chỉ mảng
    lw   s1, 0x28           # s1 = n
    addi s1, s1, -1      # s1 = n-1 (số vòng lặp ngoài)
loop1:
    blez s1, exit       # nếu s1 <= 0 thì thoát
    li   t0, 0           # i = 0
    la   t1, 0x00000008       # t1 = con trỏ đầu mảng
loop2:
    bge  t0, s1, next_outer  # nếu i >= s1, sang vòng ngoài
    lw   t2, 0(t1)       # t2 = array[i]
    lw   t3, 4(t1)       # t3 = array[i+1]
    ble  t2, t3, no_swap # nếu array[i] <= array[i+1] thì bỏ qua
    sw   t3, 0(t1)
    sw   t2, 4(t1)
no_swap:
    addi t0, t0, 1      
    addi t1, t1, 4      
    j    loop2

next_outer:
    addi s1, s1, -1     
    j    loop1

exit:
    beq x2, x2, exit