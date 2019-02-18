/**\file
 * \brief entry file
 */
//---------------------------------------------------------------------------

#include <iostream>
#include <sstream>
#include <time.h>

#ifdef _WIN32
#include <windows.h>
#endif

#ifdef _WIN64
#include <windows.h>
#endif

#ifdef __linux__
#include <unistd.h>
#endif

#ifdef __APPLE__
#include <unistd.h>
#endif

//the only information the GUI needs from the model
#include "CHerbEff.h"
#include "CTKmodel.h"


//------------------------------------------------------------------------------
/**\mainpage Grassland Model (for console) - documentation

\author
Felix May (basic model, ZOI, cutting option) and
Ines Steinhauer (clonal option)
\author Katrin Koerner (revision and rebuilt Felix' grazing experiments,
  belowground grazing)
\author Jette Reeg (herbicide disturbances)

\date 2008-02-13 (first version of the model)
\date 2009-05 (revision)
\date 2010-01 (Felix' grazing rebuilt and belowground grazing)
\date 2010-03 (Ines' clonal plants' rebuilt)
\date 2010-07 (Lina's real-PFT Simulations)
\date 2013-07 (Jette's herbicide risk assessment)

\par Verbal description of what the code does:
This code runs real (field-observed) PFT-combinations with or without considering herbicide effects

\par Type (function, class, unit, form, ...):
c++ written application with different classes

\par Flow chart (for complex code):
\image html Flowchart.jpg "FlowChart of the herbicide model version. In: Reeg et al.(2018a)"
Flowchart of IBC-grass incl. herbicide induced processes.

\par Expected input (type and range of values, units):
- input file for definitions of plant types initially used
- a list of program arguments
- input file of herbicide effects if read from txt-file
Input files and program arguments are defined by the GUI built in R

\sa main() for program arguments

\par Output (type and range of values, units):
- ASCII-coded *.txt-files with weekly variables PFT specific or summarized over the whole grid

\par Requirements and environment (libraries, headers):
- standard C++ - compatible compiler needed (working IDE is eclipse)
- GUI uses g++ compiler


\par Sensitivity analysis (reference to publication):
- Weiss et al. (2014)
- with regard to herbicide effects: Reeg et al. (2018a)

\par Validation (reference to publication):
- Weiss et al. (2014)
- Reeg et al. (2018b)

\par Sources or reasons for parameter values, methods, equations:
see publications of May(2008), Steinhauer(2008), Weiss et al (2014), Reeg et al (2017, 2018a, 2018b)

\bug
see additional page for solved and unsolved bugs

\par Publications or applications referring to the code:
- Reeg J, Heine S, Mihan C, McGee S, Preuss TG, Jeltsch F. 2018b.
  Simulation of herbicide impacts on a plant community:
  comparing model predictions of the plant community model IBC-grass to empirical data.
  Environ Sci Eur. 30:44. doi: 10.1186/s12302-018-0174-9
- Reeg J, Heine S, Mihan C, Preuss TG, McGee S, Jeltsch F. 2018a.
  Potential impact of effects on reproductive attributes induced by herbicides on a plant community.
  Environmental Toxicology and Chemistry. doi: 10.1002/etc.4122
- Reeg, J., Schad, T., Preuss, T.G., Solga, A., Koerner, K., Mihan, C., Jeltsch, F., 2017.
  Modelling direct and indirect effects of herbicides on non-target grassland communities.
  Ecol. Modell. 348, 44-55. doi:10.1016/j.ecolmodel.2017.01.010
- Weiss L, H Pfestorf, F May, K Koerner, S Boch, M Fischer, J Mueller,
  D Prati, S Socher , F Jeltsch (2014)
  Grazing response patterns indicate isolation of semi-natural
  European grasslands. Oikos
- Koerner, K., Pfestorf, H., May, F., Jeltsch, F., 2014.
  Modelling the effect of belowground herbivory on grassland diversity.
  Ecological Modelling 273, 79-85.
- May, Felix, Grimm, Volker and Jeltsch, Florian (2009): Reversed effects of
  grazing on plant diversity: the role of belowground competition
  and size symmetry. Oikos 118: 1830-1843.
- Steinhauer, Ines (2008): KOEXISTENZ IN GRASLANDGESELLSCHAFTEN -
  Modellgestuetzte Untersuchungen unter Beruecksichtigung klonaler Arten.
  Diplomarbeit Universitaet Potsdam
- May, Felix (2008): Modelling coexistence of plant functional types
  in grassland communities - the role of above- and below-ground competition.
  Diploma thesis Potsdam University.
*/

//---------------------------------------------------------------------------
CHerbicideEffectEnv* Envir;   ///<environment in which simulations are run
using namespace std;

void Init();
void Run();
time_t GetSec(){
  time_t CurrentTime;
  time(&CurrentTime);
  return CurrentTime;
};

