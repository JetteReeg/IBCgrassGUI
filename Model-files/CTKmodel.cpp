/**\file
 * \brief functions of effect profiles

 * CTKmodel.cpp
 *
 *  \since 07.02.2014
 *  \author KatrinK, JetteR
 */
#include "CTKmodel.h"
#include "CEnvir.h"
#include "RunPara.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <utility>


using namespace std;
//! name of txt-file
string CTKmodel::NameHerbFile="HerbFact.txt";
//! name of AppRate file
string CTKmodel::NameAppFile="AppRate.txt";
//! listed herbicide induced effects
vector<SEffProfile> CTKmodel::EffTimeline;
//! application rate timeline
vector<double> CTKmodel::AppRateTimeline;
//! type specific sensitivity to herbicide
map<string, double> CTKmodel::PFTsensi;
//! type specific effect on plant growth
map<string, double> CTKmodel::PFTeffect_growVV;
//! type specific effect on plant mortality
map<string, double> CTKmodel::PFTeffect_survivalVV;
//! type specific effect on seed mortality
map<string, double> CTKmodel::PFTeffect_survivalSE;
//! type specific effect on seedling biomass
map<string, double> CTKmodel::PFTeffect_growSE;
//! type specific effect on establishment
map<string, double> CTKmodel::PFTeffect_estabSE;
//! type specific effect on reproduction
map<string, double> CTKmodel::PFTeffect_AllocSE;

//! constructor...
SEffProfile::SEffProfile():pEstabSeedFac(0), pEstabSpacerFac(0),SeedBioFac(0),HerbSeedMort(0),AllocSpacerFac(0), AllocSeedFac(0),SurvFac(0),growthFac(0){}
//! constructor with values given
SEffProfile::SEffProfile(double pEstSE, double pEstSp, double fThres, double fMM, double fAlSp, double fAlSE, double fSurv, double fGr)
:pEstabSeedFac(pEstSE),pEstabSpacerFac(pEstSp),SeedBioFac(fThres),HerbSeedMort(fMM),AllocSpacerFac(fAlSp),AllocSeedFac(fAlSE),SurvFac(fSurv),growthFac(fGr){}
//----------------------------------------------------------------------
/**
 * reading txt-file which contains effect profiles for several years (correction factors)
 * @param pos1 file position to start reading
 * @param file file name of txt file to be read
 * @return Effect timeline
 */
double CTKmodel::GetHerbEff(const int pos1,string file)
{
	//Open HerbFile
	const char* name=SRunPara::NameHerbEffectFile.c_str();
	ifstream HerbFile(name);
	if (!HerbFile.good()) {cerr<<("Error while opening HerbFile");exit(3); }
	// read header
	string line;
	getline(HerbFile,line);
	int i=0;
	// copy data into effect profile structure
	while(HerbFile.good())
	{
		string line,file_id;
		SEffProfile currY;
		HerbFile>>currY.growthFac
		>>currY.SurvFac
		>>currY.SeedBioFac
		>>currY.pEstabSeedFac
		>>currY.HerbSeedMort
		>>currY.AllocSeedFac;
		// set effects on clonal attributes
		currY.pEstabSpacerFac = currY.pEstabSeedFac;
		currY.AllocSpacerFac = currY.AllocSeedFac;
		//append
		EffTimeline.push_back(currY);
		getline(HerbFile,line);
		i++;
	}
  return HerbFile.tellg();
}//end  CEnvir::GetHerbEff
//----------------------------------------------------------------------
/**
 * reading txt-file which contains application rates for several years
 * @param pos1 file position to start reading
 * @param file file name of txt file to be read
 * @return AppRate timeline
 */
double CTKmodel::GetAppRates(const int pos1,string file)
{
	//Open AppRate file
	const char* name=SRunPara::NameAppRateFile.c_str();
	ifstream AppRateFile(name);
	 // Error message if file cannot be opened
	if (!AppRateFile.good()) {cerr<<("Error while opening AppRateFile");exit(3); }
	double current_apprate = 0;
	while (AppRateFile >> current_apprate){
				AppRateTimeline.push_back(current_apprate);
			}
	// Close the file.
	AppRateFile.close();
}
//----------------------------------------------------------------------------------------------------
/**
 * set sensitivity of type PFT
 * @param PFT
 */
