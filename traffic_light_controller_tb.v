`timescale 1ns/1ps

module traffic_light_controller_tb;

    localparam integer CLK_PER_NS = 10; // 100 MHz
    localparam integer RESET_CYCLES = 10; 
    localparam integer RUN_CYCLES = 4000; 

    reg clk, rst, sensor;
    wire NS_Red, NS_Yellow, NS_Green;
    wire EW_Red, EW_Yellow, EW_Green;

    // Instantiate DUT
    traffic_light_controller dut (
        .clk(clk), .rst(rst), .sensor(sensor),
        .NS_Red(NS_Red), .NS_Yellow(NS_Yellow), .NS_Green(NS_Green),
        .EW_Red(EW_Red), .EW_Yellow(EW_Yellow), .EW_Green(EW_Green)
    );

    // Clock Generator
    initial begin
        clk = 1'b0;
        forever #(CLK_PER_NS/2) clk = ~clk;
    end

    // Waveform dump
    `ifdef VCD
    initial begin
        $dumpfile("traffic_light_controller_tb.vcd");
        $dumpvars(0, traffic_light_controller_tb);
    end
    `endif

    integer i;
    initial begin
        $timeformat(-9, 0, " ns", 10);
        $display("** TB start @ %0t **", $realtime);
        
        rst = 1'b1;
        sensor = 1'b0;
        
        // Reset
        for (i = 0; i < RESET_CYCLES; i = i + 1) @(posedge clk);
        rst = 1'b0;
        
        // Main run
        for (i = 0; i < RUN_CYCLES; i = i + 1) begin
            @(posedge clk);
            
            // Deterministic activity on sensor
            sensor <= sensor ^ NS_Green ^ EW_Green ^ NS_Yellow ^ EW_Yellow;
            
            // Heartbeat
            if ((i % 500) == 0)
                $display("%0t: heartbeat (i=%0d) NS[G,Y,R]=%0b%0b%0b EW[G,Y,R]=%0b%0b%0b",
                        $realtime, i, NS_Green, NS_Yellow, NS_Red, EW_Green, EW_Yellow, EW_Red);
            
            // Safety check: Never both greens high
            if (!rst && (NS_Green & EW_Green)) begin
                $display("ERROR @ %0t: Both NS and EW GREEN!", $realtime);
                $stop;
            end
        end
        $display("** TB finish @ %0t **", $realtime);
        $finish;
    end
endmodule
