/**\file
   \brief functions of class CGridEnvir
*/

#include "CGridEnvir.h"
#include "CTDPlant.h"
#include <sstream>
#include <iostream>
using namespace std;
//------------------------------------------------------------------------------
/**
 * constructor
 */
CGridEnvir::CGridEnvir():CEnvir(),CGrid()
{
   ReadLandscape();
}
//------------------------------------------------------------------------------
/**
 * destructor
 */
CGridEnvir::~CGridEnvir()
{}
//------------------------------------------------------------------------------
/**
  Initiate new Run: reset grid and randomly set initial individuals.
*/
void CGridEnvir::InitRun(){
	// initialise run
	CEnvir::InitRun();
	// reset grid
	resetGrid();
	//initialise individuals (acc. CHerbEff.cpp)
	InitInds(SRunPara::NamePftFile,-1);
	// new simulation
	init=1;
}
//------------------------------------------------------------------------------
/**
 * this function reads a file, introduces PFTs and initializes seeds on grid
 * after file data.
 * Each PFT on file gets 20 seeds randomly set on grid.
  \param n position of type
  \param file name of PFT file
*/
void CGridEnvir::InitInds(string file,int n){}// end initialization based on file
//------------------------------------------------------------------------------
/**
 This function initiates a number of seeds of the specified type on the grid.

 \param type string naming the type to be set
 \param number number of seeds to set
*/
void CGridEnvir::InitSeeds(string type, int number){}// end InitSeeds
//------------------------------------------------------------------------------
/**
 * one run of simulations
 * environmental prefenences are stored in SRunPara::RunPara
*/
void CGridEnvir::OneRun(){
	ResetT (); // reset time
	//run simulation until TMax (SRunPara::RunPara.Tmax)
	do{
		this->NewWeek();
		this->resetCuttedBM();
		// run one year
		OneYear();
		// write output to files
		WriteOFiles();
		if (endofrun)break;
   }while(year<SRunPara::RunPara.Tmax);// loop over all years
}  // end OneSim
//------------------------------------------------------------------------------
void CGridEnvir::OneYear(){
	do{
		//cout<<year<<" w "<<week<<endl;
		// one week
		OneWeek();
		if (endofrun)break;
	}while(++week<=WeeksPerYear);// loop over all weeks
} // end OneYear
//------------------------------------------------------------------------------
/*! \page oneweek Weekly processes
  Each week the model will go through following processes:
     - \link CGrid::ResetWeeklyVariables() reset weekly variables\endlink (orig. by F.May)
     - \link CGrid::SetCellResource() Set the weekly resources in cell (e.g. seasonal variation) \endlink
     - \link CGrid::CoverCells() Calculates current ZOIs \endlink  (orig. by F. May)
     - \link CGridEnvir::setCover() Sets current cover of grid and PFTs \endlink
     - \link CGrid::DistribResource() Resource distribution between plants\endlink
     - \link CGrid::PlantLoop() Plant processes (e.g. growth)\endlink   (orig. by F.May)
     - \link CGrid::Disturb() Disturbances (apart from herbicide) \endlink
     - \link CGrid::RemovePlants() Remove dead and trampled plants \endlink
     - \link CGrid::SeedMort() Seed mortality \endlink
     - \link CGrid::EstabLottery() Seed and ramet establishment \endlink
     - \link CGrid::Winter() Winter dieback \endlink
     - \link CGridEnvir::GetOutput() Output of PFT and grid variables \endlink

  The function CGridEnvir::OneWeek() coordinates sequence and occurence
  of weekly processes on the grid.

*/
/**
 * calculation of one week's processes
*/
void CGridEnvir::OneWeek(){
	ResetWeeklyVariables(); //cell loop, removes data from cells
	SetCellResource();      //variability between weeks
	CoverCells();           //plant loop
	setCover();             //set ACover und BCover lists, as well as type cover
	DistribResource();      //cell loop, resource uptake and competition
	PlantLoop();            //Growth, Dispersal, Mortality
	if (year>1) Disturb();  //grazing and disturbance
	RemovePlants();         //remove trampled plants
	SeedMort();             //seed mortality
	EstabLottery();         //establishment for seeds and ramets
	if (week==WeeksPerYear){     //at end of year ...
		Winter();            //removal of above ground biomass and of dead plants
	}
   //generate weekly output..
	if (true){
		GetOutput();   //calculate output variables
	}
	if (true){
		//get cutted biomass
		GetOutputCutted();
	}
}//end CClonalGridEnvir::OneWeek()
//---------------------------------------------------------------------------
/**
 * calculate Output-variables and store in intern 'database'
*/
void CGridEnvir::GetOutput()
{
   string pft_name;
   double prop_PFT;
   // for PFT specific output
   SPftOut*  PftWeek =new SPftOut();
   // for grid output
   SGridOut* GridWeek=new SGridOut();

   //Individual output
   //go through all plants
   	   for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant){
   		   //create link to plant
   		   CTDPlant* plant = (CTDPlant*)*iplant;
   		   //make sure to only count living plants not located at the boarder
   		   if (!plant->dead){
   			   //create a new struct
   			   SIndOut* IndWeek=new SIndOut();
   			   IndWeek->age = plant->age;
   			   IndWeek->name = plant->pft();
   			   IndWeek->rootmass = plant->mroot;
   			   IndWeek->shootmass = plant->mshoot;
   			   IndOutData.push_back(IndWeek);
   		   }// end if not dead
   	   } // end for all plants on grid

   //calculate sums for each PFT
   // for all plants
   for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant){
	   // link to plant
	   CPlant* plant = *iplant;
	   pft_name=plant->pft();
	   // if plant not dead
	   if (!plant->dead){
		   map<string,SPftOut::SPftSingle*>::const_iterator pos = PftWeek->PFT.find(pft_name);
		   SPftOut::SPftSingle* mi;
		   if (pos==PftWeek->PFT.end())
			   PftWeek->PFT[pft_name] = new SPftOut::SPftSingle();
		   mi =PftWeek->PFT.find(pft_name)->second;
		   mi->addInd(plant);
	   } // end if plant not dead
   } // end loop over all plants
   //calculate mean values
   typedef map<string, SPftOut::SPftSingle*> mapType;
   // loop over PFT week
   for(mapType::const_iterator it = PftWeek->PFT.begin();
          it != PftWeek->PFT.end(); ++it){
	   //cover..
	   string type=it->first;
	   double cover=this->PftCover.find(it->first)->second ;
	   it->second->cover=cover;

	   // shanon index
	   if (it->second->Nind>=1){
		   //calculate shannon index and proportion of each PFT
		   prop_PFT=(double) it->second->Nind/PlantList.size();
		   GridWeek->shannon+=(-1)*prop_PFT*log(prop_PFT);
	   }

	   //update plants' mort_base value
	   if (week == 20) {
		   // loop over all plants
		   for (plant_iter iplant = PlantList.begin();iplant < PlantList.end(); ++iplant) {
			   CPlant* plant = *iplant;
			   // if plant not dead
			   if (plant->dead == false) {
					pft_name = plant->pft();
					if (PftWeek->PFT.find(pft_name) == PftWeek->PFT.end()) {
						cerr << "wrong pft: " << pft_name;
						exit(3);
					} // end if PFT could not be found
				//based on Abundance.. 1+(NInd(PFT)/maxnIndPFT)
				//0.007*0.5*([1-2]) meanly resulting in 0.007
				double abundance = PftWeek->PFT.find(pft_name)->second->Nind;
				// set mort base according to abundance (if densitiy dependent mortality is active)
				plant->setMortBase(abundance);
				}//end if plant alive
			}// end for each plant
		}// end if week==20

	   //output for grid
	   GridWeek->totmass+=it->second->totmass;
	   GridWeek->above_mass+=it->second->shootmass;
	   GridWeek->below_mass+=it->second->rootmass;
	   GridWeek->Nind+=it->second->Nind;
   }// end loop over PFT week

   //summarize seeds on grid...
   int sumcells=SRunPara::RunPara.GetSumCells();
   for (int i=0; i<sumcells; ++i){
	   CCell* cell = CellList[i];
       for (seed_iter iter=cell->SeedBankList.begin();iter<cell->SeedBankList.end(); ++iter){
    	   string pft=(*iter)->pft();
    	   if (!PftWeek->PFT[pft])
    		   PftWeek->PFT[pft] = new SPftOut::SPftSingle();
            	++PftWeek->PFT[pft]->Nseeds;
       	   }// end if new PFT
   }// end summarise seeds on grid

   //summarise resources on grid
   double sum_above=0, sum_below=0;
   for (int i=0; i<sumcells; ++i){
	   CCell* cell = CellList[i];
	   sum_above+=cell->AResConc;
	   sum_below+=cell->BResConc;
   }// end ober all cells
   GridWeek->aresmean=sum_above/sumcells;
   GridWeek->bresmean=sum_below/sumcells;

   //summarise clonal output on grid
   this->GetClonOutput(*GridWeek);

   NCellsAcover=GetCoveredCells();

   // add output to lists
   // for PFT
   PftOutData.push_back(PftWeek);
   // for grid
   GridWeek->PftCount=PftSurvival(); //get PFT survival
   GridOutData.push_back(GridWeek);
}//end CClonalGridEnvir::GetOutput
//---------------------------------------------------------------------------
/**
 * get and reset amount of cutted biomass
 *
 * Appends Output struct
 */
