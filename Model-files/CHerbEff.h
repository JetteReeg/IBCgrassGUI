/**  \file
   \brief definition for IBC-grass herbicide version functions
*/
//---------------------------------------------------------------------------
#include "CGridEnvir.h"
//#include "environment.h"
#include <iostream>
#include <map>
#include <cstdlib>
#include <string>
#include <utility>
#include <vector>

class CSeed;
/** \brief wrapping class for herbicide-induced effects
Wrapping class to temporally change trait parameters depending on
year, week and PFT.
*/
class CHerbicideEffectEnv: public CGridEnvir
{
private:
  map<string,shared_ptr<SPftTraits> > PFTTraits;
  void setTraitChanges(); ///< set time- and type-depending trait values due to herbicide effect

protected:
  ///start new spacer of a clonal plant
  CPlant* newSpacer(const int x,const int y, CPlant* plant);
  ///convert inds and seeds to td plants and seeds
  void convertInds2TD();

public:
  /**\brief get link to pft definitions
   *
   * @param type string of PFT-ID
   * @return address of PFT definition
   * \sa SPftTraits
   */
  shared_ptr<SPftTraits> getPftLinkH(string type){return PFTTraits.find(type)->second;};
  //! only needed if there is only one affected PFT - however this can be also done via susceptibility parameter
  static string EffectType;

  CHerbicideEffectEnv(); ///< constructor
  ~CHerbicideEffectEnv(); ///<destructor

  //! initalization of seeds
  virtual void InitTDSeeds(shared_ptr<SPftTraits> traits,
    const int n,double estab=1.0);

  //! initialization of inds based on file data
  virtual void InitInds(string file, int n=-1);

  //! establishmend of initial seeds
  virtual void EstabLott_help(CSeed*);
  //! set new seeds in cell
  virtual void newSeed(CPlant*,CCell*);
  //! delete plant
  void DeletePlant(CPlant* plant1);
  //! base seed mortality
  virtual void SeedMort();
  //! herbicide induced seed mortality
  void SeedMortHerb();
  //! initialise seeds on grid
  void InitSeeds(string type, int number);
  //! initialize run
  void InitRun();
  //! reset standard trait settings
  void resetGlobalTraits();
  //! run one year
  void OneYear();
  //! run one week
  void OneWeek();
};
#ifndef CHerbEffH
#define CHerbEffH
//---------------------------------------------------------------------------
#endif
