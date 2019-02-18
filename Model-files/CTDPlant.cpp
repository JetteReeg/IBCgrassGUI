/**\file
   \brief functions of toxico-dynamic plants
 *
 * CTDPlant.cpp
 *
 */

#include "CTDPlant.h"
#include "LCG.h"
#include <iostream>
#include "CEnvir.h"
#include "CTDSeed.h"
//---------------------------------------------------------------------------
/**
 * destructor
 */
CTDPlant::~CTDPlant() {
	delete Cexposition;
}
//---------------------------------------------------------------------------
/**
  The new Plant inherits its parameters from 'plant'.
  Genet is the same as for plant, Generation is by one larger than
  that of plant.
  sets the plant to a CTD plant
  specific for herbicide version of IBCgrass
  @param x cell location on grid
  @param y cell location on grid
  @param plant plant
*/
CTDPlant::CTDPlant(double x, double y, CTDPlant* plant)
  :CPlant(x,y,plant),age(0),Hexposed(0)
{
	//ramet plant inherit profile from mother plant
	// if mother plant is affected and F1 generation should inherit the effects
	if (plant->Cexposition->isExposed() && SRunPara::RunPara.Generation=="F1") {
		// new plant will inherit the effects
		this->Cexposition=getProfileProxy(this->pft(),CEnvir::year);
	}
	//otherwise a new effect profile is created
	else this->Cexposition=new SEffProfile();
	// if mother plant was exposed set this plant to exposed
	if (plant->Hexposed!=0) this->setHexposed();
	// copy trait sets
	Traits = SPftTraits::copyTraitSet(plant->Traits);
	// set mshoot beginning shoot mass
	mshoot = Traits->m0;
	// set mroot to beginning root mass
	mroot = Traits->m0;
}// end constructor
//---------------------------------------------------------------------------
/**
 * constructor for
 * upgrading CPlant
 *
 * translates clonal plant (CPlant) into TD plant with specific age and herbicide history.
 * @param plant plant to upgrade
 */
CTDPlant::CTDPlant(CPlant* plant)
  :CPlant(plant->xcoord,plant->ycoord,plant),
   age(0),Hexposed(0)
{
	//set cell..
	this->setCell(plant->getCell());
	//set clonal variables
	this->setGenet(this->genet);
	this->Generation-=1;

	//TD parameters...
	//create an effect profile for the plant
	this->Cexposition=new SEffProfile();
}// end constructor
//---------------------------------------------------------------------------
/**
 * constructor
  If a seed germinates, the new plant inherits its parameters.
  Genet has to be defined externally.
  @param seed established seed
*/
CTDPlant::CTDPlant(CSeed* seed)
  :CPlant((CSeed*)seed),age(0),Hexposed(0)
{
	//plant inherits effects of seeds if F1 generation is included
	if(((CTDSeed*)seed)->Hexposed!=0 && SRunPara::RunPara.Generation=="F1") {
		// create a new profile with effects of the current year
		this->Cexposition=getProfileProxy(this->pft(),CEnvir::year);
	}
	// otherwise create an empty effect profile
	else this->Cexposition=new SEffProfile();
	// set traits
	Traits = SPftTraits::createTraitSetFromPftType(seed->Traits->name);
	// possibly vary traits
	Traits->varyTraits();
	// set initial shoot and root masses
	mshoot = Traits->m0;
	mroot = Traits->m0;
}

/**
 * get Plant's class type
 * @return 'CTDPlant'
 */
string CTDPlant::type(){
        return "CTDPlant";
}
//------------------------------------------------
/**
 * Get individual base mortality.
 * @return base mortality
 */
double CTDPlant::getMortBase() {
	return this->mort_base;
}
/**
 * Get individual herbicide induced mortality
 * @return herbicide mortality
 */
double CTDPlant::getMortHerb() {
	// get the herbicide induced mortality from effect profile of the plant
	double fac=this->Cexposition->SurvFac;
	// effect occurs only in one week per year
	this->Cexposition->SurvFac=0.0;
	return fac;
}
/**
 * set plant's individual base mortality
 * @param abundance species' abundance on grid
 * \warning param has different meaning from that of base class version (KK)
 */
