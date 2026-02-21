# addi: cộng hằng
    addi x5, x0, 10        # x5 = 0 + 10 = 10

    # xori: XOR với hằng số
    xori x6, x5, 3         # x6 = x5 ^ 3 = 10 ^ 3 = 9

    # ori: OR với hằng số
    ori  x7, x6, 4         # x7 = x6 | 4 = 9 | 4 = 13

    # andi: AND với hằng số
    andi x8, x7, 7         # x8 = x7 & 7 = 13 & 7 = 5
