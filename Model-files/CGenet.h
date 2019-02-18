/**\file
   \brief definition of class CGenet
*/
//---------------------------------------------------------------------------
#ifndef CGenetH
#define CGenetH

#include "Plant.h"
#include <vector>
using namespace std;

class CPlant;
//---------------------------------------------------------------------------
//! Class organizing ramets of a genet.
class CGenet
{
public:
	static int staticID;
	//! list of ramets
	vector<CPlant*> AllRametList;
	//! ID of genet
	int number;
	//! constructor
	CGenet():number(++staticID){};
	//! destructor
	~CGenet(){};
	//! share above-ground resources
	void ResshareA();
	//! share below-ground resources
	void ResshareB();
};

class CPlant;
/**\brief a genet consists of several ramets
*/
//---------------------------------------------------------------------------
#endif

