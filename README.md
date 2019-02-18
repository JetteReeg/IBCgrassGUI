# IBCgrassGUI
Individual-based community model for grassland communities: version with herbicide impacts. Incl. graphical user interface
## Author
Jette Reeg
### Authors of earlier versions of IBCgrass
Felix May, Ines Steinhauer, Katrin Koerner, Lina Weiss, Hans Pfestorf
## Short discription
This software includes not only the source code of IBCgrass including the herbicide impact modules. It also comes with a graphical user interface to facilitate the use of IBCgrass in herbicide risk assessment of non-target terrestrial plants. 
For further information, including a manual, ODD protocol, DoxyGen Documentation and further literature pleaqse go to the 'Manual, GMP, ODD, Literature' folder.
## Language
The IBCgrass model is written in C++(11) and needs to be compiled with g++.
The Graphical User Interface (GUI) is written in R using the packages RGtk2, RGtk2Extras, data.table, reshape2, foreach, doParallel, ggplot2 and ggthemes.
## Requirements
The software needs R to be installed and set as environmental variable and g++ to compile the IBCgrass code.
The software was tested on Windows 7 and higher, Ubuntu 16.04 and MAC iOS. 
