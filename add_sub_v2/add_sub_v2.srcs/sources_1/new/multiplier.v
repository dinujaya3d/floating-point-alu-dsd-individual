module fp_multiplier_32 (
    input [31:0] a,  // 32-bit floating point input a
    input [31:0] b,  // 32-bit floating point input b
    output [31:0] result  // 32-bit floating point output
);

    // Extract sign, exponent, and mantissa from inputs
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] mant_a = {1'b1, a[22:0]}; // Implicit leading 1
    wire [23:0] mant_b = {1'b1, b[22:0]}; // Implicit leading 1

    // Step 1: Compute the sign of the result
    wire sign_result = sign_a ^ sign_b;

    // Step 2: Add exponents and subtract bias (127) from the sum
    wire [8:0] exp_sum = exp_a + exp_b - 127;

    // Step 3: Multiply the mantissas using shift-and-add method
    reg [47:0] mant_product;  // Double-width to store the product of two 24-bit numbers
    integer i;

    always @(*) begin
        mant_product = 48'b0;  // Initialize the product to zero
        for (i = 0; i < 24; i = i + 1) begin
            if (mant_b[i]) begin
                mant_product = mant_product + (mant_a << i);
            end
        end
    end

    // Step 4: Normalize the mantissa result
    reg [22:0] mantissa_result;
    reg [7:0] exponent_result;
    always @(*) begin
        if (mant_product[47]) begin  // If there is a carry, shift right and adjust the exponent
            mantissa_result = mant_product[46:24];
            exponent_result = exp_sum + 1;
        end else begin
            mantissa_result = mant_product[45:23];
            exponent_result = exp_sum;
        end
    end

    // Step 5: Handle special cases like zero, infinity, and NaN
    wire is_zero = (a[30:0] == 0) || (b[30:0] == 0);
    wire is_inf = (exp_a == 8'hFF && mant_a == 0) || (exp_b == 8'hFF && mant_b == 0);
    wire is_nan = (exp_a == 8'hFF && mant_a != 0) || (exp_b == 8'hFF && mant_b != 0);

    assign result = (is_nan) ? {1'b0, 8'hFF, 23'h1} :  // NaN representation
                    (is_inf) ? {sign_result, 8'hFF, 23'h0} :  // Infinity representation
                    (is_zero) ? 32'b0 :  // Zero representation
                    {sign_result, exponent_result, mantissa_result};  // Normal result

endmodule
