# IBCgrassGUI
Individual-based community model for grassland communities: version with herbicide impacts. Incl. graphical user interface
## Author
Jette Reeg
### Authors of earlier versions of IBCgrass
Felix May, Ines Steinhauer, Katrin Koerner, Lina Weiss, Hans Pfestorf
## Short discription
The IBC-grass GUI was developed to facilitate the use of the plant community model IBC-grass for herbicide risk assessments of non-target terrestrial plant communities in Central Europe.  Users are able to run simulations for various plant communities, which may differ in their species composition, environmental parameter settings and herbicide settings. Several different outputs can be generated on population as well as on community level.
Detailed information on the model can be found in the ODD-protocol and GMP document. 
For support, please contact Jette Reeg (jreeg@uni-potsdam.de).

Licence  
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Language
The IBCgrass model is written in C++(11) and needs to be compiled with g++.
The Graphical User Interface (GUI) is written in R using the packages RGtk2, RGtk2Extras, data.table, reshape2, foreach, doParallel, ggplot2 and ggthemes.

## Requirements

To run the IBCgrass GUI, following software need to be installed on the local machines:

GTK		The R package RGtk2 depends on gtk. It might be necessary to install gtk by hand. 

C++ compiler	e.g. MinGW (http://www.mingw.org/wiki/Getting_Started)

The software was tested on Windows 7, Windows 10 with following version:

R		3.4.1 and 3.5.2    
g++		4.8.1    
RGtk2		2.20.35 (with gtk 2.22.1)    
RGtk2Extras	0.6.1 (not supported anymore under R Version >=3.6)    
data.table	1.12.0   
reshape2	1.4.3   
foreach		1.4.4   
doParallel	1.0.14   
ggplot2		3.1.0   
ggthemes	4.0.1   

The software might be used on Ubuntu OS, if R including all necessary packages are installed locally. In that case the file "RunIBCgrassGUI.bat" needs to be adapted. Please contact jreeg@uni-potsdam.de for further details.
