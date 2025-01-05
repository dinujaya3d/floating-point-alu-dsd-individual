module adder_float_tb;

    // Testbench signals
    reg clk;
    reg [31:0] a;
    reg [31:0] b;
    wire [31:0] result;

    // Instantiate the adder_float module
    adder_float uut (
        .clk(clk),
        .a(a),
        .b(b),
        .result(result)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10-time unit clock period
    end

    // Test stimulus
    initial begin
        // Monitor output
        $monitor("Time: %0t | a: %h | b: %h | result: %h", $time, a, b, result);

        // Initialize inputs
         a = 32'h40533333; // Infinity in IEEE 754
         b = 32'h404ccccd; // -Infinity in IEEE 754
        #10;


        // Run clock for 1000 cycles
        repeat (1000) @(posedge clk);
        $finish;
    end

endmodule
