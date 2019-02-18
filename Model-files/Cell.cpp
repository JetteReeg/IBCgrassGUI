/**\file
   \brief functions of grid cells (CCell)
 *
 */
//---------------------------------------------------------------------------
#include <iostream>
#include <map>
#include <string>
#include <sstream>
//---------------------------------------------------------------------------
#include "Cell.h"
#include "CGrid.h"
#include "CEnvir.h"

//-----------------------------------------------------------------------------
/**
 * constructor
 * @param xx x-coordinate on grid
 * @param yy y-coordinate on grid
 * @param ares aboveground resources
 * @param bres belowground resources
 */
CCell::CCell(const unsigned int xx,const unsigned int yy, double ares, double bres)
:x(xx),y(yy),AResConc(ares),BResConc(bres),NPftA(0),NPftB(0),
occupied(false),PlantInCell(NULL)
{
	AbovePlantList.clear();
	BelowPlantList.clear();
	SeedBankList.clear();
	SeedlingList.clear();

	PftNIndA.clear();
	PftNIndB.clear();
	PftNSeedling.clear();

	const unsigned int index=xx*SRunPara::RunPara.CellNum+yy;
	AResConc=CEnvir::AResMuster.at(index);
	BResConc=CEnvir::BResMuster[index];
}// end constructor
//---------------------------------------------------------------------------
/**
 * reset cell properties
 */
void CCell::clear(){
	AbovePlantList.clear();
	BelowPlantList.clear();
	for (unsigned int i=0; i<SeedBankList.size();i++) delete SeedBankList[i];
	for (unsigned int i=0; i<SeedlingList.size();i++) delete SeedlingList[i];
	SeedBankList.clear();   SeedlingList.clear();

	PftNIndA.clear();
	PftNIndB.clear();
	PftNSeedling.clear();

	NPftA=(0);NPftB=(0);
	occupied=(false);
	PlantInCell=(NULL);
}// end clear()
//---------------------------------------------------------------------------
/**
 * destructor
 */
CCell::~CCell()
{
	for (unsigned int i=0; i<SeedBankList.size();i++) delete SeedBankList[i];
	for (unsigned int i=0; i<SeedlingList.size();i++) delete SeedlingList[i];
	SeedBankList.clear();   SeedlingList.clear();
	AbovePlantList.clear();
	BelowPlantList.clear();

	PftNSeedling.clear();
}// end destructor
//---------------------------------------------------------------------------
/**
 * Set cell resources
 *
 * @param Ares aboveground
 * @param Bres belowground
 */
void CCell::SetResource(double Ares, double Bres)
{
	double SideLength=SRunPara::RunPara.CellScale();
	AResConc=Ares*(SideLength*SideLength);
	BResConc=Bres*(SideLength*SideLength);
}//end setResource
//---------------------------------------------------------------------------
/**
 * Germination on cell.
 * 4 options for seed germination: in spring and late summer, in spring, in late summer or during the whole year
 * defined as a PFT trait
 * @return biomass of germinated seeds
 */
