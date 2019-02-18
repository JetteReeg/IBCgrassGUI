/**\file
   \brief functions of seeds
 */
//---------------------------------------------------------------------------
#include "CSeed.h"
#include "CGrid.h"
#include "iostream"
//---------------------------------------------------------------------------
/**
 * constructor of seed (produced by a plant a distributed on the grid)
 * @param x location of seed
 * @param y location of seed
 * @param plant plant which produced seed
 */
CSeed::CSeed(double x, double y, CPlant* plant)
  :xcoord(x),ycoord(y),Age(1),cell(NULL),remove(false),
  Traits(plant->Traits),estab(Traits->pEstab),mass(Traits->SeedMass)
{}// end CSeed
//---------------------------------------------------------------------------
/**
 * constructor of a seed in a cell by a specified plant
 * @param plant plant which produced seed
 * @param cell cell of new seed
 */
CSeed::CSeed(CPlant* plant,CCell* cell)
  :xcoord(plant->xcoord),ycoord(plant->ycoord),Age(1),cell(NULL),remove(false)
{
   Traits=plant->Traits;
   estab=Traits->pEstab;
   mass=Traits->SeedMass;
   setCell(cell);
}//end CSeed
//---------------------------------------------------------------------------
/**
 * constructor of a seed in a cell with specific traits
 * @param estab establishment probability
 * @param cell location of cell
 */
CSeed::CSeed(double estab, shared_ptr<SPftTraits> traits,CCell* cell)
  :xcoord(0),ycoord(0),Age(1),cell(NULL),remove(false),estab(estab),
  Traits(traits),mass(traits->SeedMass)
{
   setCell(cell);
   if (cell){
     xcoord=(cell->x*SRunPara::RunPara.CellScale());
     ycoord=(cell->y*SRunPara::RunPara.CellScale());
   }
}// end CSeed
//---------------------------------------------------------------------------
/**
 * constructor of a seed in a x,y cell with specific traits
 * @param x location on grid
 * @param y location on grid
 * @param establ establishment probability
 * @param traits trait characteristics
 */
CSeed::CSeed(double x, double y,double estab, shared_ptr<SPftTraits> traits)
  :xcoord(x),ycoord(y),estab(estab){
   Traits=traits;
   mass=Traits->SeedMass;
   Age=1;
   remove=false;
   cell=NULL;
}//end CSeed
//-----------------------------------------------------------------------------
/**
 * defines a cell if none is defined yet
 * @param cell location of cell on grid
 */
void CSeed::setCell(CCell* cell){
	// if cell not defined
	if (this->cell==NULL){
		// define cell as cell
		this->cell=cell;
		//add to seed bank to list
		this->cell->SeedBankList.push_back(this);
	}// end if not defined
}//end setCell
//---------------------------------------------------------------------------
/**
 * returnes if seed is marked for remove
 * @param seed1 seed
 */
bool GetSeedRemove(const CSeed* seed1)
{
	return (!seed1->remove);
}// end of getseedremove
//-----------------------------------------------------------------------------
/**
 * returns the type of the seed
 */
std::string CSeed::type(){
	return "CSeed";
}//end of type()
//-----------------------------------------------------------------------------
/**
 * returns to which pft the seed belongs
 */
std::string CSeed::pft(){
	return this->Traits->name;
}// end of pft()
//-----------------------------------------------------------------------------
/**
 * get current establishment probability
 */
double CSeed::getpEstab(){
	return Traits->pEstab;
};// end getpestab
//-eof----------------------------------------------------------------------------
