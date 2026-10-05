
module Project_2 #(
    parameter INC_DEC_INTERVAL = 10000,     // CLK frequency is 12MHz, so 10,000 cycles is ~833 us
    parameter INC_DEC_MAX = 200,            // Transition to next state after 200 increments / decrements, which is 0.2s
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX // 6 stages
)(
    input logic clk,
    // outputs for every LED instead of just one
    output logic [$clog2(PWM_INTERVAL):0] pwm_r_value,
    output logic [$clog2(PWM_INTERVAL):0] pwm_g_value,
    output logic [$clog2(PWM_INTERVAL):0] pwm_b_value
);

    // Define state variable values
    // 0: red -> yellow
    // 1: yellow -> green
    // 2: green -> cyan
    // 3: cyan -> blue
    // 4: blue -> magenta
    // 5: magenta -> red
    localparam COLOR_0 = 3'd0;
    localparam COLOR_1 = 3'd1;
    localparam COLOR_2 = 3'd2;
    localparam COLOR_3 = 3'd3;
    localparam COLOR_4 = 3'd4;
    localparam COLOR_5 = 3'd5;


    // Declare state variables
    logic [2:0] current_state = COLOR_0;
    logic [2:0] next_state;


    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL)-1:0] count = 0;
    logic [$clog2(INC_DEC_MAX)-1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        // pwm starts at red, so red will be max, and green and blue will be min
        pwm_r_value = PWM_INTERVAL;
        pwm_g_value = 0;
        pwm_b_value = 0;
    end

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition) begin
        current_state <= next_state;
    end

    // Compute the next state of the FSM
    always_comb begin
        next_state = 3'bxxx;
        case (current_state)
            COLOR_0:
                next_state = COLOR_1;

            COLOR_1:
                next_state = COLOR_2;

            COLOR_2:
                next_state = COLOR_3;

            COLOR_3:
                next_state = COLOR_4;

            COLOR_4:
                next_state = COLOR_5;

            COLOR_5:
                next_state = COLOR_0;

        endcase

    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin

        case (current_state)
            // Transitioning from red to yellow
            // So red stays at 100%, green increases from 0% to 100%, and blue stays at 0%
            COLOR_0: begin
                pwm_r_value <= PWM_INTERVAL;
                pwm_g_value <= pwm_g_value + INC_DEC_VAL;
                pwm_b_value <= 0;
            end

            // Transitioning from yellow to green
            // So red goes from 100% to 0%, green stays at 100%, and blue stays at 0%
            COLOR_1: begin
                pwm_r_value <= pwm_r_value - INC_DEC_VAL;
                pwm_g_value <= PWM_INTERVAL;
                pwm_b_value <= 0;
            end

            // Transitioning from green to cyan
            // So red stays at 0%, green stays at 100%, and blue increases from 0% to 100%
            COLOR_2: begin
                pwm_r_value <= 0;
                pwm_g_value <= PWM_INTERVAL;
                pwm_b_value <= pwm_b_value + INC_DEC_VAL;
            end

            // Transitioning from cyan to blue
            // So red stays at 0%, green decreases from 100% to 0% and blue stays at 100%
            COLOR_3: begin
                pwm_r_value <= 0;
                pwm_g_value <= pwm_g_value - INC_DEC_VAL;
                pwm_b_value <= PWM_INTERVAL;
            end

            // Transitioning from blue to magenta
            // So red increases from 0 to 100%, green stays at 0%, and blue stays at 100%
            COLOR_4: begin
                pwm_r_value <= pwm_r_value + INC_DEC_VAL;
                pwm_g_value <= 0;
                pwm_b_value <= PWM_INTERVAL;

            end

            // Transitioning from magenta to red
            // So red stays at 100%, green stays at 0%, and blue decreases from 100% to 0%
            COLOR_5: begin
                pwm_r_value <= PWM_INTERVAL;
                pwm_g_value <= 0;
                pwm_b_value <= pwm_b_value - INC_DEC_VAL;
            end
        endcase
    end

    // // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end

        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule