###############################################################################
#                                                                             #
# This function will show all possible options                                #
# for starting a new IBCgrass project                                         #
#                                                                             #
###############################################################################
Selection<-function(){
  ##################################################
  ### Update variables of the IBCgrass environment (necessary if user goes one step back)
  ##################################################
  assign("GUIopen", "open", envir = IBCvariables)
  assign("IBCcommunity", "Fieldedge.txt", envir = IBCvariables)
  assign("IBCcommunityFile", NULL, envir = IBCvariables)
  assign("IBCbelres", 40, envir = IBCvariables)
  assign("IBCabres", 40, envir = IBCvariables)
  assign("IBCgraz", 0.0, envir = IBCvariables)
  assign("IBCtramp", 0.0, envir = IBCvariables)
  assign("IBCcut", 1, envir = IBCvariables)
  assign("IBCherbeffect", "txt-file", envir = IBCvariables)
  assign("IBCApprates", "0", envir = IBCvariables)
  assign("nb_data", 6, envir = IBCvariables)
  assign("origWD", getwd(), envir=IBCvariables)
  assign("IBCDuration", 1, envir=IBCvariables)
  assign("IBCRecovery", 1, envir=IBCvariables)
  assign("IBCInit", 1, envir=IBCvariables)
  assign("BiomassEff", F, envir=IBCvariables)
  assign("SeedlingBiomassEff", F, envir=IBCvariables)
  assign("SurvivalEff", F, envir=IBCvariables)
  assign("EstablishmentEff", F, envir=IBCvariables)
  assign("SeedSterilityEff", F, envir=IBCvariables)
  assign("SeedNumberEff", F, envir=IBCvariables)
  assign("origFiles",list.files(getwd()), envir=IBCvariables)
  lookuptable <- read.table("Input-files/PFTtoSpecies.txt", sep="\t", header=T)[,1:2]
  assign("PFTtoSpecies", lookuptable, envir=IBCvariables)
  assign("IBCherbeffect", "", envir = IBCvariables)
  assign("EffectData", NULL, envir=IBCvariables)
  assign("BiomassEffFile", NULL, envir=IBCvariables)
  assign("SeedlingBiomassEffFile", NULL, envir=IBCvariables)
  assign("SurvivalEffFile", NULL, envir=IBCvariables)
  assign("EstablishmentEffFile", NULL, envir=IBCvariables)
  assign("SeedSterilityEffFile", NULL, envir=IBCvariables)
  assign("SeedNumberEffFile", NULL, envir=IBCvariables)
  assign("PFTSensitivityFile", NULL, envir=IBCvariables)
  assign("IBCrepetition", 10, envir = IBCvariables)
  assign("IBCgridsize", 174, envir = IBCvariables)
  assign("IBCSeedInput", 10, envir = IBCvariables)
  assign("IBCApprates", "", envir=IBCvariables)
  assign("IBCloadedSettings", NULL, envir=IBCvariables)
  ##################################################
  ### Title of the window
  ##################################################
  vbox <- gtkVBoxNew()
  vbox$setBorderWidth(10)
  label_title <- gtkLabel()
  label_title$setMarkup('<span weight=\"bold\" size=\"large\">Select an option...</span>')
  vbox$packStart(label_title)
  ##################################################
  ### Choices the user has
  ##################################################
  choices <- c("Run scenarios on pre-set IBC-grass communities" , "Create a new IBC-grass community", "Load previously saved community file",
               "Load previous simulation settings (SimulationSettings.RData file is needed)")
  radio_buttons <- NULL
  
  for (choice in choices){
    button <- gtkRadioButton(radio_buttons, choice)
    # use one of the three communities, which has been already used in one of the publicationes (Reeg et al. 2017, 2018a, 2018b)
    if (choice==choices[1]) button$setTooltipText("Run IBCgrass on one of three given communities")
    # create a new IBCgrass community based either on already classified PFTs (but different regional species pool) or add new plant species
    # new communities can be saved to be used in later projects
    if (choice==choices[2]) button$setTooltipText("Create a new community")
    # load a community which was saved in previous projects (see above)
    if (choice==choices[3]) button$setTooltipText("Load a community file, which you saved in a previous session")
    # load the settings of previous simulations either to rerun the simulation or to change only a few settings
    if (choice==choices[4]) button$setTooltipText("Rerun or modify previous simulation settings. If a personal community was used, you will need to provide the community file.")
    vbox$packStart(button)
    radio_buttons<- c(radio_buttons, button)
  }
  
  ##################################################
  ### Buttons for calling the right function 
  ### depend on the selected option
  ##################################################
  
  ClickOnButton <- function(button){
    
    if(vbox[[2]]$getActive()==T) {
      RunPreSet()
    }
    
    if(vbox[[3]]$getActive()==T) {
      CreateNew()
    }
    
    if(vbox[[4]]$getActive()==T) {
      LoadNew()
    }
    
    if(vbox[[5]]$getActive()==T) {
      LoadPrev()
    }
    SelectionWindow$destroy()
  }
  
  ClickOnReturn <- function(button){
    
    SelectionWindow$destroy()
    Welcomefct()
    
  }
  
  # packing the buttons
  SelectionButton <- gtkButton('Continue')
  vbox$packStart(SelectionButton,fill=F) #button which will start one of the option 
  
  ReturnButton <- gtkButton('Back')
  ReturnButton$setTooltipText('Go back to previous step.')
  vbox$packStart(ReturnButton,fill=F) #button which will return
  
  gSignalConnect(SelectionButton, "clicked", ClickOnButton)
  gSignalConnect(ReturnButton, "clicked", ClickOnReturn)
  
  ##################################################
  ### put it together
  ##################################################
  SelectionWindow <- gtkWindow(show=F)
  SelectionWindow$setPosition('GTK_WIN_POS_CENTER')
  SelectionWindow["title"] <- "IBC-grass GUI"
  color <-gdkColorToString('white')
  SelectionWindow$ModifyBg("normal", color)
  SelectionWindow$add(vbox)
  SelectionWindow$show()
}
