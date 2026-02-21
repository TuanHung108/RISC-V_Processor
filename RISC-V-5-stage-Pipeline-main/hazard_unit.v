module hazard_unit( 
    input  [4:0] rs1E, rs2E,
    input  [4:0] rs1D, rs2D,
    input  [4:0] rdM, rdW, rdE,
    input        regwriteM, regwriteW,
    input  [1:0] wbselE,      
    input        pcselE,
    output       flushE,
    output       flushD,
    output       stallF, stallD,
    output reg [1:0] forwardAE, forwardBE
);
    // Forwarding Control
    always @(regwriteM, regwriteW, rs1E, rs2E, rdM, rdW) begin
        if (regwriteM && (rdM != 5'd0) && (rs1E == rdM))  begin
            forwardAE = 2'b10;
        end else if (regwriteW && (rdW != 5'd0) && (rs1E == rdW)) begin
            forwardAE = 2'b01;
        end else begin
            forwardAE = 2'b00;
        end

        if (regwriteM && (rdM != 5'd0) && (rs2E == rdM)) begin
            forwardBE = 2'b10;
        end else if (regwriteW && (rdW != 5'd0) && (rs2E == rdW)) begin
            forwardBE = 2'b01;
        end else begin
            forwardBE = 2'b00;
        end
    end


    // Stalling Control
    wire lwstall;
    assign lwstall = (wbselE == 2'b00) && (rdE != 5'd0) && ((rs1D == rdE) || (rs2D == rdE));
    assign stallD = lwstall;
    assign stallF = lwstall;

    // Control hazard
    assign flushD = pcselE;
    assign flushE = lwstall | pcselE;
    
endmodule



