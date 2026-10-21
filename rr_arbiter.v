
module rr_arbiter (
    input clk,
    input rst,
    input [3:0] req,
    output reg [3:0] gnt
);

    //state reg will store our state which was last granted...
    reg [1:0] state;

    // Sequential logic, here the last grated pointer will be updated
    always @(posedge clk) begin
        if (rst) begin
            state <= 2'b11;  // Initialize to LAST3
        end
        else begin
            case (gnt)
                4'b0001: state <= 2'b00; // R0 is granted
                4'b0010: state <= 2'b01; // R1 is granted
                4'b0100: state <= 2'b10; // R2 is granted
                4'b1000: state <= 2'b11; // R3 is granted
                default: state <= state; // No one is granted, therfore state will hold itself
            endcase
        end
    end
    //this is the combinational logic here we assign the arbiter based on last granted one
    always @(*) begin
        gnt = 4'b0000;

        case (state)
            2'b00: begin // LAST0 was assigned, now priority will be R1, R2, R3, R0
                if      (req[1]) gnt = 4'b0010;
                else if (req[2]) gnt = 4'b0100;
                else if (req[3]) gnt = 4'b1000;
                else if (req[0]) gnt = 4'b0001;
            end

            2'b01: begin // LAST1 was assigned, now priority will be R2, R3, R0, R1
                if      (req[2]) gnt = 4'b0100;
                else if (req[3]) gnt = 4'b1000;
                else if (req[0]) gnt = 4'b0001;
                else if (req[1]) gnt = 4'b0010;
            end

            2'b10: begin // LAST2 was assigned, now priority will be R3, R0, R1, R2
                if      (req[3]) gnt = 4'b1000;
                else if (req[0]) gnt = 4'b0001;
                else if (req[1]) gnt = 4'b0010;
                else if (req[2]) gnt = 4'b0100;
            end

            2'b11: begin // LAST3 was assigned, now priority will be R0, R1, R2, R3
                if      (req[0]) gnt = 4'b0001;
                else if (req[1]) gnt = 4'b0010;
                else if (req[2]) gnt = 4'b0100;
                else if (req[3]) gnt = 4'b1000;
            end

            default: gnt = 4'b0000;
        endcase
    end

endmodule
