module substractor_float (
    input clk,
    input [31:0] a,          // Input A in IEEE 754 format
    input [31:0] b,          // Input B in IEEE 754 format
    output reg [31:0] result // Result in IEEE 754 format
);
    // Internal signals
    reg sign_a, sign_b, sign_result;
    reg [7:0] exp_a, exp_b, exp_result, exp_diff;
    reg [23:0] mantissa_a, mantissa_b, mantissa_diff, normalized_mantissa;
    reg [24:0] diff_mantissa;
    wire [4:0] leading_zeros; // Output of leading_zero_counter_sync is now a wire

    // Instantiate synchronous leading zero counter
    leading_zero_counter_sync lzc (
        .clk(clk),
        .in(mantissa_diff),
        .count(leading_zeros)
    );

    always @(posedge clk) begin
        // Extract fields from input operands
        sign_a = a[31];
        sign_b = ~b[31]; // Negate B's sign for subtraction
        exp_a = a[30:23];
        exp_b = b[30:23];
        mantissa_a = {1'b1, a[22:0]}; // Add implicit leading 1
        mantissa_b = {1'b1, b[22:0]}; // Add implicit leading 1

        // Align mantissas
        if (exp_a > exp_b) begin
            exp_diff = exp_a - exp_b;
            mantissa_b = mantissa_b >> exp_diff;
            exp_result = exp_a;
        end else begin
            exp_diff = exp_b - exp_a;
            mantissa_a = mantissa_a >> exp_diff;
            exp_result = exp_b;
        end

        // Subtract mantissas
        if (mantissa_a >= mantissa_b) begin
            diff_mantissa = mantissa_a - mantissa_b;
            sign_result = sign_a;
        end else begin
            diff_mantissa = mantissa_b - mantissa_a;
            sign_result = sign_b;
        end

        // Normalize result
        mantissa_diff = diff_mantissa[23:0];
        if (mantissa_diff != 0) begin
            normalized_mantissa = mantissa_diff << leading_zeros;
            exp_result = exp_result - leading_zeros;
        end else begin
            normalized_mantissa = 24'b0;
        end

        // Pack result
        result = {sign_result, exp_result, normalized_mantissa[22:0]};
    end
endmodule
