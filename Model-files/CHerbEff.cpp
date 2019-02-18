/**  \file
   \brief functions for IBC-grass herbicide version
*/
//---------------------------------------------------------------------------

#include "CHerbEff.h"
#include "CTDPlant.h"
#include "CTDSeed.h"
#include <iostream>
#include <map>
#include <cstdlib>
#include <string>
#include <utility>
#include <vector>
#include <algorithm>
//---------------------------------------------------------------------------
using namespace std;

string CHerbicideEffectEnv::EffectType=" ";


CHerbicideEffectEnv::CHerbicideEffectEnv()
:CGridEnvir(){}
//----------------------------------------------------------------------
CHerbicideEffectEnv::~CHerbicideEffectEnv(){
}
//----------------------------------------------------------------------
/**
 * Convert Plants and Seeds of older Versions to TD-Versions.
 * \note the new TD-Individuals have no herbicide history.
 */
void CHerbicideEffectEnv::convertInds2TD() {
	//transform inds to TD-Inds
	vector<CPlant*> temp;
	//for all plants
	for (plant_iter iter = this->PlantList.begin(); iter != PlantList.end();
			++iter) {
		CPlant* plant = *iter;
		if (plant->type()=="CTDPlant") continue;//do nothing and take next plant
		plant->getCell()->clear();
    	temp.push_back(new CTDPlant( plant));

		this->DeletePlant(plant);//delete incl list enries
		//delete plant;
	}
	//transform seeds to TD seeds
	long int nbseeds = 0;
	//for all cells
	for (unsigned int i = 0; i < SRunPara::RunPara.GetSumCells(); ++i) {
		//loop for all cells
		CCell* cell = CellList[i];
		vector<CSeed*> temp;
		//for all seeds
		unsigned int sbsize = cell->SeedBankList.size();
		for (unsigned int i = 0; i < sbsize; i++) {
			CSeed* seed = cell->SeedBankList[i]; // *iter;
			temp.push_back((CSeed*) (new CTDSeed(seed)));

			delete seed;
		}
		cell->SeedBankList = temp; //copy new list of objects to seed list
		nbseeds += cell->SeedBankList.size();
	}
}
//----------------------------------------------------------------------
/**
  Initiate new Run: reset grid and randomly set initial individuals.
*/
void CHerbicideEffectEnv::InitRun(){
  CGridEnvir::InitRun(); //CHerbicideEffectEnv::InitInds(string) is used
  //transform inds and seeds to TD-Inds and TD seeds
  convertInds2TD();
  //set PFT sensitivities according to PFT trait 'herb'
  for (map<string,long int>::iterator it=CEnvir::PftInitList.begin();it!=CEnvir::PftInitList.end();++it)
	CTKmodel::setPFTsensi(it->first);
}
//------------------------------------------------------------------------------
/**
  This function reads a file and initializes seeds on grid after
  file data.
  Each PFT on file gets 20 seeds randomly set on grid.
  \param file file name of PFT definitions
*/
void CHerbicideEffectEnv::InitInds(string file, int n){
	const int no_init_seeds=20;
	for (auto var = SPftTraits::PftLinkList.begin();
			var != SPftTraits::PftLinkList.end(); ++var) {
		shared_ptr<SPftTraits> traits=var->second;
	    //sew TKTD seeds
	    InitTDSeeds(traits,no_init_seeds);
	    PftInitList[traits->name]+=no_init_seeds;
	    SPftTraits::PftLinkList[traits->name]=traits;
	    this->PFTTraits[traits->name]=traits;
		}
}// end of function Initialisation based on PFT file
//----------------------------------------------------------------------
/**
Does time dependent trait-parameter change.

\note changed values only apply in the first week of a process per year after Tinit and start_week
\note plants are aging in this function
*/
void CHerbicideEffectEnv::setTraitChanges(){
	//go through all plants
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant){
		CTDPlant* plant = (CTDPlant*)*iplant;
	    //age them
	    plant->Ageing();
	    //get current effects
	    if (year>SRunPara::RunPara.Tinit & week==SRunPara::RunPara.week_start) plant->GetProfile(year);// effects are updated after the initial phase in the start_week
	   }// end for each plant
	// set effects for each seed
	unsigned int gridsize=SRunPara::RunPara.GetSumCells();
	if(year>SRunPara::RunPara.Tinit & week==SRunPara::RunPara.week_start){//die Effektprofile werden zu Beginn eines Jahres in der ersten Woche geupdated
		// loop over all cells
		for (unsigned int i=0; i<gridsize; ++i){
			CCell* cell = CellList[i];
			// loop over all seeds in that cell
			for (vector<CSeed*>::iterator j=cell->SeedBankList.begin();j!=cell->SeedBankList.end();++j){
				((CTDSeed*)*j)->GetProfile(year);//get effects of the year
				} // end for each seed in cell
			 } //end for each cell
	   }// end during herbicide period
} //end function to set time- and type-depending ParameterValues
//----------------------------------------------------------------------
/**
 * Randomly disperse seeds of a given PFT on grid.
 * @param traits PFT to seed
 * @param n number of seeds to disperse
 * @param estab germination rate of dispersed seeds
 */
