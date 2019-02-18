//---------------------------------------------------------------------------
#ifndef CObjectH
#define CObjectH
#include <string>
//---------------------------------------------------------------------------
using namespace std;
//!base class for seeds and plants
class CObject{
public:
	//! Constructor
	CObject(){};
	//! Destructor
	virtual ~CObject(){};
	//! say what you are
   	virtual string type();
};
#endif
