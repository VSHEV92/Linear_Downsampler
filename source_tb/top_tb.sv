`timescale 1ns/1ps

function logic [31:0] Freq_Ratio_Real_to_Logic(input real freq_ratio);
    return unsigned'(2**31) * freq_ratio;
endfunction 

function logic [31:0] Freq_Ratio_Inv_Real_to_Logic(input real freq_ratio);
    return unsigned'(2**22) / freq_ratio;
endfunction 

module top_tb ();

    import uvm_pkg::*;
    import test_pkg::*; 

    localparam TDATA_BYTES_IN = 2;
    localparam TDATA_BYTES_OUT = 2;

    bit aclk = 0;
    axis_if #(TDATA_BYTES_IN) axis_in (aclk);
    axis_if #(TDATA_BYTES_OUT) axis_out (aclk);
    
    always 
        #2 aclk = ~aclk;

    downsampler_core DUT (
        .aclk(aclk),
        .aresetn(axis_in.aresetn),
        .freqRatio(Freq_Ratio_Real_to_Logic(`FREQ_RATIO)),
        .freqRatioInv(Freq_Ratio_Inv_Real_to_Logic(`FREQ_RATIO)),
        
        .indata_tdata(axis_in.tdata),
        .indata_tvalid(axis_in.tvalid),
        .indata_tready(axis_in.tready),

        .outdata_tdata(axis_out.tdata),
        .outdata_tvalid(axis_out.tvalid),
        .outdata_tready(axis_out.tready)       
    );

    initial begin
        uvm_config_db #(virtual axis_if #(TDATA_BYTES_IN))::set(null, "uvm_test_top.*", "axis_in", axis_in);
        uvm_config_db #(virtual axis_if #(TDATA_BYTES_OUT))::set(null, "uvm_test_top.*", "axis_out", axis_out);
        run_test("sin_data_test");
    end

endmodule