/** \brief entry point
 *
  The experimental design is read from program arguments
  (sample values in brackets):
  general parameters
  -#  ModelVersion (3); // mode of density denpendent mortality and competition
  -#  CellNum (173); // grid size (cm)
  -#  Tmax (100); // maximal number of years simulated
  -#  Tinit (50); // initial years before herbicide effects are simulated
  -#  NamePftFile ("Fieldedge.txt"); // PFT list
  -#  NameHerbEffectFile ("HerbFact.txt"); // fixed herbicide effect values
  -#  seedsPerType (10); // degree of isolation as number of seed input per year
  resources
  -#  meanBRes (90); // belowground resources
  -#  meanARes (100); // aboveground resources
  -#  Aampl (0.7); // amplitude of seasonal distribution of aboveground resources (based on day length)
  -#  Bampl (0); // amplitude of seasonal distribution of belowground resources
  disturbances
  -#  AreaEvent (0.1); // amount of area trampled per year
  -#  GrazProb (0.01); // amount of area grazed per year
  -#  NCut (1); // number of cutting events per year
  herbicide impact parameter
  -#  week_start (1); // week of application of herbicide
  -#  Generation ("F0"); // affected generation
  -#  HerbDuration (30); // number of years simulated with herbicide effect
  -#  HerbEffectType (1); // defines simulation run as treatment of control (1 - treatment; 0 - control)
  -#  EffectModel (0); // defines on which input herbicide effects are based (0 - txt file 2 - dose response)
  -#  app_rate (260); // application rate (only used if EffectModel is 2)
  -#  MCrun (1); // number of monte carlo runs

Output file names are given for each run individually.
*/
int main(int argc, char* argv[])
{
	#ifdef _WIN32
	DWORD pid=GetCurrentProcessId();
	#endif

	#ifdef _WIN64
	DWORD pid=GetCurrentProcessId();
	#endif

	#ifdef __linux__
	long int pid=getpid();
	#endif

	#ifdef __APPLE__
	long int pid=getpid();
	#endif


	initLCG( pid, 3487234);
	if (argc>=2) {
		// example parameters:
		// 3 50 5 1 Fieldedge.txt HerbFact.txt 10 90 100 0 0.1 0.01 1 1 0 0 0 1
		//general parameter
		SRunPara::RunPara.ModelVersion=atoi(argv[1]); // mode of density denpendent mortality and competition
		SRunPara::RunPara.CellNum=atoi(argv[2]); // grid size
		SRunPara::RunPara.Tmax=atoi(argv[3]); // maximal number of years simulated
		SRunPara::RunPara.Tinit=atoi(argv[4]); // initial years before herbicide effects are simulated
		SRunPara::RunPara.NamePftFile=argv[5]; // PFT list
		SRunPara::RunPara.NameHerbEffectFile=argv[6]; // fixed herbicide effect values
		SRunPara::RunPara.seedsPerType=atoi(argv[7]); // degree of isolation as number of seed input per year
		// resources
		SRunPara::RunPara.meanBRes=atoi(argv[8]); // belowground resources
		SRunPara::RunPara.meanARes=atoi(argv[9]); // aboveground resources
		SRunPara::RunPara.Aampl=atof(argv[10]); // amplitude of seasonal distribution of aboveground resources (based on day length)
		SRunPara::RunPara.Bampl=0; // amplitude of seasonal distribution of belowground resources
		// disturbances
		SRunPara::RunPara.AreaEvent=atof(argv[11]); // amount of area trampled per year
		SRunPara::RunPara.GrazProb=atof(argv[12]); // amount of area grazed per year
		SRunPara::RunPara.NCut=atoi(argv[13]); // number of cutting events per year
		//herbicide impact parameter
		SRunPara::RunPara.week_start=1; // week of application of herbicide
		SRunPara::RunPara.Generation="F0"; // affected generation
		SRunPara::RunPara.HerbDuration=atoi(argv[14]); // number of years simulated with herbicide effect
		SRunPara::RunPara.HerbEffectType=atoi(argv[15]); // defines simulation run as treatment of control (1 - treatment; 0 - control)
		SRunPara::RunPara.EffectModel=atoi(argv[16]); // defines on which input herbicide effects are based (0 - txt file 2 - dose response)
		SRunPara::RunPara.app_rate=atof(argv[17]); // application rate (only used if EffectModel is 2)
		SRunPara::RunPara.MCrun=atoi(argv[18]); // number of monte carlo runs
}

	SRunPara::RunPara.GridSize=SRunPara::RunPara.CellNum; // normally 173 for pot experiments smaller

	Envir=new CHerbicideEffectEnv();

	// generating file names
    string idstr= SRunPara::RunPara.getRunID();
    stringstream strd;
    // PFT output
    strd<<"Pt_"<<idstr
        <<".txt";
	Envir->NamePftOutFile=strd.str();
	// Ind output
	strd.str("");// clear stream
	strd<<"Ind_"<<idstr
              <<".txt";
	Envir->NameIndOutFile=strd.str();
	// Grd output
	strd.str("");// clear stream
	strd<<"Grd_"<<idstr<<".txt";
	Envir->NameGridOutFile=strd.str();
	//needed for random_shuffle()
	srand (time (0));
	// initialize run
	Init();
	// get herbicide effect data
	CTKmodel::GetHerbEff();
	// start run
	Run();
	// reset
	delete Envir;
	SPftTraits::PftLinkList.clear();
	return 0;
}
//---------------------------------------------------------------------------
void Init(){
	// read PFT List
	SPftTraits::ReadPFTDef(SRunPara::NamePftFile);
	// initialize environment
    Envir->InitRun();
}
//---------------------------------------------------------------------------
void Run(){
	Envir->OneRun();
	cout<<"finished";
}

//eof---------------------------------------------------------------------------
