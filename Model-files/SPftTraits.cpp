/**\file
   \brief functions PFT traits
 *
 *  Created on: 21.04.2014
 *      Author: KatrinK
 */

#include <cstdlib>
#include <string>
#include <fstream>
#include <iostream>
#include <memory>
#include <cassert>
#include <sstream>

#include "SPftTraits.h"
#include "CEnvir.h"
#include "RunPara.h"

using namespace std;
//! structure of PFT traits
map< string, shared_ptr<SPftTraits> > SPftTraits::PftLinkList = map< string, shared_ptr<SPftTraits> >();
//------------------------------------------------------------------------------
/**
 * constructor
 */
SPftTraits::SPftTraits() :TypeID(999),name("default"),MaxAge(100),
	  AllocSeed(0.05),LMR(0),m0(0),MaxMass(0),SeedMass(0),Dist(0),
	  pEstab(0.5),Gmax(0),memory(0),SLA(0),palat(0),RAR(1),growth(0.25),herb(1),
	  allocroot(1), allocshoot(1),
	 EC50_biomass(0), slope_biomass(0),
	 EC50_SEbiomass(0), slope_SEbiomass(0),
	 EC50_survival(0),  slope_survival(0),
	 EC50_establishment(0), slope_establishment(0),
	 EC50_sterility(0), slope_sterility(0),
	 EC50_seednumber(0), slope_seednumber(0),
	  mThres(0.2),Dorm(2),FlowerWeek(16),DispWeek(20), GermPeriod(1), overwintering(1),
	  PropSex(0.1),meanSpacerlength(17.5),sdSpacerlength(12.5),
	  Resshare(true),mSpacer(70),AllocSpacer(0.05),clonal(true),comp_power(1)
{
}//end constructor
//------------------------------------------------------------------------------
/*
 * Copy constructor
 * @param s structure of traits
 */
SPftTraits::SPftTraits(const SPftTraits& s) :
		TypeID(s.TypeID), name(s.name),MaxAge(s.MaxAge),
		  AllocSeed(s.AllocSeed),LMR(s.LMR),m0(s.m0),MaxMass(s.MaxMass),SeedMass(s.SeedMass),Dist(s.Dist),
		  pEstab(s.pEstab),Gmax(s.Gmax),memory(s.memory),SLA(s.SLA),palat(s.palat),RAR(s.RAR),growth(s.growth),herb(s.herb),
		  allocroot(s.allocroot), allocshoot(s.allocshoot),
		  EC50_biomass(s.EC50_biomass), slope_biomass(s.slope_biomass),
		  EC50_SEbiomass(s.EC50_SEbiomass), slope_SEbiomass(s.slope_SEbiomass),
		  EC50_survival(s.EC50_survival),  slope_survival(s.slope_survival),
		  EC50_establishment(s.EC50_establishment), slope_establishment(s.slope_establishment),
		  EC50_sterility(s.EC50_sterility), slope_sterility(s.slope_sterility),
		  EC50_seednumber(s.EC50_seednumber), slope_seednumber(s.slope_seednumber),
		  mThres(s.mThres),Dorm(s.Dorm),FlowerWeek(s.FlowerWeek),DispWeek(s.DispWeek),GermPeriod(s.GermPeriod), overwintering(s.overwintering),
		  PropSex(s.PropSex),meanSpacerlength(s.meanSpacerlength),sdSpacerlength(s.sdSpacerlength),
		  Resshare(s.Resshare),mSpacer(s.mSpacer),AllocSpacer(s.AllocSpacer),clonal(s.clonal), comp_power(s.comp_power)
{

}// end copy constructor
//------------------------------------------------------------------------------
/**
 * Get - link for specific PFT
 * @param type PFT asked for
 * @return Object pointer to PFT definition
 */
shared_ptr<SPftTraits> SPftTraits::getPftLink(string type)
{
	auto pos = PftLinkList.find(type);
	// if PFT is not found..
	if (pos == PftLinkList.end())
		{
			cerr << "Type not found: " << type << endl;
			exit(1);
		}
	// otherwhise get traits and return traits
	shared_ptr<SPftTraits> traits = pos->second;
	return traits;
}
//-----------------------------------------------------------------------------
/**
 * Get - the instance (pass by value) of a specific PFT (as defined by its name)
 * @param type PFT asked for
 * @return Object instance defining a PFT.
 */
shared_ptr<SPftTraits> SPftTraits::createTraitSetFromPftType(string type)
{
	const auto pos = PftLinkList.find(type);
	// if type was not found..
	if ( PftLinkList.find(type) == PftLinkList.end() ) {
		cerr << "Type not found: " << type << endl;
		exit(1);
	}
	shared_ptr<SPftTraits> traits = std::make_shared<SPftTraits>(*pos->second);
	return traits;
}
//-----------------------------------------------------------------------------
/**
 * Get - the instance (pass by value) of a specific PFT (as defined by its name)
 * @param type PFT asked for
 * @return Object instance defining a PFT.
 */
shared_ptr<SPftTraits> SPftTraits::copyTraitSet(const shared_ptr<SPftTraits> t)
{
	shared_ptr<SPftTraits> traits = std::make_shared<SPftTraits>(*t);
	return traits;
}
//-----------------------------------------------------------------------------
/**
 * Read definition of PFTs used in the simulation
 * @param file file containing PFT definitions
 * @param n default=-1;
 */
