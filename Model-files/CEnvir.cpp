/**\file CEnvir.cpp
   \brief functions and static defaults of environmental classes
*/
//---------------------------------------------------------------------------
#include "CEnvir.h"
#include <iostream>
#include <time.h>
#include <iomanip>
#include <sstream>

using namespace std;
//-CEnvir: Init static variables--------------------------------------------------------------------------
	//! week
	int CEnvir::week=0;
	//! year
	int CEnvir::year=1;
	//! nb of weeks per year
	int CEnvir::WeeksPerYear=30;

	//Output Files
	//! output for PFT
	string CEnvir::NamePftOutFile= "PftOut.txt";
	//! output for individuals
	string CEnvir::NameIndOutFile= "IndOut.txt";
	//! output for grid
	string CEnvir::NameGridOutFile= "GridOut.txt";
	//! aboveground resources
	vector<double> CEnvir::AResMuster;
	//! belowground resources
	vector<double> CEnvir::BResMuster;
	//! list of Pfts used
	map<string,long> CEnvir::PftInitList;
	//! random number generator
	RandomGenerator CEnvir::rng;
//---------------------------------------------------------------------------
/**
 * constructor for virtual class
 */
 CEnvir::CEnvir():
  NCellsAcover(0),init(1),endofrun(false)
{
	 //! set the landscape
	 ReadLandscape();
	 //! set aboveground cover to zero
	 ACover.assign(SRunPara::RunPara.GetSumCells(),0);
	 //! set belowground cover to zero
	 BCover.assign(SRunPara::RunPara.GetSumCells(),0);
}// end constructor
//------------------------------------------------------------------------------
/**
 * destructor -
 * free summarizing data sets
 */
 CEnvir::~CEnvir(){
	for (unsigned int i=0;i<GridOutData.size();i++) delete GridOutData[i];
	for (unsigned int i=0;i<PftOutData.size();i++)  delete PftOutData[i];
}
//------------------------------------------------------------------------------
/**
  Function defined global muster resources, set to gridcells at beginning
  of each Year. At the moment only evenly distributed single values for above-
  and belowground resources are implemented.
  Later the function can read source files of values <100\% autocorrelated or
  generate some noise around fixed values etc..
*/
void CEnvir::ReadLandscape(){
	AResMuster.clear();BResMuster.clear();
	//! set aboveground resources to meanARes value
	AResMuster.assign(SRunPara::RunPara.GetSumCells(),
		  SRunPara::RunPara.meanARes);
	//! set belowground resources to meanBRes value
	BResMuster.assign(SRunPara::RunPara.GetSumCells(),
		  SRunPara::RunPara.meanBRes);
}//end ReadLandscape
//------------------------------------------------------------------------------
/**
 * initializes a new run
 * clears OutData structures, PFTinitlist, PFTsurvtime, and sets endofrun to false
 */
void CEnvir::InitRun(){
	for (unsigned int i=0;i<GridOutData.size();i++) delete GridOutData[i];
	for (unsigned int i=0;i<PftOutData.size();i++)  delete PftOutData[i];
	PftInitList.clear();
	PftSurvTime.clear();
	PftOutData.clear();
	GridOutData.clear();
	endofrun=false;
	//! set resources
	ReadLandscape();
}
//------------------------------------------------------------------------------
/**
 * File Output..
 * writes the output of the PFT, GRD and/or Ind files over the whole period of simulation
 *
 */
void CEnvir::WriteOFiles() {
	//! at the end of the run
	if (year == SRunPara::RunPara.Tmax || endofrun==true){
		//! write grid file
		WriteGridComplete();
		//! write PFT file
		WritePftComplete(year);
		//! may write Ind file
		//WriteIndComplete(year);
	}
}
//------------------------------------------------------------------------------
/**
 * File Output - grid-wide summaries
 * @param allYears write all data or only the last entry?
 */
