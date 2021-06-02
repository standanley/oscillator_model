/* 
functional model for an oscillator

     0      0.2     0.4     0.6     0.8      1
     |       |       |       |       |       |
A   _.- - - - - - - - - -._ _ _ _ _ _ _ _ _ _.-
     |       |       |       |       |       |
B   - - -._ _ _ _ _ _ _ _ _ _.- - - - - - - - -
     |       |       |       |       |       |
C   _ _ _ _ _.- - - - - - - - - -._ _ _ _ _ _ _
     |       |       |       |       |       |
D   - - - - - - -._ _ _ _ _ _ _ _ _ _.- - - - -
     |       |       |       |       |       |
E   _ _ _ _ _ _ _ _ _.- - - - - - - - - -._ _ _
     |       |       |       |       |       |

*/

module osc (
    input [1:0] ctrl,
    output reg out_a,
    output reg out_b,
    output reg out_c,
    output reg out_d,
    output reg out_e
);

real period_seconds;
real period;
real current_pos;
real periods_elapsed;

event check_inputs;
event set_rise_fall;
event a_rise;
event a_fall;

initial begin
    // Set outputs to time 0+epsilon
    current_pos = 0;
    out_a <= 1;
    out_b <= 1;
    out_c <= 0;
    out_d <= 1;
    out_d <= 0;
    
    current_pos_time = $realtime;
    -> check_inputs;
end

always @(*, check_inputs) begin
    // see how many periods have elapsed with the old period length
    periods_elapsed = ($realtime - current_pos_time) / period;
    current_pos = (current_pos + periods_elapsed) % 1;

    // calculate new period based on new input
    period_seconds = 800e-12 + 100e-12 * ctrl[1] + 50e-12 * ctrl[0];
    period = (period_seconds * 1s);
    -> recalculate;

    // set rising and falling edges based on new period
    -> set_rise_fall;
end

always @(set_rise_fall) #(((0.0-current_pos+1) % 1) * period) -> a_rise;
always @(set_rise_fall) #(((0.5-current_pos+1) % 1) * period) -> a_fall;

always @(a_rise) begin
    out_a <= 1;
    #period -> a_rise;
end
always @(a_fall) begin
    out_a <= 0;
    #period -> a_fall;
end

endmodule
