/**\file7
 * \brief definitions of effect profile

 * CTKmodel.h
 *
 *  Created on: 07.02.2014
 *      Author: KatrinK, JetteR
 */
/**\page HerbEff Implementing herbicide effects
 *
 * @param year specific year
 * @param sensitivity herbicide susceptibility of PFT individual
 * @param app_rate application rate for dose responses
 * @param SEffProfile individual effect profile where effects on different plat attributes are stored
 *
 * \par
 * Herbicide effects can be calculated in 2 different ways:
 * 	-# via a simple txt-file with each row containing effect for the specific year
 * 		- txt file includes 6 different columns for the herbicide induced effects on:
 * 			- establishment
 * 			- seedling biomass
 * 			- seed mortality
 * 			- resource allocation to reproduction
 * 			- plant mortality
 * 			- plant growth
 * 	-# via a dose response function
 * 		- trait file includes traits for the EC50 and slope of the dose responses
 * 			- dose responses can be calculated for:
 * 				- establishment
 * 				- seedling biomass
 * 				- seed mortalitiy (i.e. seed fertility)
 * 				- seed production
 * 				- plant mortality
 * 				- plant growth
 * 		- simulation parameter app_rate gives the specific application rate
 * 		- calculation of effect: app_rate^slope/(app_rate^slope + EC50^slope)
 *
 * 	Independent of the way, effects are stored as effect profiles for each plant and seed individual effect profile which is part of the plant and seed characteristics.
 *
 */

#ifndef CTKMODEL_H_
#define CTKMODEL_H_

#include <string>
#include <map>
#include <vector>
using namespace std;
//------------------------------------------------------------------------------
/**\brief herbicide effect profile
 * Set of herbicide effect endpoints on plant and seed performance.
 */
struct SEffProfile{
	//! effect on seed establishment (0)
	double pEstabSeedFac;
	//! effect on spacer establishment (0)
	double pEstabSpacerFac;
	//! effect on seed biomass (0)
	double SeedBioFac;
	//! effect on seed mortality (0)
	double HerbSeedMort;
	//! effect on resource allocation to spacer (0)
	double AllocSpacerFac;
	//! effect on resource allocation to seeds (0)
	double AllocSeedFac;
	//! effect on survival rate (0)
	double SurvFac;
	//! effect on growth rate (0)
	double growthFac;
	//! constructor
	SEffProfile();
	//! constructor
	SEffProfile(double, double,double,double,double,double,double,double);
	//! is currently herbicide exposition?
   bool isExposed(){return (pEstabSeedFac+pEstabSpacerFac+SeedBioFac+
			  HerbSeedMort+AllocSpacerFac+AllocSeedFac+growthFac+SurvFac)>0;};
   //! herbicide exposure strength as sum of single effects
   double exposure_strength(){return pEstabSeedFac+pEstabSpacerFac+SeedBioFac+
			  HerbSeedMort+AllocSpacerFac+AllocSeedFac+growthFac+SurvFac;}
};
//-----------------------------------------------------------------------------------
/**
 * \brief toxicokinetic environment
 */
class CTKmodel {
	//! Filename of Herbicide factors if read via a txt file
	static string NameHerbFile;
	//! Filename of Application rates
	static string NameAppFile;
	//! annually correction factors for txt-file option
	static vector<SEffProfile> EffTimeline;
	//! annual application rates for dose response option
	static vector<double> AppRateTimeline;
	//! type specific susceptibility
	static map<string, double> PFTsensi;
	//! type specific effect
	static map<string, double> PFTeffect_growVV;
	//! type specific effect
	static map<string, double> PFTeffect_survivalVV;
	//! type specific effect
	static map<string, double> PFTeffect_survivalSE;
	//! type specific effect
	static map<string, double> PFTeffect_growSE;
	//! type specific effect
	static map<string, double> PFTeffect_estabSE;
	//! type specific effect
	static map<string, double> PFTeffect_AllocSE;

public:
	//! reading txt-file with effect intensities
	static double GetHerbEff(const int pos1=0,string file=NameHerbFile);
	//! reading txt file with application rates
	static double GetAppRates(const int pos1=0,string file=NameAppFile);
	//! set PFT sensitivities
	static void setPFTsensi(string PFT);
protected:
	//! get correction factors for model parameters depending on PFTsensi for plants
    SEffProfile* getProfileProxy(string PFT,int year);
    //! get correction factors for model parameters depending on PFTsensi for seeds
    SEffProfile* getProfileProxySeeds(string PFT,int year);
};//end class CTKModel

#endif /* CTKMODEL_H_ */
