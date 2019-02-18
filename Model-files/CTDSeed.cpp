/**\file
   \brief functions of toxico-dynamic seeds
 *
 * CTDSeed.cpp
 *
 */

//! herbicide effect on seed germination; set false if established seedling should be affected
#define EFFECT_BEVORE_THINNING true

#include "CTDSeed.h"
#include <iostream>
#include "CEnvir.h"
//---------------------------------------------------------------------------
/**\brief destructor
 * delete resources at heap..
 */
CTDSeed::~CTDSeed() {
	delete this->Cexposition;
}
//---------------------------------------------------------------------------
/**\brief constructor
 * Transform a CclonalSeed to CDTSeed.
 * @param seed Seed to transform
 */
CTDSeed::CTDSeed(CSeed* seed)
  :CSeed(seed->estab,seed->Traits,seed->getCell()),
   Cexposition(NULL),Hexposed(0)
{
	// create a new effect profile
	Cexposition=new SEffProfile();
	// set traits
	this->Traits = SPftTraits::createTraitSetFromPftType(seed->Traits->name);
}
//---------------------------------------------------------------------------
/**\brief constructor
 *
 * @param x x coordinate on grid
 * @param y y coordinate on grid
 * @param estab weekly germination rate
 * @param traits link to PFT definition
 *
 */
CTDSeed::CTDSeed(double x, double y, double estab,
		shared_ptr<SPftTraits> traits)
  :CSeed(x,y,estab,traits),Cexposition(NULL),Hexposed(0)
{
	// create a new effect profile
	Cexposition=new SEffProfile();
	// set traits
	this->Traits = SPftTraits::createTraitSetFromPftType(traits->name);
}
//---------------------------------------------------------------------------
/**\brief constructor
 * Used in initialisation to set initial seed bank.
 *
 * @param estab weekly germination rate
 * @param traits link to PFT definition
 * @param cell link to position on grid (i.e. cell containing seed)
 */
CTDSeed::CTDSeed(double estab,
	shared_ptr<SPftTraits> traits,  CCell* cell)
 :CSeed(estab,traits,cell),Cexposition(NULL),Hexposed(0)
{
	// create a new effect profile
	Cexposition=new SEffProfile();
	// set traits
	this->Traits = SPftTraits::createTraitSetFromPftType(traits->name);
}
//---------------------------------------------------------------------------
/**\brief constructor
 * Generates a seed as produced by a plant. SeedSet
 * @param plant mother plant
 * @param cell dropping cell
 * @param Cexposition inherit exposed from mother plant
 */
CTDSeed::CTDSeed(CTDPlant* plant,CCell* cell):
		CSeed(plant,cell),Cexposition(NULL),Hexposed(0)
{
	// if mother plant was exposed and seed should inherit the effects
 	if (plant->Cexposition->isExposed() && SRunPara::RunPara.Generation=="F1") {
 		// set the effect profile of the seed to the one of the mother
 		Cexposition=getProfileProxySeeds(this->pft(),CEnvir::year);
 	}
 	// otherwise create a new effect profile
	else Cexposition=new SEffProfile();
 	//if mother plant was exposed, seed is marked
 	if (plant->Hexposed!=0) this->setHexposed();
 	// set traits
 	this->Traits = SPftTraits::createTraitSetFromPftType(plant->Traits->name);
}
//---------------------------------------------------------------------------
/**
 * Get germination rate depending on PFT and herbicide application.
 * If the effect should act on the winning seedling \sa getpEstabMort.
 * @return germination probability
 */
double CTDSeed::getpEstab(){
	double fac=0;
	// herbicide acts before establishment lottery (not on the winning seedling, only on germination)
	if (EFFECT_BEVORE_THINNING) {
		// get the effect from effect profile
		fac=this->Cexposition->pEstabSeedFac;
		// reset the effect as it occurs only in one week per year
		this->Cexposition->pEstabSeedFac=0.0;
	}
	return CSeed::getpEstab()*(1-fac);
}
//---------------------------------------------------------------------------
/**
 * Return the mortality for the winning seedling,
 * if the herb effect acts on it.
 * \sa getpEstab
 * @return winning seedling mortality rate
 */
double CTDSeed::getpEstabMort() {
	double fac=0;
	// herbicide acts AFTER establishment lottery (ONLY on the winning seedling)
	if (!EFFECT_BEVORE_THINNING) {
		// get the effect based on the current effect profile
		fac=this->Cexposition->pEstabSeedFac;
		// reset the effect as it occurs only in one week per year
		this->Cexposition->pEstabSeedFac=0.0;
	}
	return fac;
}
//---------------------------------------------------------------------------
/**
 * get effect profile for specific PFT, year and week
 * \note very time consuming - optimize!
 * @param year current year
 */
void CTDSeed::GetProfile(int year)
{
	// save old profile
	SEffProfile* tmp_old=this->Cexposition;
	// get the new profile
	SEffProfile* tmp_new=getProfileProxySeeds(this->pft(),year);
	// keep the profile with the stronger values and delete the other one
	if(tmp_new->exposure_strength()>=tmp_old->exposure_strength()){
		this->Cexposition=tmp_new;
		delete tmp_old;
	}
	else{
		this->Cexposition=tmp_old;
		delete tmp_new;
	}
	// mark seed if it is exposed
	if (this->Cexposition->isExposed()) this->setHexposed();
}

//eof
