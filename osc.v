// Autogenerated by empy! Install with "pip install empy"
// Edit osc_empy.v and then run
// python -m em -p ^ osc_empy.v > osc.v

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

// timeunit / 2 seconds is a good choice for EPSILON
localparam EPSILON = 0.5;

// duration of one period and delay between edges
real period_seconds;
real period;
real edge_delay;

integer event_id = 1;
real next_edge_time;

event recalculate;


/////////////////
// It is surprisingly difficult to do this block
// The issue is that an always block cannot be triggered again if it has not finished.
// So if the next edge time becomes sooner due to a control change,
// whichever block is waiting for the correct time will ignore all requests to
// finish sooner. This gets around that by having many blocks that can do the
// waiting, and invalidating old ones that are trying to wait too long.
event timing_recalculate;
event timing_final;
event timing_0;
event timing_1;
event timing_2;
event timing_3;
event timing_4;
integer timing_current_event = 0;
integer timing_current_in_flight = 0;
integer timing_total_in_flight = 0;
integer timing_error_occurred = 0;

always @(timing_recalculate) begin
    if (timing_current_in_flight == 1) begin
        // the current timing_i is in use, so we need to use timing_(i+1)
        timing_current_event = (timing_current_event + 1) % 5;
        timing_current_in_flight = 0;
    end
    
    // dispatch the right one
    if (timing_current_event == 0) -> timing_0;
    else if (timing_current_event == 1) -> timing_1;
    else if (timing_current_event == 2) -> timing_2;
    else if (timing_current_event == 3) -> timing_3;
    else -> timing_4;
    timing_current_in_flight = 1;
    timing_total_in_flight += 1;
    if(timing_total_in_flight > 5 && !timing_error_occurred) begin
        timing_error_occurred = 1;
        $display("Error in oscillator control read! Too many inputs at sim time %g", $realtime);
    end
end

always @(timing_0) begin
    #(next_edge_time - $realtime) if (timing_current_event == 0) -> timing_final;
    timing_total_in_flight -= 1;
end
always @(timing_1) begin
    #(next_edge_time - $realtime) if (timing_current_event == 1) -> timing_final;
    timing_total_in_flight -= 1;
end
always @(timing_2) begin
    #(next_edge_time - $realtime) if (timing_current_event == 2) -> timing_final;
    timing_total_in_flight -= 1;
end
always @(timing_3) begin
    #(next_edge_time - $realtime) if (timing_current_event == 3) -> timing_final;
    timing_total_in_flight -= 1;
end
always @(timing_4) begin
    #(next_edge_time - $realtime) if (timing_current_event == 4) -> timing_final;
    timing_total_in_flight -= 1;
end

always @(timing_final) begin
    timing_current_in_flight = 0;
    // if it's past next_edge_time, that's bad
    if ($realtime > next_edge_time + EPSILON) $display("Error in oscillator! at time %g! edge_time %g", $realtime, next_edge_time);
    // if it's exactly at next_edge_time, then we should recalculate
    if ($realtime > next_edge_time - EPSILON) -> recalculate;
    // if it's before next_edge_time, it was probably an edge and a control
    // change at the same time, and this event is okay to ignore
end
/////////////////


initial begin
    // Set outputs to time 0+epsilon
    out_a <= 0;
    out_b <= 1;
    out_c <= 0;
    out_d <= 1;
    out_e <= 0;
    next_edge_time = 0;
end

// rerun this when ctrl changes plus at least once per cycle to reset events
real prev_edge_delay, remaining_fraction, remaining_delay;
always @(ctrl or recalculate) begin
    // $display("Top of recalculate at %g", $realtime);

    // calculate new period based on new input
    period_seconds = 500e-12 + 400e-12 * ctrl[1] + 200e-12 * ctrl[0];
    period = (period_seconds * 1e12);
    prev_edge_delay = edge_delay;
    edge_delay = period / 10;
    if ($realtime < next_edge_time - EPSILON) begin
        // probably a change in ctrl, but could also be an old event left over
        remaining_fraction = (next_edge_time - $realtime) / prev_edge_delay;
        remaining_delay = remaining_fraction * edge_delay;
        next_edge_time = $realtime + remaining_delay;
        -> timing_recalculate;

    // TODO one big flaw with this design is its reliance on floating point
    // equality in the next line. It should be ok if timescale and timestep
    // match, because then next_edge time should be integer?
    end else if ($abs(next_edge_time - $realtime) < EPSILON) begin
        
        if (event_id == 0) out_a <= 0;
        else if (event_id == 1) out_b <= 1;
        else if (event_id == 2) out_c <= 0;
        else if (event_id == 3) out_d <= 1;
        else if (event_id == 4) out_e <= 0;
        else if (event_id == 5) out_a <= 1;
        else if (event_id == 6) out_b <= 0;
        else if (event_id == 7) out_c <= 1;
        else if (event_id == 8) out_d <= 0;
        else out_e <= 1;

        event_id = (event_id+1) % 10;
        next_edge_time = $realtime + edge_delay;
        -> timing_recalculate;
    end else begin
        // $realtime > next_edge_time
        $display("Oscillator model missed an edge? check time %g", $realtime);
    end
end

endmodule