/**\file
   \brief functions of class CGrid
*/


#include "CGrid.h"
#include "CEnvir.h"
#include <iostream>
#include <map>
#include <algorithm>
//---------------------------------------------------------------------------
/**
 * Constructor
 */
CGrid::CGrid():cutted_BM(0)
{
	CellsInit();
	LDDSeeds = new map<string,long>;
	//generate ZOIBase...
	ZOIBase.assign(SRunPara::RunPara.GetSumCells(),0);
	for (unsigned int i=0;i<ZOIBase.size();i++) ZOIBase[i]=i;
	sort(ZOIBase.begin(),ZOIBase.end(),CompareIndexRel);
}
//-----------------------------------------------------------------------------
/**
  Initiate grid cells with above and belowground resources
  \note call only once or delete cell objects before;
  better reset cells (resetGrid()) to start a new environment
*/
void CGrid::CellsInit()
{
	int index;const int SideCells=SRunPara::RunPara.CellNum;
	// loop over all gridcells
	for (int x=0; x<SideCells; x++){
    	for (int y=0; y<SideCells; y++){index=x*SideCells+y;
    		// set cell resources
        	CCell* cell = new CCell(x,y,CEnvir::AResMuster[index],CEnvir::BResMuster[index]);
         CellList.push_back(cell);
    	}
	}// end loop over all gridcells
}//end CellsInit
//---------------------------------------------------------------------------
/**
  Clears the grid from Plants and resets cells.
*/
void CGrid::resetGrid(){
	//cells...
	for (unsigned int i=0; i<SRunPara::RunPara.GetSumCells(); ++i){
		CCell* cell = CellList[i];
		cell->clear();
	}
	//plants...
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant){
		delete *iplant;
	}
	PlantList.clear();
	//Genet list..
	for(unsigned int i=0;i<GenetList.size();i++) delete GenetList[i];
	GenetList.clear();CGenet::staticID=0;
}
//---------------------------------------------------------------------------
/**
  CGrid destructor
*/
CGrid::~CGrid()
{
	// plants
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant){
	  CPlant* plant = *iplant;
	  delete plant;
	};
	PlantList.clear();
	// cells
	for (unsigned int i=0; i<SRunPara::RunPara.GetSumCells(); ++i){
	  CCell* cell = CellList[i];
	  delete cell;
	}
   CellList.clear();
   // Genet list
   for(unsigned int i=0;i<GenetList.size();i++) delete GenetList[i];
   GenetList.clear();CGenet::staticID=0;
}//end ~CGrid
//-----------------------------------------------------------------------------
/*! \page plantloop Plant processes
  The plant will go through the following processes each week
     - \link CPlant::Grow() Growth\endlink (orig. by F.May)
     - \link CGrid::DispersRamets() Dispersal of ramets \endlink (orig. by I. Steinhauer)
     - \link CPlant::SpacerGrow() Growth of spacer\endlink  (orig. by I. Steinhauer)
     - \link CGrid::DispersSeeds() Seed dispersal\endlink   (orig. by F.May)
     - \link CPlant::Kill() Plant mortality\endlink   (orig. by F.May)

  The function CGrid::PlantLoop() coordinates sequence and occurence
  of processes.

*/
/**
  The clonal version of PlantLoop additionally to the CGrid-version
  disperses and grows the clonal ramets
  Growth (resource allocation and vegetative growth), seed dispersal and
  mortality of plants.
*/
void CGrid::PlantLoop()
{
	// loop over all plants
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant)
	{
		CPlant* plant = *iplant;
		// if plant not dead
		if (!plant->dead)
		{
			// plant growth
			plant->Grow();
			// if plant is clonal
			if ((plant->Traits->clonal))
			{
				//ramet dispersal in every week
				DispersRamets(plant);
				//if the plant has a growing spacer - grow it
				plant->SpacerGrow();
			}// end if plant is clonal
			//seed dispersal (clonal and non-clonal seeds) in week of dispersal
			if (CEnvir::week>plant->Traits->DispWeek)
            	addLDDSeeds(plant->pft(),DispersSeeds(plant));
			// plant mortality
			plant->Kill();
		}// end if plant not dead
		// decompose dead plants
		plant->DecomposeDead();
	}// end loop over all plants
}//plant loop
//-----------------------------------------------------------------------------
/**
  lognormal dispersal kernel
  Each Seed is dispersed after an log-normal dispersal kernel with mean and sd
  given by plant traits. The dispersal direction has no prevalence.
  @param xx location on grid
  @param yy location on grid
  @param mean mean dispersal distance
  @param sd standard deviation of dispersal distance
  @param cellscale scale of one cell
*/
void getTargetCell(int& xx,int& yy,const float mean,const float sd,double cellscale)
{
   double sigma=sqrt(log((sd/mean)*(sd/mean)+1));
   double mu=log(mean)-0.5*sigma;
   double dist=exp(CEnvir::normrand(mu,sigma));
   if (cellscale==0)cellscale= SRunPara::RunPara.CellScale();
   double CmToCell=1.0/cellscale;

   //direction uniformly distributed
   double direction=2*Pi*CEnvir::rand01();
   xx=CEnvir::Round(xx+cos(direction)*dist*CmToCell);
   yy=CEnvir::Round(yy+sin(direction)*dist*CmToCell);
}
//-----------------------------------------------------------------------------
/**
  Function disperses the seeds produced by a plant when seeds are to be
  released (at dispersal time - DispWeek).

  Each Seed is dispersed after an log-normal dispersal kernel
  in function getTargetCell().

  @param plant specific plant

\return list of seeds to dispers per LDD
  */
