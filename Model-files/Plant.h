#ifndef PlantH
#define PlantH

#include <math.h>
#include "CObject.h"
#include "CGenet.h"
#include "RunPara.h"
#include "SPftTraits.h"
#include <vector>
using namespace std;
//---------------------------------------------------------------------------
const double Pi=3.14159265358979323846;
//---------------------------------------------------------------------------
//! Structure to store all PFT Parameters
//! Class that describes seed individuals
class CSeed;class CCell;class CGenet;
//! Class that describes plant individuals
class CPlant : public CObject
{
protected:
	//! cell of the stem of the plant
	CCell* cell;      ///<cell where it sits
	//! resource allocation to reproduction + reproductive growth
	virtual double ReproGrow(double uptake);
	//! shoot growth function
	virtual double ShootGrow(double shres);
	//! root growth function
	virtual double RootGrow(double rres);
	//! resources for ramet growth
	double mReproRamets;
	//! genet of the clonal plant
	CGenet* genet;
public:
	//! PFT Traits
	shared_ptr<SPftTraits> Traits;
	//! Variable that takes track of plant age yearly!
	int Age;
	//! location of plant's central point
	double xcoord;
	//! location of plant's central point
	double ycoord;
	//! shoot mass
	double mshoot;
	//! root mass
	double mroot;
	//! reproductive mass (which is converted to seeds)
	double mRepro;
	//! discrete above-ground ZOI area [number of cells covered * area of one cell]
	double Ash_disc;
	//! discrete below-ground ZOI area [number of cells covered * area of one cell]
	double Art_disc;
	//! area of all species' roots in ZOI
	double Aroots_all;
	//! area of all PFT's roots in ZOI
	double Aroots_type;
	//! uptake of above-ground resource in one time step
	double Auptake;
	//! uptake below-ground resource one time step
	double Buptake;
	//!plant dead or alive?
	bool dead;
	// trampled or not - should the plant be removed?
	bool remove;
	//! counter for weeks with resource stress exposure
	int stress;
	//! pft-density - based base mortality (annually updated in CEnvir::GetOutput())
	double mort_base;
//--clonal..
	//! List of growing Spacer
	vector<CPlant*> growingSpacerList;
	//! real spacer length
	double Spacerlength;
	//! spacer direction
	double Spacerdirection;
	//! length to grow
	double SpacerlengthToGrow;
	//! clonal generation
	int Generation;
//functions
	//! constructor for plant objects
	CPlant(double x, double y,shared_ptr<SPftTraits> Traits);
	//! make a plant from a seed object
	CPlant(CSeed* seed);
	//! destructor
	virtual ~CPlant();
	//! initalization of one plant on specific location
	CPlant(double x, double y, CPlant* plant);
//---
	//! get type of plant
	virtual string type();
	//! get PFT name of plant
	virtual string pft();
//-2nd order properties
	//! ZOI area aboveground
	double Area_shoot();
	//! ZOI area belowground
	double Area_root();
	//! ZOI radius aboveground
	double Radius_shoot();
	//! ZOI radius belowground
	double Radius_root();
	//! growth
	virtual double dmGrow(double Assim, double Resp);
//-- herbicide effects
	//! herbicide effect: reduction in biomass
	virtual double AdBioRed(){return 1.0;};
	//! herbicide effect: reduction in resource allocation to seed production
	virtual double AllocSeedRed(){return 1.0;};
	//! herbicide effect: reduction in resource allocation to spacer production
	virtual double AllocSpacerRed(){return 1.0;};
//--
	//! competition coefficient for a plant -needed for AboveComp and BelowComp
	double comp_coef(const int layer,const int symmetry)const;
	//!  return true if plant is stressed
	virtual bool stressed();
	//! lower threshold of aboveground resource uptake (light stress thresh.)
	virtual double minresA(){return Traits->mThres*Ash_disc*Traits->Gmax;}
	//! lower threshold of belowground resource uptake (nutrient stress thresh.)
	virtual double minresB(){return Traits->mThres*Art_disc*Traits->Gmax;}
	//! shoot-root resource allocation and plant growth in two layers
	virtual void Grow();
	//! Mortality due to resource shortage or at random
	virtual void Kill();
	//! calculate mass decomposition of dead plants
	void DecomposeDead();
	//! removal of above-ground biomass in winter
	void WinterLoss();
	//! removal of plants not able to overwinter (for annual plants)
	void Overwintering();
	//! removal of above-ground biomass by grazing
	double RemoveMass();
//getters and setters...
	//! define cell for plant
	void setCell(CCell* cell);
	//! returns central cell
	inline CCell* getCell(){return cell;};
	//! returns plant mass
	inline double GetMass(){return mshoot+mroot+mRepro;};
	//! returns number of seeds of one plant individual
	virtual int GetNSeeds();
	//! set genet and add ramet to its list
	void setGenet(CGenet* genet);
	//! get the genet
	CGenet* getGenet(){return genet;};
	//! spacer growth
	void SpacerGrow();
	//! return number of ramets
	virtual int GetNRamets();
//-----------------------------------------------------------------------------
//functions that are used for STL algorithms (sort + partition)
	//! return true if plant should be removed (necessary to apply algorithms from STL)
	bool GetPlantRemove(){return (!this->remove);};
	//! sort plant individuals descending after shoot size * palatability
	static bool ComparePalat(const CPlant* plant1, const CPlant* plant2)
	{
	  return ((plant1->mshoot*plant1->Traits->GrazFac())
		 > (plant2->mshoot*plant2->Traits->GrazFac()));
	};
//-----------------------------------------------------------------------------
	//! sort plants descending after shoot size (mass*1/LMR)
	static bool CompareShoot(const CPlant* plant1, const CPlant* plant2)
	{
		return ((plant1->mshoot/plant1->Traits->LMR)
		  > (plant2->mshoot/plant2->Traits->LMR));
	};
//-----------------------------------------------------------------------------
   //! sort plants descending after root mass
   static bool CompareRoot(const CPlant* plant1, const CPlant* plant2)
   {
	  return ((plant1->mroot) > (plant2->mroot));
   };
//-----------------------------------------------------------------------------
	/**
	 * get constant base mortality
	 * @return base mortality
	 */
	virtual double getMortBase(){return mort_base;};
//-----------------------------------------------------------------------------
	/**
	 * get herbicide mortality
	 * @return herbicide mortality
	 */
	virtual double getMortHerb(){return 0;};
//-----------------------------------------------------------------------------
	/**
	 * set base mortality
	 * @param mortBase
	 */
	virtual void setMortBase(double mortBase) {
			mort_base = mortBase;
		};
//-----------------------------------------------------------------------------
	//! get current ramet establishment probability
	virtual double getpEstabRamet();
};
//---------------------------------------------------------------------------
#endif
