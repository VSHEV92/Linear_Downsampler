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

    axis_seqc_out_config.trans_numb = 100;
    axis_seqc_in_config.trans_numb = 1000*axis_seqc_out_config.trans_numb;

    axis_seqc_in_config.max_clock_before_tvalid = 4;
    axis_seqc_out_config.max_clock_before_tready = 5;   

    axi_lite_seqc_config.max_clocks_before_addr = 10;
    axi_lite_seqc_config.min_clocks_before_addr = 4;
    axi_lite_seqc_config.max_clocks_before_data = 10;
    axi_lite_seqc_config.min_clocks_before_data = 4;
    axi_lite_seqc_config.max_clocks_before_resp = 10;
    axi_lite_seqc_config.min_clocks_before_resp = 4;
      
endfunction