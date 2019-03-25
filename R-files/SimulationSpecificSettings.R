SimulationSpecifics<-function(){
  ##################################################
  ### Title
  ##################################################
  vbox1 <- gtkVBoxNew()
  vbox1$setBorderWidth(10)
  label_title <- gtkLabel()
  label_title$setMarkup('<span weight=\"bold\" size=\"x-large\">Simulation specific settings</span>')
  vbox1$packStart(label_title)
  ##################################################
  ### slider 'number of repetitions'
  ##################################################
  vbox2 <- gtkVBoxNew()
  vbox2$setBorderWidth(10)
  label_nb_repetitions <-gtkLabel()
  label_nb_repetitions$setMarkup('<span underline=\"single\" size=\"large\">Number of repetitions per scenario</span>')
  label_nb_repetitions['height.request'] <- 15
  label_nb_repetitions$setTooltipText('Trade-off: The higher the number of repetitions, the lower is the standard deviation, but the longer is the runtime. We advise to have at least 10 repetitions if you just want some fast results, but at least 30 to get high accuracy.')
  RepSlider <- gtkHScale(min = 3, max = 50, step = 1)
  RepSlider$setTooltipText('Trade-off: The higher the number of repetitions, the lower is the standard deviation, but the longer is the runtime. We advise to have at least 10 repetitions if you just want some fast results, but at least 30 to get high accuracy.')
  RepSlider$setValue(get("IBCrepetition", envir = IBCvariables))
  vbox2$packStart(label_nb_repetitions)
  vbox2$packStart(RepSlider)
  ##################################################
  ### slider 'plotsize'
  ##################################################
  vbox3 <- gtkVBoxNew()
  vbox3$setBorderWidth(10)
  label_plotsize <-gtkLabel()
  label_plotsize$setMarkup('<span underline=\"single\" size=\"large\">Plot size [m2]</span>')
  label_plotsize['height.request'] <- 15
  label_plotsize$setTooltipText('Trade-off: The higher the plot size, the longer the runtime. If you want to have fast results, decrease the plot size.')
  PlotSlider <- gtkHScale(min = 1, max = 3, step = 0.1)
  PlotSlider$setTooltipText('Trade-off: The higher the plot size, the longer the runtime. If you want to have fast results, decrease the plot size.')
  PlotSlider$setValue(round((get("IBCgridsize", envir = IBCvariables)/100)^2))
  vbox3$packStart(label_plotsize)
  vbox3$packStart(PlotSlider)
  ##################################################
  ### slider 'seed input'
  ##################################################
  vbox4 <- gtkVBoxNew()
  vbox4$setBorderWidth(10)
  label_iso<-gtkLabel()
  label_iso$setMarkup('<span underline=\"single\" size=\"large\">External seed input</span>')
  label_iso['height.request'] <- 15
  label_iso$setTooltipText("The external seed input determines the degree of isolation.  A value of 0 means, that the community is completely isolated. The higher, the less isolated is the community. However, if seed input is too high, it drives the community dynamics. We suggest a seed input between 5-15. For small plot sizes you probably want to have higher seed inputs.")
  IsoSlider <- gtkHScale(min = 0, max = 20, step = 1)
  IsoSlider$setTooltipText("The external seed input determines the degree of isolation.  A value of 0 means, that the community is completely isolated. The higher, the less isolated is the community. However, if seed input is too high, it drives the community dynamics. We suggest a seed input between 5-15. For small plot sizes you probably want to have higher seed inputs.")
  IsoSlider$setValue(get("IBCSeedInput", envir = IBCvariables))
  vbox4$packStart(label_iso)
  vbox4$packStart(IsoSlider)
  ##################################################
  ### edit field 'number of treatment scenarios'
  ##################################################
  vbox5 <- gtkVBoxNew()
  vbox5$setBorderWidth(10)
  label_scenarios <-gtkLabel()
  label_scenarios$setMarkup('<span underline=\"single\"size=\"large\">Number of herbicide scenarios</span>')
  label_scenarios['height.request'] <- 20
  label_scenarios$setTooltipText('Please type in the number of herbicide scenarios you would like to test. In the next window you will be asked to type in annual application rates for each scenario.')
  entry_scenarios <- gtkEntryNew()
  scenarios<-get("IBCScenarios", envir=IBCvariables)
  entry_scenarios$setText(scenarios)
  
  vbox5$packStart(label_scenarios)
  vbox5$packStart(entry_scenarios)
  ##################################################
  ### Button start 
  ##################################################
  SB <-gtkButton('Start simulations')
  SB$setTooltipText('Starts the IBC-grass simulations. This may take a while.')
  SB$setBorderWidth(10)
  Start <- function(button){
    assign("IBCrepetition", RepSlider$getValue(), envir = IBCvariables)
    # sqrt(PlotSlider$getValue())
    assign("IBCgridsize", round(sqrt(PlotSlider$getValue())*100), envir = IBCvariables)
    assign("IBCSeedInput", IsoSlider$getValue(), envir = IBCvariables)
    scenarios<-entry_scenarios$getText()
    assign("IBCScenarios", scenarios, envir=IBCvariables)
    w$destroy()
    if(get("IBCherbeffect", envir = IBCvariables)=="dose-response") {
      GetAppRates()
    } else  StartSimulations()
  }
  gSignalConnect(SB, signal = "clicked", Start)
  ##################################################
  ### button 'return'
  ##################################################
  ReturnButton <-gtkButton('Back')
  ReturnButton$setTooltipText('Go back to previous step.')
  ReturnButton$setBorderWidth(10)
  ClickOnReturn <- function(button){
    w$destroy()
    if(get("IBCherbeffect", envir=IBCvariables)=="txt-file") SensitivityTXT()
    if(get("IBCherbeffect", envir=IBCvariables)=="dose-response") SensitivityDR()
  }
  gSignalConnect(ReturnButton, "clicked", ClickOnReturn)
  ##################################################
  ### put it all together
  ##################################################
  vbox <- gtkVBoxNew()
  vbox$setBorderWidth(10)
  vbox$packStart(vbox1)
  vbox$packStart(vbox2)
  vbox$packStart(vbox3)
  vbox$packStart(vbox4)
  
  if(get("IBCherbeffect", envir = IBCvariables)=="dose-response") {
    vbox$packStart(vbox5)
  }
  
  vbox$packStart(SB)
  vbox$packStart(ReturnButton)
  
  # create the new window
  w <- gtkWindow(show=F) 
  w$setPosition('GTK_WIN_POS_CENTER')
  w["title"] <- "IBC-grass GUI"
  color <-gdkColorToString('white')
  w$ModifyBg("normal", color)
  w$add(vbox)
  w$show()
  
}