void CTKmodel::setPFTsensi(string PFT) {
	// read the sensitivity from the trait settings
	CTKmodel::PFTsensi[PFT]=SPftTraits::getPftLink(PFT)->herb;
}
//----------------------------------------------------------------------------------------------------
/**
 * Get one herbicide effect profile, i.e. correction factors for model parameters
 *
 * Corrects for PFT specific sensitivity
 * @param PFT PFT to be asked for
 * @param year current year
 * @return link to a set of factors (SEffProfile)
 */
SEffProfile* CTKmodel::getProfileProxy(string PFT,int year)
{
	// get the sensitivity
	double sensi=CTKmodel::PFTsensi.find(PFT)->second;
	// create a new effect profile
	SEffProfile* dummi=new SEffProfile;
	// if it is a treatment run and the years is a herbicide application year ...
	if((SRunPara::RunPara.HerbEffectType!=0) &&
			(year>SRunPara::RunPara.Tinit)&&
			(year<=(SRunPara::RunPara.Tinit+SRunPara::RunPara.HerbDuration))
			)
	{
		// if the effect is based on a txt file (which was read in at the  beginning of the run using GetHerbEff() )
		if(SRunPara::RunPara.EffectModel==0)
		{
			// get the effect profile of the specific year
			SEffProfile yearEff= EffTimeline[year-SRunPara::RunPara.Tinit];
			// correction factor based on sensitivity
			double PFTcorr=sensi;
			dummi->pEstabSeedFac=yearEff.pEstabSeedFac*PFTcorr;
				dummi->pEstabSpacerFac=yearEff.pEstabSpacerFac*PFTcorr;
				dummi->SeedBioFac=yearEff.SeedBioFac*PFTcorr;
				dummi->HerbSeedMort=yearEff.HerbSeedMort*PFTcorr;
				dummi->AllocSpacerFac=yearEff.AllocSpacerFac*PFTcorr;
				dummi->AllocSeedFac=yearEff.AllocSeedFac*PFTcorr;
				dummi->SurvFac=yearEff.SurvFac*PFTcorr;
				dummi->growthFac=yearEff.growthFac*PFTcorr;
		}// end update effect profile
		// if the effect is based on dose-response functions
		if(SRunPara::RunPara.EffectModel==2)
		{
			// EC50...
			double EC50_biomass, EC50_SEbiomass, EC50_survival, EC50_establishment, EC50_sterility, EC50_seednumber;
			// slope...
			double slope_biomass, slope_SEbiomass, slope_survival, slope_establishment, slope_sterility, slope_seednumber;
			// effect on plant growth
			EC50_biomass = SPftTraits::PftLinkList.find(PFT)->second->EC50_biomass;
			// effect on seedling growth
			EC50_SEbiomass = SPftTraits::PftLinkList.find(PFT)->second->EC50_SEbiomass;
			// effect on survival
			EC50_survival = SPftTraits::PftLinkList.find(PFT)->second->EC50_survival;
			// effect on establishment
			EC50_establishment = SPftTraits::PftLinkList.find(PFT)->second->EC50_establishment;
			// effect on seed mortality
			EC50_sterility = SPftTraits::PftLinkList.find(PFT)->second->EC50_sterility;
			// effect on seed number
			EC50_seednumber = SPftTraits::PftLinkList.find(PFT)->second->EC50_seednumber;
			// effect on plant growth
			slope_biomass = SPftTraits::PftLinkList.find(PFT)->second->slope_biomass;
			// effect on seedling growth
			slope_SEbiomass = SPftTraits::PftLinkList.find(PFT)->second->slope_SEbiomass;
			// effect on survival
			slope_survival = SPftTraits::PftLinkList.find(PFT)->second->slope_survival;
			// effect on establishment
			slope_establishment = SPftTraits::PftLinkList.find(PFT)->second->slope_establishment;
			// effect on seed mortality
			slope_sterility = SPftTraits::PftLinkList.find(PFT)->second->slope_sterility;
			// effect on seed number
			slope_seednumber = SPftTraits::PftLinkList.find(PFT)->second->slope_seednumber;
			// get the application rates (as RunPara)
			int rate;
			rate=AppRateTimeline[year-SRunPara::RunPara.Tinit];
			// set effect on establishment (seeds)
			if(EC50_establishment>0)	dummi->pEstabSeedFac=pow(rate,slope_establishment)/(pow(EC50_establishment,slope_establishment)+pow(rate,slope_establishment));
				else dummi->pEstabSeedFac=0.0;
			// set effect on establishment (spacer)
			if(EC50_establishment>0)	dummi->pEstabSpacerFac=pow(rate,slope_establishment)/(pow(EC50_establishment,slope_establishment)+pow(rate,slope_establishment));
				else dummi->pEstabSpacerFac=0.0;
			// set effect on seedling growth
			if(EC50_SEbiomass>0)	dummi->SeedBioFac=pow(rate,slope_SEbiomass)/(pow(EC50_SEbiomass,slope_SEbiomass)+pow(rate,slope_SEbiomass));
				else dummi->SeedBioFac=0.0;
			// set effect on seed mortality
			if(EC50_sterility>0)	dummi->HerbSeedMort=pow(rate,slope_sterility)/(pow(EC50_sterility,slope_sterility)+pow(rate,slope_sterility));
				else dummi->HerbSeedMort=0.0;
			// set effect on spacer production
			if(EC50_seednumber>0)	dummi->AllocSpacerFac=pow(rate,slope_seednumber)/(pow(EC50_seednumber,slope_seednumber)+pow(rate,slope_seednumber));
				else dummi->AllocSpacerFac=0.0;
			// set effect on seed production
			if(EC50_seednumber>0)	dummi->AllocSeedFac=pow(rate,slope_seednumber)/(pow(EC50_seednumber,slope_seednumber)+pow(rate,slope_seednumber));
				else dummi->AllocSeedFac=0.0;
			// set effect on survival
			if(EC50_survival>0)	dummi->SurvFac=pow(rate,slope_survival)/(pow(EC50_survival,slope_survival)+pow(rate,slope_survival));
				else dummi->SurvFac=0.0;
			// set effect on plant growth
			if(EC50_biomass>0)	dummi->growthFac=pow(rate,slope_biomass)/(pow(EC50_biomass,slope_biomass)+pow(rate,slope_biomass));
				else dummi->growthFac=0.0;
		}// end if based on dose responses
	}// end if treatment run
	// return new effect profile for plants
    return dummi;
}// end getProfileProxy
//----------------------------------------------------------------------------------------------------
/**
 * Get one herbicide effect profile, i.e. correction factors for model parameters
 *
 * Corrects for PFT specific sensitivity
 * @param PFT PFT to be asked for
 * @param year current year
 * @return link to a set of factors (SEffProfile)
 */
