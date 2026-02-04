# 🎓 RISC-V Processor Projects

Dự án này là một **bộ sưu tập các bộ xử lý RISC-V** được viết bằng **Verilog HDL** (ngôn ngữ mô tả phần cứng). Nó bao gồm **2 kiến trúc khác nhau** để minh họa các cách thiết kế bộ xử lý.

---

## 📖 Giới Thiệu

### Dự án là gì?
Dự án này cung cấp 2 triển khai khác nhau của bộ xử lý RISC-V (Reduced Instruction Set Computer - Vietnam):
- **RISC-V 5-stage Pipeline**: Kiến trúc hiệu suất cao với pipeline 5 giai đoạn
- **Single-Cycle RISC-V**: Kiến trúc đơn giản với 1 chu kỳ/lệnh

### Dùng để làm gì?
- 📚 **Mục đích giáo dục**: Học thiết kế CPU từ cấp độ phần cứng
- ⚖️ **So sánh hiệu suất**: Giữa kiến trúc pipeline (hiệu suất cao) vs single-cycle (đơn giản)
- 🧪 **Mô phỏng thực tế**: Sử dụng Quartus (công cụ thiết kế FPGA) và ModelSim
- 🔧 **Học RISC-V ISA**: Tập hợp lệnh open-source

---

## 📁 Cấu Trúc Tổng Quan

```
RISC-V_Processor/
├── RISC-V-5-stage-Pipeline-main/      (Kiến trúc Pipeline 5 giai đoạn)
│   ├── core.v                         (Module chính kết nối các stage)
│   ├── fetch.v                        (Giai đoạn 1: Lấy lệnh)
│   ├── decode.v                       (Giai đoạn 2: Giải mã lệnh)
│   ├── execute.v                      (Giai đoạn 3: Thực hiện phép toán)
│   ├── memory.v                       (Giai đoạn 4: Truy cập bộ nhớ)
│   ├── hazard_unit.v                  (Xử lý xung đột dữ liệu)
│   ├── imem.v                         (Bộ nhớ chương trình)
│   ├── data_memory.v                  (Bộ nhớ dữ liệu)
│   ├── RISCV_Pipeline.v               (Top-level module)
│   ├── tb_pipeline_automated.v        (Testbench tự động)
│   ├── tb_riscv.v                     (Testbench cơ bản)
│   ├── tb_bubble_sort.v               (Testbench sắp xếp)
│   ├── RISCV_Pipeline.qsf/.qpf        (Cấu hình Quartus)
│   ├── RISCV_5stage_pipeline.mpf      (Cấu hình ModelSim)
│   └── db/                            (Cơ sở dữ liệu biên dịch)
│
└── Single-Cycle-RISC-V-Processor-main/  (Kiến trúc Single-Cycle)
    ├── control_unit.v                 (Tạo tín hiệu điều khiển)
    ├── datapath.v                     (Đường dữ liệu chính)
    ├── register_file.v                (32 thanh ghi)
    ├── data_memory.v                  (Bộ nhớ dữ liệu)
    ├── imem.v                         (Bộ nhớ chương trình)
    ├── riscv.v                        (Module top-level)
    ├── Single_cycle_RISCV.v           (Wrapper)
    ├── tb_control_unit.v              (Testbench control unit)
    ├── tb_datapath.v                  (Testbench datapath)
    ├── tb_data_memory.v               (Testbench data memory)
    ├── tb_imem.v                      (Testbench instruction memory)
    └── tb_register_file.v             (Testbench register file)
```

---

## 🏗️ Kiến Trúc 1: RISC-V 5-stage Pipeline

### Sơ đồ Pipeline 5 Giai Đoạn

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌────────────┐
│ FETCH   │ →  │ DECODE  │ →  │ EXECUTE │ →  │ MEMORY  │ →  │ WRITE-BACK │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └────────────┘
 (Stage 1)     (Stage 2)       (Stage 3)      (Stage 4)       (Stage 5)