double CCell::Germinate()
{
	double sumseedmass=0;
	unsigned int sbsize=SeedBankList.size();
	int gweek=CEnvir::week;
	//Germination
	// go through the whole seedbank of the cell
	for (unsigned int i =0; i<sbsize;i++)
	{
		// link to seed
		CSeed* seed = SeedBankList[i];
		// go through different germination types
		// option 1 (standard): two germination periods in spring and late summer
		if (seed->Traits->GermPeriod==1){
			// if current week is within the germination periods
			if (((gweek>=1) && (gweek<4)) || ((gweek>21) && (gweek<=25))) {
				// get the establishment probability
				double dummi = seed->getpEstab();
				if (CEnvir::rand01()<dummi){
					 //make a copy in seedling list
					 SeedlingList.push_back(seed);
					 // add to PFT seedling list
					 PftNSeedling[seed->pft()]++;
					 // remove the seed
					 seed->remove=true;
				}//end rand dummi
			}//end periods
		}//end Option 1

		//Option 2: only 1 germination period in the spring
		if (seed->Traits->GermPeriod==2){
			// if current week is within the germination period
			if (((gweek>=1) && (gweek<4))) {
				// get the establishment period
				double dummi = seed->getpEstab();
				if (CEnvir::rand01()<dummi){
					 //make a copy in seedling list
					 SeedlingList.push_back(seed);
					 // add to PFT seedling list
					 PftNSeedling[seed->pft()]++;
					 // remove seed
					 seed->remove=true;
				}//end rand dummi
			}//end periods
		}//end Option 2

		//Option 3: germination only in late summer
		if (seed->Traits->GermPeriod==3){
			// if current week is within the germination period
			if (((gweek>21) && (gweek<=25))) {
				// get the establishment probability
				double dummi = seed->getpEstab();
				if (CEnvir::rand01()<dummi){
					 //make a copy in seedling list
					 SeedlingList.push_back(seed);
					 // add to PFT seedling list
					 PftNSeedling[seed->pft()]++;
					 // remove seed
					 seed->remove=true;
				}//end rand dummi
			}//end periods
		}//end Option 3

		//Option 4: seed can germinate during the whole year (not used currently)
		if (seed->Traits->GermPeriod==4){
			// get establishment period
			double dummi = seed->getpEstab();
			if (CEnvir::rand01()<dummi){
				//make a copy in seedling list
				SeedlingList.push_back(seed);
				// add to PFT seedling list
				PftNSeedling[seed->pft()]++;
				// remove seed
				seed->remove=true;
			}//end rand dummi
		}//end Option 4
	}// end go through seedbank of the cell

	//remove germinated seeds from SeedBankList
	seed_iter iter_rem = partition(SeedBankList.begin(),SeedBankList.end(),GetSeedRemove);
	SeedBankList.erase(iter_rem,SeedBankList.end());

	//get Mass of all seedlings in cell
	for (seed_iter iter=SeedlingList.begin(); iter!=SeedlingList.end(); ++iter)
	{
	   sumseedmass+=(*iter)->mass;
	}// end go through all seedlings
	// return the cummulatve mass of seedlings
	return sumseedmass;
}//end Germinate()
//---------------------------------------------------------------------------
/**
 * removes the seedlings from the cell
 */
void CCell::RemoveSeedlings()
{
	PftNIndA.clear();
	PftNIndB.clear();
	PftNSeedling.clear();
	// go through the whole seedling list
	for (seed_iter iter=SeedlingList.begin(); iter!=SeedlingList.end();++iter){
	  CSeed* seed = *iter;
	  // all seeds that germinated but not established deleted
	  delete seed;
	}
	SeedlingList.clear();
}//end removeSeedlings
//---------------------------------------------------------------------------
/**
 * removes the dead seeds from the seedbank list
 */
void CCell::RemoveSeeds()
{
	seed_iter irem = partition(SeedBankList.begin(),SeedBankList.end(),GetSeedRemove);

	for (seed_iter iter=irem; iter!=SeedBankList.end(); ++iter){
	  CSeed* seed = *iter;
	  delete seed;
	}
	SeedBankList.erase(irem,SeedBankList.end());
}//end removeSeeds

