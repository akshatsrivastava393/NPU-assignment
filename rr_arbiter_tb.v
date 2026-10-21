
`timescale 1ns/1ps

module rr_arbiter_tb;

    reg clk;
    reg rst;
    reg [3:0] req;
    wire [3:0] gnt;

    rr_arbiter uut (
        .clk(clk),
        .rst(rst),
        .req(req),
        .gnt(gnt)
    );

    // generating the clock signal
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $monitor(
            "t=%0t rst=%b req=%b gnt=%b state=%b",
            $time, rst, req, gnt, uut.state
        );

        // Reset case to last3 state
        rst = 1'b1;
        req = 4'b0000;
        repeat (2) @(negedge clk);
        rst = 1'b0;

        // All requesters remain active, now the grant will happen based on priority order
        req = 4'b1111;
        repeat (8) @(negedge clk);

        // testing requests R0 and R2
        req = 4'b0101;
        repeat (4) @(negedge clk);

        // No active requests: grant zero, pointer holds
        req = 4'b0000;
        repeat (3) @(negedge clk);

        $finish;
    end

endmodule
