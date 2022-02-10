vlib work

# axis stream uvm
vlog AXIS_UVM_Agent/src/axis_intf.sv
vlog \AXI_Lite_UVM_Agent/src/axi_lite_intf.sv

# ip source
vlog source_hdl/downsampler_core.sv
vlog source_hdl/Linear_Downsampler_v1_0.v
vlog source_hdl/Linear_Downsampler_v1_0_S_AXI.v

# tb source
vlog source_tb/linear_resampler_model.c
vlog +define+FREQ_RATIO=$1 source_tb/test_pkg.sv
vlog source_tb/top_tb.sv

# start sim
vsim -novopt work.top_tb
run -all