
module memory (
    input  wire        clk,
    input  wire        rst_n,

    // từ EX/M
    input  wire        regwriteM,
    input  wire        memrwM,             
    input  wire [1:0]  wbselM,
    input  wire [4:0]  rdM,
    input  wire [31:0] data_writeM,
    input  wire [31:0] ALUresM,
    input  wire [31:0] pc4M,

    // dữ liệu đọc về từ DMEM (ngoài)
    input  wire [31:0] data_readM,

    // sang W
    output wire        regwriteW,
    output wire [1:0]  wbselW,
    output wire [4:0]  rdW,
    output wire [31:0] ALUresW,
    output wire [31:0] data_readW,
    output wire [31:0] pc4W,

    // điều khiển tới DMEM (ngoài)
    output wire        dmem_we,
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata
);

    assign dmem_we    = memrwM;
    assign dmem_addr  = ALUresM;
    assign dmem_wdata = data_writeM;

    reg        regwriteM_r;
    reg [1:0]  wbselM_r;
    reg [4:0]  rdM_r;
    reg [31:0] ALUresM_r, data_readM_r, pc4M_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            regwriteM_r  <= 1'b0;
            wbselM_r     <= 2'b00;
            rdM_r        <= 5'd0;
            ALUresM_r    <= 32'd0;
            data_readM_r <= 32'd0;
            pc4M_r       <= 32'd0;
        end else begin
            regwriteM_r  <= regwriteM;
            wbselM_r     <= wbselM;
            rdM_r        <= rdM;
            ALUresM_r    <= ALUresM;
            data_readM_r <= data_readM;
            pc4M_r       <= pc4M;
        end
    end

    assign regwriteW  = regwriteM_r;
    assign wbselW     = wbselM_r;
    assign rdW        = rdM_r;
    assign ALUresW    = ALUresM_r;
    assign data_readW = data_readM_r;
    assign pc4W       = pc4M_r;

endmodule

