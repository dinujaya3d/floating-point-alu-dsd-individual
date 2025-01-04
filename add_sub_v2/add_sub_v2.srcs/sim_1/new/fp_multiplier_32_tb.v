module tb_fp_multiplier_32;

    reg clk;
    reg [31:0] a, b;  // Inputs to the multiplier
    wire [31:0] result;  // Output from the multiplier

    // Instantiate the fp_multiplier_32 module
    fp_multiplier_32 uut (
        .clk(clk),
        .a(a),
        .b(b),
        .result(result)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10 time units clock period
    end

    // Test stimulus
    initial begin
        // Apply test inputs
        a = 32'h425371AA;  // 1.0 in IEEE 754
        b = 32'hC29147AE;  // 2.0 in IEEE 754

        // Wait for 1000 clock cycles
        #10000;

        // Finish simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor($time, " clk=%b, a=%h, b=%h, result=%h", clk, a, b, result);
    end

endmodule
