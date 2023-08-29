#####
# libraries
#####
library(foreach)
library(doParallel)
library(labeling)s
#####
# Notes
#####
# -------------- Make sure to compile IBC before running this code ----------- #
# ----------------- run Model-files/CompileIBC.bat --------------------------- #
# code is copied/adapted from R-files/SimulationSpecificSettings.R
#####
# Load previously saved simulation settings 
#####
# You can use the GUI to generate the SimulationSettings.Rdata
# simply run a very small test script (min. repetitions, min. years, min. grid size) and save the project
# You then might want to adapt some of the settings manually (e.g. increase repetitions, number of simulated years etc.)
load("ExampleAnalyses/DoseResponse/HerbicideSettings/SimulationSettings.Rdata") # just as an example for this script
#####
# read PFT community file and sensitivity file
#####
ModelVersion <- 3
PFTfileName <- get("IBCcommunity", envir=SaveEnvironment) # txt-file with trait parameters of all species
PFTHerbEffectFile <- "./HerbFact.txt" # you need this file if you run IBC with manual effects
AppRateFile <- "./AppRate.txt" # you need this file if you run IBC with dose-response data
MCruns <- get("IBCrepetition", envir=SaveEnvironment) # nb of repetitions 
GridSize <- get("IBCgridsize", envir=SaveEnvironment) # area of the grid
SeedInput <- get("IBCSeedInput", envir=SaveEnvironment) # external seed input
belowres <- get("IBCbelres", envir=SaveEnvironment) # belowground resources
abres <- get("IBCabres", envir=SaveEnvironment) # aboveground resources
abampl <- get("IBCabampl", envir=SaveEnvironment) # seasonal amplitude of aboveground resources
graz <- get("IBCgraz", envir=SaveEnvironment) # grazing intensity
tramp <- get("IBCtramp", envir=SaveEnvironment) # trampling intensity
cut <- get("IBCcut", envir=SaveEnvironment) # cutting/mowing events
week_start <- get("IBCweekstart", envir=SaveEnvironment)-10 # start of the herbicide application (calendar week); note that IBC only simulate growing period
HerbDuration <- get("IBCDuration", envir=SaveEnvironment) # hericide duration [years]
RecovDuration <- get("IBCRecovery", envir=SaveEnvironment) # recovery duration [years]
InitDuration <- get("IBCInit", envir=SaveEnvironment) # intial years 
Tmax <- InitDuration + HerbDuration + RecovDuration # years to simulate
HerbEff <- get("IBCherbeffect", envir=SaveEnvironment) # txt or dose response
if(HerbEff=="txt-file") EffectModel <- 0
if(HerbEff=="dose-response") EffectModel <- 2
Scenarios <- as.numeric(get("IBCScenarios", envir=SaveEnvironment)) # number of rates tested
nb_data <- as.numeric(get("nb_data", envir=SaveEnvironment)) # number of test species

#####
# running control
#####
scenario <- 0 # for control runs
# copy community file into Model-folder
path <- "Model-files/"
write.table(get("IBCcommunityFile", envir=SaveEnvironment), paste(path,PFTfileName, sep=""), sep="\t", quote=F,row.names=F) # make sure the Model-files folder includes the file of your PFT community 

copy <- file.copy("Input-files/HerbFact.txt",  path) # make sure the Model-files folder includes the HerbFact.txt file 
copy <- file.copy("Input-files/AppRate.txt",  path) # make sure the Model-files folder includes the AppRate.txt file

# Change directory
setwd('Model-files')
# determine the number of cores that can be used (for parallel running)
no_cores <- max(detectCores()-2,1) # you might want to adapt this and give a specific number of cores (e.g. when using a HPC)
cl <- makeCluster(no_cores)
registerDoParallel(cl)

# Start control simulations in parallel with the given settings
foreach(MC = 1:MCruns)  %dopar%
  system(paste('./IBCgrassGUI', ModelVersion, GridSize, Tmax, InitDuration, PFTfileName, SeedInput, belowres, abres, abampl, tramp, graz, cut,
               week_start, HerbDuration, 0, EffectModel, scenario, MC, sep=" "), intern=T)
