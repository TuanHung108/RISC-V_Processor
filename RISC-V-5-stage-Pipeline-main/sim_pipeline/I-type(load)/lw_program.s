    .option norvc
    .text
    .globl _start
_start:
    # Base của DMEM
    addi x1, x0, 0          # x1 = 0x00000000 (MEMORY_OFFSET)

    # ---- Ghi trực tiếp các word ----
    addi x2, x0, 100        # M[0] = 100
    sw   x2, 0(x1)

    addi x2, x0, 200        # M[4] = 200
    sw   x2, 4(x1)

    addi x2, x0, 300        # M[8] = 300
    sw   x2, 8(x1)

    # ---- LOADs test ----
    lw   x10, 0(x1)         # x10 = 100
    lw   x11, 4(x1)         # x11 = 200
    lw   x12, 8(x1)         # x12 = 300

done:
    j done
