/**\file
 * \brief class for plant processes
*/
//---------------------------------------------------------------------------
#include <iostream>
#include <sstream>
#include <cstdlib>

#include "Plant.h"
#include "CTDPlant.h"
#include "CEnvir.h"
//---------------------------------------------------------------------------
/**
 * constructor
 * @param x location on grid
 * @param y location on grid
 * @param Traits trait characteristics
 */
CPlant::CPlant(double x, double y, shared_ptr<SPftTraits> Traits):
  xcoord(x),ycoord(y),Traits(Traits),Age(0),mshoot(Traits->m0),mroot(Traits->m0),
  Aroots_all(0),Aroots_type(0),mRepro(0),Ash_disc(0),Art_disc(0),
  Auptake(0),Buptake(0),dead(false),remove(false),stress(0),mort_base(0.007),cell(NULL),
  mReproRamets(0),Spacerlength(0),Spacerdirection(0),
  Generation(1),SpacerlengthToGrow(0),genet(NULL)
{
	growingSpacerList.clear();
} // end constructor
//-----------------------------------------------------------------------------
/**
 * constructor - germination
 *
 * If a seed germinates, the new plant inherits its parameters.
 * Genet has to be defined externally.
 * @param seed seed to be established
 */
CPlant::CPlant(CSeed* seed):
  xcoord(seed->xcoord),ycoord(seed->ycoord),Age(0),Traits(seed->Traits),
  mshoot(seed->Traits->m0),mroot(seed->Traits->m0),
  Aroots_all(0),Aroots_type(0),mRepro(0),Ash_disc(0),Art_disc(0),
  Auptake(0),Buptake(0),dead(false),remove(false),stress(0),mort_base(0.007),cell(NULL),
  mReproRamets(0),Spacerlength(0),Spacerdirection(0),
  Generation(1),SpacerlengthToGrow(0),genet(NULL)
{
	//establish this plant on cell
	setCell(seed->getCell());
	if (cell){
		xcoord=(cell->x*SRunPara::RunPara.CellScale());
		ycoord=(cell->y*SRunPara::RunPara.CellScale());
	}
	growingSpacerList.clear();
} // end constructor
//-----------------------------------------------------------------------------
/**
  Clonal Growth - The new Plant inherits its parameters from 'plant'.
  Genet is the same as for plant, Generation is by one larger than
  that of plant.

  @param x location on grid
  @param y location on grid
  @param plant plant

  \note For clonal growth:
  cell has to be set and plant has to be added to genet list
  when ramet establishes.
*/
CPlant::CPlant(double x, double y, CPlant* plant):
  xcoord(x),ycoord(y),Traits(plant->Traits),Age(0),
  mshoot(plant->Traits->m0),mroot(plant->Traits->m0),
  Aroots_all(0),Aroots_type(0),mRepro(0),Ash_disc(0),Art_disc(0),
  Auptake(0),Buptake(0),dead(false),remove(false),stress(0),mort_base(0.007),cell(NULL),
  mReproRamets(0),Spacerlength(0),Spacerdirection(0),
  Generation(plant->Generation+1),SpacerlengthToGrow(0),genet(plant->genet)
{
	growingSpacerList.clear();
}// end clonal growth constructor
//---------------------------------------------------------------------------
/**
 * destructor
 */
CPlant::~CPlant(){
	for (unsigned int i=0;i<growingSpacerList.size();++i)
		delete growingSpacerList[i];
	growingSpacerList.clear();
}
//---------------------------------------------------------------------------
/**
 * set genet and add ramet to its list
 * @param genet genet of the plant
 */
void CPlant::setGenet(CGenet* genet){
	if (this->genet==NULL){
		this->genet=genet;
		this->genet->AllRametList.push_back(this);
	}
}//end setGenet
//---------------------------------------------------------------------------
/**
 * join cell to plant object
 *
 * \param cell current cell
 */
void CPlant::setCell(CCell* cell){
	if (this->cell==NULL&&cell!=NULL){
		this->cell=cell;
		this->cell->occupied=true;
		this->cell->PlantInCell = this;
	}
}//end setCell
//-----------------------------------------------------------------------------
/**
 * say what type you are
 */
string CPlant::type(){
	return "CPlant";
}
//-----------------------------------------------------------------------------
/**
 * Say, what PFT you are
 * @return PFT name
 */
string CPlant::pft(){
	return this->Traits->name;
}   // end pft
//---------------------------------------------------------------------------
/**
 * Growth of reproductive organs (seeds and spacer).
 *
 * Function adapted to annual plants with AllocSeed of 1.
 * @param uptake Resource uptake of plant object.
 * @return resources available for individual needs.
 * \author FM, IS adapted by HP
 * \note no 'respiration' costs for reproduction
 */
