#############################################################
#                                                           #
#       Graphical User Interface for IBC-grass              #
#                                                           #
#############################################################
# Author: Jette Reeg
#############################################################
rm(list=ls())
if (!"RGtk2" %in% installed.packages()) install.packages("RGtk2", repos='http://cran.us.r-project.org', dependencies = T)
if (!"RGtk2Extras" %in% installed.packages()) install.packages("RGtk2Extras", repos='http://cran.us.r-project.org', dependencies = T)
if (!"data.table" %in% installed.packages()) install.packages("data.table", repos='http://cran.us.r-project.org', dependencies = T)
if (!"ggplot2" %in% installed.packages()) install.packages("ggplot2", repos='http://cran.us.r-project.org', dependencies = T)
if (!"ggthemes" %in% installed.packages()) install.packages("ggthemes", repos='http://cran.us.r-project.org', dependencies = T)
if (!"reshape2" %in% installed.packages()) install.packages("reshape2", repos='http://cran.us.r-project.org', dependencies = T)
if (!"foreach" %in% installed.packages()) install.packages("foreach", repos='http://cran.us.r-project.org', dependencies = T)
if (!"doParallel" %in% installed.packages()) install.packages("doParallel", repos='http://cran.us.r-project.org', dependencies = T)
require(RGtk2)
require(RGtk2Extras)
require(data.table)
require(reshape2)
require(ggplot2)
require(ggthemes)
require(foreach)
require(doParallel)
source('R-files/Welcome.R')
source('R-files/Selection.R')
source('R-files/Selected.R')
source('R-files/HerbicideSettings.R')
source('R-files/Sensitivities.R')
source('R-files/SimulationSpecificSettings.R')
source('R-files/CalculateDR.R')
source('R-files/AnalysesDialog.R')
#############################################################
# global parameters
#############################################################
# create a new environment
IBCvariables <- new.env(parent = baseenv())
# parameters
assign("GUIopen", "open", envir = IBCvariables) # ensures the GUI is not closed
assign("IBCcommunity", "Fieldedge.txt", envir = IBCvariables) # IBC community
assign("IBCcommunityFile", NULL, envir = IBCvariables) # IBC community PFT data
assign("IBCbelres", 40, envir = IBCvariables) # belowground resources
assign("IBCabres", 40, envir = IBCvariables) # aboveground resources
assign("IBCabampl", 0, envir = IBCvariables) # aboveground resource amplitude (for seasonality)
assign("IBCgraz", 0.0, envir = IBCvariables) # grazing intensity
assign("IBCtramp", 0.0, envir = IBCvariables) # trampling intensity
assign("IBCcut", 1, envir = IBCvariables) # cutting events
assign("IBCherbeffect", "txt-file", envir = IBCvariables) # source of herbicide effects
# assign("IBCApprates", "0", envir = IBCvariables) # application rates
assign("nb_data", 6, envir = IBCvariables) # number of test species
assign("origWD", getwd(), envir=IBCvariables) # original working directory
assign("IBCDuration", 1, envir=IBCvariables) # herbicide duration (in years)
assign("IBCRecovery", 1, envir=IBCvariables) # recovery period (in years)
assign("IBCInit", 1, envir=IBCvariables) # initial years
assign("BiomassEff", F, envir=IBCvariables) # whether biomass is affects
assign("SeedlingBiomassEff", F, envir=IBCvariables) # whether seedling biomass is affected
assign("SurvivalEff", F, envir=IBCvariables) # whether survival is affectes
assign("EstablishmentEff", F, envir=IBCvariables) # whether establishment is affected
assign("SeedSterilityEff", F, envir=IBCvariables) # whether seed sterility is affected
assign("SeedNumberEff", F, envir=IBCvariables) # whether seed number is affected
assign("origFiles",list.files(getwd()), envir=IBCvariables) # original files of GUI software -> should not be deleted
lookuptable <- read.table("Input-files/PFTtoSpecies.txt", sep="\t", header=T)[,1:2] # lookup table for species -> PFT classification
assign("PFTtoSpecies", lookuptable, envir=IBCvariables) # lookup table for species -> PFT classification
assign("IBCherbeffect", "", envir = IBCvariables) # herbicide effect
assign("EffectData", NULL, envir=IBCvariables) # effect data
assign("BiomassEffFile", NULL, envir=IBCvariables) # effect data for biomass
assign("SeedlingBiomassEffFile", NULL, envir=IBCvariables) # effect data for seedling biomass
assign("SurvivalEffFile", NULL, envir=IBCvariables) # effect data for survival
assign("EstablishmentEffFile", NULL, envir=IBCvariables) # effect data for establishment
assign("SeedSterilityEffFile", NULL, envir=IBCvariables) # effect data for seed sterility
assign("SeedNumberEffFile", NULL, envir=IBCvariables) # effect data for seed number
assign("PFTSensitivityFile", NULL, envir=IBCvariables) # PFT sensitivity fiel
assign("IBCrepetition", 10, envir = IBCvariables) # number of repetitions
assign("IBCgridsize", 174, envir = IBCvariables) # grid size
assign("IBCSeedInput", 10, envir = IBCvariables) # seed input
assign("IBCApprates", "", envir=IBCvariables) # application rates
assign("IBCloadedSettings", NULL, envir=IBCvariables) # name for loaded settings
#############################################################
# save all further output to a file
#############################################################
con <- file("IBCgrassGUI.log")
sink(con, append=TRUE)
sink(con, append=TRUE, type="message")
#############################################################
# start GUI
#############################################################
Welcomefct()
sink()
