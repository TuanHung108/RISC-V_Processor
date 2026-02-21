# quy ước RARS:
# a7 = mã số syscall
# a0, a1,... = tham số truyền vào        
        
        .data
msg:    .asciiz "Tong = "

        .text
        .globl main

main:
        # Gán giá trị cho a và b
        li t0, 5       # t0 = a = 5
        li t1, 7       # t1 = b = 7

        # sum = a + b
        add t2, t0, t1 # t2 = t0 + t1

        # In ra "Tong = "
        li a7, 4       # syscall: print_string
        la a0, msg     # a0 = địa chỉ của msg (la = load address)
        ecall

        # In ra sum
        li a7, 1       # syscall: print_int
        mv a0, t2      # copy giá trị từ t2 sang a0
        ecall

        # In xuống dòng
        li a7, 11      # syscall: print_char
        li a0, 10      # ký tự '\n'
        ecall

        # Thoát chương trình
        li a7, 10
        ecall
