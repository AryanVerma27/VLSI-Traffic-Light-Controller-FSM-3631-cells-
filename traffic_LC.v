module traffic_light_controller #(
    parameter integer GREEN_TIME  = 3000,
    parameter integer YELLOW_TIME = 500,
    parameter integer CWIDTH      = 256,
    parameter integer UNIQUE_ID   = 0
)(
    input  wire clk,
    input  wire rst,
    input  wire sensor,
    output reg  NS_Red,
    output reg  NS_Yellow,
    output reg  NS_Green,
    output reg  EW_Red,
    output reg  EW_Yellow,
    output reg  EW_Green
);
    localparam [3:0] S_NS_G = 4'b0001,
                     S_NS_Y = 4'b0010,
                     S_EW_G = 4'b0100,
                     S_EW_Y = 4'b1000;

    reg [3:0] state, next_state;
    reg [CWIDTH-1:0] counter, next_counter;
    
    reg [7:0] unique_reg;
    always @(posedge clk) begin
        if (rst) unique_reg <= 8'b00000000;
        else unique_reg <= unique_reg + UNIQUE_ID;
    end

    always @(posedge clk) begin
        if (rst) begin
            state   <= S_NS_G;
            counter <= {CWIDTH{1'b0}};
        end else begin
            state   <= next_state;
            counter <= next_counter;
        end
    end

    always @* begin
        next_state   = state;
        next_counter = counter + {{(CWIDTH-1){1'b0}},1'b1};

        case (state)
            S_NS_G: if (counter >= GREEN_TIME-1)  begin next_state=S_NS_Y; next_counter={CWIDTH{1'b0}}; end
            S_NS_Y: if (counter >= YELLOW_TIME-1) begin next_state=S_EW_G; next_counter={CWIDTH{1'b0}}; end
            S_EW_G: if (counter >= GREEN_TIME-1)  begin next_state=S_EW_Y; next_counter={CWIDTH{1'b0}}; end
            S_EW_Y: if (counter >= YELLOW_TIME-1) begin next_state=S_NS_G; next_counter={CWIDTH{1'b0}}; end
            default: begin next_state=S_NS_G; next_counter={CWIDTH{1'b0}}; end
        endcase
    end

    always @* begin
        NS_Red=0; NS_Yellow=0; NS_Green=0;
        EW_Red=0; EW_Yellow=0; EW_Green=0;
        case (state)
            S_NS_G: begin NS_Green=1;  EW_Red=1;  end
            S_NS_Y: begin NS_Yellow=1; EW_Red=1;  end
            S_EW_G: begin EW_Green=1;  NS_Red=1;  end
            S_EW_Y: begin EW_Yellow=1; NS_Red=1;  end
            default: begin NS_Green=1; EW_Red=1;  end
        endcase
    end
endmodule

module pwm #(
    parameter integer BITS = 256
)(
    input  wire clk,
    input  wire rst,
    input  wire [BITS-1:0] duty,
    output reg  y
);
    reg [BITS-1:0] cnt;
    always @(posedge clk) begin
        if (rst) cnt <= {BITS{1'b0}};
        else      cnt <= cnt + {{(BITS-1){1'b0}},1'b1};
    end
    always @* y = (cnt < duty);
endmodule

module ctl_with_pwm #(
    parameter integer GREEN_TIME  = 3000,
    parameter integer YELLOW_TIME = 500,
    parameter integer CWIDTH      = 256,
    parameter integer PWM_BITS    = 256,
    parameter integer UNIQUE_ID   = 0
)(
    input  wire clk,
    input  wire rst,
    input  wire sensor,
    output wire NS_Red, NS_Yellow, NS_Green,
    output wire EW_Red, EW_Yellow, EW_Green
);
    wire nsr, nsy, nsg, ewr, ewy, ewg;

    traffic_light_controller #(
        .GREEN_TIME(GREEN_TIME), .YELLOW_TIME(YELLOW_TIME), .CWIDTH(CWIDTH), .UNIQUE_ID(UNIQUE_ID)
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

module big_system #(
    parameter integer N             = 200,
    parameter integer GREEN_TIME    = 3000,
    parameter integer YELLOW_TIME   = 500,
    parameter integer CWIDTH        = 256,
    parameter integer PWM_BITS      = 256
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire [N-1:0]         sensor,
    output wire [N-1:0]         NS_Red, NS_Yellow, NS_Green,
    output wire [N-1:0]         EW_Red, EW_Yellow, EW_Green
);
    genvar i;
    generate
        for (i=0; i<N; i=i+1) begin : G
            ctl_with_pwm #(
                .GREEN_TIME(GREEN_TIME), .YELLOW_TIME(YELLOW_TIME),
                .CWIDTH(CWIDTH), .PWM_BITS(PWM_BITS),
                .UNIQUE_ID(i)
            ) u (
                .clk(clk), .rst(rst), .sensor(sensor[i]),
                .NS_Red(NS_Red[i]), .NS_Yellow(NS_Yellow[i]), .NS_Green(NS_Green[i]),
                .EW_Red(EW_Red[i]), .EW_Yellow(EW_Yellow[i]), .EW_Green(EW_Green[i])
            );
        end
    endgenerate
endmodule