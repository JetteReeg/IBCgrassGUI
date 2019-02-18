/** \file
    \brief functions of class CGenet
*/
//---------------------------------------------------------------------------

#include "CGenet.h"
#include "cmath"

//----------------------------------------------------------------------------
int CGenet::staticID=0;
/**
 * Calculate the mean of the shared aboveground uptakes of one genet and save this
 * as the uptake for each plant of this genet.
 */
void CGenet::ResshareA()
{
	double sumAuptake=0;
	double MeanAuptake=0;
	const int listsize=this->AllRametList.size();
	// go through all ramets
	for (int m=0; m<listsize;m++)
	{
    	double AddtoSum=0;
    	CPlant* Ramet = AllRametList[m];
    	// minimal uptake of the ramet
    	double minres= Ramet->Traits->mThres
                     *Ramet->Ash_disc
                     *Ramet->Traits->Gmax*2;
    	//resource to share is uptake - minimal resources needed
    	AddtoSum=max(0.0,Ramet->Auptake-minres);
    	//if the plant has enough resources
    	//new uptake is the min amount of resources
    	if (AddtoSum>0)    Ramet->Auptake=minres;
    	// counting resources not needed by the ramet
    	sumAuptake+=AddtoSum;
	}// end for all ramets
	// mean shared uptake per ramet
	MeanAuptake=(sumAuptake/(double)listsize);

	//Add the shared resources (MeanAuptake) to the uptake of each ramet
	for (int m=0; m<listsize;m++)
		AllRametList[m]->Auptake+=MeanAuptake;
} //end CGridclonal::ResshareA
//-----------------------------------------------------------------------------
/**
 * Calculate the mean of the shared belowground uptakes of one genet and save this
 * as the uptake for each plant of this genet.
 */
void CGenet::ResshareB()
{
	double sumBuptake=0;
	double MeanBuptake=0;
	// go through all ramets
    for (unsigned int m=0; m<AllRametList.size();m++)//for all ramets of the genet
    {
       double AddtoSum=0;
       CPlant* Ramet =AllRametList[m];
       // minimal uptake needed for the ramet
       double minres= Ramet->Traits->mThres*Ramet->Art_disc*Ramet->Traits->Gmax*2;
       // resource to share is uptake - minimal resources needed
       AddtoSum=max(0.0,Ramet->Buptake-minres);
       //if the plant has enough resources
       //new uptake is the min amount of resources
       if (AddtoSum>0)Ramet->Buptake=minres;
       sumBuptake+=AddtoSum;
    }// end for all ramets
	// mean shared uptake per ramet
    MeanBuptake=(sumBuptake/(AllRametList.size()));

    //Add the shared resources to the uptake of each ramet
    for (unsigned int m=0; m<AllRametList.size();m++)
    	AllRametList[m]->Buptake+=MeanBuptake;
}//end CGridclonal::ResshareB
//eof---------------------------------------------------------------------



