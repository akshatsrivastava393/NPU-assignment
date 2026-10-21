`timescale 1ns/1ps

module tb_bonus;

    reg  [127:0] A;
    reg  [127:0] B;
    reg  [1:0]   width_selection;
    reg          sub;
    wire [127:0] Y;

    integer passed;
    integer failed;
		//module instantiation
    bonus dut (.A(A),.B(B),.width_selection(width_selection),.sub(sub),.Y(Y));
    // apply one test vector and compare the full output.
    task check_result;
        input [1:0]   mode;
        input         operation;
        input [127:0] a_val;
        input [127:0] b_val;
        input [127:0] expected;
        begin
            width_selection = mode;
            sub = operation;
            A = a_val;
            B = b_val;

            #10;

            if (Y !== expected) begin
                $display(
                    "FAIL: mode=%b sub=%b A=%h B=%h",
                    mode, operation, a_val, b_val
                );
                $display("Expected Y = %h", expected);
                $display("Actual   Y = %h", Y);
                failed = failed + 1;
            end
            else begin
                $display(
                    "PASS: mode=%b sub=%b Y=%h",
                    mode, operation, Y
                );
                passed = passed + 1;
            end
        end
    endtask

    initial begin
        A = 128'b0;
        B = 128'b0;
        width_selection = 2'b00;
        sub = 1'b0;
        passed = 0;
        failed = 0;
			// 8 bit mode
        //normal addition, 10+20=30
        check_result(
            2'b00, 1'b0,
            {16{8'd10}}, {16{8'd20}},
            {16{8'd30}}
        );

        // normal subtraction, 50-20=30
        check_result(
            2'b00, 1'b1,
            {16{8'd50}}, {16{8'd20}},
            {16{8'd30}}
        );
			// Saturating addition, 250+20=255
        check_result(
            2'b00, 1'b0,
            {16{8'd250}}, {16{8'd20}},
            {16{8'hFF}}
        );

        // Underflow, 5-10=0
        check_result(
            2'b00, 1'b1,
            {16{8'd5}}, {16{8'd10}},
            {16{8'd0}}
        );
        // 16-bit mode: 8 lanes will be formed

        // Normal addition: 1000 + 2000 = 3000
        check_result(
            2'b01, 1'b0,
            {8{16'd1000}}, {8{16'd2000}},
            {8{16'd3000}}
        );

        // Normal subtraction:5000-2000 =3000
        check_result(
            2'b01, 1'b1,
            {8{16'd5000}}, {8{16'd2000}},
            {8{16'd3000}}
        );

        // Saturating addition: 65000+1000=65535
        check_result(
            2'b01, 1'b0,
            {8{16'd65000}}, {8{16'd1000}},
            {8{16'hFFFF}}
        );

        // Underflow:100-500=0
        check_result(
            2'b01, 1'b1,
            {8{16'd100}}, {8{16'd500}},
            {8{16'd0}}
        );
        // 32-bit mode: 4 lanes

        // Normal addition:100000+200000=300000
        check_result(
            2'b10, 1'b0,
            {4{32'd100000}}, {4{32'd200000}},
            {4{32'd300000}}
        );

        // Normal subtraction: 500000-200000=300000
        check_result(
            2'b10, 1'b1,
            {4{32'd500000}}, {4{32'd200000}},
            {4{32'd300000}}
        );

        // Saturating addition: overflow beyond 32 bits
        check_result(
            2'b10, 1'b0,
            {4{32'hFFFFFFF0}}, {4{32'h00000020}},
            {4{32'hFFFFFFFF}}
        );

        // Underflow: 100-500=0
        check_result(
            2'b10, 1'b1,
            {4{32'd100}}, {4{32'd500}},
            {4{32'd0}}
        );

        // Reserved width encoding must show our output zero
        check_result(
            2'b11, 1'b0,
            {128{1'b1}}, {128{1'b1}},
            128'b0
        );
			//dispplaying the results 
        $display("Tests passed = %0d", passed);
        $display("Tests failed = %0d", failed);
			$finish;
    end

endmodule