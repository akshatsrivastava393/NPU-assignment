module bonus (
    input  wire [127:0] A,
    input  wire [127:0] B,
    input  wire [1:0]   width_selection,
    input  wire         sub,
    output reg  [127:0] Y
);
    //the following are the simple control signals that we have used in our design
    // sub = 0 means addition
    // sub = 1 means Subtraction
    // width_selection = 00: 16 lanes, each 8 bits
    // width_selection = 01:  8 lanes, each 16 bits
    // width_selection = 10:  4 lanes, each 32 bits
    // width_selection = 11: Reserved; output will be zero

    integer i;

    // as our design of structure every time we compute 3 results 
    reg [8:0]  sum_8;
    reg [16:0] sum_16;
    reg [32:0] sum_32;

    always @(*) begin
        
        Y = 128'b0;// this is the default output for invalid width selection like 2'b11

        // these defaults are used to avoid latch generation in case of invalid input
        sum_8  = 9'b0;
        sum_16 = 17'b0;
        sum_32 = 33'b0;

        case (width_selection)

           
            2'b00: begin //for 8 bit mode
                for (i = 0; i < 16; i = i + 1) begin

                    if (sub == 1'b0) begin
                        // we will extende operands to one extra bit for addition
                        sum_8 = {1'b0, A[i*8 +: 8]}
                             + {1'b0, B[i*8 +: 8]};

                        //logic for saturation is simple case statements
                        if (sum_8[8])
                            Y[i*8 +: 8] = 8'hFF;// result saturates to 255
                        else
                            Y[i*8 +: 8] = sum_8[7:0];
                    end
                    else begin
                        // negative results will saturate to zero
                        if (A[i*8 +: 8] < B[i*8 +: 8])
                            Y[i*8 +: 8] = 8'h00;
                        else
                            Y[i*8 +: 8] =
                                A[i*8 +: 8] - B[i*8 +: 8];
                    end
                end
            end
				
				// now 16 bit mode, here 8 lanes will be formed
            2'b01: begin
                for (i = 0; i < 8; i = i + 1) begin

                    if (sub == 1'b0) begin
                        sum_16 = {1'b0, A[i*16 +: 16]}
                              + {1'b0, B[i*16 +: 16]};

                        if (sum_16[16])
                            Y[i*16 +: 16] = 16'hFFFF;// result saturates to 65535
                        else
                            Y[i*16 +: 16] = sum_16[15:0];
                    end
                    else begin
                        if (A[i*16 +: 16] < B[i*16 +: 16])
                            Y[i*16 +: 16] = 16'h0000;
                        else
                            Y[i*16 +: 16] =
                                A[i*16 +: 16] - B[i*16 +: 16];
                    end
                end
            end

            // 32 bit mode, 4 diffent lanes will be formed
            2'b10: begin
                for (i = 0; i < 4; i = i + 1) begin

                    if (sub == 1'b0) begin
                        sum_32 = {1'b0, A[i*32 +: 32]}
                              + {1'b0, B[i*32 +: 32]};

                        if (sum_32[32])
                            Y[i*32 +: 32] = 32'hFFFFFFFF;//result saturates to 4294967295
                        else
                            Y[i*32 +: 32] = sum_32[31:0];
                    end
                    else begin
                        if (A[i*32 +: 32] < B[i*32 +: 32])
                            Y[i*32 +: 32] = 32'h00000000;
                        else
                            Y[i*32 +: 32] =
                                A[i*32 +: 32] - B[i*32 +: 32];
                    end
                end
            end

            // for reserved width we will put output as default zero 
            default: begin
                Y = 128'b0;
            end

        endcase
    end

endmodule