GetAppRates <- function(){
  ##################################################
  ### Create data frame to insert annual application rates
  ##################################################
  # if no effect data exist (e.g. if previous settings were loaded)
  if (is.null(get("IBCAppRateScenarios", envir=IBCvariables))){
    rep.col<-function(x,n){
      matrix(rep(x,each=n), ncol=n, byrow=TRUE)
    }
    df<-NULL
    #####
    # create the table
    #####
    # 
    df <- data.frame()
    scenarios <- as.numeric(get("IBCScenarios", envir = IBCvariables))
    column_name <-c()
    for (i in 1:scenarios){
      column_name_help <- paste('Scenario',i,sep="")
      column_name <- c(column_name, column_name_help)
    }
    col <- c(rep(0.0,get("IBCDuration", envir=IBCvariables)))
    df <- as.data.frame(rep.col(col, length(column_name)))
    colnames(df)<-column_name
  } else {
    # load previous effect data
    df <- get("IBCAppRateScenarios", envir=IBCvariables)
  }
  # create a dataframe object
  obj <- gtkDfEdit(df, update=T, envir=IBCvariables)
  #####
  # What to do
  #####
  label_txtfile<-gtkLabel()
  label_txtfile$setMarkup('
                          <span weight=\"bold\" size=\"large\">Application rates</span>
                          <span size=\"large\">Please insert the annual application rates for each scenario.</span><span weight=\"bold\"></span>')
  label_txtfile['height.request'] <- 100
  #####
  # Buttons
  #####
  SaveCloseButton <- gtkButton('Save & Continue')
  SaveCloseButton$setTooltipText("Save the data and go to the next step.")
  # Save the data and go to the next step
  SaveClose <- function(button){
    df<-obj$getModel()
    test<-data.frame(df)
    # inserted values should not be greater than 1
    if(is.na(test)){
      dialog1 <- gtkMessageDialog(parent=win,
                                  flags = "destroy-with-parent",
                                  type="warning" ,
                                  buttons="ok" ,
                                  "Please make sure, that you insert values for all years.")
      color <-gdkColorToString('white')
      dialog1$ModifyBg("normal", color)
      gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
    } else{
      # close windows
      win$destroy()
      # save the table
      test<-data.frame(df)
      # calculate expected column number
      col_exp <- as.numeric(get("IBCScenarios", IBCvariables))
      # delete everything greater than the expected column number
      test<-test[,c(2:(col_exp+1))]
      assign("IBCAppRateScenarios", test, IBCvariables)
      print(test)
      fwrite(test, "AppRateScenarios.txt", sep="\t")
      # call the sensitivity window
      StartSimulations()
    }
  }
  # return to the herbicide settings
  ReturnButton <- gtkButton('Back')
  ReturnButton$setTooltipText("Go back to the previous step.")
  ClickOnReturn <- function(button){
    # destroy current windows
    win$destroy()
    # call herbicide window
    SimulationSpecifics()
  }
  # packing
  gSignalConnect(ReturnButton, "clicked", ClickOnReturn)
  gSignalConnect(SaveCloseButton, "clicked", SaveClose)
  
  #####
  # put it together
  #####
  vbox1 <- gtkVBoxNew()
  vbox1$setBorderWidth(10)
  vbox1$packStart(label_txtfile)
  vbox1$packStart(obj)
  vbox1$packStart(SaveCloseButton,fill=F)
  vbox1$packStart(ReturnButton,fill=F) #button which will start 
  
  win <- gtkWindow(show=F) 
  win["title"] <- "IBC-grass GUI"
  win$setPosition('GTK_WIN_POS_CENTER')
  color <-gdkColorToString('white')
  win$ModifyBg("normal", color)
  win$add(vbox1)
  win$show()
}

StartSimulations <- function(){
  ##################################################
  ### save simulation details
  ##################################################
  SaveEnvironment <- IBCvariables
  save(SaveEnvironment, file = "SimulationSettings.Rdata")
  ##################################################
  ### title
  ###################################################
  vbox1 <- gtkVBoxNew()
  vbox1$setBorderWidth(10)
  label_title <- gtkLabel()
  label_title$setMarkup('<span weight=\"bold\" size=\"x-large\">Running IBC-grass simulations</span>')
  label_title$setTooltipText('Depending on the settings, this might take several hours.')
  vbox1$packStart(label_title)
  ##################################################
  ### description
  ##################################################
  vbox2 <- gtkVBoxNew()
  vbox2$setBorderWidth(10)
  please_wait_label <- gtkLabel()
  please_wait_label$setMarkup('
Please wait while simulations are running.
')
  vbox2$packStart(please_wait_label)
  ##################################################
  ### Control Simulation Bar
  ##################################################
  task2 <- gtkSpinnerNew()
  task2['width.request'] <- 20
  # task2$SetFraction(0)
  task2_label <- gtkLabel()
  task2_label$setMarkup('<span weight=\"bold\" size=\"large\">Running control simulations</span>')
  task2_label$setWidthChars(40)
  hbox_task2 <- gtkHBoxNew(homogeneous=T)
  hbox_task2$setBorderWidth(10)
  hbox_task2$packStart(task2_label)
  hbox_task2$packStart(task2, fill=F, expand=F)
  ##################################################
  ### Treatment Simulation Bar
  ##################################################
  task3 <- gtkSpinnerNew()
  task3['width.request'] <- 20
  task3_label <- gtkLabel()
  task3_label$setMarkup('<span weight=\"bold\" size=\"large\">Running treatment simulations</span>')
  task3_label$setWidthChars(40)
  hbox_task3 <- gtkHBoxNew(homogeneous=T)
  hbox_task3$setBorderWidth(10)
  hbox_task3$packStart(task3_label)
  hbox_task3$packStart(task3, fill=F, expand=F)
  ##################################################
  ### R spinner
  ##################################################
  task4 <- gtkSpinnerNew()
  task4['width.request'] <- 20
  task4_label <- gtkLabel()
  task4_label$setMarkup('<span weight=\"bold\" size=\"large\">Preanalyzing simulations   </span>')
  task4_label$setWidthChars(40)
  hbox_task4 <- gtkHBoxNew(homogeneous=T)
  hbox_task4$setBorderWidth(10)
  hbox_task4$packStart(task4_label)
  hbox_task4$packStart(task4, fill=F, expand=F)
  ##################################################
  ### Return button
  ##################################################
  ReturnButton <- gtkButton('Stop simulations')
  ReturnButton$setTooltipText('Stop the current simulations. Only press if really necessary!')
  ReturnButton$setBorderWidth(30)
  ClickOnReturn <- function(button){
    w$destroy()
    setwd(get("origWD", envir=IBCvariables))
    Welcomefct()
  }
  gSignalConnect(ReturnButton, "clicked", ClickOnReturn)
  ##################################################
  ### put it all together
  ##################################################
  
  vbox <- gtkVBoxNew()
  vbox$setBorderWidth(10)
  vbox$packStart(vbox1)
  # vbox$packStart(vbox2)
  vbox$packStart(hbox_task2)
  vbox$packStart(hbox_task3)
  vbox$packStart(hbox_task4)
  vbox$packStart(ReturnButton,fill=F) #button which will start 
  w <- gtkWindow(show=F)
  w$setPosition('GTK_WIN_POS_CENTER')
  w["title"] <- "IBC-grass GUI"
  color <-gdkColorToString('white')
  w$ModifyBg("normal", color)
  w$add(vbox)
  w$show()
  
  
  ##################################################
  ### Running Simulations
  ##################################################
  wd<-getwd()
    #####
    # preparations
    #####
    #####
    # Delete all old simulation files
    #####
    files.list <- list.files(pattern="Pt__*")
    file.remove(files.list)   
    files.list <- list.files(pattern="Grd__*")
    file.remove(files.list)
    if (length(list.files("currentSimulation/"))>0){
      setwd('currentSimulation')
      unlink(list.files(getwd()), recursive=TRUE)
      setwd('..')
    }
    #####
    # read PFT community file and sensitivity file
    #####
    ModelVersion <- 2
    PFTfileName <- get("IBCcommunity", envir=IBCvariables)
    PFTHerbEffectFile <- "./HerbFact.txt"
    AppRateFile <- "./AppRate.txt"
    MCruns <- get("IBCrepetition", envir=IBCvariables)
    GridSize <- get("IBCgridsize", envir=IBCvariables)
    SeedInput <- get("IBCSeedInput", envir=IBCvariables)
    belowres <- get("IBCbelres", envir=IBCvariables)
    abres <- get("IBCabres", envir=IBCvariables)
    abampl <- get("IBCabampl", envir=IBCvariables)
    graz <- get("IBCgraz", envir=IBCvariables)
    tramp <- get("IBCtramp", envir=IBCvariables)
    cut <- get("IBCcut", envir=IBCvariables)
    week_start <- get("IBCweekstart", envir=IBCvariables)-10
    HerbDuration <- get("IBCDuration", envir=IBCvariables)
    RecovDuration <- get("IBCRecovery", envir=IBCvariables)
    InitDuration <- get("IBCInit", envir=IBCvariables)
    Tmax <- InitDuration + HerbDuration + RecovDuration
    HerbEff <- get("IBCherbeffect", envir=IBCvariables) # txt or dose response
    if(HerbEff=="txt-file") EffectModel <- 0
    if(HerbEff=="dose-response") EffectModel <- 2
    Scenarios <- as.numeric(get("IBCScenarios", envir=IBCvariables)) # vector of rates
    nb_data <- as.numeric(get("nb_data", envir=IBCvariables)) # number of test species
    #####
    # running control
    #####
    gtkSpinnerStart(task2)
    scenario <- 0
    # copy community file into Model-folder
    path <- "Model-files/"
    write.table(get("IBCcommunityFile", envir=IBCvariables), paste(path,PFTfileName, sep=""), sep="\t", quote=F,row.names=F)

    copy <- file.copy("Input-files/HerbFact.txt",  path)
    copy <- file.copy("Input-files/AppRate.txt",  path)
    setwd('Model-files')
    no_cores <- detectCores()-2
    cl <- makeCluster(no_cores)
    registerDoParallel(cl)

    foreach(MC = 1:MCruns)  %dopar%
      system(paste('./IBCgrassGUI', ModelVersion, GridSize, Tmax, InitDuration, PFTfileName, SeedInput, belowres, abres, abampl, tramp, graz, cut,
                   week_start, HerbDuration, 0, EffectModel, scenario, MC, sep=" "), intern=T)
    stopCluster(cl)

    setwd('..')
    remove <- file.remove(paste("Model-files/", PFTfileName, sep=""))
    remove <- file.remove("Model-files/HerbFact.txt")
    remove <- file.remove("Model-files/AppRate.txt")
    #####
    # copy control
    #####
    # create folder
    dir.create("currentSimulation/0", recursive=TRUE)
    # PFT files
    file_list <- list.files(path = "Model-files/", pattern="Pt__*")
    for (file in file_list){
      path <- paste("currentSimulation/", unlist(strsplit(file,"_"))[6], sep="")
      copy <- file.copy(paste("Model-files/" ,file , sep="") ,  path)
      #  todo make sure that all files were copied!
      if (copy==T) file.remove(paste("Model-files/" ,file , sep="") )
    }
    # GRD files
    file_list <- list.files(path = "Model-files/", pattern="Grd__*", recursive=TRUE)
    for (file in file_list){
      path <- paste("currentSimulation/", unlist(strsplit(file,"_"))[6], sep="")
      copy <- file.copy(paste("Model-files/" ,file , sep="") ,  path)
      #  todo make sure that all files were copied!
      if (copy==T) file.remove(paste("Model-files/" ,file , sep="") )
    }

    #####
    # running treatment based on txt file
    #####
    gtkSpinnerStop(task2)
    gtkSpinnerStart(task3) 
    if(HerbEff=="txt-file"){
      # for each MC run --> random sensitivity
      no_cores <- detectCores()-2
      cl <- makeCluster(no_cores)
      registerDoParallel(cl)
      PFTfile <- get("IBCcommunityFile", envir=IBCvariables)
      PFTsensitivity <- get("PFTSensitivityFile", envir=IBCvariables)
      
      foreach(MC = 1:MCruns, .export=c("PFTfile", "PFTsensitivity", "PFTfileName", "EffectModel",
                                       "ModelVersion", "belowres", "abres", "abampl", "Tmax", "InitDuration", "GridSize", "SeedInput",
                                       "HerbDuration", "tramp", "graz", "cut", "week_start"))  %dopar%
      {
        scenario <- 1
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
        # copy others
        PFTfile[PFTfile$Sensitivity=="not affected",25] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
        
        PFTfile<-PFTfile[,-ncol(PFTfile)]
        PFTfile <- cbind(PFTfile[,c(2,1)],PFTfile[,-c(1:2)])
        
        #save PFT file
        write.table(PFTfile[,-ncol(PFTfile)], paste(unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""), row.names=F, quote=F, sep="\t")
        
        path <- "Model-files/"
        copy <- file.copy(paste(unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""),  path)
        copy <- file.copy("HerbFact.txt",  path)
        copy <- file.copy("Input-files/AppRate.txt",  path)
        setwd('Model-files')
        mycall<-paste('./IBCgrassGUI', ModelVersion, GridSize, Tmax, InitDuration, paste("./",unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""), 
                      SeedInput, belowres, abres, abampl, tramp, graz, cut, 
                      week_start, HerbDuration, 1, EffectModel, scenario, MC, sep=" ")
        #start treatment run
        system(mycall, intern=TRUE)
        setwd('..')
        remove <- file.remove(paste("Model-files/", unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""))
        remove <- file.remove("Model-files/HerbFact.txt")
        remove <- file.remove("Model-files/AppRate.txt")
      }
        
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
    PFTfile <- get("IBCcommunityFile", envir=IBCvariables)
    AppRateScenarios <- get("IBCAppRateScenarios", envir=IBCvariables)
    PFTsensitivity <- get("PFTSensitivityFile", envir=IBCvariables)
    # question: same random distributions for the AppRates? --> first MCrun loop than apprate loop
    no_cores <- detectCores()-2
    cl <- makeCluster(no_cores)
    registerDoParallel(cl)
    
    foreach(MC = 1:MCruns, .export=c("PFTfile", "PFTsensitivity", "PFTfileName", "EffectModel",
                                     "ModelVersion", "belowres", "abres", "abampl", "Tmax", "InitDuration", "GridSize", "SeedInput",
                                     "week_start", "HerbDuration", "tramp", "graz", "cut", "Scenarios", "nb_data",
                                     "AppRateScenarios"))  %dopar%
    {
        #####
        # set sensitivities
        #####
        PFTfile<-merge(PFTfile, PFTsensitivity, by="Species")
        #make sure, all values are set to 0 (no affect)
        PFTfile[,28:39] <- 0
        # assign EC50 and slope values
        #####
        # biomass
        #####
        if("EC50andslope_Biomass.txt" %in% list.files()){
          # read the calculated DR
          DR<-read.table("EC50andslope_Biomass.txt", sep="\t", header=T)
          # random DRs
          # EC50
          PFTfile[PFTfile$Sensitivity=="random",28] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
          # slope
          PFTfile[PFTfile$Sensitivity=="random",29] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
          # existing DR
          for (i in 1:nb_data){
            # EC50
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),28] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
            # slope
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),29] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
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
          DR<-read.table("EC50andslope_SeedlingBiomass.txt", sep="\t", header=T)
          # random DRs
          # EC50
          PFTfile[PFTfile$Sensitivity=="random",30] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
          # slope
          PFTfile[PFTfile$Sensitivity=="random",31] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
          # existing DR
          for (i in 1:nb_data){
            # EC50
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),30] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
            # slope
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),31] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
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
          DR<-read.table("EC50andslope_Survival.txt", sep="\t", header=T)
          # random DRs
          # EC50
          PFTfile[PFTfile$Sensitivity=="random",32] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
          # slope
          PFTfile[PFTfile$Sensitivity=="random",33] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
          # existing DR
          for (i in 1:nb_data){
            # EC50
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),32] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
            # slope
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),33] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
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
        if("EC50andslope_Establishment.txt" %in% list.files()){
          # read the calculated DR
          DR<-read.table("EC50andslope_Establishment.txt", sep="\t", header=T)
          # random DRs
          # EC50
          PFTfile[PFTfile$Sensitivity=="random",34] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
          # slope
          PFTfile[PFTfile$Sensitivity=="random",35] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
          # existing DR
          for (i in 1:nb_data){
            # EC50
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),34] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
            # slope
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),35] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
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
          DR<-read.table("EC50andslope_SeedSterility.txt", sep="\t", header=T)
          # random DRs
          # EC50
          PFTfile[PFTfile$Sensitivity=="random",36] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
          # slope
          PFTfile[PFTfile$Sensitivity=="random",37] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
          # existing DR
          for (i in 1:nb_data){
            # EC50
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),36] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
            # slope
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),37] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
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
          DR<-read.table("EC50andslope_SeedNumber.txt", sep="\t", header=T)
          # random DRs
          # EC50
          PFTfile[PFTfile$Sensitivity=="random",38] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
          # slope
          PFTfile[PFTfile$Sensitivity=="random",39] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity=="random",]), min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
          # existing DR
          for (i in 1:nb_data){
            # EC50
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),38] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,2] - DR[nb_data+2,2]), max = (DR[nb_data+1,2] + DR[nb_data+2,2])))
            # slope
            PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),39] <- c(runif(nrow(PFTfile[PFTfile$Sensitivity==paste("dose response based on Spec ", i, sep=""),]),  min = (DR[nb_data+1,3] - DR[nb_data+2,3]), max = (DR[nb_data+1,3] + DR[nb_data+2,3])))
          } # end nb of test species
          # not affected
          # EC50
          PFTfile[PFTfile$Sensitivity=="not affected",38] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
          # slope
          PFTfile[PFTfile$Sensitivity=="not affected",39] <- c(rep(0, nrow(PFTfile[PFTfile$Sensitivity=="not affected",])))
        } # end seed number affected
        PFTfile<-PFTfile[,-ncol(PFTfile)]
        PFTfile <- cbind(PFTfile[,c(2,1)],PFTfile[,-c(1:2)])
        #save PFT file
        write.table(PFTfile[,-ncol(PFTfile)], paste(unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""), row.names=F, quote=F, sep="\t")
        #####
        # run simulations per apprate
        #####
        path <- "Model-files/"
        copy <- file.copy(paste(unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""),  path)
        copy <- file.copy("Input-files/HerbFact.txt",  path)
        setwd('Model-files')
        for(scenario in 1:Scenarios){
          #split txt file with all AppRates of all Scenarios into the scenario and save as AppRate.txt
          write.table(AppRateScenarios[,scenario], "AppRate.txt",  col.names=FALSE,  row.names=FALSE, sep="\t")
          mycall<-paste('./IBCgrassGUI',ModelVersion, GridSize, Tmax, InitDuration, 
                        paste("./",unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""), 
                        SeedInput, belowres, abres, abampl, tramp, graz, cut, 
                        week_start, HerbDuration, 1, EffectModel, scenario, MC, sep=" ")
          #start treatment run
          system(mycall, intern=TRUE)
          remove <- file.remove("Model-files/AppRate.txt")
          } # end for apprates
        setwd('..')
        remove <- file.remove(paste("Model-files/", unlist(strsplit(PFTfileName,".txt")), MC, ".txt", sep=""))
        remove <- file.remove("Model-files/HerbFact.txt")
        
    }
      
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
    dir.create(paste("currentSimulation/HerbicideSettings", sep=""), recursive=TRUE)
    file_list <- list.files(pattern=paste(unlist(strsplit(PFTfileName,".txt")),"*",sep=""))
    file_list <- file_list[file_list!=PFTfileName]
    file_list <- c(file_list, "SimulationSettings.Rdata", "Example_doseresponse.png", "AppRateScenarios.txt")
    copy <- file.copy(file_list ,  paste("currentSimulation/HerbicideSettings", sep=""))
    #  todo make sure that all files were copied!
    if (all(copy==T)) file.remove(file_list)
    copy <- file.copy("HerbFact.txt" ,  paste("currentSimulation/HerbicideSettings", sep=""))
    if (all(copy==T)) file.remove("HerbFact.txt")
    copy <- file.copy("PFTsensitivity.txt" ,  paste("currentSimulation/HerbicideSettings", sep=""))
    if (all(copy==T)) file.remove("PFTsensitivity.txt")
    file_list <- list.files(pattern="EC50andslope*")
    copy <- file.copy(file_list ,  paste("currentSimulation/HerbicideSettings", sep=""))
    #  todo make sure that all files were copied!
    if (all(copy==T)) file.remove(file_list)
    #
    file_list <- list.files(pattern="*Effects.txt")
    copy <- file.copy(file_list ,  paste("currentSimulation/HerbicideSettings", sep=""))
    #  todo make sure that all files were copied!
    if (all(copy==T)) file.remove(file_list)
  } # end if dose response based
  ##################################################
  ### Start R Analyses
  ##################################################
  gtkSpinnerStop(task3) 
  gtkSpinnerStart(task4) 
    #####
    # necessary functions
    #####
    shannon <- function(df) {
      #proportional abundance
      sum <- sum(df)
      pi <- df/sum
      #shannon index
      pi_shannon <- pi*log(pi)
      shannon <- -sum(pi_shannon)
      return(shannon)
    }
  
    simpson <- function(df){
      #proportional abundance
      sum <- sum(df)
      pi <- df/sum
      #simpson index
      pi_simpson <- pi^2
      simpson <- 1-sum(pi_simpson)
      return(simpson)
    }
    
    simpsoninv <- function(df){
      #proportional abundance
      sum <- sum(df)
      pi <- df/sum
      #simpson index
      pi_simpson <- pi^2
      #inverse simpson index
      simpsoninv <- 1/sum(pi_simpson)
      return(simpsoninv)
    }
    
    eveness <- function(df){
      #proportional abundance
      sum <- sum(df)
      pi <- df/sum
      #shannon index
      pi_shannon <- pi*log(pi)
      shannon <- -sum(pi_shannon)
      # eveness
      eveness <- shannon/log(length(df))
      return(eveness)
    }
 
    #####
    # combine all repetitions for all apprate directories
    #####
    wd<-getwd()
    setwd("currentSimulation/")
    dir <- list.files()
    dir <- dir[dir!="HerbicideSettings"]
    results.PFT <- data.frame()
    results.GRD <- data.frame()
    for (curr_dir in dir){
      setwd(curr_dir)
      rm(PFT, diversity_Inds)
      file_list <- list.files(pattern="Pt__*")
      
      for (file in file_list){
        if (!exists("PFT")){
          # save also MC run ID
          MCtmp <- unlist(strsplit(file, "_"))[7]
          MC <- unlist(strsplit(MCtmp, ".txt"))
          temp <-  fread(file, sep="\t")
          temp[,MC:=MC]
          PFT<-temp
        } else {
          MCtmp <- unlist(strsplit(file, "_"))[7]
          MC <- unlist(strsplit(MCtmp, ".txt"))
          temp <-  fread(file, sep="\t")
          temp[,MC:=MC]
          # also save MC run ID
          l <- list(PFT,temp)
          PFT<-rbindlist(l)
        }
        diversity <- temp[Inds>0,.(shannon = shannon(Inds), simpson = simpson(Inds), simpsoninv = simpsoninv(Inds), eveness = eveness(Inds)), by=.(Time)]
        if (!exists("diversity_Inds")){
          diversity_Inds <-  diversity
        } else {
          l <-  list(diversity_Inds,diversity)
          diversity_Inds <- rbindlist(l)
        }
        rm(temp)
      }
      
      PFT<-PFT[,scenario:=curr_dir,]
  
      fwrite(PFT, "alltogether_PFT.txt", sep="\t")
      l <- list(results.PFT,PFT)
      results.PFT <- rbindlist(l)
      
      rm(GRD)
      file_list <- list.files(pattern="Grd__*")
      for (file in file_list){
        if (!exists("GRD")){
          MCtmp <- unlist(strsplit(file, "_"))[7]
          MC <- unlist(strsplit(MCtmp, ".txt"))
          temp <-  fread(file, sep="\t")
          temp[,MC:=MC]
          GRD<-temp
        }
        # if the merged dataset does exist, append to it
        else {
          MCtmp <- unlist(strsplit(file, "_"))[7]
          MC <- unlist(strsplit(MCtmp, ".txt"))
          temp <-  fread(file, sep="\t")
          temp[,MC:=MC]
          # also save MC run ID
          l <- list(GRD, temp)
          GRD<-rbindlist(l)
          rm(temp)
        }
      }
      setkey(diversity_Inds, Time)
      GRD <- GRD[,-9]
      setkey(GRD, Time)
      GRD<-GRD[diversity_Inds, all=T]
      GRD[,scenario:=curr_dir]
      fwrite(GRD, "alltogether_GRD.txt", sep="\t")
      l <- list(results.GRD,GRD)
      results.GRD <- rbindlist(l)
      
      # change to base directory
      setwd('..')
    }
    fwrite(results.PFT[,-5], "resultsPFT.txt", sep="\t")
    results.GRD[is.na(results.GRD)] <- 0
    fwrite(results.GRD[,-c(2,5,6,7,8,10,11,12,13,14,15,16)], "resultsGRD.txt", sep="\t")
    rm(PFT, GRD, temp_GRD, shannon, simpson, simpsoninv, results.PFT, results.GRD, diversity, diversity_Inds)
    gc()
    #####
    # calculate effects for each repetion
    #####
      #####
      # for PFTs
      #####
      results.PFT <- fread("resultsPFT.txt", sep="\t")
      results.PFT[,Inds:=Inds+1]
      results.PFT[,seedlings:=seedlings+1]
      results.PFT[,seeds:=seeds+1]
      results.PFT[,cover:=cover+1]
      results.PFT[,shootmass:=shootmass+1]
    
      control_frequ  <- results.PFT[Inds>1, .(frequ=length(Inds)), by=.(scenario, PFT, Time)]
      control_frequ[,Frequency:=frequ/max(frequ)]
      mean_frequ <- control_frequ[scenario==0,.(mean.frequ=mean(Frequency)),by=.(PFT)]
      mean_frequ <- mean_frequ[mean.frequ>0.5,]
      results.PFT <- results.PFT[PFT %in% mean_frequ$PFT,]
      # calculate control mean
      control.mean.PFT<-results.PFT[scenario==0,.(mean.Inds=mean(Inds),  mean.seedlings=mean(seedlings),
                            mean.seeds=mean(seeds), mean.cover=mean(cover), mean.shootmass=mean(shootmass)), by=.(Time, PFT)]
        
      setkey(results.PFT, Time, PFT, scenario)
      setkey(control.mean.PFT, Time, PFT)
      results.PFT<-results.PFT[control.mean.PFT,allow.cartesian = T]
 
      results.PFT[,Inds := ((Inds/mean.Inds))]
    
      results.PFT[,seedlings := ((seedlings/mean.seedlings))]
    
      results.PFT[,seeds := ((seeds/mean.seeds))]
    
      results.PFT[,cover := ((cover/mean.cover))]
    
      results.PFT[,shootmass := ((shootmass/mean.shootmass))]
      
      # get year + week
      results.PFT[,year:= floor((Time-1)/30)]
      results.PFT[, week := Time-(year*30)]
      results.PFT[,year := year+1]
      
      results.PFT[, period:= "during"] 
      results.PFT[year<InitDuration, period := "before"] 
      results.PFT[year>=(InitDuration+HerbDuration), period := "after"] 
      # only frequent PFTs
      frequentPFTs <- results.PFT[,.(mean.Popsize=mean(mean.Inds)),by=.(PFT)]
      frequentPFTs<-frequentPFTs[mean.Popsize>5,]
      results.PFT<-results.PFT[PFT %in% frequentPFTs$PFT,]
      #save
      fwrite(results.PFT, "resultsPFT.txt", sep="\t")
      rm(results.PFT, frequentPFTs, control.mean.PFT)
      gc()
      
      #####
      # for GRD
      #####
      results.GRD <- fread("resultsGRD.txt", sep="\t")
      results.GRD[,NInd:=NInd+1]
      results.GRD[,abovemass:=abovemass+1]
      results.GRD[,NPFT:=NPFT+1]
      results.GRD[,eveness:=eveness+1]
      results.GRD[,shannon:=i.shannon+1]
      results.GRD[,simpson:=simpson+1]
      results.GRD[,simpsoninv:=simpsoninv+1]
      # calculate control mean
      control.mean.GRD<-results.GRD[scenario==0,.(mean.NInd=mean(NInd),  mean.abovemass=mean(abovemass),
                                                  mean.NPFT=mean(NPFT), mean.eveness=mean(eveness), mean.shannon=mean(shannon),
                                                  mean.simpson=mean(simpson), mean.simpsoninv=mean(simpsoninv)), by=.(Time)]
    
      setkey(results.GRD, Time, scenario)
      setkey(control.mean.GRD, Time)
      results.GRD<-results.GRD[control.mean.GRD,allow.cartesian = T]
      
      results.GRD[,NInd := ((NInd/mean.NInd))]
      
      results.GRD[,abovemass := ((abovemass/mean.abovemass))]
      
      results.GRD[,NPFT := ((NPFT/mean.NPFT))]
      
      results.GRD[,eveness := ((eveness/mean.eveness))]
      
      results.GRD[,shannon := ((shannon/mean.shannon))]
      
      results.GRD[,simpson := ((simpson/mean.simpson))]
     
      results.GRD[,simpsoninv := ((simpsoninv/mean.simpsoninv))]
      
      # year and week
      results.GRD[,year:= floor((Time-1)/30)]
      results.GRD[, week := Time-(year*30)]
      results.GRD[,year := year+1]
      
      results.GRD[, period:= "during"] 
      results.GRD[year<InitDuration, period := "before"] 
      results.GRD[year>=(InitDuration+HerbDuration), period := "after"] 
      
      fwrite(results.GRD, "resultsGRD.txt", sep="\t")
      rm(results.GRD, control.mean.GRD)
      setwd('..')
  #####
  # Continue Analyses Dialog
  #####
  BasisAnalyses()
  gtkSpinnerStop(task4)
  w$destroy()
  Results()
} # end start simulations
