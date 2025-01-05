module leading_zero_counter_sync (
    input clk,
    input [23:0] in,         // Input 24-bit signal
    output reg [4:0] count   // Output: Leading zero count
);
    integer i;

    always @(posedge clk) begin
        count = 0;
        for (i = 23; i >= 0; i = i - 1) begin
            if (in[i] == 1'b1) begin
                count = 23 - i;
                i = -1; // Exit the loop
            end
        end
    end
endmodule
