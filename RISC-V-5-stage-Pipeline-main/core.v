module core (
    input clk, rst_n,
    input [31:0] instrF,
    input [31:0] data_readM,

    output dmem_we,
    output [31:0] dmem_addr,
    output [31:0] dmem_wdata,
    output [31:0] pcF
);

    // Wires between stages
    wire [31:0] pcD, pc4D, instrD, data_readW;
    wire [31:0] pcE, pc4E, imm_exE;
    wire [31:0] pc4M;
    wire [31:0] pc4W;
    wire [31:0] pcTargetE;

    // Wires for control signals
    wire regwriteE, regwriteM, regwriteW;
    wire memrwE, memrwM, jalrE;
    wire pcselE, brunE, branchE, jumpE, bselE;
    wire [1:0] wbselE, wbselM, wbselW;
    wire [3:0] ALUselE;
    wire [2:0] funct3E;


    // Wires for data signals
    wire [4:0] rdE, rdM, rdW;
    wire [4:0] rs1D, rs2D, rs1E, rs2E;
    wire [31:0] rd1E, rd2E;
    wire [31:0] resultW;
    wire [31:0] ALUresM, ALUresW;
    wire [31:0] writedataM;
    
    // Wires for hazard unit
    wire flushE, flushD;
    wire stallF, stallD;
    wire [1:0] forwardAE, forwardBE;

    // Instantiate modules
    fetch u_fetch (
        .clk(clk),
        .rst_n(rst_n),
        .pcselE(pcselE),
        .pcTargetE(pcTargetE),
        .instrF(instrF),
        .stallD(stallD),
        .stallF(stallF),
        .flushD(flushD),

        .pcF(pcF),
        .instrD(instrD),
        .pcD(pcD),
        .pc4D(pc4D)
    );

    decode u_decode (
        .clk(clk),
        .rst_n(rst_n),
        .regwriteW(regwriteW),
        .flushE(flushE),
        .rdW(rdW),
        .instrD(instrD),
        .pcD(pcD),
        .pc4D(pc4D),
        .resultW(resultW),

        .regwriteE(regwriteE),
        .memrwE(memrwE),
        .brunE(brunE),
        .branchE(branchE),
        .jumpE(jumpE),
        .bselE(bselE),
        .wbselE(wbselE),
        .ALUselE(ALUselE),
        .funct3E(funct3E),
        .imm_exE(imm_exE),
        .rs1D(rs1D),
        .rs2D(rs2D),
        .rs1E(rs1E),
        .rs2E(rs2E),
        .rdE(rdE),
        .rd1E(rd1E),
        .rd2E(rd2E),
        .pcE(pcE),
        .pc4E(pc4E),
        .jalrE(jalrE)
    );

    execute u_execute (
        .clk(clk),
        .rst_n(rst_n),
        .regwriteE(regwriteE),
        .memrwE(memrwE),
        .brunE(brunE),
        .branchE(branchE),
        .jumpE(jumpE),
        .wbselE(wbselE),
        .ALUselE(ALUselE),
        .bselE(bselE),
        .funct3E(funct3E),
        .forwardAE(forwardAE),
        .forwardBE(forwardBE),
        .rs1E(rs1E),
        .rs2E(rs2E),
        .rdE(rdE),
        .resultW(resultW),
        .rd1E(rd1E),
        .rd2E(rd2E),
        .imm_exE(imm_exE),
        .pcE(pcE),
        .pc4E(pc4E),
        .jalrE(jalrE),

        .regwriteM(regwriteM),
        .memrwM(memrwM),
        .pcselE(pcselE),
        .wbselM(wbselM),
        .pc4M(pc4M),
        .pcTargetE(pcTargetE),
        .rdM(rdM),
        .ALUresM(ALUresM),
        .data_writeM(writedataM)
    );

    memory u_memory (
        .clk(clk),
        .rst_n(rst_n),
        .regwriteM(regwriteM),
        .memrwM(memrwM),
        .wbselM(wbselM),
        .rdM(rdM),
        .data_writeM(writedataM),
        .ALUresM(ALUresM), 
        .pc4M(pc4M),

        .regwriteW(regwriteW),
        .wbselW(wbselW), 
        .rdW(rdW),   
        .ALUresW(ALUresW),
        .data_readW(data_readW),
        .pc4W(pc4W),

        //Connect with DMEM
        .data_readM(data_readM),
        .dmem_we(dmem_we),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata)
    );

    assign resultW = (wbselW == 2'b00) ? data_readW :
                    (wbselW == 2'b01) ? ALUresW :
                    (wbselW == 2'b10) ? pc4W : 32'd0;
    
    hazard_unit u_hazard_unit (
        .rs1E(rs1E),
        .rs2E(rs2E),
        .rs1D(rs1D),
        .rs2D(rs2D),
        .rdM(rdM),
        .rdW(rdW),
        .rdE(rdE),
        .regwriteM(regwriteM),
        .regwriteW(regwriteW),
        .wbselE(wbselE),
        .pcselE(pcselE),

        .flushE(flushE),
        .flushD(flushD),
        .stallF(stallF),
        .stallD(stallD),
        .forwardAE(forwardAE),
        .forwardBE(forwardBE)
    );

endmodule