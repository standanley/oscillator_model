module event_test;

// CONCLUSION
// if an event is in-progress, calls to it are ignored

event e;
event call_e_in_10;
//event call_e_in_20;

always @(e) $display("E called at %g", $realtime);
always @(call_e_in_10) #10 -> e;

initial begin
    -> e;
    # 100;

    // calls at 110
    -> call_e_in_10;

    # 100;

    // calls at 210 only - second request is ignored
    -> call_e_in_10;
    # 5;
    -> call_e_in_10;


    # 95;
    
    // called at 305 and 310
    -> call_e_in_10;
    # 5;
    -> e;

    # 95

    -> e;

end

endmodule
