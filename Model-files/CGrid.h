/**\file
   \brief definition of class CGrid and some typedefs
*/
//---------------------------------------------------------------------------
#ifndef GridBaseH
#define GridBaseH
//---------------------------------------------------------------------------
#include "Cell.h"
#include "Plant.h"
#include "RunPara.h"
//! output structures for PFT and grid
struct PftOut;
struct GridOut;

//! iterator type for plant list
typedef vector<CPlant*>::iterator plant_iter;

//! size type for plant list
typedef vector<CPlant*>::size_type plant_size;


//! Class with all spatial algorithms where plant individuals interact in space
/*! Functions for competition and plant growth are overwritten by inherited classes
    to include different degrees of size asymmetry and different concepts of niche differentiation
*/
class CGrid
{
	map<string,long>* LDDSeeds; ///< list of seeds to dispers per LDD; has to be managed manually
	double cutted_BM;  ///< biomass removed by mowing
	//! List of Genets on Grid
	vector<CGenet*> GenetList;
	//! clonal functions
	void RametEstab(CPlant* plant);///< establish ramets
	void Resshare();               ///< share ressources among connected ramets

protected:
	//! assigns grid cells to plants - which cell is covered by which plant
	virtual void CoverCells();
	//! removes dead plants from the grid and deletes them
	virtual void RemovePlants();
	//! delete plant object
	virtual void DeletePlant(CPlant* plant1);
	//! loop over all plants including growth, seed dispersal and mortality
	virtual void PlantLoop();
	//! distributes resource to each plant --> calls competition functions
	virtual void DistribResource();
	//! seed dispersal
	virtual int DispersSeeds(CPlant* plant);
	//! lottery competition for seedling establishment
	virtual void EstabLottery();
	//! generates new juveniles
	virtual void EstabLott_help(CSeed* seed);
	//! calls seed mortality and mass removal of plants
	virtual void Winter();
	//! clears list of plants that cover each cell
	void ResetWeeklyVariables();
	//!  seed mortality
	virtual void SeedMort();
	//! seed mortality due to dormancy
	void SeedMortAge();
	//! random seed mortality in winter
	void SeedMortWinter();
	//! disturbance --> calls grazing and gap formation functions
	bool Disturb();
	//! simulates aboveground herbivory
	void Grazing();
	//!< trampling events
	void Trampling();
	//! cutting of all plants to equal aboveground mass
	void Cutting();
	//! initalization of cells
	void CellsInit();
	//! set amount of resources the cells serve
	void SetCellResource();
	//! create a new spacer
	virtual CPlant* newSpacer(const int x,const int y, CPlant* plant);

public:
	//! List of plant individuals
	vector<CPlant*> PlantList;
	//! array of pointers to CCell
	vector<CCell*> CellList;
	//! constructor
	CGrid();
	//! destructor
	virtual ~CGrid();
	//! reset grid
	virtual void resetGrid();

	//! initalization of plants
	virtual void InitPlants(shared_ptr<SPftTraits>  traits,const int n);
	//! initalization of seeds
	virtual void InitSeeds(shared_ptr<SPftTraits>  traits,const int n,double estab=1.0);
	//! initalization of seeds
	virtual void InitSeeds(shared_ptr<SPftTraits>  traits,const int n,int x, int y,double estab=1.0);
	//! new seed in cell
	virtual void newSeed(CPlant* plant, CCell* cell) ;
	//! add seeds to ldd-pool of grid
	void addLDDSeeds(string pft,int nb){(*LDDSeeds)[pft]+=nb;};
	//! get ldd-pool of grid and clear buffer
	map<string,long>* getLDDSeeds(){map<string,long>*ldd=LDDSeeds;LDDSeeds=new map<string,long>;return ldd;};
	//! get number if individuals per PFT
	void GetPftNInd(vector<int>&);
	//! get number of seeds per PFT
	void GetPftNSeed(vector<int>&);
	//! reset cutted biomass
	void resetCuttedBM(){cutted_BM=0;};
	//! get cutted biomass
	double getCuttedBM(){return cutted_BM;};
	//! get total aboveground biomass
	double GetTotalAboveMass();
	//! get total belowground biomass
	double GetTotalBelowMass();
	//! initiate new ramets
	void DispersRamets(CPlant* plant);
	//! add a genet
	virtual CGenet* addGenet(int id=0);
	//service functions...
	//! number of living clonal plants
	int GetNclonalPlants();
	//! number of living non-clonal plants
	int GetNPlants();
	//! number of living genets
	int GetNMotherPlants();
	//! number of dead plants
	int GetNdeadPlants();
	//! number of cells covered
	int GetCoveredCells();
	//! number of Generations
	double GetNGeneration();
};
	//! vector of cell indices increasing in distance to grid center
	static vector<int> ZOIBase;
	//! periodic boundary conditions
	void Boundary(int& xx,int& yy);
	//! test for emmigration
	bool Emmigrates(int& xx,int& yy);
	//! dispersal kernel for seeds
	void getTargetCell(int& xx,int& yy,const float mean,const float sd,double cellscale=0);
	//! distance between two points using Pythagoras
	double Distance(const double& xx, const double& yy,
                    const double& x=0, const double& y=0);
	//! compare two index-values in their distance to the center of grid
	bool CompareIndexRel(int i1, int i2);

//---------------------------------------------------------------------------
#endif
