//---------------------------------------------------------------------------

#ifndef LCGH
#define LCGH

#include <random>

//---------------------------------------------------------------------------
//! class for random number generator
class RandomGenerator
{
public:
	std::mt19937 rng;
	//! get uniform distributed random int
	int getUniformInt(int thru);
	//! get uniform distributed random double between 0 and 1
	double get01();
	//! get gaussian distributedn random double
	double getGaussian(double mean, double sd);
	//! constructor
	RandomGenerator() : rng(std::random_device()()) {}
};
//! uniformly distributed random number between 0 and 1
double combinedLCG(void);
//! normal distributed random number with mean and sd
double normcLCG(double,double);
//! init random number generator with two large integers
void initLCG(long, long);
#endif
