g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o CEnvir.o CEnvir.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o CGrid.o CGrid.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o SPftTraits.o SPftTraits.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o OutStructs.o OutStructs.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o CSeed.o CSeed.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o LCG.o LCG.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o CTDSeed.o CTDSeed.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o CGenet.o CGenet.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o CObject.o CObject.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o Cell.o Cell.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o CTDPlant.o CTDPlant.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o GMHerbicideEffect.o GMHerbicideEffect.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o Plant.o Plant.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o CTKmodel.o CTKmodel.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o CGridEnvir.o CGridEnvir.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o RunPara.o RunPara.cpp 
g++ -static -static-libgcc -static-libstdc++ -c -fmessage-length=0 -std=c++11 -o CHerbEff.o CHerbEff.cpp 
g++ -static -static-libgcc -static-libstdc++ -o IBCgrassGUI SPftTraits.o RunPara.o Plant.o OutStructs.o LCG.o GMHerbicideEffect.o Cell.o CTKmodel.o CTDSeed.o CTDPlant.o CSeed.o CObject.o CHerbEff.o CGridEnvir.o CGrid.o CGenet.o CEnvir.o 