double CPlant::ReproGrow(double uptake) {
	double SpacerRes, SeedRes, VegRes, dm_seeds, dummy1;
	//fixed Proportion of resource to seed production
	if (mRepro <= Traits->AllocSeed * mshoot)
	{
		// get resources allocated to seeds
		SeedRes = uptake * Traits->AllocSeed;
		// get resources allocated to spacers
		SpacerRes = uptake * Traits->AllocSpacer;
		// current week
		int pweek = CEnvir::week;
		//during the seed-production-weeks
		if ((pweek >= Traits->FlowerWeek) &&
				(pweek < Traits->DispWeek) &&
				(((CTDPlant*)this)->GetAge() > 5)
			) {
			// seed production
			dm_seeds = dmGrow( Traits->growth * SeedRes,0);
			mRepro += dm_seeds;

			// clonal growth
			// for large AllocSeed, ressources may be < SpacerRes, then only take remaining ressources
			dummy1 = max(0.0, min(SpacerRes, uptake - SeedRes));
			mReproRamets += dmGrow( Traits->growth * dummy1,0);
			// calculate resources left for vegetative growth
			VegRes = uptake - SeedRes - dummy1;
		} else {
			// just do vegetative reproduction
			VegRes = uptake - SpacerRes;
			mReproRamets += dmGrow(Traits->growth * SpacerRes,0);
			}// end else
	} else // if there are already enough resources for seeds
		VegRes = uptake;
	// finally return resources for vegetative growth
	return VegRes;
} //end reprogrow
//-----------------------------------------------------------------------------
/**
 * Growth of the spacer.
 */
void CPlant::SpacerGrow()
{
	double mGrowSpacer=0;
	int SpacerListSize=this->growingSpacerList.size();

	if (SpacerListSize==0)return;
	// if there are resources for ramet growth
	if ((mReproRamets>0))
	{
		// possible reduction by herbicide
		mReproRamets*=AllocSpacerRed();
		// resources for one spacer
		mGrowSpacer=(mReproRamets/SpacerListSize);//resources for one spacer
		//loop for all growing Spacer of one plant
		for (int g=0; g<(SpacerListSize); g++)
		{
			// link to spacer
			CPlant* Spacer = this->growingSpacerList[g];
			// grow spacer
			double lengthtogrow=Spacer->SpacerlengthToGrow;
			lengthtogrow-=(mGrowSpacer/Traits->mSpacer);
			Spacer->SpacerlengthToGrow=max(0.0,lengthtogrow);

			// Establishment for all growing Spacers in the last week of the year
			if ((CEnvir::week==CEnvir::WeeksPerYear)
					&& (Spacer->SpacerlengthToGrow>0))
			{
				// get cell to establish in
				double direction=Spacer->Spacerdirection;
				double complDist=Spacer->Spacerlength;//should be positive
				double dist=(complDist-Spacer->SpacerlengthToGrow);
				double CmToCell=1.0/SRunPara::RunPara.CellScale();
				int x2=CEnvir::Round(this->cell->x+cos(direction)*dist*CmToCell);
				int y2=CEnvir::Round(this->cell->y+sin(direction)*dist*CmToCell);
				//boundary condition
				Boundary(x2,y2);

				Spacer->xcoord=x2/CmToCell;
				Spacer->ycoord=y2/CmToCell;
				Spacer->SpacerlengthToGrow=0;
			}  //end if pweek==WeeksPerYear
		}   //end List of Spacers
	}// end if resources
	// reset resources
	mReproRamets=0;
} //end SpacerGrow
//-----------------------------------------------------------------------------
/**
 * Calculates net growth as difference of assimilation and respiration.
 * Negative net growth is prohibited.
 *
 * @param Assim assimilated biomass
 * @param Resp biomass costs
 * @return net difference with zero minimum
 */
