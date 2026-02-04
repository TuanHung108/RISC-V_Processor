# 🎓 RISC-V Processor Projects - Final Term Digital Design Course

Dự án này tập trung vào việc thiết kế **bộ xử lý RISC-V** bằng **Verilog HDL**.

---

## 📖 Giới Thiệu

### Tổng Quan
Dự án này gồm 2 cách triển khai khác nhau của bộ xử lý RISC-V:
- **RISC-V 5-stage Pipeline**: Kiến trúc hiệu suất cao với pipeline 5 giai đoạn
- **Single-Cycle RISC-V**: Kiến trúc đơn giản với 1 chu kỳ/lệnh

### Mục đích
- 📚 **Học tập**: Học thiết kế CPU từ cấp độ phần cứng
- ⚖️ **So sánh hiệu suất**: Giữa kiến trúc pipeline (hiệu suất cao) vs single-cycle (đơn giản)
- 🧪 **Phân tích kiến trúc**: Sử dụng Quartus (công cụ thiết kế FPGA) và QuestaSim
- 🔧 **Hiểu thêm về RISC-V ISA**: Tập hợp lệnh open-source

---

## 📁 Cấu Trúc Tổng Quan Dự Án

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

## 🔧 Ngôn Ngữ & Công Cụ

- **Verilog HDL**: Ngôn ngữ mô tả phần cứng
- **Quartus Prime**: IDE thiết kế FPGA của Intel/Altera
- **QuestaSim**: Công cụ mô phỏng Verilog
- **RISC-V ISA**: Tập hợp lệnh (Open-source ISA)

---

## 📚 Lệnh RISC-V Được Hỗ Trợ

### Các Loại Lệnh
- **R-type**: Toán học và logic (ADD, SUB, AND, OR, XOR, SLT)
- **I-type**: Toán học ngay lập tức (ADDI, ANDI, ORI)
- **Load/Store**: LW, SW (load/store word)
- **Branch**: BEQ, BNE, BLT, BGE
- **Jump**: JAL, JALR

### Lưu ý: Hiện tại dự án chưa hỗ trợ đầy đủ RISC-V ISA, mới chỉ hỗ trợ các lệnh cơ bản của tập lệnh RV32I

---

## 🚀 Cách Sử Dụng

### Chạy Mô Phỏng với QuestaSim
Thực hiện chạy mô phỏng các testbench trên QuestaSim đối với cả Pipeline và Single Cycle để quan sát waveform và debug.

---


---

## 🎯 Mục tiêu sau dự án

- ✅ Hiểu cách bộ xử lý lấy, giải mã, thực hiện một lệnh trong một hoặc nhiều chu kỳ
- ✅ Hiểu sự khác biệt giữa kiến trúc đơn chu kỳ vs pipeline
- ✅ Học cách xử lý data hazards
- ✅ Hiểu forwarding, stalling, flushing
- ✅ Làm quen với thiết kế FPGA và Verilog HDL
- ✅ Học RISC-V Instruction Set Architecture

---

## 📝 Ghi Chú

- Cả hai dự án đều chỉ mới chạy mô phỏng trên QuestaSim, chưa triển khai trên FPGA
- Các testbench cung cấp các testcase cơ bản để kiểm tra hoạt động chức năng
- Chưa có sự so sánh hiệu suất giữa 2 kiến trúc RISC-V

---
-