void CTDPlant::setMortBase(double abundance) {
	//calculate the max area of a fully grown plant
	double m_area_root=Traits->RAR*
				  pow((Traits->MaxMass)*0.25,2.0/3.0);
	double m_area_shoot=Traits->SLA*
			      pow(Traits->LMR*(Traits->MaxMass)*0.25,2.0/3.0);
	// calculate the maximal abundance based on the parameters above
	double max_abundance=
		  (double)SRunPara::RunPara.GridSize*SRunPara::RunPara.GridSize/
		  min(m_area_root,
		  m_area_shoot);

	double mbase=0;
	// depending on the strength of density dependent mortality
	switch (SRunPara::RunPara.ModelVersion){
		//high
		case 1: mbase=0.007*
	    		(exp((4/max_abundance)*abundance)); break;
		//moderate
	    case 2: mbase=0.007*
	    		(exp((5/max_abundance)*abundance)); break;
	    //without
	    case 3: mbase=0.007; break;
	}// end switch
	//update mort_base value
	CPlant::setMortBase(mbase);
}// setMortBase
//------------------------------------------------
/**
 * Get portion of biomass reduction due to herbiced effect.
 * @return BM reduction factor
 */
double CTDPlant::AdBioRed() {
	// get the effect based on the effect profile
	double fac=this->Cexposition->growthFac;
	// reset the effect value as it occurs only in one week per year
	this->Cexposition->growthFac=0.0;
	return (1-fac);
}
//------------------------------------------------
/**
 * Get herbicide effect on seed production.
 * @return reduction factor to allocation to seeds
 */
double CTDPlant::AllocSeedRed() {
	double fac=0;
	//if plant was exposed to herbicide in this year
	if (this->Hexposed!=0)
	{
		// get the effect from effect profile
		fac=this->Cexposition->AllocSeedFac;
		//reset the effect as it occurs only in one week per year
		this->Cexposition->AllocSeedFac=0.0;
	}
	//
	return (1-fac);
}
//------------------------------------------------
/**
 * Get herbicide effect on seed production.
 * @return reduction factor to allocation to seeds
 */
double CTDPlant::AllocSpacerRed() {
	double fac = 0;
	//if plant was exposed to herbicide in this year
	if (this->Hexposed!=0)
		{
		// get the effect based on the effect profile
		fac=this->Cexposition->AllocSpacerFac;
		//reset the effect as it occurs only in one week per year
		this->Cexposition->AllocSpacerFac=0.0;
		}
	//cout<<"allocation factor: "<<fac<<endl;
	return (1-fac);
}
//---------------------------------------------------------------------------
/**
 * Get establishment probability of Ramets depending on PFT and herbicide application.
 * @return establishment probability
 */
double CTDPlant::getpEstabRamet(){
	double fac=0;
	// get the effect based on the effect profile
	fac=this->Cexposition->pEstabSpacerFac;
	//reset the effect as it occurs only in one week per year
	this->Cexposition->pEstabSpacerFac=0.0;
	return CPlant::getpEstabRamet()*(1-fac);
}
//--------------------------------------------------
/**
 * Get current Plant's effect profile
 * @param year current year
 */
void CTDPlant::GetProfile(int year)
{
	// save the old effect profile
	SEffProfile* tmp_old=this->Cexposition;
	// get the new effect profile
	SEffProfile* tmp_new=getProfileProxy(this->pft(),year);
	// only refresh if new effect profile is stronger than the old one
	if(tmp_new->exposure_strength()>=tmp_old->exposure_strength()){
		this->Cexposition=tmp_new;
		delete tmp_old;
	}
	//otherwise keep the old
	else
	{
		this->Cexposition=tmp_old;
		delete tmp_new;
	}
	// if plant is exposed mark it as exposed
	if (this->Cexposition->isExposed()) this->setHexposed();
}

//eof
