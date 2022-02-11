`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)

import "DPI-C" function int Linear_Downsampler_Model(input real indata, output real outdata, input real freqRatio);

class test_scoreboard #(int TDATA_BYTES = 1) extends uvm_scoreboard;
    `uvm_component_param_utils(test_scoreboard #(TDATA_BYTES))
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern function void build_phase (uvm_phase phase);
    extern function void final_phase (uvm_phase phase);

    extern virtual function void write_in (axis_data axis_data_h);
    extern virtual function void write_out (axis_data axis_data_h);
    
    uvm_analysis_imp_in #(axis_data, test_scoreboard #(TDATA_BYTES)) analysis_port_in;
    uvm_analysis_imp_out #(axis_data, test_scoreboard #(TDATA_BYTES)) analysis_port_out;

    real axis_data_gold[$];
    real axis_data_dut[$];

    bit test_result = 1'b1;
    
endclass

// -------------------------------------------------------------------
function void test_scoreboard::build_phase (uvm_phase phase);
    analysis_port_in = new("analysis_port_in", this);
    analysis_port_out = new("analysis_port_out", this);
endfunction

function void test_scoreboard::write_in (axis_data axis_data_h);
    bit valid;
    real data_in_real, data_gold_real;
    data_in_real = real'(axis_data_h.tdata) / 2**15;

    valid = Linear_Downsampler_Model(data_in_real, data_gold_real, `FREQ_RATIO); 
    if (valid) begin
        axis_data_gold.push_back(data_gold_real);
    end
   
endfunction

function void test_scoreboard::write_out (axis_data axis_data_h);
    real data_in_real = real'(axis_data_h.tdata) / 2**15;
    axis_data_dut.push_back(data_in_real);
endfunction

function void test_scoreboard::final_phase (uvm_phase phase);
    real data_gold, data_dut;
    real error, error_last = 0;
    while (axis_data_dut.size()) begin
        data_gold = axis_data_gold.pop_front();
        data_dut = axis_data_dut.pop_front();
        // compare transactions from slave and master
        error = data_gold - data_dut;
        if (error < 0)
            error = -error;

        if (error < 0.05 || error_last < 0.05)
            `uvm_info("PASS", $sformatf("Results match. Error: %f", error), UVM_LOW)
        else begin
            `uvm_error(
                get_type_name(), {"Results mismatch! \n",
                                $sformatf("DUT: %f\n", data_dut),
                                $sformatf("Gold: %f\n", data_gold),
                                $sformatf("Error: %f", error)
                                }
            )
            test_result = 1'b0;
        end
        error_last = error;    
    end

    if (test_result)
        `uvm_info("RESULT", $sformatf("RATIO = %f. TEST RESULT: PASS", `FREQ_RATIO) , UVM_LOW)
    else
        `uvm_info("RESULT", $sformatf("RATIO = %f. TEST RESULT: FAIL", `FREQ_RATIO) , UVM_LOW)
        
endfunction