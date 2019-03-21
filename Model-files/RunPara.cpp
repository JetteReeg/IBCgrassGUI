/**\file
\brief constructor of struct SRunPara and Initialization of static Variables
*/
//---------------------------------------------------------------------------

#include "RunPara.h"
#include "CHerbEff.h"
#include <iostream>
#include <cstdlib>
#include <sstream>
//---------------------------------------------------------------------------
using namespace std;
//Input Files
//! trait file for PFT community
std::string SRunPara::NamePftFile="Fieldedge.txt";
//! effect file for herbicide induced impacts based on a txt file
std::string SRunPara::NameHerbEffectFile="HerbFact.txt";
//! Application rates per year
std::string SRunPara::NameAppRateFile="AppRate.txt";
//! parameters of specific run
SRunPara SRunPara::RunPara=SRunPara();
//---------------------------------------------------------------------------
/**
 * constructor with example values
 */
SRunPara::SRunPara():Version(version2),AboveCompMode(asympart),BelowCompMode(sym),
  mort_base(0.007),LitterDecomp(0.5),DiebackWinter(0.5),EstabRamet(1),
  GridSize(173),CellNum(173),Tmax(10),Tinit(20),NPft(81),GrazProb(0),PropRemove(0.5),BitSize(0.5),HerbDuration(0),
  HerbEffectType(0),
  CutMass(500),NCut(0),torus(true), seedsPerType(20), week_start(1),
  DistAreaYear(0),AreaEvent(0.1),mort_seeds(0.5),meanARes(100),meanBRes(100), ModelVersion(2), EffectModel(1),
  Aampl(0),Bampl(0),
  Generation("F0"),
  scenario(0),
  ITVsd(0.0)
{}
//-------------------------------------------------------------------
/**
 * create name of simulation file
 */
std::string SRunPara::getRunID(){
	stringstream dummi;
	string dummi2;
	// distinguish between control and treatment
	if (SRunPara::RunPara.HerbEffectType==0) dummi2="control";
	if (SRunPara::RunPara.HerbEffectType==1) dummi2="treatment";
	// add type, Apprate, MCrun into file name
	dummi<<"_type_"<<dummi2
	   <<"_Scenario_"<<SRunPara::RunPara.scenario
	   <<"_MCrun_"<<SRunPara::RunPara.MCrun;
	// return the file name string
	return dummi.str();
}// string for file name generation
//eof  ---------------------------------------------------------------------
