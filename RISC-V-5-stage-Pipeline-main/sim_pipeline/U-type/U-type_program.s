    .text
    .globl _start
_start:

    # --- Test LUI ---
    lui x1, 0x12345        # x1 = 0x12345000
    lui x2, 0xABCDE        # x2 = 0xABCDE000
    lui x3, 0x00001        # x3 = 0x00001000
    lui x4, 0xFFFFF        # x4 = 0xFFFFF000 (=-0x1000 nếu signed)

    # --- Test AUIPC ---
    auipc x5, 0x10         # x5 = PC + 0x10000
    auipc x6, 0xABCDE      # x6 = PC + 0xABCDE000
    auipc x7, 0x0          # x7 = PC
    auipc x8, 0xFFFFF      # x8 = PC - 0x1000

done:
    j done                 # vòng lặp vô hạn để dừng chương trình
