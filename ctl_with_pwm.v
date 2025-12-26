module ctl_with_pwm #(
    parameter integer GREEN_TIME = 3000,
    parameter integer YELLOW_TIME = 500,
    parameter integer CWIDTH = 256,
    parameter integer PWM_BITS = 256,
    parameter integer UNIQUE_ID = 0
)(
    input wire clk,
    input wire rst,
    input wire sensor,
    output wire NS_Red, NS_Yellow, NS_Green,
    output wire EW_Red, EW_Yellow, EW_Green
);
    wire nsr, nsy, nsg, ewr, ewy, ewg;

    traffic_light_controller #(
        .GREEN_TIME(GREEN_TIME), 
        .YELLOW_TIME(YELLOW_TIME),
        .CWIDTH(CWIDTH), 
        .UNIQUE_ID(UNIQUE_ID)
    ) u_ctl (
        .clk(clk), .rst(rst), .sensor(sensor),
        .NS_Red(nsr), .NS_Yellow(nsy), .NS_Green(nsg),
        .EW_Red(ewr), .EW_Yellow(ewy), .EW_Green(ewg)
    );

    localparam [PWM_BITS-1:0] FULL = {PWM_BITS{1'b1}};

    pwm #(.BITS(PWM_BITS)) p0(.clk(clk), .rst(rst), .duty(nsr ? FULL : {PWM_BITS{1'b0}}), .y(NS_Red));
    pwm #(.BITS(PWM_BITS)) p1(.clk(clk), .rst(rst), .duty(nsy ? FULL : {PWM_BITS{1'b0}}), .y(NS_Yellow));
    pwm #(.BITS(PWM_BITS)) p2(.clk(clk), .rst(rst), .duty(nsg ? FULL : {PWM_BITS{1'b0}}), .y(NS_Green));
    pwm #(.BITS(PWM_BITS)) p3(.clk(clk), .rst(rst), .duty(ewr ? FULL : {PWM_BITS{1'b0}}), .y(EW_Red));
    pwm #(.BITS(PWM_BITS)) p4(.clk(clk), .rst(rst), .duty(ewy ? FULL : {PWM_BITS{1'b0}}), .y(EW_Yellow));
    pwm #(.BITS(PWM_BITS)) p5(.clk(clk), .rst(rst), .duty(ewg ? FULL : {PWM_BITS{1'b0}}), .y(EW_Green));

endmodule
