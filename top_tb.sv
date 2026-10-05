`timescale 10ns/10ns
`include "top.sv"

module top_tb;

    parameter PWM_INTERVAL = 1200;

    logic clk = 0;
    logic RGB_B;
    logic RGB_G;
    logic RGB_R;
    real red_percentage = 0.0;
    real green_percentage = 0.0;
    real blue_percentage = 0.0;

    top #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u0 (
        .clk            (clk),
        .RGB_B          (RGB_B),
        .RGB_G          (RGB_G),
        .RGB_R          (RGB_R)
    );


    // Create VCD file for GTKWave
    initial begin

        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        // since there's 6 colors to run within a second
        #100000000;
        $finish;
    end

    always begin
        #4;
        clk = ~clk;
    end

    always @(posedge clk) begin
        red_percentage <= (u0.pwm_r_value * 100.0) / PWM_INTERVAL;
        green_percentage <= (u0.pwm_g_value * 100.0) / PWM_INTERVAL;
        blue_percentage <= (u0.pwm_b_value * 100.0) / PWM_INTERVAL;
    end

endmodule