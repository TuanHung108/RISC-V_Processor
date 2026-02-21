module fetch (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        pcselE,
    input  wire [31:0] pcTargetE,
    input  wire [31:0] instrF,
    input  wire        stallF,
    input  wire        stallD,
    input  wire        flushD,

    output reg  [31:0] pcF,
    output wire [31:0] instrD,
    output wire [31:0] pc4D,
    output wire [31:0] pcD
);
    wire [31:0] pc4F = pcF + 32'd4;
    wire [31:0] pc_next = (pcselE) ? pcTargetE : pc4F;

    reg [31:0] instrF_reg;
    reg [31:0] pcF_reg, pc4F_reg;

    // PC register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pcF <= 32'd0;
        end else begin
            if (!stallF)
                pcF <= pc_next;
        end
    end

    // Fetch Cycle Register Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instrF_reg <= 32'd0;
            pcF_reg    <= 32'd0;
            pc4F_reg   <= 32'd0;
        end else begin
            if (flushD) begin
                instrF_reg <= 32'h00000013; // NOP
                pcF_reg    <= 32'd0;
                pc4F_reg   <= 32'd0;
            end else if (!stallD) begin
                instrF_reg <= instrF;
                pcF_reg    <= pcF;
                pc4F_reg   <= pc4F;
            end
        end
    end

    assign instrD = instrF_reg;
    assign pcD    = pcF_reg;
    assign pc4D   = pc4F_reg;

endmodule