int CGrid::DispersSeeds(CPlant* plant)
{
	int px=plant->getCell()->x, py=plant->getCell()->y;
	int NSeeds=0;
	int nb_LDDseeds=0;
	int SideCells=SRunPara::RunPara.CellNum;
	// get number of seeds per plant
	NSeeds=plant->GetNSeeds();
	// loop over all seeds
	for (int j=0; j<NSeeds; ++j)
	{
    	int x=px, y=py; //remember the parent's position
    	// get new cell
        getTargetCell(x,y,
        		plant->Traits->Dist*100,        //m -> cm
        		plant->Traits->Dist*100);       //mean = std (simple assumption)
        // boundary condition
        if (SRunPara::RunPara.torus){Boundary(x,y);}
        	else if (Emmigrates(x,y)) {nb_LDDseeds++;continue;}
        // selected cell..
        CCell* cell = CellList[x*SideCells+y];
        // create new seed in cell
        newSeed(plant, cell);
	}// end loop over all seeds of plant
	return nb_LDDseeds;
}//end DispersSeeds
//---------------------------------------------------------------------------
/**
 * creates new seed of a plant in specific cell
 * @param plant plant which produced the seed
 * @param cell cell where seed is dispersed to
 */
void CGrid::newSeed(CPlant* plant, CCell* cell) {
}
//---------------------------------------------------------------------------
/**
 * function disperses ramets of a plant
 * @param plant plant of the ramet
 */
