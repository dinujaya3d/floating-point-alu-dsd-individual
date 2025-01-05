module tb_top_alu;

    reg clk;
    reg reset;
    reg [1:0] sel;
    reg [31:0] a, b;
    wire [31:0] out;
    wire exception;
    wire zeroDiv;

    // Instantiate the top module
    top_alu uut (
        .clk(clk),
        .reset(reset),
        .sel(sel),
        .a(a),
        .b(b),
        .out(out),
        .exception(exception),
        .zeroDiv(zeroDiv)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        reset = 1;
        sel = 2'b00;
        a = 32'b0;
        b = 32'b0;

        // Reset pulse
        #100 reset = 0;

        // Test Addition
        #10 sel = 2'b00;
        a = 32'h40400000; // 3.0
        b = 32'h40800000; // 4.0
        #100;

        // Test Subtraction
        #10 sel = 2'b01;
        a = 32'h41000000; // 8.0
        b = 32'h3F800000; // 1.0
        #100;

        // Test Multiplication
        #10 sel = 2'b10;
        a = 32'h40000000; // 2.0
        b = 32'h40400000; // 3.0
        #100;

        // Test Division
        #10 sel = 2'b11;
        a = 32'h40800000; // 4.0
        b = 32'h40000000; // 2.0
        #100;

        // Test Division by Zero
        #10 sel = 2'b11;
        a = 32'h3F800000; // 1.0
        b = 32'h0;        // 0.0
        #100;

        // End simulation
        #10 $stop;
    end

endmodule