```

### Các Giai Đoạn Chi Tiết

#### **1️⃣ FETCH (fetch.v)**
- Lấy lệnh từ bộ nhớ chương trình (Instruction Memory)
- Tính toán địa chỉ PC (Program Counter) tiếp theo
- Hỗ trợ jump/branch thông qua `pcselE` và `pcTargetE`
- Quản lý stall và flush cho hazard handling

#### **2️⃣ DECODE (decode.v)**
- Giải mã lệnh RISC-V để lấy opcode, registers, immediate values
- Đọc dữ liệu từ 2 thanh ghi (rs1, rs2)
- Tạo các tín hiệu điều khiển cho các stage tiếp theo

#### **3️⃣ EXECUTE (execute.v)**
- Thực hiện phép toán ALU (Add, Sub, AND, OR, XOR, SLT, v.v.)
- Tính toán địa chỉ branch/jump
- Xử lý forwarding để giải quyết data hazards
- Tạo các flag: branch taken, comparison results

#### **4️⃣ MEMORY (memory.v)**
- Truy cập bộ nhớ dữ liệu (load/store)
- Hỗ trợ các kích thước khác nhau: byte, halfword, word
- Đọc/ghi dữ liệu từ/vào data_memory.v

#### **5️⃣ WRITE-BACK**
- Ghi kết quả vào thanh ghi đích (rd)
- Có thể là: ALU result, memory data, PC+4 (cho link registers)

### Module Hỗ Trợ

#### **hazard_unit.v** - Xử Lý Xung Đột
- **Hazard là gì?** Khi lệnh tiếp theo phụ thuộc vào kết quả của lệnh trước
- **Giải pháp**:
  - **Forwarding/Bypassing**: Đưa dữ liệu từ stage sau trở lại stage EXECUTE
  - **Stalling**: Dừng pipeline cho đến khi dữ liệu sẵn sàng
  - **Flushing**: Loại bỏ lệnh trong pipeline khi có branch

#### **imem.v** - Instruction Memory
- Bộ nhớ chỉ đọc chứa các lệnh RISC-V
- Truyền lệnh theo địa chỉ PC

#### **data_memory.v** - Data Memory
- Bộ nhớ đọc/ghi cho dữ liệu
- Hoạt động đồng bộ với clock

### Ưu Điểm Pipeline
✅ **Thông lượng cao**: 3-5 lệnh/chu kỳ  
✅ **Hiệu suất tốt**: Xử lý lệnh song song  
✅ **Sát với CPU thực**: Phần lớn CPU hiện đại dùng kiến trúc này

### Nhược Điểm
❌ **Phức tạp**: Phải xử lý hazards  
❌ **Chi phí điều khiển**: Hazard unit, forwarding logic  
❌ **Độ trễ lệnh**: ~5 chu kỳ cho 1 lệnh hoàn tất

---

## 🔄 Kiến Trúc 2: Single-Cycle RISC-V

### Sơ Đồ Single-Cycle

```
┌────────────────────────────────────────────────────┐
│ FETCH → DECODE → EXECUTE → MEMORY → WRITE-BACK   │  (1 chu kỳ)
└────────────────────────────────────────────────────┘
```

### Cách Hoạt Động
- **Mỗi lệnh** mất **1 chu kỳ clock** để hoàn tất từ fetch đến write-back
- Không có pipeline → không có hazards
- Từng lệnh được xử lý **tuần tự hoàn toàn**

### Các Module Chính

#### **control_unit.v**
- Giải mã opcode/funct3/funct7 từ lệnh
- Tạo ra các tín hiệu điều khiển: `regwen`, `memrw`, `alusel`, `immsel`, v.v.
- Quyết định: register write enable, memory write, ALU operation, v.v.

#### **datapath.v**
- **Đường dữ liệu chính** của bộ xử lý
- Gồm:
  - Program Counter (PC)
  - Register File (32 thanh ghi)
  - ALU (arithmetic logic unit)
  - Immediate Value Extender (mở rộng immediate)
  - Multiplexers (chọn nguồn dữ liệu)
  - Branch/comparison logic

#### **register_file.v**
- 32 thanh ghi RISC-V (x0-x31)
- x0 luôn = 0
- Đọc 2 thanh ghi song song
- Ghi 1 thanh ghi mỗi chu kỳ

#### **imem.v & data_memory.v**
- Tương tự pipeline version
- Bộ nhớ chương trình và bộ nhớ dữ liệu

#### **riscv.v**
- Module top-level
- Kết nối `control_unit` + `datapath`

### Ưu Điểm Single-Cycle
✅ **Đơn giản**: Dễ hiểu logic  
✅ **Không hazards**: Không cần xử lý xung đột  
✅ **Dễ debug**: Control flow rõ ràng  
✅ **Tốt cho học tập**: Nền tảng để hiểu CPU

### Nhược Điểm
❌ **Hiệu suất thấp**: 1 lệnh/chu kỳ  
❌ **Chu kỳ dài**: Phải chờ tất cả stage hoàn tất  
❌ **Lãng phí**: Nhiều phần tử không hoạt động khi đang ở stage khác

---

## 📊 Bảng So Sánh

| Tiêu Chí | Pipeline (5-stage) | Single-Cycle |
|----------|-------------------|--------------|
| **Thông lượng** | 3-5 lệnh/chu kỳ | 1 lệnh/chu kỳ |
| **Độ phức tạp** | Cao (hazard unit) | Thấp |
| **Độ trễ/lệnh** | ~5 chu kỳ | ~1 chu kỳ |
| **Xung đột dữ liệu** | Có (cần xử lý) | Không |
| **Khó độ học tập** | Khó | Dễ |
| **Sát với CPU thực** | Rất sát | Không sát |
| **Giai đoạn riêng** | Có | Không |
| **Forwarding logic** | Cần thiết | Không cần |

---

## 🧪 Testbench (Bộ Kiểm Tra)

### Pipeline Version

#### **tb_pipeline_automated.v**
- Kiểm tra tự động các lệnh RISC-V
- Kiểm tra pipeline hoạt động đúng
- Kiểm tra hazard detection

#### **tb_riscv.v**
- Testbench cơ bản
- Lệnh mẫu để kiểm tra

#### **tb_bubble_sort.v**
- Testbench thực tế: **Thuật toán sắp xếp Bubble Sort**
- Kiểm tra pipeline với chương trình phức tạp hơn
- Sử dụng các lệnh: load, store, branch, ALU operations

### Single-Cycle Version

#### **tb_control_unit.v**
- Kiểm tra việc giải mã lệnh
- Kiểm tra tín hiệu điều khiển được tạo đúng

#### **tb_datapath.v**
- Kiểm tra đường dữ liệu
- Kiểm tra PC, ALU, register operations

#### **tb_data_memory.v & tb_imem.v**
- Kiểm tra bộ nhớ dữ liệu
- Kiểm tra bộ nhớ chương trình

#### **tb_register_file.v**
- Kiểm tra đọc/ghi thanh ghi

---

## 🔧 Công Cụ & Công Nghệ

- **Verilog HDL**: Ngôn ngữ mô tả phần cứng
- **Quartus Prime**: IDE thiết kế FPGA của Intel/Altera
- **ModelSim**: Công cụ mô phỏng Verilog
- **RISC-V ISA**: Tập hợp lệnh (Open-source ISA)

### File Cấu Hình
- **RISCV_Pipeline.qsf/.qpf**: Cấu hình Quartus (đối với pipeline)
- **RISCV_5stage_pipeline.mpf**: Cấu hình ModelSim
- **db/**: Cơ sở dữ liệu biên dịch Quartus
- **vsim.wlf**: Tệp sóng (waveform) từ mô phỏng

---

## 📚 Lệnh RISC-V Được Hỗ Trợ

### Các Loại Lệnh
- **R-type**: Toán học và logic (ADD, SUB, AND, OR, XOR, SLT)
- **I-type**: Toán học ngay lập tức (ADDI, ANDI, ORI)
- **Load/Store**: LW, SW (load/store word)
- **Branch**: BEQ, BNE, BLT, BGE
- **Jump**: JAL, JALR

### Ví Dụ Lệnh
```
ADD x1, x2, x3      # x1 = x2 + x3
ADDI x1, x1, 100    # x1 = x1 + 100
LW x1, 0(x2)        # x1 = memory[x2 + 0]
SW x1, 0(x2)        # memory[x2] = x1
BEQ x1, x2, label   # if (x1 == x2) jump
JAL x1, func        # x1 = PC+4; jump to func
```

---

## 🚀 Cách Sử Dụng

### Chạy Mô Phỏng với ModelSim

#### Pipeline Version
```bash
cd RISC-V-5-stage-Pipeline-main
# Mở ModelSim
vsim -do "do simulate.do"
# Hoặc tạo file do và run
```

#### Single-Cycle Version
```bash
cd Single-Cycle-RISC-V-Processor-main
# Chạy testbench
vsim tb_riscv
```

### Biên Dịch với Quartus
```bash
quartus_sh -t RISCV_Pipeline.qsf
```

---

## 📖 Hành Trình Học Tập

1. **Bắt đầu**: Nghiên cứu Single-Cycle version để hiểu cơ bản
2. **Tiến bộ**: Tìm hiểu từng module: control unit, datapath, register file
3. **Nâng cao**: Chuyển sang Pipeline version
4. **Chuyên sâu**: Hiểu hazard detection, forwarding, stalling
5. **Thực hành**: Chạy testbench, quan sát waveform trong ModelSim

---

## 🎯 Mục Tiêu Học Tập

- ✅ Hiểu cách bộ xử lý lấy, giải mã, thực hiện lệnh
- ✅ Hiểu sự khác biệt giữa kiến trúc đơn chu kỳ vs pipeline
- ✅ Học cách xử lý data hazards
- ✅ Hiểu forwarding, stalling, flushing
- ✅ Làm quen với thiết kế FPGA và Verilog HDL
- ✅ Học RISC-V Instruction Set Architecture

---

## 📝 Ghi Chú

- Cả hai dự án đều có thể chạy mô phỏng trên ModelSim
- Dự án Pipeline có thể được lập trình lên FPGA thông qua Quartus
- Các testbench cung cấp các ví dụ tốt để bắt đầu
- Khuyến nghị: bắt đầu từ Single-Cycle rồi chuyển sang Pipeline

---

## 📧 Liên Hệ & Hỗ Trợ

Để hiểu rõ hơn từng module, tham khảo các tệp Verilog trực tiếp hoặc chạy mô phỏng và quan sát waveform.

---

**Chúc bạn học tập vui vẻ với RISC-V! 🚀**