void CGrid::DispersRamets(CPlant* plant)
{
	// transform scale (1 cell==1cm)
	double CmToCell=1.0/SRunPara::RunPara.CellScale();
	// only for clonal plants
	if (plant->Traits->clonal)
	{
    	// loop over all ramets
        for (int j=0; j<plant->GetNRamets(); ++j)
        {
        	// parameters for lognormal dispersal kernel
        	// similar to getTargetCell()
        	double dist=0, direction;
        	double mean, sd;

        	//normal distribution for spacer length
        	mean=plant->Traits->meanSpacerlength;   //cm
        	sd  =plant->Traits->sdSpacerlength;     //mean = std (simple assumption)

        	while (dist<=0) dist=CEnvir::normrand(mean,sd);

        	//direction uniformly distributed
        	direction=2*Pi*CEnvir::rand01();
        	int x=CEnvir::Round(plant->getCell()->x+cos(direction)*dist*CmToCell);
        	int y=CEnvir::Round(plant->getCell()->y+sin(direction)*dist*CmToCell);
        	// periodic boundary condition
        	Boundary(x,y);

         // save distance and direction in spacer/ramet

         CPlant *Spacer= this->newSpacer(x/CmToCell,y/CmToCell,plant);
         Spacer->SpacerlengthToGrow=dist;
         Spacer->Spacerlength=dist;
         Spacer->Spacerdirection=direction;
         plant->growingSpacerList.push_back(Spacer);
         }//end loop over all ramets
	}  //end loop fo clonal plant
}//end CGridclonal::DispersRamets()
//--------------------------------------------------------------------------
/**
  This function calculates ZOI of all plants on grid.
  Each grid-cell gets a list
  of plants influencing the above- (alive and dead individuals) and
  belowground (alive plants only) layers.

  \par revision
  Let ZOI be defined by a list sorted after ascending distance to center instead
  of searching a square defined by maximum radius.
*/
void CGrid::CoverCells()
{
	int index;
	int xhelp, yhelp;

	double CellScale=SRunPara::RunPara.CellScale();
	double CellArea=CellScale*CellScale;
	//loop over all plants
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant){
		// link to plant
		CPlant* plant = *iplant;
		string p_pft=plant->pft();
		// get aboveground area covered by the plants shoot
		double Ashoot=plant->Area_shoot()/CellArea;
		plant->Ash_disc=floor(plant->Area_shoot())+1;
		// get belowground area covered by the plants root
		double Aroot=plant->Area_root()/CellArea;
		plant->Art_disc=floor(plant->Area_root())+1;
		// get maximal area covered by the plant
		double Amax=max(Ashoot,Aroot);
		// loop over all cells covered by the plant
		for (int a=0;a<Amax;++a){
			//get current position: add plant pos with ZOIBase-pos
			xhelp=plant->getCell()->x
              +ZOIBase[a]/SRunPara::RunPara.CellNum
              -SRunPara::RunPara.CellNum/2;
			yhelp=plant->getCell()->y
              +ZOIBase[a]%SRunPara::RunPara.CellNum
              -SRunPara::RunPara.CellNum/2;
			// periodic boundary conditions
			Boundary(xhelp,yhelp);
			// index of cell
			index = xhelp*SRunPara::RunPara.CellNum+yhelp;
			// link to cell
			CCell* cell = CellList[index];
			// if cell is covered by plants shoot
			if (a<Ashoot){
				//dead plants still shade others
				cell->AbovePlantList.push_back(plant);
				cell->PftNIndA[p_pft]++;
			}// end if cell covered by plants shoot
			// if cell is covered by plants root
			if (a<Aroot){
				//dead plants do not compete for below ground resource
				if (!plant->dead){
				   cell->BelowPlantList.push_back(plant);
				   cell->PftNIndB[p_pft]++;
				}
			}// end cell is covered by plants root
		}// end loop over all cells covered by plant
	}//end of plant loop
}// end CoverCells()
//---------------------------------------------------------------------------
/**
  Resets all weekly variables of individual cells and plants (only in PlantList)
*/
void CGrid::ResetWeeklyVariables()
{
	//loop for all cells
	for (unsigned int i=0; i<SRunPara::RunPara.GetSumCells(); ++i){
		//link to cell
		CCell* cell = CellList[i];
		// clear aboveground plant list
		cell->AbovePlantList.clear();
		// clear belowground plant list
	  	cell->BelowPlantList.clear();
	  	// remove seedlings and pft-counter
	  	cell->RemoveSeedlings();
	}// end loop over all cells
	//loop for all plants
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant){
		// link to plant
		CPlant* plant = *iplant;
		//reset weekly variables resource uptake and zone of influence
		plant->Auptake=0;plant->Buptake=0;
		plant->Ash_disc=0;plant->Art_disc=0;
	}// end loop over plants
}
//---------------------------------------------------------------------------
/**
  Distributes local resources according to local competition
  and shares them between connected ramets of clonal genets.
*/
void CGrid::DistribResource()
{
	// loop over all cells
	for (unsigned int i=0; i<SRunPara::RunPara.GetSumCells(); ++i){  //loop for all cells
		// link to cell
    	CCell* cell = CellList[i];
    	// number of PFTs in cell
    	cell->GetNPft();
    	// resource competiton
    	cell->AboveComp();
    	cell->BelowComp();
	} //end loop over all cells
	// resource sharing between connected ramets
	Resshare();
}//end DistribResource()
//----------------------------------------------------------------------------
/**
  Resource sharing between connected ramets on grid.
*/
void CGrid::Resshare()
{
	for (unsigned int i=0; i<GenetList.size();i++)
	{
		// link to genet list
		CGenet* Genet = GenetList[i];
		// if there is at least one ramet
        if (Genet->AllRametList.size()>1)
        {
        	// link to ramet plant
        	CPlant* plant=Genet->AllRametList.front();
        	// if clonal plant, which shares resources with ramets
            if (plant->Traits->clonal&&plant->Traits->Resshare==true)
            {
            	// aboveground
            	Genet->ResshareA();
            	// belowground
            	Genet->ResshareB();
            } // end if resource sharing clonal plant
        }//end if at least one ramet
	}// end loop over genet list
}//end CGridclonal::Resshare()
//-----------------------------------------------------------------------------
/**
  For each grid cell seeds from seed bank germinate and establish.
  Seedlings that do not establish will die.

  \note this function is \b completely reimplemented by CGridclonal

  For each plant ramets establish and
  for each grid cell seeds from seed bank germinate and establish.
  Seedlings that do not establish will die.

  -# ramets establish if goal is reached (RametEstab())
  -# seeds establish from the seed bank during
    germination time (weeks 1-3, 22-25).
  -# seedlings that fail to establish will die
*/
void CGrid::EstabLottery()
{
	// for ramets
	int PlantListsize=PlantList.size();
	// loop over all plants
	for (int z=0; z<PlantListsize;z++)
	{
		// link to plant
    	CPlant* plant=PlantList[z];
    	// if clonal plant and not dead
    	if ((plant->Traits->clonal) &&(!plant->dead))
    	{
    		// call ramet establishment
    		RametEstab(plant);
    	}// end if clonal plant
	}//end loop over all plants

	//for Seeds (for clonal and non-klonal plants)
	map<string,double> PftEstabProb;
	map<string,int> PftNSeedling;

    double sum=0;
    // loop over all cells
    for (unsigned int i=0; i<SRunPara::RunPara.GetSumCells(); ++i)
    {
    	// link to cell
    	CCell* cell = CellList[i];
    	// only if cell is not covered and there are seeds
        if ((cell->AbovePlantList.empty())
            && (!cell->SeedBankList.empty())
            && (!cell->occupied))
        {
        	// germinating seeds
        	sum=cell->Germinate();
        	// if seeds germinated
        	if (sum>0){
        		typedef map<string,int> mapType;
        		// loop for all seedlings
        		for(mapType::const_iterator it = cell->PftNSeedling.begin();
        				it != cell->PftNSeedling.end(); ++it)
        		{
        			// link to PFT
					string  pft =it->first;//aktueller PFT
					map<string, int>::iterator itr = cell->PftNSeedling.find(pft);
					if (itr != cell->PftNSeedling.end()) {
						// get establishment probability of PFT seedlings
						// number of seedlings * seed mass
						PftEstabProb[pft]=
								(double) itr->second
								*SPftTraits::getPftLink(pft)->SeedMass;
						PftNSeedling[pft]=itr->second;
					}// end if PFT seedlings
        		}// end loop for each seedling

				//chose seedling that establishes (randomly)
				//random double between 0 and sum of seed mass
				double rnum=CEnvir::rand01()*sum;
				// loop over all PFT seedlings in cell
				for(mapType::const_iterator it = cell->PftNSeedling.begin();
					it != cell->PftNSeedling.end()&&(!cell->occupied); ++it)
				{
					string pft =it->first;
					//if the random number is lower than the current types' estab probability
					if (rnum<PftEstabProb[pft])
					{
						//shuffle between winning seedlings
						random_shuffle(cell->SeedlingList.begin(),
							partition(cell->SeedlingList.begin(),cell->SeedlingList.end(),
							bind2nd(mem_fun(&CSeed::SeedOfType),pft)));
						// first seedling wins
						CSeed* seed = cell->SeedlingList.front();
						// establish that seed in cell
						EstabLott_help(seed);
						// remove established seedling
						cell->PftNSeedling[pft]--;
						continue; //if one seed established, go to next cell
					}// end if
					else{
						rnum-= PftEstabProb.find(pft)->second;
					}   //und gehe zum nächsten Typ
				}//end for all types in list
            // remove seedlings in cell
            cell->RemoveSeedlings();
        	}//if seedlings in cell
        }//seeds in cell
    }//for all cells
    // clear lists
	PftEstabProb.clear();
	PftNSeedling.clear();
}//end CGridclonal::EstabLottery()
//-----------------------------------------------------------------------------
/**
 * Establish new genet.
 * @param seed seed which germinates.
 */
