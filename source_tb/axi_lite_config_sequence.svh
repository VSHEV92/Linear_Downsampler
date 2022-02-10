class axi_lite_config_sequence extends axi_lite_sequence;
    `uvm_object_utils(axi_lite_config_sequence)
    function new (string name = "");
        super.new(name);
    endfunction
    
    extern task body();

    function logic [31:0] Freq_Ratio_Real_to_Logic(input real freq_ratio);
       return unsigned'(2**31) * freq_ratio;
    endfunction 

    function logic [31:0] Freq_Ratio_Inv_Real_to_Logic(input real freq_ratio);
        return unsigned'(2**22) / freq_ratio;
    endfunction 

endclass

task axi_lite_config_sequence::body();
    // reset ip
    axi_lite_data_h = axi_lite_data::type_id::create("axi_lite_data_h");
    start_item(axi_lite_data_h);
        config_item();
        assert(axi_lite_data_h.randomize());
        axi_lite_data_h.transaction_type = 1'b1;
        axi_lite_data_h.strb = 4'b1111;
        axi_lite_data_h.data = 32'h00A0;
        axi_lite_data_h.addr = 0;
    finish_item(axi_lite_data_h);

    // set freq ratio
    axi_lite_data_h = axi_lite_data::type_id::create("axi_lite_data_h");
    start_item(axi_lite_data_h);
        config_item();
        assert(axi_lite_data_h.randomize());
        axi_lite_data_h.transaction_type = 1'b1;
        axi_lite_data_h.strb = 4'b1111;
        axi_lite_data_h.data = Freq_Ratio_Real_to_Logic(`FREQ_RATIO);
        axi_lite_data_h.addr = 4;
    finish_item(axi_lite_data_h);

    // set freq ratio inv
    axi_lite_data_h = axi_lite_data::type_id::create("axi_lite_data_h");
    start_item(axi_lite_data_h);
        config_item();
        assert(axi_lite_data_h.randomize());
        axi_lite_data_h.transaction_type = 1'b1;
        axi_lite_data_h.strb = 4'b1111;
        axi_lite_data_h.data = Freq_Ratio_Inv_Real_to_Logic(`FREQ_RATIO);
        axi_lite_data_h.addr = 8;
    finish_item(axi_lite_data_h);
    
    // enable params
    axi_lite_data_h = axi_lite_data::type_id::create("axi_lite_data_h");
    start_item(axi_lite_data_h);
        config_item();
        assert(axi_lite_data_h.randomize());
        axi_lite_data_h.transaction_type = 1'b1;
        axi_lite_data_h.strb = 4'b1111;
        axi_lite_data_h.data = 32'h1;
        axi_lite_data_h.addr = 12;
    finish_item(axi_lite_data_h);
endtask