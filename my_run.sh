# module load vcs
iverilog -l osc.v -o osc_tb osc_tb.v
vvp osc_tb
rm osc_tb
vcd2vpd waveforms.vcd waveforms.vpd
rm waveforms.vcd
