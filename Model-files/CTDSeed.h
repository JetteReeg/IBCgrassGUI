/**\file
   \brief definition of toxico-dynamic seeds

 * CTDSeed.h
 *
 *  \since 13.02.2014
 *  \author KatrinK
 */

#ifndef CTDSEED_H_
#define CTDSEED_H_

#include "CTKmodel.h"
#include "CSeed.h"
#include "CTDPlant.h"
#include "Plant.h" //for struct CPftTraits


/*
 * Toxico Dynamic seeds
 * class includes all functions and processes regarding herbicide induced effects on seeds
 */
//! Class that describes herbicide impacts on seeds
class CTDSeed: public CTKmodel, public CSeed {
	//! constructor
	CTDSeed(double x, double y, CPlant* plant);

public:
	//! construct seed based on location, establishment probability and traits
	CTDSeed(double x, double y, double estab, shared_ptr<SPftTraits> traits);
	//! construct seed based establishment probability, traits and cell
	CTDSeed(double estab, shared_ptr<SPftTraits> traits,CCell* cell);
	//! construct seed based on plant and cell
	CTDSeed(CTDPlant* plant,CCell* cell);
	//! turn a normal seed into a CTD seed
	CTDSeed(CSeed* seed);
	//! destructor
	virtual ~CTDSeed();
	//! say what type you are
	virtual string type(){return "CTDSeed";};
	//! get (herbicide induced) establishment probability
	virtual double getpEstab();
	//! herbicide incuded mortality of established plant
	virtual double getpEstabMort();
	//! herbicide induced seed mortality
	virtual double getpMort(){return Cexposition->HerbSeedMort;};
	//! herbicide induced seedling mortality
	virtual double JuvBioRed(){return 1-Cexposition->SeedBioFac;};
	//! get herbicide profile of a plant/seed and append to history
    void GetProfile(int year);
    //! current herbicide exposition
    SEffProfile* Cexposition;
    //! get herbicide exposition -> if the seed was exposed
	double getHexposed() const {return Hexposed;}
	//! set herbicide exposition
	/**
	 * Set the exposition flag.
	 * if seed was exposed
	 * @param hexposed value of exposition (default=1)
	 */
	void setHexposed(double hexposed=1) {Hexposed = hexposed;}
	//! was seed exposed?
	bool wasHexposed(){return Hexposed>0;};
	//! herbicide exposition flag
	double Hexposed;
};

#endif /* CTDSEED_H_ */
