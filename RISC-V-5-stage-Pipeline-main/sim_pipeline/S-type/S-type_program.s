# Chuẩn bị base address trong x10
lui   x10, 0x10010       # x10 = 0x10010000 (địa chỉ base của data memory)

# Đưa dữ liệu vào các thanh ghi
addi  x5,  x0,  5        # x5 = 5
addi  x6,  x0,  10       # x6 = 10
addi  x7,  x0,  15       # x7 = 15
addi  x8,  x0,  100      # x8 = 100
addi  x9,  x0,  105      # x9 = 105

# Lưu dữ liệu xuống memory
sw    x5,  0(x10)        # M[0x10010000] = 5
sw    x6,  4(x10)        # M[0x10010004] = 10
sw    x7,  8(x10)        # M[0x10010008] = 15
sw    x8, 12(x10)        # M[0x1001000C] = 100
sw    x9, 16(x10)        # M[0x10010010] = 105