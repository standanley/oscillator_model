^'// Autogenerated by empy! Install with "pip install empy"'
^'// Edit osc_empy.v and then run'
^'// python -m em -p ^ osc_empy.v > osc.v'

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

^{output_names = ['out_a', 'out_b', 'out_c', 'out_d', 'out_e']}
^{N = len(output_names)}

`timescale 1ps/1ps

module osc (
    input [1:0] ctrl,
^[for i, output_name in enumerate(output_names)]^
    output reg ^output_name^(',' if i != N-1 else '')
^[end for]^
);

// duration of one period
real period_seconds;
real period;

// when recalculating, 
// Where in the period we are (from 0 to 1)
// Simulation time when we last recalculated
// How many periods have elapsed since we last recalculated
real current_pos;
real current_pos_time;
real periods_elapsed;


event recalculate;
event set_rise_fall;

^[for i in range(N)]^
event rise_^i;
event fall_^i;
^[end for]^

initial begin
    // Set outputs to time 0+epsilon
    current_pos = 0;
^[for i, output_name in enumerate(output_names)]^
    ^output_name <= ^(1 if i==0 else i%2);
^[end for]^
    current_pos_time = $realtime;
    // anything but 0 will work for the initial period
    period = 1.0;
end

// rerun this when ctrl changes plus at least once per cycle to reset events
always @(ctrl or recalculate) begin
    // see how many periods have elapsed with the old period length
    periods_elapsed = ($realtime - current_pos_time) / period;
    current_pos = (current_pos + periods_elapsed) % 1;
    current_pos_time = $realtime;

    // calculate new period based on new input
    period_seconds = 500e-12 + 400e-12 * ctrl[1] + 200e-12 * ctrl[0];
    period = (period_seconds * 1e12);

    // set rising and falling edges based on new period
    -> set_rise_fall;
end

always @(set_rise_fall) #(period / 2) -> recalculate;

^[for i, output_name in enumerate(output_names)]^

// Setting things for ^output_name
^[if i==0]^
// when set_rise_fall happens, reschedule next rising and falling edge based
// on current_pos
^[end if]^
always @(set_rise_fall) #(((^((1/N*i)%1)    - current_pos + 1) % 1) * period) -> rise_^i;
always @(set_rise_fall) #(((^((1/N*i+.5)%1) - current_pos + 1) % 1) * period) -> fall_^i;
^[if i==0]^

// When rise or fall event happens, make the corresponding edge.
// Also, we will need to recalculate within one period to get this again
^[end if]^
always @(rise_^i) begin
    ^output_name <= 1;
    //#(period/2);
    //-> recalculate;
end
always @(fall_^i) begin
    ^output_name <= 0;
    //#(period/2);
    //-> recalculate;
end

^[end for]^

endmodule