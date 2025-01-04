module adder_float(
    input clk,              // Clock signal
    input [31:0] a,         // 32-bit floating point input a
    input [31:0] b,         // 32-bit floating point input b
    output reg [31:0] result // 32-bit floating point output
);

    // Extract sign, exponent, and mantissa from inputs
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] mant_a = {1'b1, a[22:0]}; // Implicit 1
    wire [23:0] mant_b = {1'b1, b[22:0]}; // Implicit 1

    // Intermediate registers
    reg [7:0] exp_common;
    reg [23:0] mant_a_shifted, mant_b_shifted;
    reg [24:0] mant_sum;
    reg [7:0] exp_result;
    reg [23:0] mant_result;
    reg sign_result;

    // Sequential logic block
    always @(posedge clk) begin
        // Step 1: Align exponents by shifting mantissa
        if (exp_a > exp_b) begin
            exp_common <= exp_a;
            mant_a_shifted <= mant_a;
            mant_b_shifted <= mant_b >> (exp_a - exp_b);
        end else begin
            exp_common <= exp_b;
            mant_a_shifted <= mant_a >> (exp_b - exp_a);
            mant_b_shifted <= mant_b;
        end

        // Step 2: Add/Subtract mantissas
        if (sign_a == sign_b) begin
            mant_sum <= mant_a_shifted + mant_b_shifted;
            sign_result <= sign_a;
        end else if (mant_a_shifted > mant_b_shifted) begin
            mant_sum <= mant_a_shifted - mant_b_shifted;
            sign_result <= sign_a;
        end else begin
            mant_sum <= mant_b_shifted - mant_a_shifted;
            sign_result <= sign_b;
        end

        // Step 3: Normalize the result
        if (mant_sum[24]) begin
            mant_result <= mant_sum[24:1]; // Normalize mantissa
            exp_result <= exp_common + 1; // Increment exponent
        end else begin
            mant_result <= mant_sum[23:0];
            exp_result <= exp_common;
        end

        // Step 4: Handle zero result condition
        if (mant_sum == 0) begin
            result <= 32'b0; // Zero result
        end else begin
            result <= {sign_result, exp_result, mant_result[22:0]}; // Combine sign, exponent, and mantissa
        end
    end

endmodule
