`timescale 1ns/1ps
class base_test extends uvm_test;

    `uvm_component_utils(base_test)
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern task configure_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    extern task shutdown_phase(uvm_phase phase);
    
   function logic [31:0] Freq_Ratio_Real_to_Logic(input real freq_ratio);
       return unsigned'(2**31) * freq_ratio;
    endfunction 

    function logic [31:0] Freq_Ratio_Inv_Real_to_Logic(input real freq_ratio);
        return unsigned'(2**22) / freq_ratio;
    endfunction 

    test_env test_env_h; 

    axis_sin_sequence axis_seqc_in;
    axis_sin_sequence axis_seqc_out;
    axi_lite_config_sequence axi_lite_seqc;

    axis_sequence_config axis_seqc_in_config;
    axis_sequence_config axis_seqc_out_config;
    axi_lite_sequence_config axi_lite_seqc_config;
    
    uvm_status_e status;

    reg2axi_adapter axi_lite_adapter;

endclass

// --------------------------------------------------------------------
function void base_test::build_phase(uvm_phase phase);
    
    test_env_h = test_env::type_id::create("test_env_h", this);   

    axis_seqc_in = axis_sin_sequence::type_id::create("axis_seqc_in", this);
    axis_seqc_out = axis_sin_sequence::type_id::create("axis_seqc_out", this);
    axi_lite_seqc = axi_lite_config_sequence::type_id::create("axi_lite_seqc", this);

    axis_seqc_in_config = axis_sequence_config::type_id::create("axis_seqc_in_config");
    axis_seqc_out_config = axis_sequence_config::type_id::create("axis_seqc_out_config");
    axi_lite_seqc_config = axi_lite_sequence_config::type_id::create("axi_lite_seqc_config");
    
    axis_seqc_in.axis_seqc_config = axis_seqc_in_config;
    axis_seqc_out.axis_seqc_config = axis_seqc_out_config;
    axi_lite_seqc.axi_lite_seqc_config = axi_lite_seqc_config;
    test_env_h.axi_lite_seqc_config = axi_lite_seqc_config;
  
endfunction

task base_test::configure_phase(uvm_phase phase);
    phase.raise_objection(this);
        //axi_lite_seqc.start(test_env_h.axi_lite_agent_master.axi_lite_sequencer_h);
        test_env_h.reg_model.reset.write(status, 16'h00A0);
        test_env_h.reg_model.ratio.write(status, Freq_Ratio_Real_to_Logic(`FREQ_RATIO));
        test_env_h.reg_model.ratio_inv.write(status, Freq_Ratio_Inv_Real_to_Logic(`FREQ_RATIO));
        test_env_h.reg_model.new_ratio.write(status, 1'b1);
        #100ns;    
    phase.drop_objection(this);
endtask

task base_test::main_phase(uvm_phase phase);
    phase.raise_objection(this);
        fork
            axis_seqc_in.start(test_env_h.axis_agent_in.axis_sequencer_h);
            axis_seqc_out.start(test_env_h.axis_agent_out.axis_sequencer_h);  
        join_any 
    phase.drop_objection(this);
endtask

task base_test::shutdown_phase(uvm_phase phase);
    phase.raise_objection(this);
        #100ns;    
    phase.drop_objection(this);
endtask