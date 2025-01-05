module top_alu (
    input clk,               // Clock signal
    input reset,             // Reset signal
    input [1:0] sel,         // Selection signal: 00-Add, 01-Subtract, 10-Multiply, 11-Divide
    input [31:0] a,          // Input A (32-bit IEEE-754 floating-point)
    input [31:0] b,          // Input B (32-bit IEEE-754 floating-point)
    output reg [31:0] out,   // Output result (32-bit IEEE-754 floating-point)
    output reg exception,    // Exception flag for division
    output reg zeroDiv       // Zero division flag for division
);

    // Internal wires
    wire [31:0] add_out, sub_out, mul_out, div_out;
    wire div_exception, div_zeroDiv;

    // Instantiate functional modules
    adder_float adder (
        .clk(clk),
        .a(a),
        .b(b),
        .result(add_out)
    );

    subtractor_float subtractor (
        .clk(clk),
        .a(a),
        .b(b),
        .result(sub_out)
    );

    fp_multiplier_32 multiplier (
        .clk(clk),
        .a(a),
        .b(b),
        .result(mul_out)
    );

    divider_32 divider (
        .clk(clk),
        .reset(reset),
        .DD(a),
        .DS(b),
        .start(sel == 2'b11),  // Start division only when selected
        .out(div_out),
        .exception(div_exception),
        .zeroDiv(div_zeroDiv)
    );

    // Control logic to route outputs based on `sel`
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            out <= 32'b0;
            exception <= 0;
            zeroDiv <= 0;
        end else begin
            case (sel)
                2'b00: begin
                    out <= add_out;
                    exception <= 0;
                    zeroDiv <= 0;
                end
                2'b01: begin
                    out <= sub_out;
                    exception <= 0;
                    zeroDiv <= 0;
                end
                2'b10: begin
                    out <= mul_out;
                    exception <= 0;
                    zeroDiv <= 0;
                end
                2'b11: begin
                    out <= div_out;
                    exception <= div_exception;
                    zeroDiv <= div_zeroDiv;
                end
                default: begin
                    out <= 32'b0;
                    exception <= 0;
                    zeroDiv <= 0;
                end
            endcase
        end
    end

endmodule
