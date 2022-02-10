
`timescale 1 ns / 1 ps

	module Linear_Downsampler_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_AXI
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
		input  wire [15:0] indata_tdata, // входные данные (fix_16_15)
		input  wire indata_tvalid,
		output wire indata_tready,

		output wire [15:0] outdata_tdata, // выходные данные fix_16_15
		output wire outdata_tvalid,
		input  wire outdata_tready,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S_AXI
		input wire  aclk,
		input wire  aresetn,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
		input wire [2 : 0] s_axi_awprot,
		input wire  s_axi_awvalid,
		output wire  s_axi_awready,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
		input wire  s_axi_wvalid,
		output wire  s_axi_wready,
		output wire [1 : 0] s_axi_bresp,
		output wire  s_axi_bvalid,
		input wire  s_axi_bready,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
		input wire [2 : 0] s_axi_arprot,
		input wire  s_axi_arvalid,
		output wire  s_axi_arready,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
		output wire [1 : 0] s_axi_rresp,
		output wire  s_axi_rvalid,
		input wire  s_axi_rready
	);

	wire [31:0] freq_ratio;
	wire [31:0] freq_ratio_inv;
	wire soft_reset;
	wire resetn_internal;

// Instantiation of Axi Bus Interface S_AXI
	Linear_Downsampler_v1_0_S_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) Linear_Downsampler_v1_0_S_AXI_inst (
		.S_AXI_ACLK(aclk),
		.S_AXI_ARESETN(aresetn),
		.S_AXI_AWADDR(s_axi_awaddr),
		.S_AXI_AWPROT(s_axi_awprot),
		.S_AXI_AWVALID(s_axi_awvalid),
		.S_AXI_AWREADY(s_axi_awready),
		.S_AXI_WDATA(s_axi_wdata),
		.S_AXI_WSTRB(s_axi_wstrb),
		.S_AXI_WVALID(s_axi_wvalid),
		.S_AXI_WREADY(s_axi_wready),
		.S_AXI_BRESP(s_axi_bresp),
		.S_AXI_BVALID(s_axi_bvalid),
		.S_AXI_BREADY(s_axi_bready),
		.S_AXI_ARADDR(s_axi_araddr),
		.S_AXI_ARPROT(s_axi_arprot),
		.S_AXI_ARVALID(s_axi_arvalid),
		.S_AXI_ARREADY(s_axi_arready),
		.S_AXI_RDATA(s_axi_rdata),
		.S_AXI_RRESP(s_axi_rresp),
		.S_AXI_RVALID(s_axi_rvalid),
		.S_AXI_RREADY(s_axi_rready),
		.soft_reset(soft_reset),
		.freq_ratio(freq_ratio),
		.freq_ratio_inv(freq_ratio_inv)
	);

	// reset signal
	assign resetn_internal = (aresetn == 1'b0 || soft_reset == 1'b1) ? 0 : 1;

	// Add user logic here
    downsampler_core DUT (
        .aclk(aclk),
        .aresetn(resetn_internal),
        .freqRatio(freq_ratio),
        .freqRatioInv(freq_ratio_inv),
        
        .indata_tdata(indata_tdata),
        .indata_tvalid(indata_tvalid),
        .indata_tready(indata_tready),

        .outdata_tdata(outdata_tdata),
        .outdata_tvalid(outdata_tvalid),
        .outdata_tready(outdata_tready)       
    );
	// User logic ends

	endmodule
