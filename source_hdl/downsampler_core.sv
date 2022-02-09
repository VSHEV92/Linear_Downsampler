module downsampler_core(
    input logic aclk,
    input logic aresetn,

    input logic [31:0] freqRatio,      // коэффициент прореживания сигнала (ufix_32_31)
    input logic [31:0] freqRatioInv,   // обратная величина к коэффициенту прореживания сигнала (ufix_32_22)
    
    input  logic signed [15:0] indata_tdata, // входные данные (fix_16_15)
    input  logic indata_tvalid,
    output logic indata_tready,

    output logic signed [15:0] outdata_tdata, // выходные данные fix_16_15
    output logic outdata_tvalid,
    input  logic outdata_tready
);
    
    localparam logic [31:0] ONE_VALUE = 32'h80000000;

    logic signed [32:0] NCO_out;        // выходное значение NCO (fix_33_31)
    logic [31:0] phase;                 // фаза выходного отсчета (ufix_32_31)
    logic signed [64:0] mult_freq_inv;  // fix64_53
    
    logic signed [16:0] indata_delta;       // разница текущего и предыдущего входного отсчета (fix_17_15)
    logic signed [49:0] phase_mult;         // fix_50_46
    logic signed [4:0][16:0] indata_delay;  // задержанные входные данные (fix_17_15)
    
    logic [5:0] NCO_overflow;
    logic enable;
     
    // сигнал выполнения блока
    assign enable = indata_tvalid && outdata_tready;

    // реализация NCO для формирования выходных стробов
    always_ff @(posedge aclk) begin : NCO_proc
        if (!aresetn) begin
            NCO_out <= '0;
            NCO_overflow <= '0;    
        end else if (enable) begin
            if (NCO_out + freqRatio >= ONE_VALUE) begin
                NCO_out <= NCO_out + freqRatio - ONE_VALUE;
                NCO_overflow[0] <= 1'b1;
            end else begin
                NCO_out <= NCO_out + freqRatio;
                NCO_overflow[0] <= 1'b0;
            end
            NCO_overflow[5:1] <= NCO_overflow[4:0]; 
        end
    end : NCO_proc

    // вычисление фазы выходного отсчета
    always_ff @(posedge aclk) begin : phase_proc
        if (!aresetn) begin
            mult_freq_inv <= '0;
            phase <= '0;
        end
        else if (enable) begin
            if (NCO_overflow[0]) begin
                mult_freq_inv <= NCO_out * signed'({1'b0, freqRatioInv});
            end
            if (NCO_overflow[1]) begin
                phase <= ONE_VALUE - mult_freq_inv[53-:32];
            end
        end
    end : phase_proc
    
    // вычисление выходного отсчета
    always_ff @(posedge aclk) begin : resample_proc
        if (!aresetn) begin
            indata_delta <= '0;
            phase_mult <= '0;
            outdata_tvalid <= '0; 
        end 
        else begin
            outdata_tvalid <= 1'b0;
            if (outdata_tvalid && !outdata_tready)
                outdata_tvalid <= 1'b1;
            if (enable) begin
                indata_delta <= indata_delay[1] - indata_delay[2];
                phase_mult <= indata_delta * signed'({1'b0, phase});
                if (NCO_overflow[3]) begin
                    outdata_tdata <= phase_mult[47-:17] + indata_delay[4];
                    outdata_tvalid <= 1'b1;
                end
            end
        end  
    end : resample_proc

    // задержка входного сигнала
    always_ff @(posedge aclk) begin : indata_delay_proc
        if (!aresetn) begin
            indata_delay <= '0;
        end 
        else if (enable) begin
            indata_delay[0] <= {indata_tdata[15], indata_tdata};
            indata_delay[4:1] <= indata_delay[3:0];
        end  
    end : indata_delay_proc

    // формирование флагов AXI Stream
    assign indata_tready = outdata_tready;

endmodule