void CGridEnvir::GetOutputCutted(){
   SGridOut* GridWeek=GridOutData.back();
   //store cutted biomass and reset value for next mowing
   GridWeek->cutted=this->getCuttedBM();
} // end GetOutputCutted
//---------------------------------------------------------------------------
/**
 * get clonal variables (grid wide)
 * @param GridData structure which stores the variables of the grid
 */
void CGridEnvir::GetClonOutput(SGridOut& GridData)
{
   GridData.NclonalPlants=GetNclonalPlants();
   GridData.NGenets=GetNMotherPlants();
   GridData.MeanGeneration=GetNGeneration();
   GridData.NPlants=GetNPlants();
   if (GridData.NGenets>0)
	   GridData.MeanGenetsize=GridData.NclonalPlants/(float) GridData.NGenets;
}
//------------------------------------------------------------------------------
/**
   Saves Pft survival times and returns number of surviving PFTs
   \return number of surviving PFTs
*/
int CGridEnvir::PftSurvival()
{
    typedef map<string,long> mapType;
    // for all PFT
    for(mapType::const_iterator it = PftInitList.begin(); it != PftInitList.end(); ++it){
    	// if PFT exists
    	if (PftOutData.back()->PFT.find(it->first)==PftOutData.back()->PFT.end()){
    		if(PftSurvTime.find(it->first)->second==0)// PFT existed last year
    			PftSurvTime[it->first]=CEnvir::year;// get current year
    			}else{                            // if not delete
    				PftSurvTime[it->first]=0;
    			} // [it->first];
   }// end loop over all PFTs
   return PftOutData.back()->PFT.size();// count_pft;
}//end PftSurvival
//---------------------------------------------------------------------------
/**
 * get aboveground cover in cell
 * @param x, y cell location
 */
