#include <stdio.h>
// Linear Downsampler Reference Model
int Linear_Downsampler_Model(double indata, double *outdata, double freqRatio)
{
	static double outputNCO = 0;
	static double indataLast = 0;

	int overflowNCO = 0;
    double outputPhase;
	
	// NCO counter value
	outputNCO = outputNCO + freqRatio;
	if (outputNCO >= 1){
		outputNCO = outputNCO - 1;
		overflowNCO = 1;
	}

	// output value
	if (overflowNCO){
		outputPhase = 1 - outputNCO/freqRatio; // downsampler phase
		*outdata = outputPhase*(indata -indataLast) + indataLast;
	}

	// update last value
	indataLast = indata;

	return overflowNCO;

}
