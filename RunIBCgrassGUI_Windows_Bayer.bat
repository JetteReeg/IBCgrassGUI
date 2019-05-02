echo IBCgrass GUI Copyright (C) 2019  Jette Reeg This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions.

cd ./Model-files
g++ -c -fmessage-length=0 -std=c++0x -o CEnvir.o CEnvir.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o CGrid.o CGrid.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o SPftTraits.o SPftTraits.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o OutStructs.o OutStructs.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o CSeed.o CSeed.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o LCG.o LCG.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o CTDSeed.o CTDSeed.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o CGenet.o CGenet.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o CObject.o CObject.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o Cell.o Cell.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o CTDPlant.o CTDPlant.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o GMHerbicideEffect.o GMHerbicideEffect.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o Plant.o Plant.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o CTKmodel.o CTKmodel.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o CGridEnvir.o CGridEnvir.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o RunPara.o RunPara.cpp 
g++ -c -fmessage-length=0 -std=c++0x -o CHerbEff.o CHerbEff.cpp 
g++ -static -o IBCgrassGUI SPftTraits.o RunPara.o Plant.o OutStructs.o LCG.o GMHerbicideEffect.o Cell.o CTKmodel.o CTDSeed.o CTDPlant.o CSeed.o CObject.o CHerbEff.o CGridEnvir.o CGrid.o CGenet.o CEnvir.o 
cd ..
"C:\Program Files\R\R-3.1.3\bin\i386\Rscript.exe" "./R-files/IBC-grass.R"
