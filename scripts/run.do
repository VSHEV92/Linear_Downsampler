vlib work

# axis stream uvm
vlog AXIS_UVM_Agent/src/axis_intf.sv

# ip source
vlog source_hdl/downsampler_core.sv

# tb source
vlog source_tb/linear_resampler_model.c
vlog +define+FREQ_RATIO=$1 source_tb/test_pkg.sv
vlog +define+FREQ_RATIO=$1 source_tb/top_tb.sv

# start sim
vsim -novopt work.top_tb
run -all