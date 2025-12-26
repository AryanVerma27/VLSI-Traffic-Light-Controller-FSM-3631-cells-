module pwm #(
    parameter integer BITS = 256
)(
    input wire clk,
    input wire rst,
    input wire [BITS-1:0] duty,
    output reg y
);
    reg [BITS-1:0] cnt;

    always @(posedge clk) begin
        if (rst) 
            cnt <= {BITS{1'b0}};
        else
            cnt <= cnt + {{ (BITS-1){1'b0} }, 1'b1};
    end

    always @(*) y = (cnt < duty);

endmodule
