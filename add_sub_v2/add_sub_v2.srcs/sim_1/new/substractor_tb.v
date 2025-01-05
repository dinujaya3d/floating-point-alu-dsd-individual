module tb_substractor_float;

    reg clk;
    reg [31:0] a, b;
    wire [31:0] result;

    // Instantiate the subtractor
    substractor_float uut (
        .clk(clk),
        .a(a),
        .b(b),
        .result(result)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    // Test sequence
    initial begin
        $display("Starting test for IEEE 754 Subtractor...");

        // Test 1: Subtract two positive numbers
        a = 32'h41200000; // 10.0
        b = 32'h40A00000; // 5.0
        #1000;
        $display("Test 1: A = %h, B = %h, Result = %h", a, b, result);
        $finish;
    end

endmodule
