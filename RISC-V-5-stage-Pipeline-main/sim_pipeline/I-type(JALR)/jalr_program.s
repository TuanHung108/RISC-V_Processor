    .globl _start
_start:

    addi x5, x0, 10       # x5 = 10
    addi x6, x0, 8        # x6 = 8 (offset base)
    
    jalr x1, x6, 4        # jump tới PC = x6 + 4, lưu return address vào x1
    
    addi x5, x5, 5

target:
    addi x7, x0, 123      # x7 = 123, điểm nhảy tới
    addi x8, x1, 0        # copy địa chỉ trả về vào x8 để kiểm tra
