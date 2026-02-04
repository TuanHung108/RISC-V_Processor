    addi x5, x0, 5          # x5 = 5
    j    target             # nhảy đến nhãn target

    addi x5, x5, 10         # (bị bỏ qua vì đã nhảy)

target:
    addi x6, x0, 99         # x6 = 99
