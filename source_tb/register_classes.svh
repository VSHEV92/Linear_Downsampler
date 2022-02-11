// ------------- reset register ----------------------
class reg_reset extends uvm_reg;
    `uvm_object_utils(reg_reset)

    rand uvm_reg_field reset;
    uvm_reg_field reserved;

    function new(string name = "reg_reset");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        reset = uvm_reg_field::type_id::create("reset");
        reserved = uvm_reg_field::type_id::create("reserved");
        reset.configure(this, 16, 0, "RW", 0, 16'h0000, 1, 1, 0);
        reserved.configure(this, 16, 16, "RO", 0, 16'h0000, 1, 0, 0);
    endfunction

endclass

// ------------- ratio register ----------------------
class reg_ratio extends uvm_reg;
    `uvm_object_utils(reg_ratio)

    rand uvm_reg_field data;

    function new(string name = "reg_ratio");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        data = uvm_reg_field::type_id::create("data");
        data.configure(this, 32, 0, "RW", 0, 32'h0000, 1, 1, 0);
    endfunction

endclass

// ------------- enable new ratio register ----------------------
class reg_enable_param extends uvm_reg;
    `uvm_object_utils(reg_enable_param)

    rand uvm_reg_field enable;
    uvm_reg_field reserved;
    
    function new(string name = "reg_enable_param");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        enable = uvm_reg_field::type_id::create("enable");
        reserved = uvm_reg_field::type_id::create("reserved");

        enable.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
        reserved.configure(this, 31, 1, "RO", 0, 31'h00000000, 1, 0, 0);
    endfunction

endclass

// ------------- register block ----------------------
class reg_block extends uvm_reg_block;
    `uvm_object_utils(reg_block)

    rand reg_reset reset;
    rand reg_ratio ratio;
    rand reg_ratio ratio_inv;
    rand reg_enable_param new_ratio;

    function new(string name = "reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();

        reset = reg_reset::type_id::create("reset");
        ratio = reg_ratio::type_id::create("ratio");
        ratio_inv = reg_ratio::type_id::create("ratio_inv");
        new_ratio = reg_enable_param::type_id::create("new_ratio");

        reset.configure(this, null, "");
        ratio.configure(this, null, "");
        ratio_inv.configure(this, null, "");
        new_ratio.configure(this, null, "");

        reset.build();
        ratio.build();
        ratio_inv.build();
        new_ratio.build();

        default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN);
        default_map.add_reg(reset, 32'h00000000, "RW");
        default_map.add_reg(ratio, 32'h00000004, "RW");
        default_map.add_reg(ratio_inv, 32'h00000008, "RW");
        default_map.add_reg(new_ratio, 32'h0000000c, "RW");


    endfunction

endclass


// ------------- adapter ----------------------
class reg2axi_adapter extends uvm_reg_adapter;
    
    `uvm_object_utils(reg2axi_adapter)

    axi_lite_sequence_config axi_lite_seqc_config;
    
    function new(string name = "reg2axi_adapter");
        super.new(name);
        supports_byte_enable = 0;
        provides_responses = 0;
    endfunction

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

        axi_lite_data axis_data_h = axi_lite_data::type_id::create("axis_data_h");
        axis_data_h.max_clocks_before_addr = axi_lite_seqc_config.max_clocks_before_addr;
        axis_data_h.min_clocks_before_addr = axi_lite_seqc_config.min_clocks_before_addr;
        axis_data_h.max_clocks_before_data = axi_lite_seqc_config.max_clocks_before_data;
        axis_data_h.min_clocks_before_data = axi_lite_seqc_config.min_clocks_before_data;
        axis_data_h.max_clocks_before_resp = axi_lite_seqc_config.max_clocks_before_resp;
        axis_data_h.min_clocks_before_resp = axi_lite_seqc_config.min_clocks_before_resp;
        assert(axis_data_h.randomize());

        axis_data_h.transaction_type = (rw.kind == UVM_READ) ? 0 : 1;
        axis_data_h.addr = rw.addr;
        axis_data_h.strb = 4'b1111;
        axis_data_h.data = rw.data;
        
        return axis_data_h;
    endfunction: reg2bus

    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        axi_lite_data axis_data_h;
        
        if (!$cast(axis_data_h, bus_item)) begin
            `uvm_fatal("NOT_APB_TYPE","Provided bus_item is not of thecorrect type")
            return;
        end
        
        rw.kind = axis_data_h.transaction_type ? UVM_WRITE : UVM_READ;
        rw.addr = axis_data_h.addr;
        rw.data = axis_data_h.data;
        rw.status = UVM_IS_OK;
    endfunction: bus2reg

endclass