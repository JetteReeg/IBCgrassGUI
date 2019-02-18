/**
 * \file
   \brief definition of grid cells
 *
 */
//---------------------------------------------------------------------------
#ifndef CellH
#define CellH
//---------------------------------------------------------------------------
#include "Plant.h"
#include "CSeed.h"
#include <algorithm>
#include <map>

using namespace std;

//! iterator type for seed list
typedef vector<CSeed*>::iterator seed_iter;

//! class for cell objects (surprisingly)
class CCell
{
public:
	//! x location [grid cells]
	int x;
	//! y location [grid cells]
	int y;
	//! above-ground resource availability in resource units per cm2
	double AResConc;
	//! below-ground resource availability in resource units per cm2
	double BResConc;
	//! returns cell-cover (int-coded)
	int getCover(const int layer)const;
	//! returns cell's cover of the given type
	double getCover(const string type) const;
	//! is the cell occupied by any plant? (its stem)
   	bool occupied;
   	//! pointer to plant individual that has its central point in the cell (if any)
   	CPlant* PlantInCell;
   	//! List of all plant individuals that cover the cell ABOVE ground
	vector<CPlant*> AbovePlantList;
	//! List of all plant individuals that cover the cell BELOW ground
	vector<CPlant*> BelowPlantList;
	//! List of all (ungerminated) seeds in the cell
	vector<CSeed*> SeedBankList;
	//! List of all freshly germinated seedlings in the cell
	vector<CSeed*> SeedlingList;
	//! array with individual numbers of each PFT covering the cell above-ground
	/*! necessary for niche differentiation version 2
	*/
	map<string,int> PftNIndA;
	//! array with individual numbers of each PFT covering the cell below-ground
	/*! necessary for niche differentiation version 2
	*/
	map<string,int> PftNIndB;
	//! array of seedling number of each PFT
	map<string,int>PftNSeedling;
	//! number of different PFTs covering the cell above-ground
	/*! necessary for niche differentiation version 3 */
	int NPftA;
	//! number of different PFTs covering the cell
	/*! necessary for niche differentiation version 3 */
	int NPftB;
	//!< constructor
	CCell(const unsigned int xx,const unsigned int yy, double ares=0, double bres=0);
	//! destructor
	virtual ~CCell();
	//! reset
	void clear();
	//! set resources
	void SetResource(double Ares, double Bres);
	//! on-cell germination
	double Germinate();
	//! remove dead seedlings
	void RemoveSeedlings();
	//! remove dead seeds
	void RemoveSeeds();
	//! calculates number of individuals of each PFT
	void GetNPft();
	//! competition function for size symmetric above-ground resource competition
	/*! function is overwritten if inherited class with different competitive
	size-asymmetry of niche differentiation is used*/
	virtual void AboveComp();
	//! competition function for size symmetric below-ground resource competition
	/*! function is overwritten if inherited class with different competitive
	 size-asymmetry of niche differentiation is used*/
	virtual void BelowComp();
	//! portion cell resources the plant is gaining
	double prop_res(const string type,const int layer,const int version)const;
};

//---------------------------------------------------------------------------
#endif
