ip:
	vivado -mode batch -source scripts/package_ip.tcl

AXI_UVM_Agents:
	git clone https://github.com/VSHEV92/AXI_Lite_UVM_Agent.git
	git clone https://github.com/VSHEV92/AXIS_UVM_Agent.git
	
tests:
	FREQ_RATIO=1 make test_ip | tee test_ratio_one.txt
	FREQ_RATIO=0.5 make test_ip | tee test_ratio_5.txt
	FREQ_RATIO=0.25 make test_ip | tee test_ratio_25.txt
	FREQ_RATIO=0.3333 make test_ip | tee test_ratio_3333.txt 
	FREQ_RATIO=0.6784 make test_ip | tee test_ratio_6784.txt 
	FREQ_RATIO=0.1235 make test_ip | tee test_ratio_1235.txt 
	FREQ_RATIO=0.4354 make test_ip | tee test_ratio_4354.txt 
	FREQ_RATIO=0.8465 make test_ip | tee test_ratio_8465.txt 
	make check

test_ip:
	vsim -c -do "do scripts/run.do $(FREQ_RATIO)"

check:
	cat *.txt | grep "TEST RESULT"

clean:
	rm -Rf work
	rm -Rf Linear_Downsampler_1.0
	rm transcript
	rm test_ratio*.txt
	rm *.wlf

