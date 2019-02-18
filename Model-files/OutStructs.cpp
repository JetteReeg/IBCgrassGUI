/**\file
 * \brief output structures
*/
//---------------------------------------------------------------------------

#include "OutStructs.h"
#include "CEnvir.h"
#include "CTDPlant.h"
#include <map>
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
/**
 * constructor
 */
SPftOut::SPftOut():week(CEnvir::GetT()){
}//end PftOut constructor
//---------------------------------------------------------------------------
/**
 * destructor
 */
SPftOut::~SPftOut(){
	//delete PFT...
    typedef map<string,SPftSingle*> mapType;
    for(mapType::const_iterator it = PFT.begin();
    	it != PFT.end(); ++it) delete it->second;
    PFT.clear();
}// end destructor
//---------------------------------------------------------------------------
/**
 * constructor
 */
SPftOut::SPftSingle::SPftSingle():
	totmass(0),rootmass(0),shootmass(0),repromass(0),cover(0),
	Nind(0),Nseedlings(0),Nseeds(0){}//end SPftSingle constructor
//-------------------------------------------------------
/**
 * constructor
 */
SGridOut::SGridOut():week(CEnvir::GetT()),
  above_mass(0),below_mass(0),
  aresmean(0),bresmean(0),Nind(0),PftCount(0),shannon(0),
  totmass(0),cutted(0),
  MclonalPlants(0),MeanGeneration(0),MeanGenetsize(0),
  MPlants(0),NclonalPlants(0),NGenets(0),NPlants(0){}// end SGridOut constructor
//-------------------------------------------------------
/**
 * constructor
 */
SIndOut::SIndOut():
	week(CEnvir::GetT()),name(""),age(0),shootmass(0),rootmass(0){}//end SIndOut constructor
//-------------------------------------------------------
/**
 * adds one Individual to the output struct
 * \note class CTDPlant has to be known
 * @param plant individual to be reported
 */
void SPftOut::SPftSingle::addInd(CPlant* plant) {
	// total biomass
    totmass+=plant->GetMass();
    // shoot mass
    shootmass+=plant->mshoot;
    // root mass
    rootmass+=plant->mroot;
    // reproductive mass
    repromass+=plant->mRepro;
    // age in weeks
    int tmp_age = ((CTDPlant*)plant)->age;
    // if age <5 weeks count as seedling
    if (((CTDPlant*)plant)->age < 5) ++Nseedlings;
    	// otherwise as established individual
    	else ++Nind;
}// end addInd
//eof----------------------------------------------------------------

