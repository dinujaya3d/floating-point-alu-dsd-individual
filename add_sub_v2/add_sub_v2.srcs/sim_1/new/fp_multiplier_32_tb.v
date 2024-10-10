`timescale 1ns / 1ps

module tb_fp_multiplier_32();

    // Inputs
    reg [31:0] a;
    reg [31:0] b;

    // Output
    wire [31:0] result;

    // Instantiate the floating-point multiplier module
    fp_multiplier_32 uut (
        .a(a),
        .b(b),
        .result(result)
    );

    // Function to convert 32-bit IEEE 754 to real (decimal)
    function real ieee_754_to_real;
        input [31:0] fp;
        reg [22:0] mantissa;
        reg [7:0] exponent;
        reg sign;
        real fraction;
        integer i;
        begin
            sign = fp[31];
            exponent = fp[30:23] - 127; // Exponent with bias removed
            mantissa = fp[22:0];
            fraction = 1.0;

            // Convert mantissa to fraction
            for (i = 0; i < 23; i = i + 1) begin
                fraction = fraction + (mantissa[i] * (1.0 / (1 << (i + 1))));
            end

            // Compute the final real value
            ieee_754_to_real = (sign ? -1.0 : 1.0) * fraction * (2.0 ** exponent);
        end
    endfunction

    initial begin
        // Display result
        $monitor("Time: %0t | a = %h (%f) | b = %h (%f) | result = %h (%f)", 
                 $time, a, ieee_754_to_real(a), b, ieee_754_to_real(b), result, ieee_754_to_real(result));

        // Test case 1: Multiply two positive floating-point numbers
        a = 32'h40400000; // 3.0 in IEEE 754
        b = 32'h40000000; // 2.0 in IEEE 754
        #10;
        
        // Test case 2: Multiply positive and negative floating-point numbers
        a = 32'hC0400000; // -3.0 in IEEE 754
        b = 32'h40400000; // 2.0 in IEEE 754
        #10;
        
        // Test case 3: Multiply two negative floating-point numbers
        a = 32'hC0400000; // -3.0 in IEEE 754
        b = 32'hC0000000; // -2.0 in IEEE 754
        #10;
        
        // Test case 4: Multiply zero and a floating-point number
        a = 32'h00000000; // 0.0 in IEEE 754
        b = 32'h3F800000; // 1.0 in IEEE 754
        #10;

        // Test case 5: Multiply two large floating-point numbers
        a = 32'h7F7FFFFF; // Largest positive float (close to max)
        b = 32'h3F800000; // 1.0 in IEEE 754
        #10;

        // End simulation
        $stop;
    end

endmodule
