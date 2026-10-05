`include "Project_2.sv"
`include "pwm.sv"

// Top level module for the RGB color wheel

module top #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk,

    output logic    RGB_B,
    output logic    RGB_G,
    output logic    RGB_R
);

    logic [$clog2(PWM_INTERVAL):0] pwm_r_value;
    logic [$clog2(PWM_INTERVAL):0] pwm_g_value;
    logic [$clog2(PWM_INTERVAL):0] pwm_b_value;
    logic pwm_r_out;
    logic pwm_g_out;
    logic pwm_b_out;

    Project_2 #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk            (clk),
        .pwm_r_value    (pwm_r_value),
        .pwm_g_value    (pwm_g_value),
        .pwm_b_value    (pwm_b_value)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) red_pwm (
        .clk            (clk),
        .pwm_value      (pwm_r_value),
        .pwm_out        (pwm_r_out)
    );

    pwm #(
        .PWM_INTERVAL(PWM_INTERVAL)
    ) green_pwm (
        .clk            (clk),
        .pwm_value      (pwm_g_value),
        .pwm_out        (pwm_g_out)
    );

    pwm #(
        .PWM_INTERVAL(PWM_INTERVAL)
    ) blue_pwm (
        .clk            (clk),
        .pwm_value      (pwm_b_value),
        .pwm_out        (pwm_b_out)
    );

    assign RGB_R = ~pwm_r_out;
    assign RGB_G = ~pwm_g_out;
    assign RGB_B = ~pwm_b_out;

endmodule