void CGrid::EstabLott_help(CSeed* seed) {
	// create new plant from seed
	CPlant* plant= new CPlant(seed);
	// add genet for clonal plants
	plant->setGenet(addGenet());
	// add plant to plant list
	PlantList.push_back(plant);
}
//-----------------------------------------------------------------------------
/**
  Establishment of ramets. If spacer is readily grown tries to settle on
  current cell.
  If it is already occupied it finds a new goal nearby.
  If the cell is empty, the ramet establishes:
  cell information is set and the ramet is added to the global plant list,
  the genet's ramet list as well as erased
  from the spacer list of the mother plant.
*/
void CGrid::RametEstab(CPlant* plant)
{
	int RametListSize=plant->growingSpacerList.size();
	// if no ramets there, return to next process
	if (RametListSize==0)return;
	// go through all ramets
	for (int f=0; f<(RametListSize);f++)
	{
		CPlant* Ramet = plant->growingSpacerList[f];
		// if length is reached
		if (Ramet->SpacerlengthToGrow<=0){

			int x=CEnvir::Round(Ramet->xcoord/SRunPara::RunPara.CellScale());
			int y=CEnvir::Round(Ramet->ycoord/SRunPara::RunPara.CellScale());

			//find the number of the cell in the List with x,y
			CCell* cell=CellList[x*SRunPara::RunPara.CellNum+y];

			// if cell is not occupied, establish the ramet in that cell
			if ((!cell->occupied))
			{
				Ramet->getGenet()->AllRametList.push_back(Ramet);
				Ramet->setCell(cell);
				// add to plant list
				PlantList.push_back(Ramet);
				//delete from list but not the element itself
				plant->growingSpacerList.erase(plant->growingSpacerList.begin()+f);
				//establishment success
				double estabramet = plant->getpEstabRamet();
				if(CEnvir::rand01()<(1.0-estabramet)) Ramet->dead=true;
			}// end if cell is not occupied
			else //find another random cell in the area around
			{
				// during the year
				if (CEnvir::week<CEnvir::WeeksPerYear)
				{
					// find a new cell
					int factorx;int factory;
					do{
						factorx=CEnvir::nrand(5)-2;
						factory=CEnvir::nrand(5)-2;
					}while(factorx==0&&factory==0);

					double dist=Distance(factorx,factory);
					double direction=acos(factorx/dist);
					double cellscale=SRunPara::RunPara.CellScale();
					int x=CEnvir::Round((Ramet->xcoord+factorx)/cellscale);
					int y=CEnvir::Round((Ramet->ycoord+factory)/cellscale);

					//periodic boundary conditions
                    Boundary(x,y);

                    //new position, dist and direction
                    Ramet->xcoord=x*cellscale; Ramet->ycoord=y*cellscale;
                    Ramet->SpacerlengthToGrow=dist;
                    Ramet->Spacerlength=dist;
                    Ramet->Spacerdirection=direction;
				}// end if during the year
				// at the end of the year
				if (CEnvir::week==CEnvir::WeeksPerYear)
				{
					//delete element - ramet dies unestablished
					delete Ramet;
					plant->growingSpacerList.erase(plant->growingSpacerList.begin()+f); //delete
				}// end if end of the year
			}// end else occupied
		}//end if pos reached
	}//loop for all Ramets
}//end CGridclonal::RametEstab()
//-----------------------------------------------------------------------------
/**
 * seed dormancy as seed mortality due to age
 */
