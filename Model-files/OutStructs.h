//---------------------------------------------------------------------------

#ifndef OutStructsH
#define OutStructsH

#include <map>
#include <string>
using namespace std;
//---------------------------------------------------------------------------
//! class of a plant
class CPlant;
//! Structure with output data for each PFT
struct SPftOut
{
	//! Structure with output data for each PFT
	struct SPftSingle{
		//! total biomass
		double totmass;
		//! shoot mass
		double shootmass;
		//! root mass
		double rootmass;
		//! reproductive mass
		double repromass;
		//! cover
		double cover;
		//!< population size (age >4 weeks)
		int Nind;
		//!< inds younger 5 weeks
		int Nseedlings;
		//!< number of seeds
		int Nseeds;
		//! constructor
		SPftSingle();
		//! destructor
		~SPftSingle(){};
		//! add individual
		void addInd(CPlant*);
	};// end struct
	//!< week of the year (1-30)
	int week;
	//!< list of active PFTs
	map<string,SPftSingle*> PFT;
	//! constructor
	SPftOut();
	//! destructor
	~SPftOut();
};// end struct PFTOut
//---------------------------------------------------------------------------
//! Structure with output data for the whole grid
struct SGridOut
{
	//! week of the year (1-30)
	int week;
	//! number surviving PFTs
	int PftCount;
	//! total biomass (sum over all PFTs
	double totmass;
	//! number of plants
	int Nind;
	//! shannon diversity index
	double shannon;
	//! total above-ground mass
	double above_mass;
	//! total below-ground mass
	double below_mass;
	//! mean above-ground resource availability
	double aresmean;
	//! mean below-ground resource availability
	double bresmean;
	//! cutted biomass
	double cutted;
	//clonal..
	//! nb non-clonal plants
	int NPlants;
	//! nb clonal plants
	int NclonalPlants;
	//! Number of living genets
	int NGenets;
	//! total biomass non-clonal plants
	double MPlants;
	//! total biomass clonal plants
	double MclonalPlants;
	//! mean size of genets
	double MeanGenetsize;
	//! mean number of generations
	double MeanGeneration;
	//! constructor
	SGridOut();
};// end of struct Gridout

//---------------------------------------------------------------------------

//! Structure with output data for each individual
struct SIndOut
{
	//! week of the year (1-30)
	int week;
	//! list of active functional type names
    string name;
    //! age of plant
    int age;
    //! shoot mass
    double shootmass;
    //! root mass
    double rootmass;
    //! constructor
   	SIndOut();
};
//---------------------------------------------------------------------------

#endif