//---------------------------------------------------------------------------
/**
  Updates Numbers of Plant functional traits on grid
  (refreshes NPftA and NPftB)
*/
void CCell::GetNPft()
{
	// aboveground
	NPftA=PftNIndA.size();
	// belowground
	NPftB=PftNIndB.size();
}// end GetNPFT
//-----------------------------------------------------------------------------
/**
  Returns the cell-cover of the plant type given (only aboveground).
  \param type name of PFT to look for
*/
double CCell::getCover(const string type) const{
	//if cell is the center of a plant return 1
	if (occupied) {
		string ltype=PlantInCell->pft();
		if (ltype==type) return 1;}
	//if cell empty return 0
	if (AbovePlantList.empty()){
		return 0;
	} else{
		// get all plants in cell
		unsigned int noplants = AbovePlantList.size();
		// set number of alive plants to number of plants in cell
		unsigned int nonodead = noplants; // nb of not dead plants
		// set number of PFT type in cell to 0
		unsigned int notype   = 0; // nb of type-plants
		// go through all plants covering the cell
		for (unsigned int i=0;i<noplants;i++){
			// if plant is dead, decrease number of total not dead plants in cell
			if (AbovePlantList.at(i)->dead) --nonodead;
			// if plant is of type , increase number of type-plants
			if (AbovePlantList.at(i)->pft()==type) ++notype;
		}// end for all plants in cell
		// relative amount in the cell
		// notype is the number of plant individuals of the specific type covering the cell
		// nonodead is the number of not dead plant individuals covering the cell (overall)
		if (nonodead>0)return notype/(double)nonodead;
			// if all plants are dead reaturn 0
			else return 0;
	}// end above plant list is not empty
}// end getCover
//-----------------------------------------------------------------------------
/**
  Returns cellstate. To adapt for individual use.
  \param layer one is for aboveground, two for belowground Layer#
  \return returns int coded cover for the grid
  \note has to be called before dead plants are deleted
      (access-violation else because Cell's
       Above- and BelowPlantLists are used)
*/
int CCell::getCover(const int layer)const{
	// if cell is occupied return 99
	if (occupied) return 99;
	// if layer is aboveground
	if (layer==1){
		// if no aboveground plants return 0
		if (AbovePlantList.empty())return 0;
		// if only dead plants return 98
		if (AbovePlantList.back()->dead)return 98;
		// if clonal plant return 102
		bool clonal=AbovePlantList.back()->Traits->clonal;
		if(clonal)return 102;
		//
		return (AbovePlantList.back()->getGenet()->number%20)*2+1;
	  }else{
		  // if layer is belowground
		  // if layer is empty return 0
		  if (BelowPlantList.empty())return 0;
		  // if all plants are dead return 98
		  if (BelowPlantList.back()->dead)return 98;
		  //
		  return BelowPlantList.back()->Traits->TypeID;
	  }// end if layer is belowground
}//end getCover
//-----------------------------------------------------------------------------
/**
ABOVEground competition takes global information on symmetry and version to
distribute the cell's resources. Version is 1

virtual function will be substituted by comp function from sub class

*/
void CCell::AboveComp()
{
	// if there are no plants covering the cell
	if (AbovePlantList.empty()) return;
	// if there is only one plant covering the cell
	if (AbovePlantList.size()==1) {
		// plant takes up all resources
		AbovePlantList.back()->Auptake+=AResConc;
		return;
	}// end if only one plant covering the cell
	// if mode of competition is asymmetric
	if (SRunPara::RunPara.AboveCompMode==asymtot){
     	// only for above ground competition
		// sort plant list by growth form/shoot length
		sort(AbovePlantList.begin(),AbovePlantList.end(),CPlant::CompareShoot);
		// get the biggest plant
		CPlant* plant=*AbovePlantList.begin();
		// biggest plant get all resources
		plant->Auptake+=AResConc;
		return;
	}// end if asymmetric aboveground

	int symm=1;
	// if partial asymetric competition
	if (SRunPara::RunPara.AboveCompMode==asympart) symm=2;
		double comp_tot=0, comp_c=0;

		//1. sum of resource requirement
		// go through all plants
		for (plant_iter iter=AbovePlantList.begin(); iter!=AbovePlantList.end(); ++iter){
			// link to a plant
			CPlant* plant=*iter;
			// aboveground competition for resources depending on the model version
			comp_tot+=plant->comp_coef(1,symm)
            		   *prop_res(plant->pft(),1,SRunPara::RunPara.Version);
		}// end over all plants

		//2. distribute resources
		// go through all plants
		for (plant_iter iter=AbovePlantList.begin(); iter!=AbovePlantList.end(); ++iter){
			// link to plant
			CPlant* plant=*iter;
			// get specific competition
			comp_c=plant->comp_coef(1,symm)
        		   *prop_res(plant->pft(),1,SRunPara::RunPara.Version);
			// set resource uptake
			plant->Auptake+=AResConc*comp_c/comp_tot;
		}// end over all plants
}//end above_comp
//-----------------------------------------------------------------------------
/**
BELOWground competition takes global information on symmetry and version to
distribute the cell's resources. Version is 1.

virtual function will be substituted by comp function from sub class
*/
void CCell::BelowComp()
{
	// if cell is not covered by a plant
	if (BelowPlantList.empty()) return;
	// if there are no competitors
	if (BelowPlantList.size()==1) {
		// resource uptake is equal to resource concentration
		BelowPlantList.back()->Buptake+=BResConc;
		return;
	}// end if no competitors
	// if mode of competition is asymmetric
	if (SRunPara::RunPara.BelowCompMode==asymtot){
		cerr<<"CCell::BelowComp() - "
         <<"no total asymetric belowground competition allowed"; exit(3);
	}// end if mode is asymmetric

	int symm=1;
	if (SRunPara::RunPara.BelowCompMode==asympart) symm=2;
	double comp_tot=0, comp_c=0;

	//1. sum of resource requirement
	for (plant_iter iter=BelowPlantList.begin(); iter!=BelowPlantList.end(); ++iter){
		// link to plant
		CPlant* plant=*iter;
		// belowground competition for resources depending on the model version
		comp_tot+=plant->comp_coef(2,symm)
               *prop_res(plant->pft(),2,SRunPara::RunPara.Version);
	}// end for all plants

	//2. distribute resources
	// go through all plants
	for (plant_iter iter=BelowPlantList.begin(); iter!=BelowPlantList.end(); ++iter){
		// link to plant
		CPlant* plant=*iter;
		// get specific competition
		comp_c=plant->comp_coef(2,symm)
              *prop_res(plant->pft(),2,SRunPara::RunPara.Version);
		// set resource uptake
		plant->Buptake+=BResConc*comp_c/comp_tot;
	}// end for all plants
}//end below_comp
//---------------------------------------------------------------------------
/**
 * portion of cell resources the plant is gaining
  \param type     Plant_functional_Type-ID
  \param layer    above(1)- or below(2)ground
  \param version  one of [0,1,2] standard is 1
*/
double CCell::prop_res(const string type,const int layer,const int version)const{
	switch (version){
		//no difference between intra- and interspecific competition
		case 0:  return 1;
		//higher effects of intraspecific competition
     	case 1:   switch (SRunPara::RunPara.ModelVersion){
     		// intensity of densitiy dependence in background mortality
     		// case 1: increasing intraspecific competition and density dependent mortality
     		// case 2: only density dependent mortality
     		// case3: no effect; same as Weiﬂ et al (2014)
     	 	case 1:  if (layer==1){
     	 		map<string,int>::const_iterator noa =PftNIndA.find(type);
     	 	    if (noa!=PftNIndA.end())
     	 	    	return 1.0/pow(noa->second,1);
     	 	    }
     	 		// belowground layer
     	 	    if (layer==2){
     	 	    	map<string,int>::const_iterator nob =PftNIndB.find(type);
     	 	    	if (nob!=PftNIndB.end())
     	 	        	return 1.0/pow(nob->second,1);
     	 	    }break;
     	 	//
     	 	case 2: if (layer==1){
     	    	map<string,int>::const_iterator noa =PftNIndA.find(type);
     	        if (noa!=PftNIndA.end())
     	        	return 1.0/pow(noa->second,0.5);
     	   		}
     	 		// belowground layer
     	        if (layer==2){
     	        	map<string,int>::const_iterator nob =PftNIndB.find(type);
     	            if (nob!=PftNIndB.end())
     	            	return 1.0/pow(nob->second,0.5);
     	            }break;
			case 3: if (layer==1){
						map<string,int>::const_iterator noa =PftNIndA.find(type);
						if (noa!=PftNIndA.end())
							return 1.0/pow(noa->second,0.5);
						}
					if (layer==2){
     	 	 	    	map<string,int>::const_iterator nob =PftNIndB.find(type);
     	 	 	     	if (nob!=PftNIndB.end())
     	 	 	     		return 1.0/pow(nob->second,0.5);
     	 	 	    }break;
			};break;
     	// lower resource availability for intraspecific competition
     	case 2:  if (layer==1)return NPftA/(1.0+NPftA);break;
     		// belowground
        	if (layer==2)return NPftB/(1.0+NPftB);break;
     	default: cerr<<"CCell::prop_res() - wrong input";exit(3);
	}// end of switch
	return -1; //should not be reached
}//end CCell::prop_res
//-eof--------------------------------------------------------------------------



