void CGrid::SeedMortAge()
{
	// loop over all cells
	for (unsigned int i=0; i<SRunPara::RunPara.GetSumCells(); ++i){
		// link to cell
		CCell* cell = CellList[i];
		// loop over all seeds in cell
		for (seed_iter iter=cell->SeedBankList.begin();
				iter!=cell->SeedBankList.end(); ++iter){
			// link to seed
			CSeed* seed = *iter;
			// if age of the seed is equal or greater than the dormancy trait, remove the seed
			if (seed->Age >= seed->Traits->Dorm)  seed->remove=true;
			}//end loop over all seeds in cell
		// removes all marked seeds
		cell->RemoveSeeds();
	}// end loop over all cells
}//end SeedMortAge
//-----------------------------------------------------------------------------
/*! \page disturb Disturbances
  The following modes of disturbances are implemented in the model:
     - \link CGrid::Grazing() Aboveground Grazing\endlink (orig. by F.May)
     - \link CGrid::Trampling() Trampling\endlink           (orig. by F.May)
     - \link CGrid::Cutting() Cutting\endlink             (02/10 by F.May)

  The function CGrid::Disturb() coordinates sequence and occurence
  of events.

*/
//-----------------------------------------------------------------------------
/**
   Calculate the effects of Grazing() and Trampling() according to
   the probabilities \ref SRunPara::GrazProb "GrazProb" and
   \ref SRunPara::DistProb() "DistProb"
   calculate the effect of cutting after F.May(2010) \ref SRunPara::NCut() "NCut"
*/
bool CGrid::Disturb()
{
	// if there are plants
	if (PlantList.size()>0){
		// if random number is smaller than grazing probability, due grazing
		if (CEnvir::rand01()<SRunPara::RunPara.GrazProb){
			Grazing();
		}
		// trampling occurs each week, but to a specific amount
        Trampling();

        int week = CEnvir::week;
        // if there are cutting events
        if (SRunPara::RunPara.NCut>0){
        	// switch between number of cutting events (1-3)
        	switch (SRunPara::RunPara.NCut){
            	case 1: if (week==22) Cutting(); break;
            	case 2: if ((week==22) || (week==10)) Cutting(); break;
            	case 3: if ((week==22) || (week==10) || (week==16)) Cutting(); break;
            	default: cerr<<"CGrid::Disturb() - wrong input";exit(3);
        	}// end switch between number of cuttings
        }// end if there are cutting events
        return true;
   }// end if plants are there
   else return false;
}//end  Disturb
//-----------------------------------------------------------------------------
/**
  The plants on the whole grid are grazed according to
  their relative grazing susceptibility until the given
  \ref SRunPara::PropRemove "proportion of removal"
  is reached or the grid is completely grazed.
   (Above ground mass that is ungrazable - see Schwinning and Parsons (1999):
   15,3 g/m²  * 1.6641 m² = 25.5 g)
*/
void CGrid::Grazing()
{
	int    SumCells     =SRunPara::RunPara.GetSumCells();
	double CellScale    =SRunPara::RunPara.CellScale();
	// according to Schwinning and Parsons (1999): aboveground mass that is ungrazable
	double ResidualMass =15300*SumCells*CellScale*CellScale*0.0001;
	double MaxMassRemove, TotalAboveMass, MassRemoved=0;
	double grazprob;

	double Max;

	TotalAboveMass=GetTotalAboveMass();

	//maximal removal of biomass
	MaxMassRemove=TotalAboveMass*SRunPara::RunPara.PropRemove;
	MaxMassRemove=min(TotalAboveMass-ResidualMass,MaxMassRemove);
	// while the mass removed is lower than the maximal mass removed
	while(MassRemoved<MaxMassRemove){
		//calculate slope for individual grazing probability;
		//sort PlantList descending after mshoot/LMR
		sort(PlantList.begin(),PlantList.end(),CPlant::ComparePalat);
		//plant with highest grazing susceptibility
		CPlant* plant = *PlantList.begin() ;
		Max = plant->mshoot*plant->Traits->GrazFac();

		random_shuffle(PlantList.begin(),PlantList.end());
		// for all plants
		plant_size i=0;
		while((i<PlantList.size())&&(MassRemoved<MaxMassRemove)){
			CPlant* lplant=PlantList[i];
			// grazing probability is proportional to the highest grazing susceptibility
			grazprob= (lplant->mshoot*lplant->Traits->GrazFac())/Max;
			if (CEnvir::rand01()<grazprob) MassRemoved+=lplant->RemoveMass();
			++i;
		}// end while there are plants
	}// end while there is mass left to be removed
}//end CGrid::Grazing()
//-----------------------------------------------------------------------------
/**
  Cutting of all plants on the patch to a specific level
  */
