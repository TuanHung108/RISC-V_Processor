
module decode (
    input clk, rst_n,
    input regwriteW,
    input flushE,
    input [4:0] rdW,
    input [31:0] instrD, pcD, pc4D,
    input [31:0] resultW,

    output regwriteE, memrwE, 
    output brunE, branchE, jumpE,
    output bselE, jalrE,
    output [1:0] wbselE,
    output [3:0] ALUselE,
    output [2:0] funct3E,
    output [4:0] rs1D, rs2D,
    output [4:0] rdE, rs1E, rs2E,
    output [31:0] rd1E, rd2E,
    output [31:0] imm_exE,
    output [31:0] pcE, pc4E
);

    // Declaration of register
    reg regwriteD_reg, memrwD_reg, bselD_reg, brunD_reg, branchD_reg, jumpD_reg;
    reg [1:0] wbselD_reg;
    reg [2:0] funct3D_reg;
    reg [3:0] aluselD_reg;
    reg [4:0] rdD_reg, rs1D_reg, rs2D_reg;
    reg [31:0] pcD_reg, pc4D_reg;
    reg [31:0] rd1D_reg, rd2D_reg, imm_exD_reg;
    reg [14:0] control_signals;  
    reg jalrD_reg;


    // Control Unit
    // ImmSel_RegWrite_BrUn_Branch_Jump_Bsel_ALUSel_MemRW_WBSel
    wire regwriteD, memrwD, brunD, branchD, jumpD;
    wire bselD;
    wire [1:0] wbselD;
    wire [2:0] immselD;
    wire [3:0] aluselD;
    wire [4:0] rdD;
    wire [31:0] rd1D_Utype;

    wire [6:0] opcode = instrD[6:0];
    wire [2:0] funct3 = instrD[14:12];
    wire [6:0] funct7 = instrD[31:25];
    wire jalrD = (opcode == 7'b1100111); // jalr opcode

    assign rs1D = instrD[19:15];
    assign rs2D = instrD[24:20];
    assign rdD = instrD[11:7];


    // ImmSel[2:0], RegWrite, BrUn, Branch, Jump, BSel, ALUSel[3:0], MemRW, WBSel[1:0]
    assign {immselD, regwriteD, brunD, branchD, jumpD, bselD, aluselD, memrwD, wbselD} = control_signals;

    always @(opcode, funct3, funct7) begin
        control_signals = 15'b000_0_0_0_0_0_0000_0_00; // default 
        case (opcode)

            // ---------------- R-type ----------------
            7'b0110011: begin
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000) // add
                            control_signals = 15'b000_1_0_0_0_0_0000_0_01;
                        else if (funct7 == 7'b0100000) // sub
                            control_signals = 15'b000_1_0_0_0_0_0001_0_01;
                    end
                    3'b111: control_signals = 15'b000_1_0_0_0_0_0010_0_01; // and
                    3'b110: control_signals = 15'b000_1_0_0_0_0_0011_0_01; // or
                    3'b100: control_signals = 15'b000_1_0_0_0_0_0100_0_01; // xor
                    3'b001: control_signals = 15'b000_1_0_0_0_0_0101_0_01; // sll
                    3'b101: begin
                        if (funct7 == 7'b0000000) // srl
                            control_signals = 15'b000_1_0_0_0_0_0110_0_01;
                        else if (funct7 == 7'b0100000) // sra
                            control_signals = 15'b000_1_0_0_0_0_0111_0_01;
                    end
                    3'b010: control_signals = 15'b000_1_0_0_0_0_1000_0_01; // slt
                    3'b011: control_signals = 15'b000_1_0_0_0_0_1001_0_01; // sltu
                    default: control_signals = 15'b000_1_0_0_0_0_0000_0_01;
                endcase
            end

            // ---------------- I-type ----------------
            7'b0010011: begin
                case (funct3)
                    3'b000: control_signals = 15'b001_1_0_0_0_1_0000_0_01; // addi
                    3'b100: control_signals = 15'b001_1_0_0_0_1_0100_0_01; // xori
                    3'b110: control_signals = 15'b001_1_0_0_0_1_0011_0_01; // ori
                    3'b111: control_signals = 15'b001_1_0_0_0_1_0010_0_01; // andi
                    default: control_signals = 15'b001_1_0_0_0_1_0000_0_01;

                endcase
            end

            7'b0000011: control_signals = 15'b001_1_0_0_0_1_0000_0_00; // lw
            7'b1100111: control_signals = 15'b001_1_0_0_1_1_0000_0_10; // jalr

            // ---------------- S-type ----------------
            7'b0100011: control_signals = 15'b010_0_0_0_0_1_0000_1_00; // sw

            // ---------------- B-type ----------------
            7'b1100011: begin
                case (funct3)
                    3'b000: control_signals = 15'b011_0_0_1_0_1_0000_0_00; // beq
                    3'b001: control_signals = 15'b011_0_0_1_0_1_0000_0_00; // bne
                    3'b100: control_signals = 15'b011_0_0_1_0_1_0000_0_00; // blt
                    3'b101: control_signals = 15'b011_0_0_1_0_1_0000_0_00; // bge
                    3'b110: control_signals = 15'b011_0_1_1_0_1_0000_0_00; // bltu
                    3'b111: control_signals = 15'b011_0_1_1_0_1_0000_0_00; // bgeu
                    default: control_signals = 15'b000_0_0_0_0_0_0000_0_00;
                endcase
            end

            // ---------------- J-type ----------------
            7'b1101111: control_signals = 15'b100_1_0_0_1_1_0000_0_10; // jal

            // ---------------- U-type ----------------
            7'b0110111: control_signals = 15'b101_1_0_0_0_1_0000_0_01; // lui
            7'b0010111: control_signals = 15'b101_1_0_0_0_1_0000_0_01; // auipc

            default: control_signals = 15'b000_0_0_0_0_0_0000_0_00;
        endcase
    end


    // Imm extend
    reg [31:0] imm_exD;

    localparam  I_type = 3'b001,
                S_type = 3'b010,
                B_type = 3'b011,
                J_type = 3'b100,
                U_type = 3'b101;

    always @(immselD, instrD) begin
        imm_exD = 32'b0;
        case (immselD)
            I_type: imm_exD = {{20{instrD[31]}}, instrD[31:20]};
            S_type: imm_exD = {{20{instrD[31]}}, instrD[31:25], instrD[11:7]};
            B_type: imm_exD = {{19{instrD[31]}}, instrD[31], instrD[7], instrD[30:25], instrD[11:8], 1'b0};
            J_type: imm_exD = {{11{instrD[31]}}, instrD[31], instrD[19:12], instrD[20], instrD[30:21], 1'b0};
            U_type: imm_exD = {instrD[31:12], 12'b0};
            default: imm_exD = 32'b0;
        endcase
    end


    // Register File
    reg [31:0] reg_file [0:31];
    wire [31:0] rd1D, rd2D;

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_file[i] <= 32'b0;
            end
        end
        else if (regwriteW && (rdW != 5'd0)) begin
            reg_file[rdW] <= resultW;
        end
        reg_file[0] <= 32'h00000000;
    end

    wire write_wb_valid = regwriteW && (rdW != 5'd0);
    assign rd1D = (write_wb_valid && (rdW == rs1D)) ? resultW : reg_file[rs1D];
    assign rd2D = (write_wb_valid && (rdW == rs2D)) ? resultW : reg_file[rs2D];
  
    // Register Logic
    assign rd1D_Utype = (opcode == 7'b0010111) ? pcD :        // AUIPC: dùng PC
                        (opcode == 7'b0110111) ? 32'd0 : rd1D; // LUI: dùng 0     
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            regwriteD_reg <= 1'b0;
            memrwD_reg <= 1'b0; 
            bselD_reg <= 1'b0;
            brunD_reg <= 1'b0;
            branchD_reg <= 1'b0;
            jumpD_reg <= 1'b0;
            wbselD_reg <= 2'd0;
            aluselD_reg <= 4'd0;
            pcD_reg <= 32'd0;
            pc4D_reg <= 32'd0;
            rd1D_reg <= 32'd0;
            rd2D_reg <= 32'd0;
            imm_exD_reg <= 32'd0;
            rdD_reg <= 5'd0;
            rs1D_reg <= 5'd0;
            rs2D_reg <= 5'd0;
            funct3D_reg <= 3'd0;
            jalrD_reg <= 1'b0;
        end
        else begin
            if(flushE) begin
                regwriteD_reg <= 1'b0;
                memrwD_reg <= 1'b0; 
                bselD_reg <= 1'b0;
                brunD_reg <= 1'b0;
                branchD_reg <= 1'b0;
                jumpD_reg <= 1'b0;
                wbselD_reg <= 2'd0;
                aluselD_reg <= 4'd0;
                pcD_reg <= 32'd0;
                pc4D_reg <= 32'd0;
                rd1D_reg <= 32'd0;
                rd2D_reg <= 32'd0;
                imm_exD_reg <= 32'd0;
                rdD_reg <= 5'd0;
                rs1D_reg <= 5'd0;
                rs2D_reg <= 5'd0;
                funct3D_reg <= 3'd0;
                jalrD_reg <= 1'b0;
            end else begin
                regwriteD_reg <= regwriteD;
                memrwD_reg <= memrwD; 
                bselD_reg <= bselD;
                brunD_reg <= brunD;
                branchD_reg <= branchD;
                jumpD_reg <= jumpD;
                wbselD_reg <= wbselD;
                aluselD_reg <= aluselD;
                pcD_reg <= pcD;
                pc4D_reg <= pc4D;
                rd1D_reg <= rd1D_Utype;
                rd2D_reg <= rd2D; 
                imm_exD_reg <= imm_exD;
                rdD_reg <= rdD;
                rs1D_reg <= rs1D;
                rs2D_reg <= rs2D;
                funct3D_reg <= funct3;
                jalrD_reg <= jalrD;
            end
        end
    end


    assign jalrE = jalrD_reg;
    assign regwriteE = regwriteD_reg;
    assign memrwE = memrwD_reg;
    assign bselE = bselD_reg;
    assign brunE = brunD_reg;
    assign branchE = branchD_reg;   
    assign jumpE = jumpD_reg;
    assign wbselE = wbselD_reg;
    assign ALUselE = aluselD_reg;
    assign pcE = pcD_reg;
    assign pc4E = pc4D_reg;
    assign rd1E = rd1D_reg;
    assign rd2E = rd2D_reg;
    assign imm_exE = imm_exD_reg;
    assign rdE = rdD_reg;
    assign rs1E = rs1D_reg;
    assign rs2E = rs2D_reg;
    assign funct3E = funct3D_reg;

endmodule
