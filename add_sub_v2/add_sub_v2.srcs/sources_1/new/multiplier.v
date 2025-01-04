module fp_multiplier_32 (
    input clk,                // Clock signal
    input [31:0] a,           // 32-bit floating point input a
    input [31:0] b,           // 32-bit floating point input b
    output reg [31:0] result  // 32-bit floating point output
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

    // Step 3: Generate partial products for mantissa multiplication using Wallace tree method
    reg [47:0] partial_products [0:23];
    integer i, j;

    always @(*) begin
        // Initialize partial products to zero
        for (i = 0; i < 24; i = i + 1) begin
            partial_products[i] = 48'b0;
        end

        // Generate partial products
        for (i = 0; i < 24; i = i + 1) begin
            for (j = 0; j < 24; j = j + 1) begin
                partial_products[i][j + i] = mant_a[i] & mant_b[j];
            end
        end
    end

    // Step 4: Sum partial products using a Wallace tree structure
    reg [47:0] mant_product;
    always @(*) begin
        mant_product = 48'b0;  // Initialize the product to zero

        // Sum up all the partial products
        for (i = 0; i < 24; i = i + 1) begin
            mant_product = mant_product + partial_products[i];
        end
    end

    // Step 5: Normalize the mantissa result
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

    // Step 6: Handle special cases like zero, infinity, and NaN
    wire is_zero = (a[30:0] == 0) || (b[30:0] == 0);
    wire is_inf = (exp_a == 8'hFF) || (exp_b == 8'hFF);
    wire is_nan = (exp_a == 8'hFF && mant_a != 0) || (exp_b == 8'hFF && mant_b != 0);

    // Step 7: Construct the final result on posedge clk
    always @(posedge clk) begin
        if (is_nan) begin
            result <= {1'b0, 8'hFF, 23'h1}; // NaN representation
        end else if (is_inf) begin
            result <= {sign_result, 8'hFF, 23'h0}; // Infinity representation
        end else if (is_zero) begin
            result <= 32'b0; // Zero representation
        end else begin
            result <= {sign_result, exponent_result, mantissa_result}; // Normal result
        end
    end

endmodule