void CGrid::Cutting()
{
	// link to plant
	CPlant* pPlant;
	// cutting height for erect growing plants
	double mass_cut = SRunPara::RunPara.CutMass;
	double mass_removed=0;

	for (plant_size i=0; i<PlantList.size();i++){
		pPlant = PlantList[i];
		// if plant is taller than the cutting height
        if (pPlant->mshoot/(pPlant->Traits->LMR*pPlant->Traits->LMR) > mass_cut){
        	// biomass left after cutting
            double to_leave= mass_cut*(pPlant->Traits->LMR*pPlant->Traits->LMR);
            //cutted biomass removed
            mass_removed+= pPlant->mshoot-to_leave+pPlant->mRepro;
            // cut the biomass to the specific level incl. reproductive biomass
            pPlant->mshoot = to_leave;
            pPlant->mRepro = 0.0;
        }// end if plant is taller than cutting height
	}
	// sum up the cutted biomass
	cutted_BM+= mass_removed;
} //end cutting
//-----------------------------------------------------------------------------
/**
  Round gaps are created randomly, and all plants therein are killed,
  until a certain \ref SRunPara::AreaEvent "Area" is trampled.
  If a cell is trampled twice it does not influence the number of
  disturbed patches.

  (Radius of disturbance currently is 10cm)

  The ZOI is defined by a list sorted after ascending distance to center
*/
void CGrid::Trampling()
{
   int xcell, ycell,xhelp, yhelp,index;   //central point
   //radius of disturbance [cm]
   double radius=10.0;
   //area of patch [cm²]
   double Apatch=(Pi*radius*radius);
   //number of gaps
   int NTrample=floor(SRunPara::RunPara.AreaEvent
		   *SRunPara::RunPara.GridSize*SRunPara::RunPara.GridSize/
                      Apatch);
   //area of patch [cell number]
   Apatch/=SRunPara::RunPara.CellScale()*SRunPara::RunPara.CellScale();
   // loop over the number of patches trampled
   for (int i=0; i<NTrample; ++i){
	   //get random center of disturbance
	   xcell=CEnvir::nrand(SRunPara::RunPara.CellNum);
	   ycell=CEnvir::nrand(SRunPara::RunPara.CellNum);
	   // go through the cells of the area of a trampled patch
	   for (int a=0;a<Apatch;a++){
		   //get current position: add random center pos with ZOIBase-pos
		   xhelp=xcell
              +ZOIBase[a]/SRunPara::RunPara.CellNum
              -SRunPara::RunPara.CellNum/2;
		   yhelp=ycell
              +ZOIBase[a]%SRunPara::RunPara.CellNum
              -SRunPara::RunPara.CellNum/2;
		   // periodic boundary conditions
		   Boundary(xhelp,yhelp);
		   index = xhelp*SRunPara::RunPara.CellNum+yhelp;
		   // link to the specific cell
		   CCell* cell = CellList[index];
		   // if the cell is occupied by the center of a plant, remove the plant
		   if (cell->occupied){
			   CPlant* plant = (CPlant*) cell->PlantInCell;
			   plant->remove=true;
		   }//end if cell is occupied
	   }//end for all cells in patch
   }//end for all patches
}//end CGrid::Trampling()
//-----------------------------------------------------------------------------
/**
 * remove dead and trampled plants from the grid
 */
void CGrid::RemovePlants()
{
	// list of all plants marked as dead
	plant_iter irem = partition(PlantList.begin(),PlantList.end(),
			mem_fun(&CPlant::GetPlantRemove));
	// go through all dead plants
	for (plant_iter iplant=irem; iplant<PlantList.end(); ++iplant)
	{
		// link to plant
		CPlant* plant = *iplant;
		// delete plant
		DeletePlant(plant);
	}// end go through all plants
	// remove plant from plant list
	PlantList.erase(irem,PlantList.end());
}// end RemovePlants()
//-----------------------------------------------------------------------------
/**
  Delete a plant from the grid and it's references in genet list and grid cell.
  @param plant1 plant to be removed
*/
void CGrid::DeletePlant(CPlant* plant1)
{
	CGenet *Genet=plant1->getGenet();
    //search ramet in list and erase
    for (unsigned int j=0;j<Genet->AllRametList.size();j++)
    {
    	CPlant* Ramet;
        Ramet=Genet->AllRametList[j];
        if (plant1==Ramet)// delete the ramet
        	Genet->AllRametList.erase(Genet->AllRametList.begin()+j);
    }//for all ramets
    // update the cells state as not occupied
    plant1->getCell()->occupied=false;
    plant1->getCell()->PlantInCell = NULL;

    delete plant1;
} //end CGridclonal::DeletePlant
//-----------------------------------------------------------------------------
/**
 * Seed mortality in winter and summer.
 */
void CGrid::SeedMort() {
	// remove non dormant seeds before autumn
	if (CEnvir::week==20) SeedMortAge();
	// winter seed mortality
	if (CEnvir::week==CEnvir::WeeksPerYear) SeedMortWinter();
}
//-----------------------------------------------------------------------------
/**
 * biomass removal (dieback) in winter time
 */
void CGrid::Winter()
{
	//overwintering of plants
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant){
		      (*iplant)->Overwintering();
		}
	// remove dead plants
	RemovePlants();
	//mass removal during winter
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant){
		(*iplant)->WinterLoss();
	}
}
//-----------------------------------------------------------------------------
/**
 * seed mortality during winter
 */