int CGridEnvir::getACover(int x, int y){
  return ACover[x*SRunPara::RunPara.CellNum+y];}
//---------------------------------------------------------------------------
/**
 * get belowground cover in cell
 * @param x, y cell location
 */
int CGridEnvir::getBCover(int x, int y){
  return BCover[x*SRunPara::RunPara.CellNum+y];}
//---------------------------------------------------------------------------
/**
 * get aboveground cover in grid
 * @param i cell index
 */
int CGridEnvir::getGridACover(int i){return CellList[i]->getCover(1);}
//---------------------------------------------------------------------------
/**
 * get belowground cover in grid
 * @param i cell index
 */
int CGridEnvir::getGridBCover(int i){return CellList[i]->getCover(2);}
//---------------------------------------------------------------------------
/**
 * get cover of a given PFT in grid
 * @param type PFT type
 */
double CGridEnvir::getTypeCover(const string type)const{
	double number=0;
	const long int sumcells=SRunPara::RunPara.GetSumCells();
	// loop over all cells
	for (long int i=0; i<sumcells; ++i){
         number+=getTypeCover(i,type);
	} // end loop over all cells
	// return proportion of cells in which PFT occurred
	return number/sumcells;
}// end get cover of PFT
//---------------------------------------------------------------------------
/**
 * get cover of a given PFT in a cell
 * @param i cell index
 * @param type PFT type
 */
double CGridEnvir::getTypeCover(const int i, const string type)const{
	return CellList[i]->getCover(type);}// end getTypeCover
//---------------------------------------------------------------------------
/**
 * Get cover of cells.
*/
void CGridEnvir::setCover(){
	const int sum=SRunPara::RunPara.GetSumCells();
	// loop over all  cells to get above- and belowground cover of grid
	for(int i=0;i<sum;i++){
		ACover.at(i)=getGridACover(i);
		BCover[i]   =getGridBCover(i);
	} // end loop over all cells
	// get cover of all PFTs on grid
    typedef map<string, long> mapType;
    // loop over all cells
    for(mapType::const_iterator it = this->PftInitList.begin();it != this->PftInitList.end(); ++it){
    	this->PftCover[it->first]=getTypeCover(it->first);
    } // end loop over all PFTs
}
//eof
