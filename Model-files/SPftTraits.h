/**\file
   \brief definitions for plant traits
 *      Author: KatrinK
 */

#ifndef SPFTTRAITS_H_
#define SPFTTRAITS_H_

#include <map>
#include <string>
#include <vector>
#include <memory>
using namespace std;

/**
 * Structure to store all PFT Parameters
 *
 */
//! Structure to store all PFT Parameters
class SPftTraits {
public:
//general
	//! links of Pfts(SPftTrais) used
	static map<string,shared_ptr<SPftTraits>> PftLinkList;
	//! PFT ID same number for all individuals of one PFT
	int TypeID;
	//! name of PFT
	string name;
	//! maximum age of plants
	int MaxAge;

//morphology
	//! leaf mass ratio (LMR) (leaf mass per shoot mass) [0;1] 1 -> only leafs, 0 -> only stem
	double LMR;
	//! specific leaf area (SLA) equal to cshoot in the model description (leaf area per leaf mass)
	double SLA;
	//! root area ratio (root area per root mass) equal to croot in the model description
	double RAR;
	//! initial masses of root and shoot
	double m0;
	//! maximum individual mass
	double MaxMass;

//seed reproduction
	//! constant proportion that is allocated to seeds between FlowerWeek and DispWeek
	double AllocSeed;
	//! Seed mass (mass of ONE seed)
	double SeedMass;
	//! mean dispersal distance (and standard deviation of the dispersal kernel
	double Dist;
	//! maximum seed longevity
	int    Dorm;
	//! annual probability of seed establishment
	double pEstab;

//competitive strength
	//!< maximal resource utilization per ZOI area per time step
	/*!< (optimum uptake for two layers : LimRes=2*Gmax)
	(optimum uptake for one layer : LimRes=Gmax)
	*/
	double Gmax;
	//! competitive ability of perennials and annuals
	double comp_power;
	//! above-ground competitive ability
	inline double CompPowerA()const {return 1.0/LMR*Gmax*comp_power;};
	//! below-ground competitive ability
	inline double CompPowerB()const {return Gmax*comp_power;};
	//! higher resource allocation into shoots; different from normal
	double allocroot;
	//! higher resource allocation into roots; different from normal
	double allocshoot;

//grazing response
	//! fraction of above-ground biomass removal if a plant is grazed
	inline double GrazFac()const {return 1.0/LMR*palat;};
	//!< Palatability -> susceptability towards grazing
	double palat;

//stress tolerance
	//! equal to surv_max in the model description -> maximal time of survival under stress
	int    memory;
	//! Fraction of maximum uptake that is considered as resource stress
	double mThres;
	//! coersion rate  resource -> biomass [mass/resource unit]
	double growth;

//herbicide traits
	//! herbicide susceptibility
	double herb;
	//! EC50 for effect on biomass
	double EC50_biomass;
	//! EC50 for effect on seedling biomass
	double EC50_SEbiomass;
	//! EC50 for effect on survival
	double EC50_survival;
	//! EC50 for effect on establishment
	double EC50_establishment;
	//! EC50 for effect on seed sterility
	double EC50_sterility;
	//! EC50 for effect on seed number
	double EC50_seednumber;
	//! slope for effect on biomass
	double slope_biomass;
	//! slope for effect on seedling biomass
	double slope_SEbiomass;
	//! slope for effect on survival
	double slope_survival;
	//! slope for effect on establishment
	double slope_establishment;
	//! slope for effect on seed sterility
	double slope_sterility;
	//! slope for effect on seed number
	double slope_seednumber;
	   
// flowering phenology
	//! week of start of seed production
	int    FlowerWeek;
	//! week of seed dispersal (and end of seed production)
	int    DispWeek;
	//! week of seed dispersal (and end of seed production)
	int    GermPeriod;
	//! overwintering of plants yes (1) or no (0); important for annuals
	int 	  overwintering;

//clonality...
	//! is this plant clonal at all?
	bool clonal;
	//! allocation to sexual reproduction during time of seed production
	double PropSex;
	//! mean spacer length [cm]
	double meanSpacerlength;
	//! sd spacer length [cm]
	double sdSpacerlength;
	//! proportion of resource invested in ramet growth -> for annual and biannual species this should not be=AllocSeed, because this is then way to high
	double AllocSpacer;
	//! do established ramets share their resources?
	bool Resshare;
	//! resources for 1 cm spacer (default=70)
	double mSpacer;

//functions..
	//! constructor
	SPftTraits();
	//! constructor
	SPftTraits(const SPftTraits& s);
	//! for ITV: variation of mean trait values (intraspecific trait variability)
	void varyTraits();
	//! read the PFT definitions from a file
	static void ReadPFTDef(const string& file);
	//! get basic type according to string
	static std::shared_ptr<SPftTraits> getPftLink(std::string type);
	//! get the set of traits for a specific type
	static std::shared_ptr<SPftTraits> createTraitSetFromPftType(std::string type);
	//! copy a set of traits of a specific type
	static std::shared_ptr<SPftTraits> copyTraitSet(std::shared_ptr<SPftTraits> t); ///< for ITV
};

#endif /* SPFTTRAITS_H_ */