void CGrid::SeedMortWinter()
{
	// loop over all cells
	for (unsigned int i=0; i<SRunPara::RunPara.GetSumCells(); ++i){
		// link to cell
		CCell* cell = CellList[i];
		// loop over all seeds in cell
		for (seed_iter iter=cell->SeedBankList.begin(); iter!=cell->SeedBankList.end(); ++iter){
			// link to seed
			CSeed* seed = *iter;
			// 50% probability of a seed to die during winter
			if ((CEnvir::rand01()<SRunPara::RunPara.mort_seeds)){
				// remove seed
				seed->remove=true;
			} //if not seed survive and ages
			else ++seed->Age;
		}//end for seeds in cell
		// remove dead seeds
		cell->RemoveSeeds();
	}// end for all cells
}//end CGrid::SeedMortWinter()
//-----------------------------------------------------------------------------
/**
  Set a number of randomly distributed Plants (CPlant) of a specific
  trait-combination on the grid.

  \param traits   SPftTraits of the plants to be set
  \param n        number of Individuals to be set
*/
void CGrid::InitPlants(shared_ptr<SPftTraits> traits,const int n)
{}//end CGrid::PlantsInit()
//-----------------------------------------------------------------------------
/**
  Set a number of randomly distributed Seeds (CSeed) of a specific
  trait-combination on the grid.

  \param traits   SPftTraits of the seeds to be set
  \param n        number of seeds to be set
  \param estab    seed establishment (CSeed) - default is 1
*/
void CGrid::InitSeeds(shared_ptr<SPftTraits> traits, int n,double estab)
{}//end CGrid::SeedsInit()
//---------------------------------------------------------------------------
/**
 * set a seed with specific location on the grid
 * @param traits traits of the seed
 * @param n number of seeds
 * @param x x location
 * @param y y location
 * @param estab establishment probability
 */
void CGrid::InitSeeds(shared_ptr<SPftTraits> traits, int n,int x, int y,double estab)
{}//end CGrid::SeedsInit()
//---------------------------------------------------------------------------
/**
  Weekly sets cell's resources - above- and belowground variation during the
  year.
*/
void CGrid::SetCellResource()
{
	//current week
	int gweek=CEnvir::week;
	// loop over all cells
	for (unsigned int i=0; i<SRunPara::RunPara.GetSumCells(); ++i){
		// link to cell
		CCell* cell = CellList[i];
		// variable resources above and below ground
		double var_res_A;
		double var_res_B;
		// Aboveground resource variability according to day length
		// Aampl give the amplitude of the seasonal variability
		// function is based on day length in germany (berlin) 2017; calibrated with relative values
		if (SRunPara::RunPara.Aampl>0)
			var_res_A = (SRunPara::RunPara.Aampl*sin((2*Pi/365)*(((gweek+11)*7)-80))+0.73)*
      		 	 	 	 CEnvir::AResMuster[i];
		else var_res_A= CEnvir::AResMuster[i];

		// Belowground resource variability
		// function is based on mean soil moisture in germany 2015 (http://www.esa-soilmoisture-cci.org/); calibrated with relative values
		if (SRunPara::RunPara.Bampl>0)
			var_res_B = (SRunPara::RunPara.Bampl*sin((2*Pi/165)*(((gweek+11)*7)-20))+0.73)*
            		 	 CEnvir::BResMuster[i];
		else var_res_B= CEnvir::BResMuster[i];
		// set the resource
		cell->SetResource(max(0.0, var_res_A),
						max(0.0, var_res_B));
	}// end loop over all cells
}//end SetCellResource
//-----------------------------------------------------------------------------
/**
	calculates the distance between two cells in the grid
	@param xx, yy, x, y pairs of coordinates
  \return eucledian distance between two pairs of coordinates (xx,yy) and (x,y)
*/
double Distance(const double& xx, const double& yy,
				const double& x, const double& y){
	return sqrt((xx-x)*(xx-x) + (yy-y)*(yy-y));
}
//-----------------------------------------------------------------------------
/**
 * compare two index-values in their distance to the center of grid
 * @param il1, il2 index value
 */
bool CompareIndexRel(int i1, int i2)
{
	const int Num=SRunPara::RunPara.CellNum;
	return  Distance(i1/Num,i1%Num  ,Num/2,Num/2)
         <Distance(i2/Num,i2%Num  ,Num/2,Num/2);
}
//---------------------------------------------------------------------------
/**
 * periodic boundary conditions
  \param[in,out] xx  torus correction of x-coordinate
  \param[in,out] yy  torus correction of y-coordinate

*/
void Boundary(int& xx, int& yy)
{
	xx%=SRunPara::RunPara.CellNum;
	if(xx<0)xx+=SRunPara::RunPara.CellNum;
	yy%=SRunPara::RunPara.CellNum;
	if(yy<0)yy+=SRunPara::RunPara.CellNum;
}
//---------------------------------------------------------------------------
/**
 * check for emmigrating seeds
 * @param xx location of seed
 * @param yy location of seed
 */
