module reciprocal_nr(
    input clk,
    input start,
    input [17:0] D,        // Input value
    output reg [17:0] xf,  // Reciprocal output
    output reg done
);
    reg [17:0] x0, x1, x2, x4, x5, x7;
    reg [47:0] t0, x3, x6;
    reg [3:0] iteration_count;
    parameter two = 18'b000000010_000000000;
    parameter m = 18'b000000010_110100101; // Approximation factor (48/17)
    parameter n = 18'b000000001_111000011; // Approximation factor (32/17)

    always @(posedge clk) begin
        if (start) begin
            // Initialization
            t0 <= n * D; 
            x0 <= m - t0[26:9]; // Initial approximation
            x1 <= x0;
            iteration_count <= 0;
            done <= 0;
        end else if (!done) begin
            // Newton-Raphson iteration
            x3 <= D * x1;
            x4 <= x3[26:9];
            x5 <= two - x4;
            x6 <= x5 * x1;
            x7 <= x6[26:9];
            x1 <= x7;

            iteration_count <= iteration_count + 1;

            // Finalize after sufficient iterations
            if (iteration_count >= 4) begin
                xf <= x7;
                done <= 1;
            end
        end
    end
endmodule
