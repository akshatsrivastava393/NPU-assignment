module code (
    input clk,
    input rst,
    input start,
    input [3:0] multiplicand,
    input [3:0] multiplier,
    output wire [7:0] product,
    output reg done
);

    // declaring registers to perform multiplication
    reg [3:0] M;  // Stores the multiplicand
    reg [3:0] A;  // Stores the partial result
    reg [3:0] Q;  // Stores the multiplier
    reg C;        // Stores the carry during addition

    // Keeping track of the number of shifts using count
    reg [1:0] count;
    reg busy;     // it becomes 1 when multiplication is in progress so that next cycle wait for some clock interval

    // Adding M and A, including the carry bit
    wire [4:0] add_result;
    assign add_result = {1'b0, A} + {1'b0, M};

    // Combining A and Q to get the final 8-bit product
    assign product = {A, Q};

    always @(posedge clk) begin
        if (rst) begin
            M     <= 4'b0000;
            A     <= 4'b0000;
            Q     <= 4'b0000;
            C     <= 1'b0;
            count <= 2'b00;
            busy  <= 1'b0;
            done  <= 1'b0;
        end
        else begin
            done <= 1'b0;

            // Loading the two numbers when start is high
            if (!busy && start) begin
                M     <= multiplicand;
                Q     <= multiplier;
                A     <= 4'b0000;
                C     <= 1'b0;
                count <= 2'b00;
                busy  <= 1'b1;
            end

            else if (busy) begin

                // Adding M to A if the last bit of Q is 1
                // Then shifting C, A and Q one bit to the right using simple shift logic
                if (Q[0]) begin
                    {C, A, Q} <= {add_result, Q} >> 1;
                end
                else begin
                    {C, A, Q} <= {1'b0, A, Q} >> 1;
                end

                // Finishing our cycle after four shifts
                if (count == 2'd3) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end
                else begin
                    count <= count + 1'b1;
                end
            end
        end
    end

endmodule