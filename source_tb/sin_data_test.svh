class sin_data_test extends base_test;

    `uvm_component_utils(sin_data_test)
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    
endclass

// --------------------------------------------------------------------
function void sin_data_test::build_phase(uvm_phase phase);
    super.build_phase(phase);

    axis_seqc_in = axis_sin_sequence::type_id::create("axis_seqc_in", this);
    axis_seqc_out = axis_sin_sequence::type_id::create("axis_seqc_out", this);

    axis_seqc_out_config.trans_numb = 100;
    axis_seqc_in_config.trans_numb = 1000*axis_seqc_out_config.trans_numb;

    axis_seqc_in_config.max_clock_before_tvalid = 4;
    axis_seqc_out_config.max_clock_before_tready = 5;   

    axis_seqc_in.axis_seqc_config = axis_seqc_in_config;
    axis_seqc_out.axis_seqc_config = axis_seqc_out_config;
      
endfunction