Selection<-function(){
  ##################################################
  ### Update IBCvariables
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
  ### Title
  ##################################################
  vbox <- gtkVBoxNew()
  vbox$setBorderWidth(10)
  label_title <- gtkLabel()
  label_title$setMarkup('<span weight=\"bold\" size=\"large\">What do you want to do?</span>')
  vbox$packStart(label_title)
  ##################################################
  ### Choices
  ##################################################
  choices <- c("Run scenarios on pre-set IBC-grass communities" , "Create a new IBC-grass community", "Load previously saved community file",
               "Load previous simulation settings (SimulationSettings.RData file is needed)")
  radio_buttons <- NULL
  
  for (choice in choices){
    button <- gtkRadioButton(radio_buttons, choice)
    if (choice==choices[1]) button$setTooltipText("Run IBCgrass on one of three given communities")
    if (choice==choices[2]) button$setTooltipText("Create a new community")
    if (choice==choices[3]) button$setTooltipText("Load a community file, which you saved in a previous session")
    if (choice==choices[4]) button$setTooltipText("Rerun or modify previous simulation settings. If a personal community was used, you will need to provide the community file.")
    vbox$packStart(button)
    radio_buttons<- c(radio_buttons, button)
  }
  
  ##################################################
  ### Buttons
  ##################################################
  
  ClickOnButton <- function(button){
    
    if(vbox[[2]]$getActive()==T) {
      # SelectionWindow$destroy()
      RunPreSet()
    }
    
    if(vbox[[3]]$getActive()==T) {
      # SelectionWindow$destroy()
      CreateNew()
    }
    
    if(vbox[[4]]$getActive()==T) {
      # SelectionWindow$destroy()
      LoadNew()
    }
    
    if(vbox[[5]]$getActive()==T) {
      # SelectionWindow$destroy()
      LoadPrev()
    }
    SelectionWindow$destroy()
  }
  
  ClickOnReturn <- function(button){
    
    SelectionWindow$destroy()
    Welcomefct()
    
  }
  
  
  SelectionButton <- gtkButton('Continue')
  vbox$packStart(SelectionButton,fill=F) #button which will start 
  
  ReturnButton <- gtkButton('Back')
  ReturnButton$setTooltipText('Go back to previous step.')
  vbox$packStart(ReturnButton,fill=F) #button which will start 
  
  gSignalConnect(SelectionButton, "clicked", ClickOnButton)
  gSignalConnect(ReturnButton, "clicked", ClickOnReturn)
  
  ##################################################
  ### put it together
  ##################################################
  SelectionWindow <- gtkWindow(show=F)
  SelectionWindow$setPosition('GTK_WIN_POS_CENTER')
  SelectionWindow["title"] <- "IBC-grass 2.0"
  color <-gdkColorToString('white')
  SelectionWindow$ModifyBg("normal", color)
  SelectionWindow$add(vbox)
  SelectionWindow$show()
}
