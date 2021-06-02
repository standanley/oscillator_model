`timescale 1ps/1ps

module osc_tb;

reg [1:0] ctrl;
wire out_a, out_b, out_c, out_d, out_e;

initial begin
    $dumpfile("waveforms.vcd");
    $dumpvars();

    ctrl[0] = 0;
    ctrl[1] = 0;

    #(3000);
    
    ctrl[0] = 0;
    ctrl[1] = 1;
    #(3500);
    
    ctrl[0] = 1;
    ctrl[1] = 0;
    #(8000);
    
    ctrl[0] = 1;
    ctrl[1] = 1;
    #(5000);
    
    ctrl[0] = 0;
    ctrl[1] = 0;
    #(250);
    
    ctrl[0] = 1;
    ctrl[1] = 0;

    #(3000);

    
    ctrl[0] = 0;
    ctrl[1] = 1;

    #(150);
    
    ctrl[0] = 0;
    ctrl[1] = 0;

    #(400);
    
    ctrl[0] = 1;
    ctrl[1] = 1;

    #(5000)

    // stress test 
    ctrl[0] = 0;
    ctrl[1] = 1;
    #(3);
    ctrl[0] = 0;
    ctrl[1] = 0;
    #(3);
    ctrl[0] = 0;
    ctrl[1] = 1;
    #(3);
    ctrl[0] = 0;
    ctrl[1] = 0;
    #(3);
    ctrl[0] = 0;
    ctrl[1] = 1;
    #(3);
    ctrl[0] = 0;
    ctrl[1] = 0;
    #(3);
    ctrl[0] = 0;
    ctrl[1] = 1;
    #(3);
    ctrl[0] = 0;
    ctrl[1] = 0;
    #(3);
    ctrl[0] = 0;
    ctrl[1] = 1;

    #(3000);
    

    $finish;
end

osc dut (
    .ctrl(ctrl),
    .out_a(out_a),
    .out_b(out_b),
    .out_c(out_c),
    .out_d(out_d),
    .out_e(out_e)
);



endmodule
