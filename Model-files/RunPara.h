/**\file
\brief definition of struct SRunPara and enums CompMode and CompVersion
*/
//---------------------------------------------------------------------------

#ifndef RunParaH
#define RunParaH
#include <string>

//---------------------------------------------------------------------------
//! Enumeration type to specify size asymmetry/symmetry of competition
/**
  \arg sym \c symmetric resource sharing between plant individuals
  \arg asympart \c partially symmetric resource sharing (taller, bigger plants get more resources)
  \arg asymtot \c tallest/biggest plant gets all resources
 */
enum CompMode {sym, asympart, asymtot};


//! Enumeration type to specify the competition version describing interspecific niche differentiation
/**
  \arg version1 \c no difference between intra- and interspecific competition
  \arg version2 \c higher effects of intraspecific competition
  \arg version3 \c lower resource availability for intraspecific competition
*/
enum CompVersion {version1, version2, version3};

//---------------------------------------------------------------------------
//! Structure with all scenario parameters
struct SRunPara
{
public:
	//Input Files
	//! Filename of PftTrait-File
	static std::string NamePftFile;
	//! Filename of PftHerbEffect-File (if effect is based on a txt file)
	static std::string NameHerbEffectFile;
	//! scenario parameters
	static SRunPara RunPara;
	//! mode of resource competition for aboveground resources: 0 = symmetric; 1 = partial asymmetry; 2 = total asymmetry
	CompMode AboveCompMode;
	//! mode of resource competition for belowground resources: 0 = symmetric; 1 = partial asymmetry; 2 = total asymmetry
	CompMode BelowCompMode;
	//!niche differentiation
	/*!0 = no difference between intra- and interspecific competition
	  1 = higher effects of intraspecific competition
	  2 = lower resource availability for intraspecific competition
	*/
	CompVersion Version;
	//! intensity of density dependent mortality (and increasing intraspecific competition)
	//! 1: strong, 2: moderate (only density dependent mortality), 3: normal mortality and competition
	int ModelVersion;
	//! side length of grid in cm
    int GridSize;
    //! side length in cells; normally 1cell=1cm
    int CellNum;
    //! boundary behaviour
    bool torus;
    //! maximal simulation time
    int	Tmax;
    //! initialization time
    int  Tinit;
	//! week of herbicide application in the year
    int week_start;
    //! number of plant functional types
    int	NPft;
    //! seed mortality per year (in winter)
    double mort_seeds;
    //! portion of aboveground biomass to be removed in winter
    double DiebackWinter;
    //! basic mortality per week
    double mort_base;
    //! weekly litter decomposition rate
    double LitterDecomp;
    //! mean above-ground resource availability
    double meanARes;
    //! mean below-ground resource availability
    double meanBRes;
    //! amplitude for within year above-ground resource variation
    double Aampl;
    //! amplitude for within year below-ground resource variation (currently not used)
	double Bampl;
    //! standard deviation for intraspecific trait variability
    double ITVsd;
    //! probability of ramet establishment (1)
    double EstabRamet;
    //! seed input per year
    int seedsPerType;

	/** @name GrazParam
	*  Grazing parameters
	*/
	///@{
    //! grazing probability per week
	double GrazProb;
	//! proportion of above ground mass removed by grazing
	double PropRemove;
	//! Bit size of macro-herbivore
	double BitSize;
	///@}

	/** @name HerbParam
	*  Herbicide parameters
	*/
	///@{
	//! number of consecutive years of herbicide application
	int HerbDuration;
	//! treatment (=1) or control (=0) simulation
	int HerbEffectType;
	//! where to get the effects from? 0: txt-file, 2: dose response for each PFT
	int EffectModel;
	//! switch whether F1 generation is also affected ("F0" only parent generation; "F1" also F1 generation)
	std::string Generation;
	//! for dose response effects: application rate
	int app_rate;
   	///@}

	/** @name CutParam
	*  Cutting parameters
	*/
	///@{
	//! plant aboveground biomass for plants with LMR = 1.0
	double CutMass;
	//! number cuts per year
	int    NCut;
	///@}

	/** @name TramplingParam
	*  Trampling parameters
	*/
	///@{
	//! fraction of grid area disturbed per year;
	double DistAreaYear;
	//! fraction of grid area disturbed in one event
	double AreaEvent;
	//! disturbance probability
	inline double DistProb(){return DistAreaYear/AreaEvent/30.0;};
	///@}
	//! number of monte carlo simulations
	int MCrun;
	//! constructor
	SRunPara();
	//! calculates the cell scale (normally 1cm)
	inline double CellScale(){return GridSize/(double)CellNum;};
	//! grid size
	inline unsigned int GetGridSize() const {return CellNum;};
	//! sum of grid cells
	inline unsigned int GetSumCells() const {return CellNum*CellNum;};
	//! creating a run ID
	std::string getRunID();//!<function to get RunID
};
//---------------------------------------------------------------------------
#endif