bool Emmigrates(int& xx, int& yy)
{
	if(xx<0||xx>=SRunPara::RunPara.CellNum)return true;
	if(yy<0||yy>=SRunPara::RunPara.CellNum)return true;
	return false;
}
//---------------------------------------------------------------------------
/**
  \return sum of all plants' aboveground biomass (shoot and fruit)
*/
double CGrid::GetTotalAboveMass()
{
	double above_mass=0;
	// loop over all plants
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant){
		// link to a plant
		CPlant* plant = *iplant;
		// sum up biomass
		above_mass+=plant->mshoot+plant->mRepro;
	}// end loop over all plants
	return above_mass;
}// end CGrid::GetTotalAboveMass()
//---------------------------------------------------------------------------
/**
  \return sum of all plants' belowground biomass (roots)
*/
double CGrid::GetTotalBelowMass()
{
	double below_mass=0;
	// loop over all plants
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant){
		// link to plant
		CPlant* plant = *iplant;
		// sum up biomass
		below_mass+=plant->mroot;
	}// end loop ober all plants
	return below_mass;
}// end CGrid::GetTotalBelowMass()
//-----------------------------------------------------------------------------
/**
  \return number of clonal plants on grid
*/
int CGrid::GetNclonalPlants()
{
	int NClonalPlants=0;
	// loop over all plants
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant)
	{
		// link to plants
		CPlant* plant = *iplant;
		//count only if its a clonal plant
		if ((plant->Traits->clonal)
    		&&(!plant->dead))
			NClonalPlants++;
	}// end loop ober all plants
	return NClonalPlants;
}//end CGridclonal::GetNclonalPlants()
//-----------------------------------------------------------------------------
/**
  \return number of non-clonal plants on grid

*/
int CGrid::GetNPlants()
{
	int NPlants=0;
	// loop over all plants
	for (plant_iter iplant=PlantList.begin(); iplant<PlantList.end(); ++iplant)
	{
		// link to plant
		CPlant* plant = *iplant;
		//count only if its a non-clonal plant
		if (!(plant->Traits->clonal)
    			&(!plant->dead)) NPlants++;
	}// end loop over all plants
	return NPlants;
}//end CGridclonal::GetNPlants()
//-----------------------------------------------------------------------------
/**
  \return the number of genets with at least one ramet still alive
*/
int CGrid::GetNMotherPlants()
{
	int NMotherPlants=0;
	// if there are genets
	if (GenetList.size()>0)
	{
		// loop over all genets
		for (unsigned int i=0; i<GenetList.size();i++)
		{
			// link to genet
			CGenet* Genet = GenetList[i];
			// if living ramets
			if ((Genet->AllRametList.size()>0))
			{
				unsigned int g=0;
				//count living ramets
				do {g++;} while (
						(Genet->AllRametList[g-1]->dead)&&(g<Genet->AllRametList.size()));
				// count mother plants
				if (!Genet->AllRametList[g-1]->dead) NMotherPlants++;
			}//end for all ramets
		}//end for all genets
	}// end if there are genets
	return NMotherPlants;
}//end CGridclonal::GetNMotherPlants()
//------------------------------------------------------------------------------
/**
  Counts a cell covered if the list of aboveground ZOIs has length >0.

  \note Call the function after updating weekly ZOIs
  in function CGrid::CoverCells()

  \return the number of covered cells on grid
*/
int CGrid::GetCoveredCells()
{
	int NCellsAcover=0;
	const int sumcells=SRunPara::RunPara.GetSumCells();
	// go through all cells
	for (int i=0; i<sumcells; ++i)
	{
		// if cell is covered by a ZOI of a plant
		if (CellList[i]->AbovePlantList.size()>0) NCellsAcover++;
	}//end for all cells
	return NCellsAcover;
}//end CGridclonal::GetCoveredCells()
//------------------------------------------------------------------------------
/**
 * calculate the mean number of generations per genet
 * @return mean number of generations per genet
 */
double CGrid::GetNGeneration()
{
	double SumGeneration=0;
	double Sum=0;
	double highestGeneration;
	double MeanGeneration=0;
	// if there are genets
	if (GenetList.size()>0)
	{
		for (unsigned int i=0; i<GenetList.size();i++)
		{
			// link to genet
			CGenet* Genet;
			Genet = GenetList[i];
			// if genet has ramets
			if ((Genet->AllRametList.size()>0))
			{
				highestGeneration=0;
				for (unsigned int j=0;j<Genet->AllRametList.size();j++)
				{
					// link to ramet
					CPlant* Ramet;
					Ramet=Genet->AllRametList[j];
					highestGeneration=max(highestGeneration,double (Ramet->Generation));
				}// end for all ramets
			// sum up highst generations
            SumGeneration+=highestGeneration;
            Sum++;
			}//if genet has ramets
		}//for all ramets
		if (Sum>0) MeanGeneration=(SumGeneration/Sum);
	}// end if there are genets
	return MeanGeneration;
}//end CGridclonal::GetNGeneration()
//------------------------------------------------------------------------------
/**
 * add Genets to internal list. new objects are generated.
 * @param id default=0
 * @return link to the new or found genet
 */
CGenet* CGrid::addGenet(int id) {
	CGenet *Genet;
	//when id given - seach for occurence in list
	if (id>0){
		for(unsigned int i=0; i<GenetList.size();i++)
			if (GenetList[i]->number==id)
			return GenetList[i];
		Genet=new CGenet(); Genet->number=id;
		Genet->staticID=std::max(Genet->staticID,id);
		    return Genet;
	}else Genet= new CGenet();
    GenetList.push_back(Genet);
    return Genet;
}// end CGrid::addGenet(int id)
//------------------------------------------------------------------------------
/**
 * create a new spacer
 * @param x,y	location on the grid
 * @param plant	plant
 */
CPlant* CGrid::newSpacer(const int x, const int y,
		 CPlant* plant) {
	  double CmToCell=1.0/SRunPara::RunPara.CellScale();
	 return new CPlant(x/CmToCell,y/CmToCell,plant);
}

//-eof--------------------------------------------------------------------------

