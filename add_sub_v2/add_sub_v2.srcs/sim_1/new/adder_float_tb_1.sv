`timescale 1ns / 1ps

module adder_float_tb_1();

    // Inputs
    reg [31:0] a;
    reg [31:0] b;

    // Output
    wire [31:0] result;

    // Instantiate the floating point adder module
    adder_float uut (
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

    // Function to generate random 32-bit floating-point numbers within a given range
    function [31:0] get_random_float;
        input real min;
        input real max;
        real random_float;
        begin
            // Generate a random real number between 0 and 1
            random_float = $urandom() / 4294967295.0; // Scale to [0, 1]

            // Scale to the desired range
            get_random_float = $bitstoreal($realtobits(min + random_float * (max - min)));
        end
    endfunction
initial begin
    // Monitor output
    $monitor("Time: %0t | a = %h (%f) | b = %h (%f) | result = %h (%f)", 
             $time, a, ieee_754_to_real(a), b, ieee_754_to_real(b), result, ieee_754_to_real(result));

    // Add additional print statements
    $display("Starting test cases...");

    // Test case 1: Add two positive floating-point numbers
    a = 32'h40400000; // 3.0
    b = 32'h40000000; // 2.0
    #10;

    // Test case 2: Add positive and negative floating-point numbers
    a = 32'hC0400000; // -3.0
    b = 32'h40400000; // 3.0
    #10;

    // Test case 3: Add two negative floating-point numbers
    a = 32'hC0400000; // -3.0
    b = 32'hC0000000; // -2.0
    #10;

    // Test case 4: Add zero and a floating-point number
    a = 32'h00000000; // 0.0
    b = 32'h3F800000; // 1.0
    #10;

    // Test case 5: Add two large floating-point numbers
    a = 32'h7F7FFFFF; // Largest positive float
    b = 32'h7F7FFFFF; // Largest positive float
    #10;

    // End simulation
    $stop;
end

endmodule
