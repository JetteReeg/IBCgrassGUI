#!/bin/bash
echo IBCgrass GUI Copyright (C) 2019  Jette Reeg This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions.
cd ./Model-files
g++ -c -fmessage-length=0 -std=c++11 -o CEnvir.o CEnvir.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o CGrid.o CGrid.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o SPftTraits.o SPftTraits.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o OutStructs.o OutStructs.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o CSeed.o CSeed.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o LCG.o LCG.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o CTDSeed.o CTDSeed.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o CGenet.o CGenet.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o CObject.o CObject.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o Cell.o Cell.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o CTDPlant.o CTDPlant.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o GMHerbicideEffect.o GMHerbicideEffect.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o Plant.o Plant.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o CTKmodel.o CTKmodel.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o CGridEnvir.o CGridEnvir.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o RunPara.o RunPara.cpp 
g++ -c -fmessage-length=0 -std=c++11 -o CHerbEff.o CHerbEff.cpp 
g++ -o IBCgrassGUI SPftTraits.o RunPara.o Plant.o OutStructs.o LCG.o GMHerbicideEffect.o Cell.o CTKmodel.o CTDSeed.o CTDPlant.o CSeed.o CObject.o CHerbEff.o CGridEnvir.o CGrid.o CGenet.o CEnvir.o 
cd ..
Rscript "./R-files/IBC-grass.R"




