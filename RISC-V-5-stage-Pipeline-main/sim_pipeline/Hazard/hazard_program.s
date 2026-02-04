main:
    addi x2, x0, 5           # Khởi tạo x2 = 5
    addi x3, x0, 12          # Khởi tạo x3 = 12
    addi x7, x3, -9          # RAW: x7 phụ thuộc vào kết quả x3 (data hazard)
    or   x4, x7, x2          # RAW: x4 phụ thuộc vào x7, x2 (data hazard)
    and  x5, x3, x4          # RAW: x5 phụ thuộc vào x3, x4 (data hazard)
    add  x5, x5, x4          # RAW: x5 phụ thuộc ngay vào x5 (chained dependency, data hazard)
    beq  x5, x7, end         # Control hazard: cần biết x5, x7 để quyết định nhảy

    slt  x4, x3, x4          # RAW: x4 phụ thuộc vào x3, x4 (ghi/đọc cùng lúc – data hazard)
    beq  x4, x0, around      # Control hazard: nhảy dựa trên kết quả của slt

    addi x5, x0, 0           # Khởi tạo lại x5

around:
    slt  x4, x7, x2          # RAW: x4 phụ thuộc vào x7, x2
    add  x7, x4, x5          # RAW: x7 phụ thuộc vào x4, x5
    sub  x7, x7, x2          # RAW: x7 phụ thuộc vào x7 (data hazard)
    sw   x7, 84(x3)          # RAW: store dùng giá trị mới của x7 (data hazard)
    lw   x2, 96(x0)          # Load x2 từ memory
    add  x9, x2, x5          # **Load-use hazard**: x9 dùng ngay x2 sau khi load
    jal  x3, end             # Control hazard: jump luôn

    addi x2, x0, 1           # Lệnh này bị bỏ qua vì jal nhảy (test control hazard)

end:
    add  x2, x2, x9          # RAW: x2 phụ thuộc vào x2, x9
    sw   x2, 0x20(x3)        # RAW: store dùng giá trị mới của x2 (data hazard)

done:
    beq  x2, x2, done        # Control hazard: loop vô hạn, giữ CPU trong done