void SPftTraits::ReadPFTDef(const string& file) {
	//Open InitFile
	ifstream InitFile(file.c_str());
	if (!InitFile.good()) {
		cerr << ("Error while opening InitFile");
		exit(3);
	}
	// read the header line and skip it
	string line;
	getline(InitFile, line);
	while (getline(InitFile, line))
	{
		// get the trait data for each PFT
		std::stringstream ss(line);
		// create a structure for the traits
		shared_ptr<SPftTraits> traits = make_shared<SPftTraits>();
		ss >> traits->TypeID >> traits->name >> traits->MaxAge >> traits->AllocSeed >> traits->LMR
		>> traits->m0 >> traits->MaxMass >> traits->SeedMass
		>> traits->Dist >> traits->pEstab >> traits->Gmax >> traits->SLA
		>> traits->palat >> traits->memory >> traits->RAR
		>> traits->growth >> traits->mThres >> traits->clonal
		>> traits->PropSex >> traits->meanSpacerlength
		>> traits->sdSpacerlength >> traits->Resshare >>
		traits->AllocSpacer >> traits->mSpacer >> traits->herb >> traits->allocroot >> traits->allocshoot
		>> traits->EC50_biomass >> traits->slope_biomass
		>> traits->EC50_SEbiomass >> traits->slope_SEbiomass
		>> traits->EC50_survival >> traits->slope_survival
		>> traits->EC50_establishment >> traits->slope_establishment
		>> traits->EC50_sterility >> traits->slope_sterility
		>> traits->EC50_seednumber >> traits->slope_seednumber
		>> traits->FlowerWeek >> traits->DispWeek >> traits->GermPeriod >> traits->overwintering >> traits->comp_power;
		// add a new PFT to the list of PFTs
		SPftTraits::PftLinkList.insert(std::make_pair(traits->name, traits));
	}// end read all trait data for PFTs
}//read PFT defs
//-----------------------------------------------------------------------------
/* Author: Micheal Scott Crawford
 * Vary the current individual's traits, based on a Gaussian distribution with a
 * standard deviation of "ITVsd". Sub-traits that are tied will vary accordingly.
 * Bounds on 1 and -1 ensure that no trait garners a negative value and keep the resulting
 * distribution balanced. Other, trait-specific, requirements are checked as well. (e.g.,
 * LMR cannot be greater than 1, memory cannot be less than 1).
 */
void SPftTraits::varyTraits()
{
	// deviation
	double dev;
	double LMR_;
	do
	{
		//get the deviation from a gaussian distribution with a standard deviation of ITVsd
		dev = CEnvir::normrand(0, SRunPara::RunPara.ITVsd);
		// set the new value
		LMR_ = LMR + (LMR * dev);
		// make sure the value is ok
	} while (dev < -1.0 || dev > 1.0 || LMR_ < 0 || LMR_ > 1);
	LMR = LMR_;

	double m0_, MaxMass_, SeedMass_, Dist_;
	do
	{
		//get the deviation from a gaussian distribution with a standard deviation of ITVsd
		dev = CEnvir::normrand(0, SRunPara::RunPara.ITVsd);
		m0_ = m0 + (m0 * dev);
		// set the new value
		MaxMass_ = MaxMass + (MaxMass * dev);
		SeedMass_ = SeedMass + (SeedMass * dev);
		Dist_ = Dist - (Dist * dev);
		// make sure new value is ok
	} while (dev < -1.0 || dev > 1.0 || m0_ < 0 || MaxMass_ < 0 || SeedMass_ < 0 || Dist_ < 0);
	m0 = m0_;
	MaxMass = MaxMass_;
	SeedMass = SeedMass_;
	Dist = Dist_;

	double Gmax_;
	int memory_;
	do
	{
		//get the deviation from a gaussian distribution with a standard deviation of ITVsd
		dev = CEnvir::normrand(0, SRunPara::RunPara.ITVsd);
		// set the new values
		Gmax_ = Gmax + (Gmax * dev);
		memory_ = memory - (memory * dev);
		// make sure new values are ok
	} while (dev < -1.0 || dev > 1.0 || Gmax_ < 0 || memory_ < 1);
	Gmax = Gmax_;
	memory = memory_;

	double palat_, SLA_;
	do
	{
		//get the deviation from a gaussian distribution with a standard deviation of ITVsd
		dev = CEnvir::normrand(0, SRunPara::RunPara.ITVsd);
		// set the new values
		palat_ = palat + (palat * dev);
		SLA_ = SLA + (SLA * dev);
		// make sure new values are ok
	} while (dev < -1.0 || dev > 1.0 || palat_ < 0 || palat_ > 1 || SLA_ < 0);
	palat = palat_;
	SLA = SLA_;

	double meanSpacerlength_, sdSpacerlength_;
	do
	{
		//get the deviation from a gaussian distribution with a standard deviation of ITVsd
		dev = CEnvir::normrand(0, SRunPara::RunPara.ITVsd);
		// set the new value
		meanSpacerlength_ = meanSpacerlength + (meanSpacerlength * dev);
		sdSpacerlength_ = sdSpacerlength + (sdSpacerlength * dev);
		// make sure new value is ok
	} while (dev < -1.0 || dev > 1.0 || meanSpacerlength_ < 0
			|| sdSpacerlength_ < 0);
	meanSpacerlength = meanSpacerlength_;
	sdSpacerlength = sdSpacerlength_;
}

//eof
