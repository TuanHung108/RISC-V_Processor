    .text
    # nạp giá trị khởi đầu
    addi x1, x0, 5        # x1 = 5
    addi x2, x0, 10       # x2 = 10
    addi x3, x0, -3       # x3 = -3 (0xFFFFFFFD)

    # test lệnh R-type
    add  x4, x1, x2       # x4 = 5 + 10 = 15
    sub  x5, x2, x1       # x5 = 10 - 5 = 5
    and  x6, x1, x2       # x6 = 5 AND 10 = 0
    or   x7, x1, x3       # x7 = 5 OR -3 = 0xFFFFFFFF (=-1)
    xor  x8, x1, x3       # x8 = 5 XOR -3 = 0xFFFFFFFA (-6)
    slt  x9, x3, x2       # x9 = (x3 < x2) ? 1 : 0 → 1 (vì -3 < 10)
    sll  x10, x1, x2      # x10 = 5 << 10 = 5120
    srl  x11, x2, x1      # x11 = 10 >> 5 (logic) = 0
    sra  x12, x3, x1      # x12 = -3 >> 5 (arith) = -1

    # để dễ kiểm tra, copy kết quả ra các thanh ghi lớn
    addi x13, x4, 0
    addi x14, x5, 0
    addi x15, x6, 0
    addi x16, x7, 0
    addi x17, x8, 0
    addi x18, x9, 0
    addi x19, x10, 0
    addi x20, x11, 0
    addi x21, x12, 0

    # dừng chương trình (tùy simulator của bạn)
