module big_system #(
    parameter integer N = 200,
    parameter integer GREEN_TIME = 3000,
    parameter integer YELLOW_TIME = 500,
    parameter integer CWIDTH = 256,
    parameter integer PWM_BITS = 256
)(
    input wire clk,
    input wire rst,
    input wire [N-1:0] sensor,
    output wire [N-1:0] NS_Red, NS_Yellow, NS_Green,
    output wire [N-1:0] EW_Red, EW_Yellow, EW_Green
);
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : G
            ctl_with_pwm #(
                .GREEN_TIME(GREEN_TIME), 
                .YELLOW_TIME(YELLOW_TIME),
                .CWIDTH(CWIDTH), 
                .PWM_BITS(PWM_BITS),
                .UNIQUE_ID(i)
            ) u (
                .clk(clk), .rst(rst), .sensor(sensor[i]),
                .NS_Red(NS_Red[i]), .NS_Yellow(NS_Yellow[i]), .NS_Green(NS_Green[i]),
                .EW_Red(EW_Red[i]), .EW_Yellow(EW_Yellow[i]), .EW_Green(EW_Green[i])
            );
        end
    endgenerate
endmodule
