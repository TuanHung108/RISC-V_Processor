`timescale 1ns/1ps

module tb_riscv;
    reg clk;
    reg rst_n;
    wire [31:0] instrF, pcF;

    // DUT
    riscv dut (
        .clk   (clk),
        .rst_n (rst_n),
        .instrF(instrF),
        .pcF   (pcF)
    );

    imem imem_inst (
        .pc     (pcF),
        .ins    (instrF)
    );

    // clock 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // reset + stimulus
    initial begin
        #10
        rst_n = 0;
        #10;
        rst_n = 1;

        // chạy mô phỏng 500ns
        #400;
        $finish;
    end

    // quan sát waveform hoặc in log
    initial begin
        $monitor("t=%0t pcF=%h instrF=%h ALUresM=%h memrwM=%b dataW=%h dataR=%h",
                  $time,
                  dut.pcF,
                  dut.instrF,
                  dut.ALUresM,
                  dut.memrwM,
                  dut.data_writeM,
                  dut.data_readM);
    end
endmodule
