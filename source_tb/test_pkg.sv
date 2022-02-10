package test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "../AXIS_UVM_Agent/src/axis_include.svh"
    `include "../AXI_Lite_UVM_Agent/src/axi_lite_include.svh"

    `include "axis_sin_sequence.svh"
    `include "axi_lite_config_sequence.svh"
    
    `include "test_scoreboard.svh"
    `include "test_env.svh"

    `include "base_test.svh"
    `include "sin_data_test.svh"

endpackage