void CHerbicideEffectEnv::InitTDSeeds(shared_ptr<SPftTraits> traits,
		 const int n, double estab) {
	   int x,y;
	   int SideCells=SRunPara::RunPara.CellNum;
	   // for each seed to disperse
	   for (int i=0; i<n; ++i){
		   // find cell
	       x=CEnvir::nrand(SideCells);
	       y=CEnvir::nrand(SideCells);
	       // set seed in cell
	       CCell* cell = CellList[x*SideCells+y];
	       new CTDSeed(estab,traits,cell);
	   }//for each seed to disperse
}// end InitTDSeeds
//----------------------------------------------------------------------
/**
 * Establishment of the winning seedling.
 * If herbicide acts after germination,
 * juveniles potentially suffer from herbicide (survival and biomass)
 *
 * @param seed seed that establishes
 */
void CHerbicideEffectEnv::EstabLott_help(CSeed* seed) {
	// only if not CTDSeed
	if(seed->type()!="CTDSeed"){
		CGrid::EstabLott_help(seed);
		cerr<<"seed is non-TD-type\n";
		return;
	}// end if not CTDSeed

	// new plant based on the seed
	CPlant* tempPlant = new CTDPlant((CTDSeed*)seed);
    tempPlant->setGenet(addGenet());
    // add to the plant list
    PlantList.push_back(tempPlant);

    // herbicide effect which acts on survival of established juveniles
    if(CEnvir::rand01()<((CTDSeed*)seed)->getpEstabMort())
    	tempPlant->dead=true;
    // herbicide effect which acts on biomass of established juveniles
    if(tempPlant->dead!=true)
    {
    	tempPlant->mshoot=tempPlant->mshoot*((CTDSeed*)seed)->JuvBioRed();
    }
}
//----------------------------------------------------------------------
/**
 * Create a new (plant produced) seed in a cell
 * @param plant plant which produced seed
 * @param cell cell of seed
 */
void CHerbicideEffectEnv::newSeed(CPlant* plant, CCell* cell) {
	// if not a CTDplant
	 if(plant->type()!="CTDPlant"){
		 //CGrid::set
		 new CSeed(plant, cell);
		 cerr<<"seed is non-TD-type\n";
		 return;
	 }// end if not CTDplant
	 // create new seed in cell
     new CTDSeed((CTDPlant*) plant,cell);
}
//----------------------------------------------------------------------
/***
 * Delete CTD Plant and remove from ramet list.
 * @param plant1 plant to remove
 */
void CHerbicideEffectEnv::DeletePlant(CPlant* plant1) {
    CGenet *Genet=((CTDPlant*)plant1)->getGenet();
    // loop over ramet list
    for (unsigned int j=0;j<Genet->AllRametList.size();j++)
    {
      CTDPlant* Ramet;
      Ramet=(CTDPlant*)Genet->AllRametList[j];
      if (plant1==Ramet)
        Genet->AllRametList.erase(Genet->AllRametList.begin()+j);
    }//for all ramets
    CGrid::DeletePlant(plant1);
}//delete CTDplant
//----------------------------------------------------------------------
/**
 * Overall seed mortality.
 * and call of herbicide-based mortality on seeds.
 */
