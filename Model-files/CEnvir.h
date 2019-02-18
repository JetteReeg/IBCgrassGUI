/**\file
   \brief definition of environmental classes and result structures PftOut and GridOut
*/
//---------------------------------------------------------------------------
#ifndef environmentH
#define environmentH

#include "CGrid.h"
#include "OutStructs.h"

#include <vector>
#include <fstream>
#include "LCG.h"

//---------------------------------------------------------------------------
/// virtual Basic Results Class with general static simulation parameters
/** The class contains
    - simulation-wide (static) information on
      - Names of in- and output-files,
      - an Random Number Generator (plus some service functions), and
      - a template for above-and belowground resources as well as
      - current simulation status (current year, week etc.)
    - variables storing result information on grid and single pfts
    - functions
      - collecting and writing results to output-files
      - reading-in Resource data
      - core function OneWeek(), running a week of the simulation
 \par time scales of the simulations:
   - 1 step = 1 week
   - 1 year = 30 weeks
*/
class CEnvir{
protected:
	//! array for survival times of PFTs [years];
	map<string,int> PftSurvTime;
	//! list of Pfts used
	static map<string,long> PftInitList;

public:
	//! random number generator
	static RandomGenerator rng;
	//Output Files
	//! Filename of Pft-Output
	static string NamePftOutFile;
	//! Filename of Ind-Output
	static string NameIndOutFile;
	//! Filename of Grid-Output
	static string NameGridOutFile;
	//!< mean above-ground resource availability [resource units per cm2]
	static vector<double> AResMuster;
	//!< mean below-ground resource availability [resource units per cm2]
	static vector<double> BResMuster;
	//! current week (0-30)
	static int week;
	//! current year
	static int year;
	//! nb of weeks per year
	static int WeeksPerYear;
	//! end of simulation reached? (flag)
	bool endofrun;
	//! flag for simulation issue (init time)
	int init;
	//! Vector for Pft output data
	vector<SPftOut*> PftOutData;
	//! Vector for Grid output data
	vector<SGridOut*> GridOutData;
	//! Vector for Grid output data
	vector<SIndOut*> IndOutData;

	//result variables - non-clonal
	//! aboveground cover of the cell (int coded)
	vector<int> ACover;
	//! belowground cover of the cell (int coded)
	vector<int> BCover;
	//! current Grid-cover of Pfts used
	map<string,double> PftCover;
	//! Number of Cells shaded by plants on ground
	double NCellsAcover;

	//Functions
	//! constructor
	CEnvir();
	//! destrcutor
	virtual ~CEnvir();

	//! read in fractal below-ground resource distribution (not used)
	static void ReadLandscape();

	//! returns absolute time horizon
	static int GetT(){return (year-1)*WeeksPerYear+week;};
	//! reset time
	static void ResetT(){ year=1;week=0;};
	//! set new week
	static void NewWeek(){week++;if (week>WeeksPerYear){week=1;year++;};};

/**
* \name math and random help functions
*/
///@{
//! round a double value
	inline static int Round(const double& a){return (int)floor(a+0.5);};
	//! get a uniformly distributed random number (0-n)
	inline static int nrand(int n){return combinedLCG()*n;};
	//! get a uniformly distributed random number (0-1)
	inline static double rand01(){return combinedLCG();};
	//! get a uniformly distributed random number (0-1)
	inline static double normrand(double mean,double sd){return normcLCG(mean,sd);};
///@}
/**
 * \name core simulation functions (virtual)
 * Functions needed for simulation runs.
 * To be defined in inheriting classes.
 */
///@{
	//! init a new run
	virtual void InitRun();
	//! calls all weekly processes
	virtual void OneWeek()=0;
	//! runs one year in default mode
	virtual void OneYear()=0;
	//! runs one simulation run in default mode
	virtual void OneRun()=0;
	//! collect and write Output to an output-file
	virtual void GetOutput()=0;
	//! returns number of surviving PFTs
	/*! a PFT is condsidered as a survivor if individuals or
		at least seeds are still there
	*/
	virtual int PftSurvival()=0;
///@}
/**
 * \name File Output
 */
///@{
	//! collect file output
	void WriteOFiles();
	//! writes detailed data for the modeled community to output file
	void WriteGridComplete(bool allYears=true);
	//! writes detailed data for each PFT to output file
	void WritePftComplete(unsigned int allYears=1);
	//! writes detailed data for each individual to output file
	void WriteIndComplete(unsigned int allYears=1);

///@}

	//! get mean Shannon diversity over several years
	double GetMeanShannon(int years);
	//! get mean number of types
	double GetMeanNPFT(int years);
	//! get current PopSize of type pft
	double GetCurrPopSize(string pft);

};
//---------------------------------------------------------------------------
#endif
