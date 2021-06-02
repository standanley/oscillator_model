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

`timescale 1ps/1ps

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
real current_pos_time;
real periods_elapsed;

event recalculate;
event set_rise_fall;
//event a_rise;
//event a_fall;

localparam N = 5;
integer i;
event rise [N-1:0];
event fall [N-1:0];

reg out_bus [N-1:0];
always @(*) begin
    out_a <= out_bus[0];
    out_b <= out_bus[1];
    out_c <= out_bus[2];
    out_d <= out_bus[3];
    out_e <= out_bus[4];
end

initial begin
    // Set outputs to time 0+epsilon
    current_pos = 0;
    out_a <= 1;
    out_b <= 1;
    out_c <= 0;
    out_d <= 1;
    out_d <= 0;
    
    current_pos_time = $realtime;
    // anything but 0 will work for the initial period
    period = 1.0;
end

always @(ctrl or recalculate) begin
    $display("Recalculating");
    // see how many periods have elapsed with the old period length
    periods_elapsed = ($realtime - current_pos_time) / period;
    current_pos = (current_pos + periods_elapsed) % 1;
    current_pos_time = $realtime;

    // calculate new period based on new input
    period_seconds = 800e-12 + 100e-12 * ctrl[1] + 50e-12 * ctrl[0];
    period = (period_seconds * 1e12);

    $display("Recalculated these things:");
    $display(periods_elapsed);
    $display(current_pos);
    $display(period_seconds);
    $display(period);


    // set rising and falling edges based on new period
    -> set_rise_fall;
end


//always @(set_rise_fall) begin
//    $display("Decided to wait this amount of time before setting rise:");
//    $display(((0.0-current_pos+1) % 1) * period);
//end
//

for (i=0; i<N; i++) begin
    always @(set_rise_fall) #(((0.2*i    - current_pos + 1) % 1) * period) -> rise[i];
    always @(set_rise_fall) #(((0.2*i+.5 - current_pos + 1) % 1) * period) -> fall[i];
    always @(rise[i]) begin
        out_bus[i] <= 1;
        #period;
        -> recalculate;
    end
    always @(fall[i]) begin
        out_bus[i] <= 0;
        #period;
        -> recalculate;
    end
end

//always @(set_rise_fall) #(((0.0-current_pos+1) % 1) * period) -> a_rise;
//always @(set_rise_fall) #(((0.5-current_pos+1) % 1) * period) -> a_fall;
//
//always @(set_rise_fall) $display("Inside a set_rise_fall");
//
//always @(a_rise) begin
//    $display("Making a rise %g", $realtime);
//    out_a <= 1;
//    #period;
//    $display("Decided to make a rise again %g", $realtime);
//    //-> a_rise;
//    -> check_inputs;
//end
//always @(a_fall) begin
//    $display("Making a fall");
//    out_a <= 0;
//    #period -> a_fall;
//end

endmodule
