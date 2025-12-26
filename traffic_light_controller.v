module traffic_light_controller #(
    parameter integer GREEN_TIME = 3000,
    parameter integer YELLOW_TIME = 500,
    parameter integer CWIDTH = 256,
    parameter integer UNIQUE_ID = 0
)(
    input wire clk,
    input wire rst,
    input wire sensor,
    output reg NS_Red,
    output reg NS_Yellow,
    output reg NS_Green,
    output reg EW_Red,
    output reg EW_Yellow,
    output reg EW_Green
);

    // State Encoding
    localparam [3:0] S_NS_G = 4'b0001;
    localparam [3:0] S_NS_Y = 4'b0010;
    localparam [3:0] S_EW_G = 4'b0100;
    localparam [3:0] S_EW_Y = 4'b1000;

    reg [3:0] state, next_state;
    reg [CWIDTH-1:0] counter, next_counter;
    reg [7:0] unique_reg;

    // Unique ID Registration
    always @(posedge clk) begin
        if (rst) 
            unique_reg <= 8'b00000000;
        else 
            unique_reg <= unique_reg + UNIQUE_ID;
    end

    // Sequential Logic
    always @(posedge clk) begin
        if (rst) begin
            state <= S_NS_G;
            counter <= {CWIDTH{1'b0}};
        end else begin
            state <= next_state;
            counter <= next_counter;
        end
    end

    // Next State Logic
    always @(*) begin
        next_state = state;
        next_counter = counter + {{ (CWIDTH-1){1'b0} }, 1'b1};
        
        case (state)
            S_NS_G: if (counter >= GREEN_TIME - 1) begin 
                        next_state = S_NS_Y; 
                        next_counter = {CWIDTH{1'b0}}; 
                    end
            S_NS_Y: if (counter >= YELLOW_TIME - 1) begin 
                        next_state = S_EW_G; 
                        next_counter = {CWIDTH{1'b0}}; 
                    end
            S_EW_G: if (counter >= GREEN_TIME - 1) begin 
                        next_state = S_EW_Y; 
                        next_counter = {CWIDTH{1'b0}}; 
                    end
            S_EW_Y: if (counter >= YELLOW_TIME - 1) begin 
                        next_state = S_NS_G; 
                        next_counter = {CWIDTH{1'b0}}; 
                    end
            default: begin 
                        next_state = S_NS_G; 
                        next_counter = {CWIDTH{1'b0}}; 
                     end
        endcase
    end

    // Output Logic
    always @(*) begin
        NS_Red = 0; NS_Yellow = 0; NS_Green = 0;
        EW_Red = 0; EW_Yellow = 0; EW_Green = 0;
        
        case (state)
            S_NS_G: begin NS_Green = 1; EW_Red = 1; end
            S_NS_Y: begin NS_Yellow = 1; EW_Red = 1; end
            S_EW_G: begin EW_Green = 1; NS_Red = 1; end
            S_EW_Y: begin EW_Yellow = 1; NS_Red = 1; end
            default: begin NS_Green = 1; EW_Red = 1; end
        endcase
    end
endmodule