double CPlant::dmGrow(double Assim, double Resp)
{
	return max(0.0,Assim-Resp);
}//dmGrow
//-----------------------------------------------------------------------------
/**
  two-layer growth
  -# Resources for fecundity are allocated
  -# According to the resources allocated and the respiration needs
  shoot- and root-growth are calculated.
  -# Stress-value is in- or decreased according to the uptake

  adapted growth formula with correction factor for the conversion rate
  \function dm/dt = growth*(c*m^p - m^q / m_max^r)
*/
void CPlant::Grow()
{
	double dm_shoot, dm_root,alloc_shoot;
	double LimRes, ShootRes, RootRes, VegRes, ShootRes_tmp2, ShootRes_tmp, RootRes_tmp, RootRes_tmp2;
	//! function:
	/********************************************/
	/*  dm/dt = growth*(c*m^p - m^q / m_max^r)  */
	/********************************************/
	// which resource is limiting growth ?
	LimRes=min(Buptake,Auptake);
	// only take the limiting resource
	VegRes=ReproGrow(LimRes);
	//allocation to shoot and root growth
	alloc_shoot= Buptake/(Buptake+Auptake);
	// resources for shoot growth
	ShootRes=alloc_shoot*VegRes;
	// resources for root growth
	RootRes =VegRes-ShootRes;
	// calculate new allocation according to PFT traits allocroot/allocshoot
	ShootRes_tmp2=ShootRes;
	RootRes_tmp2=RootRes;

	ShootRes_tmp = ShootRes*this->Traits->allocroot;
	RootRes_tmp = RootRes*this->Traits->allocshoot;
	// if lower shoot growth
	if(ShootRes_tmp<ShootRes) {
	   RootRes_tmp2=RootRes+(ShootRes-ShootRes_tmp);
	   ShootRes_tmp2=ShootRes_tmp;
	}
	// if lower root growth
	if(RootRes_tmp<RootRes) {
   	   ShootRes_tmp2=ShootRes+(RootRes-RootRes_tmp);
   	   RootRes_tmp2=RootRes_tmp;
    }
	// update resources
	ShootRes = ShootRes_tmp2;
	RootRes = RootRes_tmp2;
	//Shoot growth
	dm_shoot=this->ShootGrow(ShootRes);
	//Root growth
	dm_root=this->RootGrow(RootRes);
	// update shoot mass
	// including potential herbicide effects (acts only on gain!)
	mshoot+=dm_shoot*AdBioRed();
	// update root mass
	mroot+=dm_root;
	// check if plant is stressed
	if (stressed())++stress;
	else if (stress>0) --stress;
} // end grow()
//----------------------------------------------------------------------
/**
     shoot growth
     dm/dt = growth*(c*m^p - m^q / m_max^r)
     @param shres resources for shoot growth
*/
double CPlant::ShootGrow(double shres){
	double Assim_shoot, Resp_shoot;
	// growth function exponents
	double p=2.0/3.0, q=2.0, r=4.0/3.0;
	// growth limited by maximal resource per area -> similar to uptake limitation
	Assim_shoot=Traits->growth*min(shres,Traits->Gmax*Ash_disc);
	// respiration proportional to mshoot^2
	Resp_shoot=Traits->growth*Traits->SLA
              *pow(Traits->LMR,p)*Traits->Gmax
              *pow(mshoot,q)/pow(Traits->MaxMass,r);
	// return mass gain
	return max(0.0,Assim_shoot-Resp_shoot);
}
//----------------------------------------------------------------------
/**
    root growth
    dm/dt = growth*(c*m^p - m^q / m_max^r)
    @param rres resources for root growth
*/
double CPlant::RootGrow(double rres){
	double Assim_root, Resp_root;
	// exponents for growth function
	double q=2.0, r=4.0/3.0;
	// growth limited by maximal resource per area -> similar to uptake limitation
	Assim_root=Traits->growth*min(rres,Traits->Gmax*Art_disc);
	// respiration proportional to root^2
	Resp_root=Traits->growth*Traits->Gmax*Traits->RAR
			*pow(mroot,q)/pow(Traits->MaxMass,r);
	// return mass gain
	return dmGrow(Assim_root,Resp_root);
}
//----------------------------------------------------------------------
/**
    identify resource stressing situation
    \return true if plant is stressed
*/
bool CPlant::stressed(){
	return (Auptake/2.0<minresA())
    	|| (Buptake/2.0<minresB());
}
//-----------------------------------------------------------------------------
/**
 * Calculate weekly individual mortality.
 * We assume an base mortality of 0.007 and add a stress dependent mortality.
 * This is a stochastic process (mortality rate is interpreted as probability here).
 * If the Plant is killed, it gets the status dead=true.
 * Subsequently the litter gets decomposed weekly.
 *
 * */
void CPlant::Kill()
{
	// get base mortality (can be density dependent based on ModelVersion parameter
	const double pmin=getMortBase();
	// probability is the sum of stress mortality and random mortality
	double pmort= (double)stress/Traits->memory  + pmin;
	if (CEnvir::rand01()<pmort) dead=true;
	// potential herbicide induced mortality
	double pherb=getMortHerb();
	if (CEnvir::rand01()<pherb) dead=true;
}
//-----------------------------------------------------------------------------
/**
 * Litter decomposition with deletion at 10mg.
 */
