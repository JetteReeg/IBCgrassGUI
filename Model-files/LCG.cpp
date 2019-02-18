/**\file
 * \brief LCG.cpp random number generator
  source: http://www.c-plusplus.de/forum/39335-full (posted by Mady 12:54:00 15.12.2002)
*/

#include "LCG.h"
#include <math.h>
#include <random>
//---------------------------------------------------------------------------
/**
 * get uniformly distributed random integer
 * @param thru maximal value
 */
int RandomGenerator::getUniformInt(int thru)
{
	return floor(get01() * thru);
}
//---------------------------------------------------------------------------
/**
 *  get uniformly distributed random double between 0 and 1
 */
double RandomGenerator::get01()
{
	std::uniform_real_distribution<double> dist(0, 1);
	return dist(rng);
}
//---------------------------------------------------------------------------
/**
 *  get gaussian distributed random double
 *  @param mean mean of the distribution
 *  @param sd standard deviation of the distribution
 */
double RandomGenerator::getGaussian(double mean, double sd)
{
	std::normal_distribution<double> dist(mean, sd);
	return dist(rng);
}
//---------------------------------------------------------------------------
/**
 *
 */
static long s1 = 1;
static long s2 = 1;

#define MODMULT(a, b, c, m, s) q = s/a; s = b*(s-a*q)-c*q; if (s < 0) s += m;
//---------------------------------------------------------------------------
/**
 *  get uniformly distributed random double between 0 and 1
 */
double combinedLCG(void)
{
    long q, z;
    MODMULT(53668, 40014, 12211, 2147483563L, s1)
    MODMULT(52774, 40692, 3791, 2147483399L, s2)
    z = s1 - s2;
    if (z < 1)
        z += 2147483562;
    return z * 4.656613e-10;
}
//---------------------------------------------------------------------------
/**
 * \return normally distributed random numbers
 *
 * Follows the algorithm
 * of the 'Marsaglia polar method', an modification of the 'Box-Muller'
 * algorithm.
 * \param mean mean
 * \param sd   standard deviation
 * */
double normcLCG(double mean,double sd){
    double u = combinedLCG() * 2 - 1;
    double v = combinedLCG() * 2 - 1;
    double r = u * u + v * v;
    if (r == 0 || r > 1) return normcLCG(mean,sd);
    double c = sqrt(-2 * log(r) / r);
    return (u * c)*sd + mean;

}
//---------------------------------------------------------------------------
/**
 * init random number generator with two large integers
 * @param init_s1 large integer
 * @param init_s2 large integer
 */
void initLCG(long init_s1, long init_s2)
{
    s1 = init_s1;
    s2 = init_s2;
}
//eof
