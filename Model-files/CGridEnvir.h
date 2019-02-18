/*
 * CGridEnvir.h
 *
 *  Created on: 24.04.2014
 *      Author: KatrinK
 */

#ifndef CGRIDENVIR_H_
#define CGRIDENVIR_H_

#include "CEnvir.h"
#include <vector>
using namespace std;
//---------------------------------------------------------------------------
/// simulation service class including grid-, result- and environmental information
/**
   The class collects simulation environment with clonal properties.
   CGridclonal and CEnvir are connected, and some Clonal-specific
   result-variables added.
*/
class CGridEnvir: public CEnvir, public CGrid{
protected:
public:
  //! Constructor
  CGridEnvir();
  //CGridEnvir(string id); ///< load from file(s)
  //! Destructor
  virtual ~CGridEnvir();///<delete clonalTraits;

  ///\name core simulating Functions
  ///@{
  //! InitRun (from CEnvir)
  void InitRun();
  //! One year function
  void OneYear();
  //! One run function
  void OneRun();
  //! One week function
  void OneWeek();
  //! get surviving PFTs (from CEnvir)
  int PftSurvival();
  ///@}

  /// \name collect general results
  ///@{
  //! get model output
  void GetOutput();
  //! get model output for clonal attributes
  void GetClonOutput(SGridOut& GridData);
  //! get annually cutted biomass after week 22
  void GetOutputCutted();
  ///@}
  ///\name init new Individuals/Seeds
  ///@{
  //! initialization of individuals on grid
  void InitInds();
  //! intitialize individuals from one file
  virtual void InitInds(string file,int n=-1);
  //! initialization of seeds on grid
  void InitSeeds(int);
  //! initialize PFT seeds
  void InitSeeds(string, int);
  ///@}

  ///\name Functions to get Acover and Bcover of cells.
  /** It is assumed that coordinates/indices match grid size.
       Functions have to be called after function CGrid::CoverCells and before
       first function calling delete for established plants in the same week.
       else undefined behavior including access violation is possible.
     \note depends (at least) on an inherited subclass of CGrid
  */
  ///@{
  //! get aboveground cover
  int getACover(int x, int y);
  //! get belowground cover
  int getBCover(int x, int y); ///< get the belowground cover
  //! get PFT cover
  double getTypeCover(const string type)const; ///< get cover per PFT

private:
  //! get aboveground cover on grid
  int getGridACover(int i);
  //! get belowground cover on grid
  int getGridBCover(int i);
  //! get cover per PFT
  double getTypeCover(const int i, const string type)const;
  //! set cell state information
  void setCover();
  ///@}
};

#endif /* CGRIDENVIR_H_ */
