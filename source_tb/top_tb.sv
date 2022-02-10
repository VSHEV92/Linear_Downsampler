`timescale 1ns/1ps

module top_tb ();

    import uvm_pkg::*;
    import test_pkg::*; 

    localparam TDATA_BYTES_IN = 2;
    localparam TDATA_BYTES_OUT = 2;

    bit aclk = 0;
    axis_if #(TDATA_BYTES_IN) axis_in (aclk);
    axis_if #(TDATA_BYTES_OUT) axis_out (aclk);
    axi_lite_if axi_lite (aclk);
    
    always 
        #2 aclk = ~aclk;

    Linear_Downsampler_v1_0 DUT (
        .aclk(aclk),
        .aresetn(axis_in.aresetn),
        
        .s_axi_araddr  (axi_lite.araddr),
        .s_axi_arprot  (axi_lite.arprot),
        .s_axi_arready (axi_lite.arready),
        .s_axi_arvalid (axi_lite.arvalid),

        .s_axi_awaddr  (axi_lite.awaddr),
        .s_axi_awprot  (axi_lite.awprot),
        .s_axi_awvalid (axi_lite.awvalid),
        .s_axi_awready (axi_lite.awready),

        .s_axi_bready  (axi_lite.bready),
        .s_axi_bresp   (axi_lite.bresp),
        .s_axi_bvalid  (axi_lite.bvalid),

        .s_axi_rdata   (axi_lite.rdata),
        .s_axi_rresp   (axi_lite.rresp),
        .s_axi_rready  (axi_lite.rready),
        .s_axi_rvalid  (axi_lite.rvalid),

        .s_axi_wdata   (axi_lite.wdata),
        .s_axi_wready  (axi_lite.wready),
        .s_axi_wstrb   (axi_lite.wstrb),
        .s_axi_wvalid  (axi_lite.wvalid),

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
        uvm_config_db #(virtual axi_lite_if)::set(null, "", "axi_lite", axi_lite);
        
        run_test("sin_data_test");
    end

endmodule