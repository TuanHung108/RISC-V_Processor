# Lệnh add
    .text
    addi x1, x0, 5
    addi x2, x0, 7
    add x3, x1, x2

# Lệnh addi
    .text
    addi x1, x0, 10
    addi, x2, x1, 3

# Lệnh lw
    .data
value: .word 32

    .text
    la x1, value    # x1 = địa chỉ biến value
    lw x2, 0(x1)    # x2 = Mem[x1]

# Lệnh sw
    .data
value: .word 0

    .text
    addi x1, x0, 55 # x1 = 55
    la x2, value    # x2 = địa chỉ biến value
    sw x1, 0(x2)    # Mem[x2] = 55

# Lệnh beq
    .text
    addi x1, x0, 5  
    addi x2, x0, 5
    beq x1, x2, else    # x1=x2 -> else
    addi x3, x0, 100    
else:
    addi x3, x0, 200

# Lệnh bne
    .text
    addi x1, x0, 5
    addi x2, x0, 6
    bne x1, x2, else
    addi x3, x0, 100
else:
    addi x3, x0, 300

# Lệnh jal
    .text
    jal x1, target  # jump tới target, lưu địa chỉ PC+4 vào x1
    addi x2, x0, -22
target:
    addi x2, x0, 123

# Lệnh jump
    .text
    addi x5, x0, 10
    j target
    addi x6, x0, 20
target:
    addi x7, x0, 30
