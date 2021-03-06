###############################################################################
#                                                                             #
#       Graphical User Interface for the plant community model IBC-grass      #
#       in herbicide risk assessments of non-target terrestrial plants        #
#                                                                             #
###############################################################################
#       Author: Jette Reeg                                                    #
###############################################################################
# Copyright Â© 2019 Jette Reeg
# This program is free software: you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free Software 
# Foundation, either version 3 of the License, or any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with 
# this program.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

# clean workspace
rm(list=ls())

# load necessary packages
library(RGtk2)
library(RGtk2Extras)
library(data.table)
library(reshape2)
library(ggplot2)
library(ggthemes)
library(foreach)
library(doParallel)
library(labeling)

# load necessary files
source('R-files/Welcome.R')
source('R-files/Selection.R')
source('R-files/Selected.R')
source('R-files/HerbicideSettings.R')
source('R-files/Sensitivities.R')
source('R-files/SimulationSpecificSettings.R')
source('R-files/CalculateDR.R')
source('R-files/AnalysesDialog.R')
###############################################################################
# global parameters
###############################################################################
# create a new environment
IBCvariables <- new.env(parent = baseenv())
# parameters
assign("GUIopen", "open", envir = IBCvariables)                               # ensures the GUI is not closed
assign("IBCcommunity", "Fieldedge.txt", envir = IBCvariables)                 # IBC community
assign("IBCcommunityFile", NULL, envir = IBCvariables)                        # IBC community PFT data
assign("IBCbelres", 40, envir = IBCvariables)                                 # belowground resources
assign("IBCabres", 40, envir = IBCvariables)                                  # aboveground resources
assign("IBCabampl", 0, envir = IBCvariables)                                  # aboveground resource amplitude (for seasonality)
assign("IBCgraz", 0.0, envir = IBCvariables)                                  # grazing intensity
assign("IBCtramp", 0.0, envir = IBCvariables)                                 # trampling intensity
assign("IBCcut", 1, envir = IBCvariables)                                     # cutting events
assign("IBCherbeffect", "txt-file", envir = IBCvariables)                     # source of herbicide effects
assign("nb_data", 6, envir = IBCvariables)                                    # number of test species
assign("origWD", getwd(), envir=IBCvariables)                                 # original working directory
assign("IBCDuration", 1, envir=IBCvariables)                                  # herbicide duration (in years)
assign("IBCweekstart", 11, envir=IBCvariables)                                # week of herbicide application within each year
assign("IBCRecovery", 1, envir=IBCvariables)                                  # recovery period (in years)
assign("IBCInit", 1, envir=IBCvariables)                                      # initial years
assign("BiomassEff", F, envir=IBCvariables)                                   # whether biomass is affected
assign("SeedlingBiomassEff", F, envir=IBCvariables)                           # whether seedling biomass is affected
assign("SurvivalEff", F, envir=IBCvariables)                                  # whether survival is affected
assign("EstablishmentEff", F, envir=IBCvariables)                             # whether establishment is affected
assign("SeedSterilityEff", F, envir=IBCvariables)                             # whether seed sterility is affected
assign("SeedNumberEff", F, envir=IBCvariables)                                # whether seed number is affected
assign("origFiles",list.files(getwd()), envir=IBCvariables)                   # original files of GUI software -> should not be deleted
lookuptable <- read.table("Input-files/PFTtoSpecies.txt", sep="\t", header=T)[,1:2] # lookup table for species -> PFT classification
assign("PFTtoSpecies", lookuptable, envir=IBCvariables)                       # lookup table for species -> PFT classification
assign("IBCherbeffect", "", envir = IBCvariables)                             # herbicide effect
assign("EffectData", NULL, envir=IBCvariables)                                # effect data
assign("BiomassEffFile", NULL, envir=IBCvariables)                            # effect data for biomass
assign("SeedlingBiomassEffFile", NULL, envir=IBCvariables)                    # effect data for seedling biomass
assign("SurvivalEffFile", NULL, envir=IBCvariables)                           # effect data for survival
assign("EstablishmentEffFile", NULL, envir=IBCvariables)                      # effect data for establishment
assign("SeedSterilityEffFile", NULL, envir=IBCvariables)                      # effect data for seed sterility
assign("SeedNumberEffFile", NULL, envir=IBCvariables)                         # effect data for seed number
assign("PFTSensitivityFile", NULL, envir=IBCvariables)                        # PFT sensitivity fiel
assign("IBCrepetition", 10, envir = IBCvariables)                             # number of repetitions
assign("IBCgridsize", 174, envir = IBCvariables)                              # grid size
assign("IBCSeedInput", 10, envir = IBCvariables)                              # seed input
assign("IBCAppRateScenarios", NULL, envir=IBCvariables)                                 # annual application rates
assign("IBCScenarios", 1, envir=IBCvariables)                                 # number of herbicide scenarios
assign("IBCloadedSettings", NULL, envir=IBCvariables)                         # name for loaded settings

###############################################################################
# save all further output to a file
###############################################################################
con <- file("IBCgrassGUI.log")                                                # log file name
sink(con, append=TRUE)
sink(con, append=TRUE, type="message")

###############################################################################
# start GUI by calling the first function
###############################################################################
Welcomefct()

###############################################################################
# close log file connection
###############################################################################
sink()
