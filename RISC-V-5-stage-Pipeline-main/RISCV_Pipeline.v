module riscv (
    input clk,
    input rst_n,
    input [31:0] instrF,

    output [31:0] pcF
);

    wire memrwM;
    wire [31:0] ALUresM, data_writeM, data_readM;

    data_memory data_memory_inst (
        .clk        (clk),
        .memrw      (memrwM),
        .address    (ALUresM),
        .data_write (data_writeM),
        .data_read  (data_readM)
    );

    core core_inst (
        .clk(clk),
        .rst_n(rst_n),
        .instrF(instrF),
        .dmem_we(memrwM),
        .dmem_addr(ALUresM),
        .dmem_wdata(data_writeM),

        .data_readM(data_readM),
        .pcF(pcF)
    );

endmodule