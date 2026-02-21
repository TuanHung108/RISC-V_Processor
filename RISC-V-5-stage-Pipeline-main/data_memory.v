module data_memory (
    input        clk, rst_n,
    input        memrw,             // 1 = write, 0 = read
    input  [31:0] address,
    input  [31:0] data_write,
    output [31:0] data_read
);
    reg [31:0] ram [0:255];
    wire [7:0] addr = address[9:2];

    always @(posedge clk) begin
        if (memrw) ram [addr] <= data_write; // ghi
    end
    
    assign data_read = ram[addr];

endmodule
