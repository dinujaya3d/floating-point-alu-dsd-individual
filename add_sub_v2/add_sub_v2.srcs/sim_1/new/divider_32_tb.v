module tb_divider_32;
    reg clk, reset, start;
    reg [31:0] DD, DS;
    wire [31:0] out;
    wire exception, zeroDiv;

    divider_32 uut (
        .clk(clk),
        .reset(reset),
        .DD(DD),
        .DS(DS),
        .start(start),
        .out(out),
        .exception(exception),
        .zeroDiv(zeroDiv)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1; start = 0; DD = 0; DS = 0;
        #10 reset = 0;

        // Test 1: 3.0 / 2.0
        DD = 32'h40400000; // 3.0
        DS = 32'h40000000; // 2.0
        #10 start = 1; #10 start = 0; #50;

        // Test 2: 0.0 / 2.0
        DD = 32'h00000000; // 0.0
        DS = 32'h40000000; // 2.0
        #10 start = 1; #10 start = 0; #50;

        // Test 3: 3.0 / 0.0
        DD = 32'h40400000; // 3.0
        DS = 32'h00000000; // 0.0
        #10 start = 1; #10 start = 0; #50;

        $finish;
    end
endmodule
