    .globl _start
_start:
    # Khởi tạo
    addi x1, x0, 5          # x1 = 5
    addi x2, x0, 5          # x2 = 5
    addi x3, x0, 7          # x3 = 7
    addi x4, x0, -3         # x4 = -3 (0xFFFFFFFD)

# =====================================================
# BEQ
# =====================================================
    beq  x1, x2, beq_taken   # 5 == 5 → nhảy
    addi x5, x0, 111         # không thực hiện
beq_taken:
    addi x5, x0, 1           # x5=1

    beq  x1, x3, beq_not_taken # 5 == 7 → sai, không nhảy
    addi x6, x0, 2           # x6=2
beq_not_taken:

# =====================================================
# BNE
# =====================================================
    bne  x1, x3, bne_taken   # 5 != 7 → nhảy
    addi x7, x0, 222         # không thực hiện
bne_taken:
    addi x7, x0, 3           # x7=3

    bne  x1, x2, bne_not_taken # 5 != 5 → sai, không nhảy
    addi x8, x0, 4           # x8=4
bne_not_taken:

# =====================================================
# BLT (signed)
# =====================================================
    blt  x4, x3, blt_taken   # -3 < 7 → nhảy
    addi x9, x0, 333         # không thực hiện
blt_taken:
    addi x9, x0, 5           # x9=5

    blt  x3, x1, blt_not_taken # 7 < 5 → sai
    addi x10, x0, 6          # x10=6
blt_not_taken:

# =====================================================
# BGE (signed)
# =====================================================
    bge  x3, x1, bge_taken   # 7 >= 5 → nhảy
    addi x11, x0, 444        # không thực hiện
bge_taken:
    addi x11, x0, 7          # x11=7

    bge  x4, x3, bge_not_taken # -3 >= 7 → sai
    addi x12, x0, 8          # x12=8
bge_not_taken:

# =====================================================
# BLTU (unsigned)
# =====================================================
    bltu x1, x3, bltu_taken  # 5 < 7 (unsigned) → nhảy
    addi x13, x0, 555        # không thực hiện
bltu_taken:
    addi x13, x0, 9          # x13=9

    bltu x3, x1, bltu_not_taken # 7 < 5 → sai
    addi x14, x0, 10         # x14=10
bltu_not_taken:

# =====================================================
# BGEU (unsigned)
# =====================================================
    bgeu x3, x1, bgeu_taken  # 7 >= 5 → nhảy
    addi x15, x0, 666        # không thực hiện
bgeu_taken:
    addi x15, x0, 11         # x15=11

    bgeu x1, x3, bgeu_not_taken # 5 >= 7 → sai
    addi x16, x0, 12         # x16=12
bgeu_not_taken:

# =====================================================
# Kết thúc
# =====================================================
done:
    j done
