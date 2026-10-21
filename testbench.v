
`timescale 1ns/1ps

module testbench;

    reg clk;
    reg rst;
    reg start;
    reg [3:0] multiplicand;
    reg [3:0] multiplier;

    wire [7:0] product;
    wire done;
    code uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .done(done)
    );

    //generating the clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $monitor(
            "Time=%0t rst=%b start=%b M_in=%b Q_in=%b A=%b Q=%b C=%b count=%d product=%d done=%b",
            $time, rst, start, multiplicand, multiplier,
            uut.A, uut.Q, uut.C, uut.count, product, done
        );

        // Initializing inputs and reset
        rst = 1'b1;
        start = 1'b0;
        multiplicand = 4'b0000;
        multiplier = 4'b0000;

        repeat (2) @(negedge clk);
        rst = 1'b0;

        // Test 1: 11 x 7 = 77
        @(negedge clk);
        multiplicand = 4'b1011;
        multiplier   = 4'b0111;
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        wait(done == 1'b1);
        #1;
        if (product !== 8'd77)
            $display("TEST 1 FAILED: product=%d", product);
        else
            $display("TEST 1 PASSED: 11 x 7 = %d", product);

        // Allow the completion pulse to finish
        @(negedge clk);

        // Test 2: 6 x 9 = 54
        multiplicand = 4'b0110;
        multiplier   = 4'b1001;
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        wait(done == 1'b1);
        #1;
        if (product !== 8'd54)
            $display("TEST 2 FAILED: product=%d", product);
        else
            $display("TEST 2 PASSED: 6 x 9 = %d", product);

        @(negedge clk);
        $finish;
    end

endmodule
