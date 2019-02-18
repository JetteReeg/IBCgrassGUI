/**\file
   \brief definition of seeds (CSeed)
 *
 */
//---------------------------------------------------------------------------

#ifndef CSeedH
#define CSeedH

#include "CObject.h"
#include "Plant.h"
//---------------------------------------------------------------------------
//! class of seed individuals
class CSeed: public CObject
{
protected:
	//! defines a cell
   CCell* cell;

public:
   //! container for traits
   shared_ptr<SPftTraits> Traits;
   //! seed mass
   double mass;
   //! estab-probability (may differ from type-specific value)
   double estab;
   //! x position on the grid
   double xcoord;
   //! y position on the grid
   double ycoord;
   //! seed age [years]
   int Age;
   //! should the seed be removed? (because it is dead)
   bool remove;
   //! PFT type ID
   virtual std::string type();
   //! PFT type string
   virtual std::string pft();
   //! create seed from plant
   CSeed(double x, double y, CPlant* plant);
   //! create seed from plant
   CSeed(CPlant* plant, CCell* cell);
   //! create seed from establishment
   CSeed(double x, double y,double estab, shared_ptr<SPftTraits> traits);
   //! create seed from establishment
   CSeed(double estab, shared_ptr<SPftTraits> traits, CCell* cell);
   //! destructor
   virtual ~CSeed(){};
   //! define cell (only if none defined yet)
   void setCell(CCell* cell);
   //! return address of cell
   CCell* getCell(){return cell;};
   //! return if seed is from clonal PFT
   virtual bool isClonal(){return false;};
   //! return type affiliation(necessary to apply algorithms from STL)
   bool SeedOfType(string type){return (this->pft()==type);};
   //! get current establishment probability
   virtual double getpEstab();
};

//-----------------------------------------------------------------------------
//! return seed removed -> necessary to use STL algorithm
bool GetSeedRemove(const CSeed* seed1);
//-----------------------------------------------------------------------------
#endif