void CHerbicideEffectEnv::SeedMort() {
    SeedMortHerb();
	CGrid::SeedMort();
}//end CHerbicideEffectEnv::SeedMort
//----------------------------------------------------------------------
/**
 * Herbicide induced seed mortality.
 * Each seed on grid is tested.
 */
void CHerbicideEffectEnv::SeedMortHerb() {
	// loop over all cells
	for (unsigned int i=0; i<SRunPara::RunPara.GetSumCells(); ++i){
		CCell* cell = CellList[i];
		// loop over all seeds in cell
	    for (seed_iter iter=cell->SeedBankList.begin(); iter!=cell->SeedBankList.end(); ++iter){
	    	CTDSeed* seed = (CTDSeed*) *iter;
	        // herbicide-based seed mortality
	        if (CEnvir::rand01()< seed->getpMort()){
	        	seed->remove=true;//mark for removal
	        } //if not seed survive
	        // set herbicide effect to zero as it acts only once
	        seed->Cexposition->HerbSeedMort=0.0;
	    }//for all seeds in cell
	    cell->RemoveSeeds();   //removes and deletes all seeds with remove==true
	}// for all cells
}// end CHerbicideEffectEnv::SeedMortHerb
//----------------------------------------------------------------------
/**
 * Adds time dependent trait-parameter change to the base function
 * of class CGridEnvir.
 * calls one week function
*/
void CHerbicideEffectEnv::OneWeek(){
//change trait Parameter (call function)
setTraitChanges();
//'normal' OneWeek()
CGridEnvir::OneWeek();
}// end CHerbicideEffectEnv::OneWeek

//----------------------------------------------------------------------
/**
 * Adds seed rain to the base function of class CGridEnvir and
 * calls base OneYear function
*/
void CHerbicideEffectEnv::OneYear(){
	//annual imigration of seeds to the simulated plot without focus species (same for each PFT)
	if (SRunPara::RunPara.seedsPerType>0){
		typedef map<string,long> mapType;
		// loop for each PFT
		for (mapType::const_iterator it = PftInitList.begin();
            it != PftInitList.end(); ++it){
			if (it->first!=CHerbicideEffectEnv::EffectType) // change if you want to have a focus PFT
				// distribute seeds for each PFT
				InitSeeds(it->first,SRunPara::RunPara.seedsPerType);
		} // end for each PFT
	}//end if migration
	/*//extra seed rain of focus type
	InitSeeds(CHerbicideEffectEnv::EffectType,CHerbicideEffectEnv::ETSeedRain);
	*/
	// start one base year
	CGridEnvir::OneYear();
}// end CHerbicideEffectEnv::OneYear
//----------------------------------------------------------------------
/**
 * Initiate seeds of a given PFT on grid.
 * @param type ID string of PFT to disperse
 * @param number number of seeds to disperse
 */
void CHerbicideEffectEnv::InitSeeds(string type, int number){
   //searching the type
   shared_ptr<SPftTraits> pfttraits=SPftTraits::getPftLink(type);
   // init seeds of the specific PFT
   InitTDSeeds(pfttraits,number,pfttraits->pEstab);
}//end CHerbicideEffectEnv::InitSeeds
//----------------------------------------------------------------------
/**
 * Start a new spacer of a clonal CTDPlant.
 * @param x coordinate on grid
 * @param y coordinate on grid
 * @param plant mother plant
 * @return address of new plant object
 */
CPlant* CHerbicideEffectEnv::newSpacer(const int x, const int y,
		CPlant* plant) {
	double CmToCell=1.0/SRunPara::RunPara.CellScale();
	if (plant->type()!="CTDPlant"){
		cerr<<"wrong plant type!\n";return NULL;}
	return new CTDPlant(x/CmToCell,y/CmToCell,(CTDPlant*)plant);
}

//eof
