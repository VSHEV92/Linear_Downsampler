class axis_sin_sequence extends axis_sequence;
    `uvm_object_utils(axis_sin_sequence)
    function new (string name = "");
        super.new(name);
    endfunction

    extern task body();
    
    real w = 0.1, t = 0;

endclass

task axis_sin_sequence::body();
    repeat(trans_numb) begin
        axis_data_h = axis_data::type_id::create("axis_data_h");
        start_item(axis_data_h);
            config_item();
            assert(axis_data_h.randomize());
            axis_data_h.tdata =  (0.95*$sin(w * t)) * 2**15;
            t++;
        finish_item(axis_data_h);
    end
endtask
