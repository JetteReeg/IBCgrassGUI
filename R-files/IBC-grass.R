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
# add local R library to install packages to (to avoid admin rights)
.libPaths( c( .libPaths(), paste(getwd(), "/Rlibraries", sep="")))
# install necessary packages
if (.Platform$OS.type == "windows") {
if (!"RGtk2" %in% installed.packages()) install.packages("https://cran.microsoft.com/snapshot/2019-02-01/bin/windows/contrib/3.6/RGtk2_2.20.35.zip", repos=NULL, dependencies=T, lib = paste(getwd(), "/Rlibraries", sep=""))
}
if (.Platform$OS.type == "unix") {
  if (!"RGtk2" %in% installed.packages()) install.packages("https://cran.r-project.org/src/contrib/Archive/RGtk2/RGtk2_2.20.35.tar.gz", repos=NULL, dependencies=T, lib = paste(getwd(), "/Rlibraries", sep=""))
}
if (!"labeling" %in% installed.packages()) install.packages("labeling", repos='http://cran.us.r-project.org', dependencies = T, lib = paste(getwd(), "/Rlibraries", sep=""))
if (!"data.table" %in% installed.packages()) install.packages("data.table", repos='http://cran.us.r-project.org', dependencies = T, lib = paste(getwd(), "/Rlibraries", sep=""))
if (!"ggplot2" %in% installed.packages()) install.packages("ggplot2", repos='http://cran.us.r-project.org', dependencies = T, lib = paste(getwd(), "/Rlibraries", sep=""))
if (!"ggthemes" %in% installed.packages()) install.packages("ggthemes", repos='http://cran.us.r-project.org', dependencies = T, lib = paste(getwd(), "/Rlibraries", sep=""))
if (!"reshape2" %in% installed.packages()) install.packages("reshape2", repos='http://cran.us.r-project.org', dependencies = T, lib = paste(getwd(), "/Rlibraries", sep=""))
if (!"foreach" %in% installed.packages()) install.packages("foreach", repos='http://cran.us.r-project.org', dependencies = T, lib = paste(getwd(), "/Rlibraries", sep=""))
if (!"doParallel" %in% installed.packages()) install.packages("doParallel", repos='http://cran.us.r-project.org', dependencies = T, lib = paste(getwd(), "/Rlibraries", sep=""))
# install gtk if not already existing...
# checks system
if (.Platform$OS.type == "windows") {
  # prüft die dlls
  dllpath <- Sys.getenv("RGTK2_GTK2_PATH")
  if (!nzchar(dllpath))
    dllpath <- file.path(file.path(system.file(package = "RGtk2"), "gtk", .Platform$r_arch), "bin")
  #tries to load the necessary dlls
  dll <- try(library.dynam("RGtk2", "RGtk2", .libPaths(), DLLpath = dllpath),
             silent = getOption("verbose"))
} else dll <- try(library.dynam("RGtk2", "RGtk2", l.libPaths()),
                silent = getOption("verbose"))
# if dlls cannot be loaded; download and install them
if (is.character(dll)) {
  # required function
  .configure_gtk_theme <- function(theme) {
    ## Only applies to Windows so far
    config_path <- file.path(system.file(package = "RGtk2"), "gtk",
                             .Platform$r_arch, "etc", "gtk-2.0")
    dir.create(config_path, recursive = TRUE)
    writeLines(sprintf("gtk-theme-name = \"%s\"", theme),
               file.path(config_path, "gtkrc"))
  }
  # install the dependencies
  # für windows 32 config..
  windows32_config <-
    list(
      source = FALSE,
      gtk_url = "http://ftp.gnome.org/pub/gnome/binaries/win32/gtk+/2.22/gtk+-bundle_2.22.1-20101227_win32.zip",
      installer = function(path) {
        gtk_path <- file.path(system.file(package = "RGtk2"), "gtk", .Platform$r_arch)
        ## unzip does this, but we want to see any warnings
        dir.create(gtk_path, recursive = TRUE) 
        unzip(path, exdir = gtk_path)
        .configure_gtk_theme("MS-Windows")
      }
    )
  
  # für windows 64 config
  windows64_config <- windows32_config
  windows64_config$gtk_url <- "http://ftp.gnome.org/pub/gnome/binaries/win64/gtk+/2.22/gtk+-bundle_2.22.1-20101229_win64.zip"
  
  # für darwin config
  darwin_config <- list(
    source = FALSE,
    gtk_url = "http://r.research.att.com/libs/GTK_2.24.17-X11.pkg", 
    installer = function(path) {
      system(paste("open", path))
    }
  )
  
  # für unix config.
  unix_config <- NULL
  
  gtk_web <- "http://www.gtk.org"
  
  install_system_dep <- function(dep_name, dep_url, dep_web, installer)
  {
    path <- file.path(tempdir(), basename(sub("\\?.*", "", dep_url)))
    if (download.file(dep_url, path, mode="wb") > 0)
      stop("Failed to download ", dep_name)
    installer(path)
  }
  
  install_all <- function() {
    if (.Platform$OS.type == "windows") {
      if (.Platform$r_arch == "i386") config <- windows32_config
        else config <- windows64_config
      } else if (length(grep("darwin", R.version$platform)))  {
        config <- darwin_config
        }  else config <- unix_config
    
    if (is.null(config))
      stop("This platform is not yet supported by the automatic installer. ",
           "Please install GTK+ manually, if necessary. See: ", gtk_web)
    
    install_system_dep("GTK+", config$gtk_url, gtk_web, config$installer)
    return()
  }
  
  install_all()
}

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
