module adder_float(
    input [31:0] a,  // 32-bit floating point input a
    input [31:0] b,  // 32-bit floating point input b
    output [31:0] result  // 32-bit floating point output
);

    // Extract sign, exponent, and mantissa from inputs
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] mant_a = {1'b1, a[22:0]}; // Implicit 1
    wire [23:0] mant_b = {1'b1, b[22:0]}; // Implicit 1

    // Step 1: Align exponents by shifting mantissa
    wire [7:0] exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
    wire [23:0] mant_a_shifted, mant_b_shifted;

    assign mant_a_shifted = (exp_a > exp_b) ? mant_a : (mant_a >> exp_diff);
    assign mant_b_shifted = (exp_b > exp_a) ? mant_b : (mant_b >> exp_diff);
    wire [7:0] exp_common = (exp_a > exp_b) ? exp_a : exp_b;

    // Step 2: Add/Subtract mantissas
    wire [24:0] mant_sum;
    assign mant_sum = (sign_a == sign_b) ? (mant_a_shifted + mant_b_shifted) :
                      (mant_a_shifted > mant_b_shifted) ? (mant_a_shifted - mant_b_shifted) :
                                                          (mant_b_shifted - mant_a_shifted);

    // Step 3: Normalize the result
    reg [7:0] exp_result;
    reg [23:0] mant_result;
    wire sign_result;

    always @(*) begin
        if (mant_sum[24]) begin
            // Result needs normalization (carry out)
            mant_result = mant_sum[24:1];  // Blocking assignment
            exp_result = exp_common + 1;   // Blocking assignment
        end else begin
            mant_result = mant_sum[23:0];  // Blocking assignment
            exp_result = exp_common;       // Blocking assignment
        end
    end

    // Step 4: Handle zero result condition
    assign sign_result = (mant_sum == 0) ? 0 : 
                         (sign_a == sign_b) ? sign_a : 
                         (mant_a > mant_b) ? sign_a : sign_b;

    // If the result is zero, set both exponent and mantissa to zero
    assign result = (mant_sum == 0) ? 32'b0 : {sign_result, exp_result, mant_result[22:0]};  // Combine sign, exponent, and mantissa

endmodule