void CPlant::DecomposeDead()
{
	// mass at which dead plants are removed
	const double minmass=10;
	// decomposition rate
	const double rate=SRunPara::RunPara.LitterDecomp;
	// if plant is dead...
	if (dead)
	{
		mRepro=0;
		mshoot*=rate;
		mroot*=rate;
		if (GetMass() < minmass) remove=true;
	}
}//end DecomposeDead
//-----------------------------------------------------------------------------
/**
  If the plant is alive and it is dispersal time, the function returns
  the number of seeds produced during the last weeks.
  Subsequently the allocated resources are reset to zero.
*/
int CPlant::GetNSeeds()
{
	int NSeeds=0;
	//proportion of reproductive biomass that are seeds
	double prop_seed=1.0;
	// if plant is not dead
	if (!dead){
		// and if dispersal week + there is reproductive mass
		if ((mRepro>0)&&(CEnvir::week>Traits->DispWeek)){
			mRepro*=AllocSeedRed();
			// calculate number of seeds
			NSeeds=floor(mRepro*prop_seed/Traits->SeedMass);
			// reset reproductive mass
			mRepro=0;
			// for annual plants
			int MaxAge = this->Traits->MaxAge - 1;
			if (Age >= MaxAge) {
				this->dead=true;
			}// kill senescent plants after they reproduced the last time
		}//end seed production
	}//end if not dead
	//return number of seeds
	return NSeeds;
}// end get number of seeds
//------------------------------------------------
/**
returns the number of new spacer to set: currently
 - 1 if there are clonal-growth-resources and spacer-lisdt is empty, and
 - 0 otherwise
\return the number of new spacer to set
Unlike CPlant::GetNSeeds() no resources are reset due to ongoing growth
*/
int CPlant::GetNRamets()
{
	// if there is reproductive mass and the plant is still alive but has no spacer yet..
	if ((mReproRamets>0)
         &&(!dead)
         &&(growingSpacerList.size()==0))
		// add one ramet
        return 1;
	// otherwise return 0
	return 0;
}
//-----------------------------------------------------------------------------
/**
  Remove half shoot mass and seed mass from a plant.
	for grazing
*/
double CPlant::RemoveMass()
{
	double mass_removed=0;
	//proportion of mass removed (0.5)
	const double prop_remove=SRunPara::RunPara.BitSize;
	if (mshoot+mRepro>1){   //only remove mass if shoot mas > 1mg
		  mass_removed=prop_remove*mshoot+mRepro;
		  mshoot*=1-prop_remove;
		  mRepro=0;
	}
	return mass_removed;
}//end removeMass
//-----------------------------------------------------------------------------
/**
 * Winter dieback of aboveground biomass. Ageing of Plant.
 */
void CPlant::WinterLoss()
{
	// portion of biomass to be removed during winter
	double prop_remove=SRunPara::RunPara.DiebackWinter;
	mshoot*=1-prop_remove;
	mRepro=0;
	// aging of plant (yearly)
	Age++;
}//end WinterLoss
//-----------------------------------------------------------------------------
/**
 * Overwintering of plants
 */
void CPlant::Overwintering()
{
	// kill plants which die over winter
	if (this->Traits->overwintering==0)this->dead=true;
}//end Overwintering
//-----------------------------------------------------------------------------
/**
 * get the radius of the shoot
 */
double CPlant::Radius_shoot(){
   return sqrt(Traits->SLA*pow(Traits->LMR*mshoot,2.0/3.0)/Pi);
}
//-----------------------------------------------------------------------------
/**
 * get the radius of the root
 */
double CPlant::Radius_root(){
   return sqrt(Traits->RAR*pow(mroot,2.0/3.0)/Pi);
}
//-----------------------------------------------------------------------------
/**
 * get the area of the shoot
 */
double CPlant::Area_shoot(){
  return Traits->SLA*pow(Traits->LMR*mshoot,2.0/3.0);
}
//-----------------------------------------------------------------------------
/**
 * get the area of the root
 */
double CPlant::Area_root(){
  return Traits->RAR*pow(mroot,2.0/3.0);
}
//-----------------------------------------------------------------------------
/**
 * Competitive strength of plant.
 * @param layer above- (1) or belowground (2) ZOI
 * @param symmetry Symmetry of competition
 * (symmetric, partial asymmetric, complete asymmetric )
 *
 * @return competitive strength
 */
double CPlant::comp_coef(const int layer, const int symmetry)const{
	switch (symmetry){
     	 case 1: if (layer==1) return Traits->Gmax;
             	 if (layer==2) return Traits->Gmax;break;
             	 break;
     	 case 2: if (layer==1) return mshoot*Traits->CompPowerA();
             	 if (layer==2) return mroot *Traits->CompPowerB();break;
             	 break;
     	 default: cerr<<"CPlant::comp_coef() - wrong input"; exit(3);
	}
	return -1;
}//end comp_coef
//-----------------------------------------------------------------------------
/**
 * get current establishment probability for ramets
 */
double CPlant::getpEstabRamet(){
	return SRunPara::RunPara.EstabRamet;
};
//-eof----------------------------------------------------------------------------