void CEnvir::WriteGridComplete(bool allYears)
{
	//Open GridFile
	ofstream GridOutFile(NameGridOutFile.c_str(),ios::app);
	if (!GridOutFile.good()) {cerr<<("Error while opening GridOutFile");exit(3); }
	// write header
	GridOutFile.seekp(0, ios::end);
	long size=GridOutFile.tellp();
	if (size==0){
		GridOutFile<<"Time\t"
			  <<"totMass\tNInd\t"
			  <<"abovemass\tbelowmass\t"
			  <<"mean_ares\tmean_bres\t"
			  <<"shannon\tmeanShannon\t"
			  <<"NPFT\tmeanNPFT\tCutted\t"
			  <<"NNonClonal\tNClonal\tmean_generation\tmean_genet_size\tNGenets"
			  ;
		GridOutFile<<"\n";
	}

	vector<SGridOut>::size_type i=0;
	if (!allYears) i= GridOutData.size()-1;
	// get values for each week and all years
	for ((i); i<GridOutData.size(); ++i){
		GridOutFile<<GridOutData[i]->week
				 <<'\t'<<GridOutData[i]->totmass
				 <<'\t'<<GridOutData[i]->Nind
				 <<'\t'<<GridOutData[i]->above_mass
				 <<'\t'<<GridOutData[i]->below_mass
				 <<'\t'<<GridOutData[i]->aresmean
				 <<'\t'<<GridOutData[i]->bresmean
				 <<'\t'<<GridOutData[i]->shannon
				 <<'\t'<<GetMeanShannon(10)
				 <<'\t'<<GridOutData[i]->PftCount
				 <<'\t'<<GetMeanNPFT(10)
				 <<'\t'<<GridOutData[i]->cutted
				 <<'\t'<<GridOutData.back()->NPlants
				 <<'\t'<<GridOutData.back()->NclonalPlants
				 <<'\t'<<GridOutData[i]->MeanGeneration
				 <<'\t'<<GridOutData[i]->MeanGenetsize
				 <<'\t'<<GridOutData.back()->NGenets
			  <<"\n";
	}// end for each week and year
	GridOutFile.close();
}//WriteGridComplete
//------------------------------------------------------------------------------
/**
 * File output - summarizing PFT information
 * @param allYears years to be included in output
*/
void CEnvir::WritePftComplete(unsigned int allYears)
{
	//Open PftFile
	ofstream PftOutFile(NamePftOutFile.c_str(),ios_base::app);
	if (!PftOutFile.good()) {cerr<<("Error opening PftOutFile");exit(3); }
	// write header
	PftOutFile.seekp(0, ios::end);
	long size=PftOutFile.tellp();
	if (size==0){
	 PftOutFile<<"Time";
	 PftOutFile<<"\tInds\tseedlings\tseeds\trepromass\tcover\tshootmass\tPFT";
	 PftOutFile<<"\n";
	}
	// for all PFTS and each week in each year
	vector<SPftOut>::size_type i=0;
	for ((i); i < PftOutData.size(); ++i) {
		if (PftOutData[i]->week >= CEnvir::GetT() - allYears * WeeksPerYear) {
			typedef map<string, SPftOut::SPftSingle*> mapType;

			for (mapType::const_iterator it = PftOutData[i]->PFT.begin();
					it != PftOutData[i]->PFT.end(); ++it) {
				PftOutFile << i+1;
				PftOutFile << '\t' << it->second->Nind;
				PftOutFile << '\t' << it->second->Nseedlings;
				PftOutFile << '\t' << it->second->Nseeds;
				PftOutFile << '\t' << it->second->repromass;
				PftOutFile << '\t' << it->second->cover;
				PftOutFile << '\t' << it->second->shootmass;
				PftOutFile << '\t' << it->first;

				PftOutFile << "\n";
			}//end for each PFT
		}// end for each week
	}// end for each week
	PftOutFile.close();
}//end WritePftComplete()
//------------------------------------------------------------------------------
/**
 * File output - summarizing Ind information
 * @param allYears years to be included in output
 * \note currently not active
*/
void CEnvir::WriteIndComplete(unsigned int allYears)
{
	//Open PftFile
	ofstream IndOutFile(NameIndOutFile.c_str(),ios_base::app);
	if (!IndOutFile.good()) {cerr<<("Error opening IndOutFile");exit(3); }
	// write header
	IndOutFile.seekp(0, ios::end);
	long size=IndOutFile.tellp();
	if (size==0){
		 IndOutFile<<"Time";
		 IndOutFile<<"\tPFT\tAge\tshootmass\trootmass";
		 IndOutFile<<"\n";
	}

	vector<SIndOut>::size_type i=0;
	// for each individual
	for ((i); i < IndOutData.size(); ++i) {
		IndOutFile << IndOutData[i]->week
				<< '\t' << IndOutData[i]->name
				<< '\t' << IndOutData[i]->age
				<< '\t' << IndOutData[i]->shootmass
				<< '\t' << IndOutData[i]->rootmass
				<< "\n";
	}// for each individual
   IndOutFile.close();
}//end WriteIndComplete()
//------------------------------------------------------------------------------
/**
 * extract mean Shannon Diversity
 * @param years time steps to accumulate
 * @return Shannon Diversity value
 */
double CEnvir::GetMeanShannon(int years)
{
	double sum=0, count=0;

	int start=(GridOutData.size()-1)-years;
	// go through all weeks of the last 10 years
	for (vector<SGridOut>::size_type i=start+1; i<GridOutData.size(); ++i){
		  sum+=GridOutData[i]->shannon;
		  count++;
	}
	// return mean shannon
	return sum/count;
}// end GetMeanShannon
//---------------------------------------------------------------------------
/**
 * extract mean PFT number
 * @param years time steps to accumulate
 * @return number of PFTs
 */
double CEnvir::GetMeanNPFT(int years)
{
	double sum=0, count=0;
	int start=(GridOutData.size()-1)-years;
	// go through all weeks of the last 10 years
	for (vector<SGridOut>::size_type i=start+1; i<GridOutData.size(); ++i){
		  sum+=GridOutData[i]->PftCount;
		  count++;
	}
	// return mean number of PFTs
	return sum/count;
}// end GetMeanNPFT
//---------------------------------------------------------------------------
/**
 * extract current population size
 * @param pft PFT asked for
 * @return population size of PFT pft
 */
double CEnvir::GetCurrPopSize(string pft){
	// if PFT not found return 0
	if (PftOutData.back()->PFT.find(pft)== PftOutData.back()->PFT.end())
		return 0;
	// else return number of individuals
	SPftOut::SPftSingle* entry
	  	  =PftOutData.back()->PFT.find(pft)->second;
	return entry->Nind;
}// end GetCurrPopSize
//---------------------------------------------------------------------------
//eof