SEffProfile* CTKmodel::getProfileProxySeeds(string PFT,int year)
{
	// PFT specific herbicide sensitivity
	double sensi=CTKmodel::PFTsensi.find(PFT)->second;
	// create a new effect profile
	SEffProfile* dummi=new SEffProfile;
	// if treatment run and during herbicide application period
	if((SRunPara::RunPara.HerbEffectType!=0) &&
			(year>=SRunPara::RunPara.Tinit)&&
			(year<=(SRunPara::RunPara.Tinit+SRunPara::RunPara.HerbDuration)))
	{
		// if the effect is based on a txt file (which was read in at the  beginning of the run using GetHerbEff() )
		if(SRunPara::RunPara.EffectModel==0)
		{
			// get the effect profile of the specific year
			SEffProfile yearEff= EffTimeline[year-SRunPara::RunPara.Tinit];
			// correction factor based on sensitivity
			double PFTcorr=sensi;

			dummi->pEstabSeedFac=yearEff.pEstabSeedFac*PFTcorr;
				dummi->pEstabSpacerFac=yearEff.pEstabSpacerFac*PFTcorr;
				dummi->SeedBioFac=yearEff.SeedBioFac*PFTcorr;
				dummi->HerbSeedMort=yearEff.HerbSeedMort*PFTcorr;
				dummi->AllocSpacerFac=yearEff.AllocSpacerFac*PFTcorr;
				dummi->AllocSeedFac=yearEff.AllocSeedFac*PFTcorr;
				dummi->SurvFac=yearEff.SurvFac*PFTcorr;
				dummi->growthFac=yearEff.growthFac*PFTcorr;
		}// end if effect is based on txt file
		// if the effect is based on dose-response functions
		if(SRunPara::RunPara.EffectModel==2)
		{
			// EC50...
			double EC50_biomass, EC50_SEbiomass, EC50_survival, EC50_establishment, EC50_sterility, EC50_seednumber;
			// slope...
			double slope_biomass, slope_SEbiomass, slope_survival, slope_establishment, slope_sterility, slope_seednumber;
			// effect on plant growth
			EC50_biomass = SPftTraits::PftLinkList.find(PFT)->second->EC50_biomass;
			// effect on seedling growth
			EC50_SEbiomass = SPftTraits::PftLinkList.find(PFT)->second->EC50_SEbiomass;
			// effect on survival
			EC50_survival = SPftTraits::PftLinkList.find(PFT)->second->EC50_survival;
			// effect on establishment
			EC50_establishment = SPftTraits::PftLinkList.find(PFT)->second->EC50_establishment;
			// effect on seed mortality
			EC50_sterility = SPftTraits::PftLinkList.find(PFT)->second->EC50_sterility;
			// effect on seed number
			EC50_seednumber = SPftTraits::PftLinkList.find(PFT)->second->EC50_seednumber;
			// effect on plant growth
			slope_biomass = SPftTraits::PftLinkList.find(PFT)->second->slope_biomass;
			// effect on seedling growth
			slope_SEbiomass = SPftTraits::PftLinkList.find(PFT)->second->slope_SEbiomass;
			// effect on survival
			slope_survival = SPftTraits::PftLinkList.find(PFT)->second->slope_survival;
			// effect on establishment
			slope_establishment = SPftTraits::PftLinkList.find(PFT)->second->slope_establishment;
			// effect on seed mortality
			slope_sterility = SPftTraits::PftLinkList.find(PFT)->second->slope_sterility;
			// effect on seed number
			slope_seednumber = SPftTraits::PftLinkList.find(PFT)->second->slope_seednumber;
			// get the application rates (as RunPara)
			int rate;
			rate=AppRateTimeline[year-SRunPara::RunPara.Tinit];
			// set effect on establishment (seeds)
			if(EC50_establishment>0)	dummi->pEstabSeedFac=pow(rate,slope_establishment)/(pow(EC50_establishment,slope_establishment)+pow(rate,slope_establishment));
				else dummi->pEstabSeedFac=0.0;
			// set effect on establishment (spacer)
			if(EC50_establishment>0)	dummi->pEstabSpacerFac=pow(rate,slope_establishment)/(pow(EC50_establishment,slope_establishment)+pow(rate,slope_establishment));
				else dummi->pEstabSpacerFac=0.0;
			// set effect on seedling growth
			if(EC50_SEbiomass>0)	dummi->SeedBioFac=pow(rate,slope_SEbiomass)/(pow(EC50_SEbiomass,slope_SEbiomass)+pow(rate,slope_SEbiomass));
				else dummi->SeedBioFac=0.0;
			// set effect on seed mortality
			if(EC50_sterility>0)	dummi->HerbSeedMort=pow(rate,slope_sterility)/(pow(EC50_sterility,slope_sterility)+pow(rate,slope_sterility));
				else dummi->HerbSeedMort=0.0;
			// set effect on spacer production
			if(EC50_seednumber>0)	dummi->AllocSpacerFac=pow(rate,slope_seednumber)/(pow(EC50_seednumber,slope_seednumber)+pow(rate,slope_seednumber));
				else dummi->AllocSpacerFac=0.0;
			// set effect on seed production
			if(EC50_seednumber>0)	dummi->AllocSeedFac=pow(rate,slope_seednumber)/(pow(EC50_seednumber,slope_seednumber)+pow(rate,slope_seednumber));
				else dummi->AllocSeedFac=0.0;
			// set effect on survival
			if(EC50_survival>0)	dummi->SurvFac=pow(rate,slope_survival)/(pow(EC50_survival,slope_survival)+pow(rate,slope_survival));
				else dummi->SurvFac=0.0;
			// set effect on plant growth
			if(EC50_biomass>0)	dummi->growthFac=pow(rate,slope_biomass)/(pow(EC50_biomass,slope_biomass)+pow(rate,slope_biomass));
				else dummi->growthFac=0.0;
		}// end if based on dose response
	}// end during herbicide period
	// return new effect profile for seeds
    return dummi;
}// end getProfileProxySeeds

//eof