stopCluster(cl)

# change directory
setwd('..')

# remove files before running treatment
remove <- file.remove(paste("Model-files/", PFTfileName, sep=""))
remove <- file.remove("Model-files/HerbFact.txt")
remove <- file.remove("Model-files/AppRate.txt")

#####
# copy control simulations
#####
# create folder
dir.create("currentSimulation/0", recursive=TRUE) # adapt path if needed

# PFT files
file_list <- list.files(path = "Model-files/", pattern="Pt__*")
for (file in file_list){
  path <- paste("currentSimulation/", unlist(strsplit(file,"_"))[6], sep="")
  copy <- file.copy(paste("Model-files/" ,file , sep="") ,  path)
  if (copy==T) file.remove(paste("Model-files/" ,file , sep="") )
}

# GRD files
file_list <- list.files(path = "Model-files/", pattern="Grd__*", recursive=TRUE)
for (file in file_list){
  path <- paste("currentSimulation/", unlist(strsplit(file,"_"))[6], sep="")
  copy <- file.copy(paste("Model-files/" ,file , sep="") ,  path)
  if (copy==T) file.remove(paste("Model-files/" ,file , sep="") )
}

#####
# running treatment based on txt file (not in this example)
#####
if(HerbEff=="txt-file"){
  # cluster for parallel processing
  no_cores <- max(detectCores()-2,1) # you might want to adapt this and give a specific number of cores (e.g. when using a HPC)
  cl <- makeCluster(no_cores)
  registerDoParallel(cl)
  
  # generate PFTfile with herbicide sensitivities 
  
  PFTfile <- get("IBCcommunityFile", envir=SaveEnvironment)
  PFTsensitivity <- get("PFTSensitivityFile", envir=SaveEnvironment) # here the sensitivity of all PFTs are stored
  
  # run treatment simulations
  foreach(MC = 1:MCruns, .export=c("PFTfile", "PFTsensitivity", "PFTfileName", "EffectModel",
                                   "ModelVersion", "belowres", "abres", "abampl", "Tmax", "InitDuration", "GridSize", "SeedInput",
                                   "HerbDuration", "tramp", "graz", "cut", "week_start"))  %dopar%
    {
      scenario <- 1 # for treatment simulations
  
      # Generate PFTfile for each MC run
      PFTfile<-merge(PFTfile, PFTsensitivity, by="Species")
      
      #make sure, all values are set to 0 (no affect)
      PFTfile[,25] <- 0
      
      # set random values
      PFTfile[PFTfile$Sensitivity=="random",25] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = 0, max = 1))
      
      # set full values
      PFTfile[PFTfile$Sensitivity=="full",25] <- c(rep(1, nrow(PFTfile[PFTfile$Sensitivity=="full",])))
      
      # set high values
      PFTfile[PFTfile$Sensitivity=="high",25] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="high",]),  min = 0.66, max = 1))
      
      # set medium values
      PFTfile[PFTfile$Sensitivity=="medium",25] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="medium",]),  min = 0.35, max = 0.65))
      
      # set low values
      PFTfile[PFTfile$Sensitivity=="low",25] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="low",]),  min = 0.1, max = 0.35))
      
      # copy others (not affected PFTs get 0)
      PFTfile[PFTfile$Sensitivity=="not affected",25] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
      
      # remove temp. column and prepare final PFT file for this repetition
      PFTfile<-PFTfile[,-ncol(PFTfile)]
      PFTfile <- cbind(PFTfile[,c(2,1)],PFTfile[,-c(1:2)])
      
      #save PFT file
      write.table(PFTfile[,-ncol(PFTfile)], paste(unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""), row.names=F, quote=F, sep="\t")
      
      # copy necessary files to Model-files folder
      path <- "Model-files/"
      copy <- file.copy(paste(unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""),  path)
      copy <- file.copy("HerbFact.txt",  path)
      copy <- file.copy("Input-files/AppRate.txt",  path)
      
      # change directory
      setwd('Model-files')
      
      # cmd call for running IBC
      mycall<-paste('./IBCgrassGUI', ModelVersion, GridSize, Tmax, InitDuration, paste("./",unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""), 
                    SeedInput, belowres, abres, abampl, tramp, graz, cut, 
                    week_start, HerbDuration, 1, EffectModel, scenario, MC, sep=" ")
      
      # start treatment run
      system(mycall, intern=TRUE)
      
      # change working directory
      setwd('..')
      
      # remove old files
      remove <- file.remove(paste("Model-files/", unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""))
      remove <- file.remove("Model-files/HerbFact.txt")
      remove <- file.remove("Model-files/AppRate.txt")
    }
  
  # stop cluster for parallel processing
  stopCluster(cl)
  
  #####
  # copy treatment
  #####
  # copy files to directory
  dir.create("currentSimulation/1", recursive=TRUE)
  file_list <- list.files(path = "Model-files/", pattern="Pt__*")
  for (file in file_list){
    path <- "currentSimulation/1"
    copy <- file.copy(paste("Model-files/" ,file , sep="") ,  path)
    #  todo make sure that all files were copied!
    if (copy==T) file.remove(paste("Model-files/" ,file , sep="") )              
  } 
  # GRD files
  file_list <- list.files(path = "Model-files/", pattern="Grd__*")
  for (file in file_list){
    path <- "currentSimulation/1"
    copy <- file.copy(paste("Model-files/" ,file , sep="") ,  path)
    #  todo make sure that all files were copied!
    if (copy==T) file.remove(paste("Model-files/" ,file , sep="") )              
  }
  
  # Copy treamtent settings
  dir.create(paste("currentSimulation/HerbicideSettings", sep=""), recursive=TRUE)
  file_list <- list.files(pattern=paste(unlist(strsplit(PFTfileName,".txt")),"*",sep=""))
  file_list <- file_list[file_list!=PFTfileName] #TODO: stimmt das mit der Datei???
  file_list <- c(file_list, "SimulationSettings.Rdata")
  copy <- file.copy(file_list ,  paste("currentSimulation/HerbicideSettings", sep=""))
  #  todo make sure that all files were copied!
  if (all(copy==T)) file.remove(file_list)
  copy <- file.copy("HerbFact.txt" ,  paste("currentSimulation/HerbicideSettings", sep=""))
  if (all(copy==T)) file.remove("HerbFact.txt")
  copy <- file.copy("PFTsensitivity.txt" ,  paste("currentSimulation/HerbicideSettings", sep=""))
  if (all(copy==T)) file.remove("PFTsensitivity.txt")
}
#####
# running treatment based on dose responses
#####
if(HerbEff=="dose-response"){
  count <- 0
  PFTfile <- get("IBCcommunityFile", envir=SaveEnvironment)
  # Application rate scenarios
  AppRateScenarios <- data.frame(get("IBCAppRateScenarios", envir=SaveEnvironment))
  PFTsensitivity <- get("PFTSensitivityFile", envir=SaveEnvironment)
  # Generate cluster for parallel processing
  no_cores <- max(detectCores()-2,1) # you might want to adapt this and give a specific number of cores (e.g. when using a HPC)
  cl <- makeCluster(no_cores)
  registerDoParallel(cl)
  
  # run repetitions for treatment
  foreach(MC = 1:MCruns, .export=c("PFTfile", "PFTsensitivity", "PFTfileName", "EffectModel",
                                   "ModelVersion", "belowres", "abres", "abampl", "Tmax", "InitDuration", "GridSize", "SeedInput",
                                   "week_start", "HerbDuration", "tramp", "graz", "cut", "Scenarios", "nb_data",
                                   "AppRateScenarios"))  %dopar%
    {
      #####
      # set sensitivities for each treatment repetition
      #####
      PFTfile<-merge(PFTfile, PFTsensitivity, by="Species")
      
      # make sure, all values are set to 0 (no affect)
      PFTfile[,28:39] <- 0
      
      # assign EC50 and slope values
      #####
      # biomass
      #####
      if("EC50andslope_Biomass.txt" %in% list.files()){
        # read the calculated dose responses by the GUI
#------ you need to prepare these data files manually if you do not use the GUI! ------------#
        DR<-read.table("EC50andslope_Biomass.txt", sep="\t", header=T)
        # random DRs
        # EC50
        PFTfile[PFTfile$Sensitivity=="random",28] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = max(0,(DR[nb_data+1,2] - DR[nb_data+2,2])), max = max(0,(DR[nb_data+1,2] + DR[nb_data+2,2]))))
        # slope
        PFTfile[PFTfile$Sensitivity=="random",29] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = max(0,(DR[nb_data+1,3] - DR[nb_data+2,3])), max = max(0,(DR[nb_data+1,3] + DR[nb_data+2,3]))))
        
        # existing DR
        for (i in 1:nb_data){
          # EC50
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),28] <- c(rep(DR[i,2],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
          # slope
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),29] <- c(rep(DR[i,3],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
        } # end nb of test species
        
        # not affected
        # EC50
        PFTfile[PFTfile$Sensitivity=="not affected",28] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
        # slope
        PFTfile[PFTfile$Sensitivity=="not affected",29] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
      } # end if biomass affected
      #####
      # seedling biomass
      #####
      if("EC50andslope_SeedlingBiomass.txt" %in% list.files()){
        # read the calculated DR
#------ you need to prepare these data files manually if you do not use the GUI! ------------#
        DR<-read.table("EC50andslope_SeedlingBiomass.txt", sep="\t", header=T)
        # random DRs
        # EC50
        PFTfile[PFTfile$Sensitivity=="random",30] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = max(0,(DR[nb_data+1,2] - DR[nb_data+2,2])), max = max(0,(DR[nb_data+1,2] + DR[nb_data+2,2]))))
        # slope
        PFTfile[PFTfile$Sensitivity=="random",31] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = max(0,(DR[nb_data+1,3] - DR[nb_data+2,3])), max = max(0,(DR[nb_data+1,3] + DR[nb_data+2,3]))))
        
        # existing DR
        for (i in 1:nb_data){
          # EC50
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),30] <- c(rep(DR[i,2],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
          # slope
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),31] <- c(rep(DR[i,3],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
        } # end nb of test species
        
        # not affected
        # EC50
        PFTfile[PFTfile$Sensitivity=="not affected",30] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
        # slope
        PFTfile[PFTfile$Sensitivity=="not affected",31] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
      } # end seedling biomass affected
      #####
      # survival
      #####
      if("EC50andslope_Survival.txt" %in% list.files()){
        # read the calculated DR
#------ you need to prepare these data files manually if you do not use the GUI! ------------#
        DR<-read.table("EC50andslope_Survival.txt", sep="\t", header=T)
        # random DRs
        # EC50
        PFTfile[PFTfile$Sensitivity=="random",32] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = max(0,(DR[nb_data+1,2] - DR[nb_data+2,2])), max = max(0,(DR[nb_data+1,2] + DR[nb_data+2,2]))))
        # slope
        PFTfile[PFTfile$Sensitivity=="random",33] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = max(0,(DR[nb_data+1,3] - DR[nb_data+2,3])), max = max(0,(DR[nb_data+1,3] + DR[nb_data+2,3]))))
        
        # existing DR
        for (i in 1:nb_data){
          # EC50
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),32] <- c(rep(DR[i,2],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
          # slope
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),33] <- c(rep(DR[i,3],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
        } # end nb of test species
        
        # not affected
        # EC50
        PFTfile[PFTfile$Sensitivity=="not affected",32] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
        # slope
        PFTfile[PFTfile$Sensitivity=="not affected",33] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
      } # end survival affected
      #####
      # establishment
      #####
      # read the calculated DR
