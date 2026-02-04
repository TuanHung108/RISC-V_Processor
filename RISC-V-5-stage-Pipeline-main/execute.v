module execute (
    input clk, rst_n,
    input regwriteE, memrwE, bselE,
    input brunE, branchE, jumpE, jalrE,
    input [2:0] funct3E,
    input [1:0] wbselE,
    input [3:0] ALUselE,
    input [1:0] forwardAE, forwardBE,
    input [4:0] rs1E, rs2E, rdE,
    input [31:0] resultW,
    input [31:0] rd1E, rd2E,
    input [31:0] imm_exE, pcE, pc4E,

    output regwriteM, memrwM, 
    output pcselE, 
    output [1:0] wbselM,
    output [31:0] pc4M, pcTargetE,
    output [4:0] rdM,
    output [31:0] ALUresM, data_writeM
);

    // Declaration of register
    reg regwriteE_reg;
    reg memrwE_reg;
    reg [1:0] wbselE_reg;
    reg [4:0] rdE_reg;
    reg [31:0] data_write_reg, ALUresE_reg, pc4E_reg;

    // ALU logic
    wire [31:0] src_B_inter;
    wire [31:0] src_A, src_B;
    reg [31:0] ALUresE;

    localparam  FWD_NONE = 2'b00,
                FWD_W    = 2'b01,
                FWD_M    = 2'b10;

    assign src_A =  (forwardAE == FWD_NONE) ? rd1E :
                    (forwardAE == FWD_W) ? resultW :
                    (forwardAE == FWD_M) ? ALUresM : rd1E; 

    assign src_B_inter =  (forwardBE == FWD_NONE) ? rd2E :
                          (forwardBE == FWD_W) ? resultW :
                          (forwardBE == FWD_M) ? ALUresM : rd2E; 


    assign src_B = (bselE) ? imm_exE : src_B_inter;


    localparam  ADD = 4'b0000,
                SUB = 4'b0001,
                AND = 4'b0010,
                OR = 4'b0011,
                XOR = 4'b0100,
                SLL = 4'b0101,
                SRL = 4'b0110,
                SRA = 4'b0111,
                SLT = 4'b1000,
                SLTU = 4'b1001;

    always @(ALUselE, src_A, src_B) begin
        ALUresE = 32'b0;
        case (ALUselE)
            ADD: ALUresE = src_A + src_B;
            SUB: ALUresE = src_A - src_B;
            AND: ALUresE = src_A & src_B;
            OR: ALUresE = src_A | src_B;
            XOR: ALUresE = src_A ^ src_B;
            SLL: ALUresE = src_A << src_B[4:0];
            SRL: ALUresE = src_A >> src_B[4:0];
            SRA: ALUresE = $signed(src_A) >>> src_B[4:0];
            SLT: ALUresE = ($signed(src_A) < $signed(src_B)) ? {{31{1'b0}}, 1'b1} : 32'd0; 
            SLTU: ALUresE = ($unsigned(src_A) < $unsigned(src_B)) ? {{31{1'b0}}, 1'b1} : 32'd0; 
            default: ALUresE  = 32'd0;
        endcase
    end

    // JALR
    wire [31:0] jalr_sum = src_A + imm_exE;
    assign pcTargetE = jalrE ? { jalr_sum[31:1], 1'b0 }   // JALR: mask LSB
                        : (pcE + imm_exE);              // JAL 

    // Branch Comp
    wire breqE, brltE;
    wire [31:0] cmpA, cmpB;
    reg conditionE;

    assign cmpA = src_A;
    assign cmpB = src_B_inter;

    assign breqE = (cmpA == cmpB);
    assign brltE = (brunE) ? (cmpA < cmpB) : ($signed(cmpA) < $signed(cmpB));

    always @(funct3E, breqE, brltE) begin
        case (funct3E)
            3'b000: conditionE = breqE;
            3'b001: conditionE = !breqE;
            3'b100: conditionE = brltE;
            3'b101: conditionE = !brltE;
            3'b110: conditionE = brltE;        
            3'b111: conditionE = !brltE;
            default: conditionE = 1'b0;
        endcase
    end

    assign pcselE = (branchE & conditionE) | jumpE;

    // Register logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            regwriteE_reg <= 1'b0;
            memrwE_reg <= 1'b0;
            wbselE_reg <= 2'd0;
            ALUresE_reg <= 32'd0;
            data_write_reg <= 32'd0;
            rdE_reg <= 5'd0;
            pc4E_reg <= 32'd0;
        end
        else begin
            regwriteE_reg <= regwriteE;
            memrwE_reg <= memrwE;
            wbselE_reg <= wbselE;
            ALUresE_reg <= ALUresE;
            data_write_reg <= src_B_inter;
            rdE_reg <= rdE;
            pc4E_reg <= pc4E;
        end
    end

    assign regwriteM = regwriteE_reg;
    assign memrwM = memrwE_reg;
    assign wbselM = wbselE_reg;
    assign ALUresM = ALUresE_reg;
    assign rdM = rdE_reg;
    assign data_writeM = data_write_reg;
    assign pc4M = pc4E_reg;

endmodule