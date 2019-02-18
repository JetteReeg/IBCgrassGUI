/**\file
   \brief definition of toxico-dynamic plants
 *
 * CTDPlant.h
 *
 *  \since 07.02.2014
 *  \author KatrinK
 */

#ifndef CTDPLANT_H_
#define CTDPLANT_H_

#include "CTKmodel.h"
#include "Plant.h"

/*
 * Toxico Dynamic plants
 * class includes all processes affecting plants due to herbicide induced impacts
 */
//! Class that describes herbicide impacts on plants
class CTDPlant: public CTKmodel, public CPlant {
	//! get base mortality
	virtual double getMortBase();
	//! get herbicide induced mortality
	virtual double getMortHerb();
	//! set base mortality
	virtual void setMortBase(double);
	//! get herbicide induced biomass reduction
	virtual double AdBioRed();
	//! get herbicide induced reduction of resource allocation to seeds
	virtual double AllocSeedRed();
	//! get herbicide induced reduction of resource allocation to spacer
	virtual double AllocSpacerRed();
public:
	//! age in weeks
	int age;
	//! current herbicide exposition
	SEffProfile* Cexposition;
	//! herbicide exposition flag;
	double Hexposed;
	//! make a plant from a seed object
	CTDPlant(CSeed* seed);
	//! make a CTD plant from a normal plant
	CTDPlant(double x, double y, CTDPlant* plant);
	//! no predefined values - translate CPlant to CDTPlant
	CTDPlant(CPlant* plant);
	//! destructor
	virtual ~CTDPlant();
	//! say what type you are
	virtual string type();
	//! aging of a plant (weekly)
	void Ageing(){age++;};
	//! get current age of a plant
	int GetAge(){return age;};
	//! get current herbicide profile (currently only per year)
	void GetProfile(int year);
	//! ask if plant was exposed to herbicide
	double getHexposed() const {return Hexposed;}
	//! set herbicide exposition
	/**
	 * Set the exposition flag.
	 * saying that plant was exposed
	 * @param hexposed value of exposition (default=1)
	 */
	void setHexposed(double hexposed=1) {Hexposed = hexposed;}
	//! was plant exposed?
	bool wasHexposed(){return Hexposed>0;};
	//! get (herbicide induced) establishment probability for ramets
	virtual double getpEstabRamet();
};

#endif /* CTDPLANT_H_ */