#------ you need to prepare these data files manually if you do not use the GUI! ------------#      
      if("EC50andslope_Establishment.txt" %in% list.files()){
        # read the calculated DR
        DR<-read.table("EC50andslope_Establishment.txt", sep="\t", header=T)
        # random DRs
        # EC50
        PFTfile[PFTfile$Sensitivity=="random",34] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = max(0,(DR[nb_data+1,2] - DR[nb_data+2,2])), max = max(0,(DR[nb_data+1,2] + DR[nb_data+2,2]))))
        # slope
        PFTfile[PFTfile$Sensitivity=="random",35] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = max(0,(DR[nb_data+1,3] - DR[nb_data+2,3])), max = max(0,(DR[nb_data+1,3] + DR[nb_data+2,3]))))
        
        # existing DR
        for (i in 1:nb_data){
          # EC50
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),34] <- c(rep(DR[i,2],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
          # slope
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),35] <- c(rep(DR[i,3],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
        } # end nb of test species
        
        # not affected
        # EC50
        PFTfile[PFTfile$Sensitivity=="not affected",34] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
        # slope
        PFTfile[PFTfile$Sensitivity=="not affected",35] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
      } # end establishment affected
      #####
      # seed sterility
      #####
      if("EC50andslope_SeedSterility.txt" %in% list.files()){
        # read the calculated DR
#------ you need to prepare these data files manually if you do not use the GUI! ------------#      
        DR<-read.table("EC50andslope_SeedSterility.txt", sep="\t", header=T)
        # random DRs
        # EC50
        PFTfile[PFTfile$Sensitivity=="random",36] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = max(0,(DR[nb_data+1,2] - DR[nb_data+2,2])), max = max(0,(DR[nb_data+1,2] + DR[nb_data+2,2]))))
        # slope
        PFTfile[PFTfile$Sensitivity=="random",37] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = max(0,(DR[nb_data+1,3] - DR[nb_data+2,3])), max = max(0,(DR[nb_data+1,3] + DR[nb_data+2,3]))))
        
        # existing DR
        for (i in 1:nb_data){
          # EC50
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),36] <- c(rep(DR[i,2],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
          # slope
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),37] <- c(rep(DR[i,3],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
        } # end nb of test species
        
        # not affected
        # EC50
        PFTfile[PFTfile$Sensitivity=="not affected",36] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
        # slope
        PFTfile[PFTfile$Sensitivity=="not affected",37] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
      } # end seed sterility affected
      #####
      # seed number
      #####
      if("EC50andslope_SeedNumber.txt" %in% list.files()){
        # read the calculated DR
#------ you need to prepare these data files manually if you do not use the GUI! ------------#      
        DR<-read.table("EC50andslope_SeedNumber.txt", sep="\t", header=T)
        # random DRs
        # EC50
        PFTfile[PFTfile$Sensitivity=="random",38] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = max(0,(DR[nb_data+1,2] - DR[nb_data+2,2])), max = max(0,(DR[nb_data+1,2] + DR[nb_data+2,2]))))
        # slope
        PFTfile[PFTfile$Sensitivity=="random",39] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = max(0,(DR[nb_data+1,3] - DR[nb_data+2,3])), max = max(0,(DR[nb_data+1,3] + DR[nb_data+2,3]))))
        
        # existing DR
        for (i in 1:nb_data){
          # EC50
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),38] <- c(rep(DR[i,2],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
          # slope
          PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),39] <- c(rep(DR[i,3],nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),])))
        } # end nb of test species
        
        # not affected
        # EC50
        PFTfile[PFTfile$Sensitivity=="not affected",38] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
        # slope
        PFTfile[PFTfile$Sensitivity=="not affected",39] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
      } # end seed number affected
      
      #####
      # save the generated PFT file (specific for one treatment repetition)
      #####
      PFTfile<-PFTfile[,-ncol(PFTfile)]
      PFTfile <- cbind(PFTfile[,c(2,1)],PFTfile[,-c(1:2)])
      
      #save PFT file
      write.table(PFTfile[,-ncol(PFTfile)], paste(unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""), row.names=F, quote=F, sep="\t")
      
      #####
      # run simulations per app rate
      #####
      path <- "Model-files/"
      # Copy generated file to Model-files folder
      copy <- file.copy(paste(unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""),  path)
      # Copy dummy HerbFact.txt file (needed for c++ code; could probably be improved)
      copy <- file.copy("Input-files/HerbFact.txt",  path)
      # Change directory
      setwd('Model-files')
      
      # generate the AppRate.txt files and run simulations
      
      for(scenario in 1:Scenarios){ # Scenarios is the number of tested/simulated application rates
        
        # split txt file with all AppRates of all Scenarios into the scenario and save as AppRate.txt
        write.table(AppRateScenarios[,scenario], "AppRate.txt",  col.names=FALSE,  row.names=FALSE, sep="\t")
        
        # cmd call for running IBC
        mycall<-paste('./IBCgrassGUI',ModelVersion, GridSize, Tmax, InitDuration, 
                      paste("./",unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""), 
                      SeedInput, belowres, abres, abampl, tramp, graz, cut, 
                      week_start, HerbDuration, 1, EffectModel, scenario, MC, sep=" ")
        # start treatment run
        system(mycall, intern=TRUE)
        
        # remove 'old' files before starting new simulation
        remove <- file.remove("Model-files/AppRate.txt")
      } # end for apprates
      
      # Change directory
      setwd('..')
      # remove old files
      remove <- file.remove(paste("Model-files/", unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""))
      remove <- file.remove("Model-files/HerbFact.txt")
      
    }
  # stop cluster for parallel processing
  stopCluster(cl)
  
  #####
  # copy treatment
  #####
  
  # PFT files
  file_list <- list.files(path = "Model-files/", pattern="Pt__*", recursive=TRUE)
  for (file in file_list){
    path <- paste("currentSimulation/", unlist(strsplit(file,"_"))[6], sep="")
    if(!(unlist(strsplit(file,"_"))[6] %in% list.files("currentSimulation/"))) dir.create(paste("currentSimulation/",unlist(strsplit(file,"_"))[6],sep=""))
    copy <- file.copy(paste("Model-files/" ,file , sep="") ,  path)
    #  todo make sure that all files were copied!
    if (copy==T) file.remove(paste("Model-files/" ,file , sep="") )              
  }
  
  # GRD files
  file_list <- list.files(path = "Model-files/", pattern="Grd__*", recursive=TRUE)
  for (file in file_list){
    path <- paste("currentSimulation/", unlist(strsplit(file,"_"))[6], sep="")
    if(!(unlist(strsplit(file,"_"))[6] %in% list.files("currentSimulation/"))) dir.create(paste("currentSimulation/",unlist(strsplit(file,"_"))[6],sep=""))
    copy <- file.copy(paste("Model-files/" ,file , sep="") ,  path)
    #  todo make sure that all files were copied!
    if (copy==T) file.remove(paste("Model-files/" ,file , sep="") )              
  }
  
  # Herbicide treatment settings
  dir.create(paste("currentSimulation/HerbicideSettings", sep=""), recursive=TRUE)
  # all generated PFT files with sensitivities
  file_list <- list.files(pattern=paste(unlist(strsplit(PFTfileName,".txt")),"*",sep=""))
  file_list <- file_list[file_list!=PFTfileName]
  # file_list <- c(file_list, "SimulationSettings.Rdata", "Example_doseresponse.png", "AppRateScenarios.txt") # these files are only generated by the GUI
  copy <- file.copy(file_list ,  paste("currentSimulation/HerbicideSettings", sep=""))
  # remove after copy
  if (all(copy==T)) file.remove(file_list)
  
  # HerbFact file 
  copy <- file.copy("HerbFact.txt" ,  paste("currentSimulation/HerbicideSettings", sep=""))
  if (all(copy==T)) file.remove("HerbFact.txt")
  
  # PFT sensitivity file
  copy <- file.copy("PFTsensitivity.txt" ,  paste("currentSimulation/HerbicideSettings", sep=""))
  if (all(copy==T)) file.remove("PFTsensitivity.txt")
  
  # EC50 and slopes
  file_list <- list.files(pattern="EC50andslope*")
  copy <- file.copy(file_list ,  paste("currentSimulation/HerbicideSettings", sep=""))
  if (all(copy==T)) file.remove(file_list)
  #
  
  file_list <- list.files(pattern="*Effects.txt")
  copy <- file.copy(file_list ,  paste("currentSimulation/HerbicideSettings", sep=""))
  if (all(copy==T)) file.remove(file_list)
} # end if dose response based