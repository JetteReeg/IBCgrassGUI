###############################################################################
# This function comprises the herbicide settings.                             #
# It defines the duration of herbicide application [years], the affected      #
# attributes and the source of herbicide effects [txt or dose-response].      #
###############################################################################
HerbicideSettings<-function(){
  ##################################################
  ### Title
  ##################################################
  vbox1 <- gtkVBoxNew()
  vbox1$setBorderWidth(5)
  label_title <- gtkLabel()
  label_title$setMarkup('<span weight=\"bold\" size=\"x-large\">Herbicide effect settings</span>')
  vbox1$packStart(label_title)
  
  ##################################################
  ### Duration settings
  ##################################################
  vbox2 <- gtkVBoxNew()
  vbox2$setBorderWidth(10)
  # title
  label_timing <- gtkLabel()
  label_timing$setMarkup('<span weight=\"bold\"size=\"large\">How long should a period last?</span>')
  label_timing['height.request'] <- 20
  # Slider init duration
  label_init<-gtkLabel('Initial years before herbicide application [years]')
  label_init$setTooltipText("The higher values you choose, the more stable are the communities when the simulation of herbicide application start. But it also increases simulation runtime.")
  InitSlider <- gtkHScale(min = 1, max = 150, step = 1)
  InitSlider$setTooltipText("The higher values you choose, the more stable are the communities when the simulation of herbicide application start. But it also increases simulation runtime.")
  InitSlider$setValue(get("IBCInit",envir=IBCvariables))
  # Slider herbicide duration
  label_duration<-gtkLabel('Herbicide duration [years]')
  label_duration$setTooltipText("The model simulates 1 herbicide application each year [effects occur for 1 week of each process].")
  DurationSlider <- gtkHScale(min = 1, max = 100, step = 1)
  DurationSlider$setTooltipText("The model simulates 1 herbicide application each year [effects occur for 1 week of each process].")
  DurationSlider$setValue(get("IBCDuration", envir=IBCvariables))
  # Slider herbicide duration
  label_weekstart<-gtkLabel('Week of herbicide application [calender week]')
  label_weekstart$setTooltipText("The model can simulate different timings of the herbicide application [effects occur for 1 week of each process].")
  weekstartSlider <- gtkHScale(min = 11, max = 40, step = 1)
  weekstartSlider$setTooltipText("The model can simulate different timings of the herbicide application [effects occur for 1 week of each process].")
  weekstartSlider$setValue(get("IBCweekstart", envir=IBCvariables))
  # Slider recovery duration
  label_recovery<-gtkLabel('Recovery duration [years]')
  label_recovery$setTooltipText("The recovery period follows the herbicide application period to analyse the potential ability to recover.")
  RecoverySlider <- gtkHScale(min = 0, max = 100, step = 1)
  RecoverySlider$setTooltipText("The recovery period follows the herbicide application period to analyse the potential ability to recover.")
  RecoverySlider$setValue(get("IBCRecovery", envir=IBCvariables))

  #packing
  vbox2$packStart(label_timing)
  vbox2$packStart(label_init)
  vbox2$packStart(InitSlider)
  vbox2$packStart(label_duration)
  vbox2$packStart(DurationSlider)
  vbox2$packStart(label_weekstart)
  vbox2$packStart(weekstartSlider)
  vbox2$packStart(label_recovery)
  vbox2$packStart(RecoverySlider)
  
  ##################################################
  ### Attribute settings
  ##################################################
  vbox3 <- gtkVBoxNew()
  vbox3$setBorderWidth(10)
  # title
  label_endpoints <- gtkLabel()
  label_endpoints$setMarkup('<span weight=\"bold\"size=\"large\">Which attributes are affected?</span>')
  label_endpoints['height.request'] <- 20
  # check points affected attributes
  BiomassCheck<-gtkCheckButton('shoot mass')
  BiomassCheck$setTooltipText("The gain in shoot mass of plants is reduced for one week.")
  BiomassCheck$setActive(get("BiomassEff", envir=IBCvariables))
  SeedlingBiomassCheck<-gtkCheckButton('seedling shoot mass')
  SeedlingBiomassCheck$setTooltipText("The gain in shoot mass of established seedlings is reduced for one week.")
  SeedlingBiomassCheck$setActive(get("SeedlingBiomassEff", envir=IBCvariables))
  SurvivalCheck<-gtkCheckButton('survival')
  SurvivalCheck$setTooltipText("The survival probability of a plant is decreased.")
  SurvivalCheck$setActive(get("SurvivalEff", envir=IBCvariables))
  EstablishmentCheck<-gtkCheckButton('establishment')
  EstablishmentCheck$setTooltipText("The establishment success of a seed is decreased.")
  EstablishmentCheck$setActive(get("EstablishmentEff", envir=IBCvariables))
  SeedSterilityCheck<-gtkCheckButton('seed sterility')
  SeedSterilityCheck$setTooltipText("The germination probability of a seed is decreased.")
  SeedSterilityCheck$setActive(get("SeedSterilityEff", envir=IBCvariables))
  SeedNumberCheck<-gtkCheckButton('seed number')
  SeedNumberCheck$setTooltipText("The number of produced seeds is decreased.")
  SeedNumberCheck$setActive(get("SeedNumberEff", envir=IBCvariables))

  # packing
  vbox3$packStart(label_endpoints)
  vbox3$packStart(BiomassCheck)
  vbox3$packStart(SeedlingBiomassCheck)
  vbox3$packStart(SurvivalCheck)
  vbox3$packStart(EstablishmentCheck)
  vbox3$packStart(SeedSterilityCheck)
  vbox3$packStart(SeedNumberCheck)
  
  ##################################################
  ### Source of herbicide impact
  ##################################################
  vbox4 <- gtkVBoxNew()
  vbox4$setBorderWidth(10)
  # title
  label_effect <- gtkLabel()
  label_effect$setMarkup('<span weight=\"bold\"size=\"large\">Herbicide effects based on</span>')
  label_effect$setTooltipText("You can either select specific effect intensities [0-1] for each attribute via a txt-file  or - if available - enter the data of standardized greenhouse experiments for the selected attributes.")
  label_effect['height.request'] <- 20
  # choices: either txt-file (for testing the impact of various intensities) or dose-responses
  Effectchoices <- c("Please select option", "txt-File", "dose-response function per attribute")
  comboherbeff <- gtkComboBoxNewText()
  comboherbeff$show()
  for (choice in Effectchoices) comboherbeff$appendText(choice)
  #
  herbeff <- get("IBCherbeffect", envir = IBCvariables)
  if(herbeff=="") comboherbeff$setActive(0)
  if(herbeff=="txt-file") comboherbeff$setActive(1)
  if(herbeff=="dose-response") comboherbeff$setActive(2)
  
  # packing
  vbox4$packStart(label_effect)
  vbox4$packStart(comboherbeff)
  
  ##################################################
  ### Functions
  ##################################################
  vbox5 <- gtkVBoxNew()
  vbox5$setBorderWidth(10)
  # after selection...
  ClickOnContinue <- function(button){
    active<-comboherbeff$getActive()
    # make sure at least one attribute was selected
    if(all(c(BiomassCheck$getActive(), SeedlingBiomassCheck$getActive(), SurvivalCheck$getActive(),
             EstablishmentCheck$getActive(),SeedSterilityCheck$getActive(),SeedNumberCheck$getActive())==F)){
      dialog1 <- gtkMessageDialog(parent=HerbicideWindow,
                                  flags = "destroy-with-parent",
                                  type="warning" ,
                                  buttons="ok" ,
                                  "Please select at least one attribute.")
      color <-gdkColorToString('white')
      dialog1$ModifyBg("normal", color)
      gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
    }
    # make sure one source was selected
    if (active == 0){
      dialog1 <- gtkMessageDialog(parent=HerbicideWindow,
                                  flags = "destroy-with-parent",
                                  type="warning" ,
                                  buttons="ok" ,
                                  "Please select the source of the effect.")
      color <-gdkColorToString('white')
      dialog1$ModifyBg("normal", color)
      gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
    } else{
      # save selected values
      assign("IBCDuration", DurationSlider$getValue(), envir=IBCvariables)
      assign("IBCweekstart", weekstartSlider$getValue(), envir=IBCvariables)
      assign("IBCRecovery", RecoverySlider$getValue(), envir=IBCvariables)
      assign("IBCInit", InitSlider$getValue(), envir=IBCvariables)
      assign("BiomassEff", BiomassCheck$getActive(), envir=IBCvariables)
      assign("SeedlingBiomassEff", SeedlingBiomassCheck$getActive(), envir=IBCvariables)
      assign("SurvivalEff", SurvivalCheck$getActive(), envir=IBCvariables)
      assign("EstablishmentEff", EstablishmentCheck$getActive(), envir=IBCvariables)
      assign("SeedSterilityEff", SeedSterilityCheck$getActive(), envir=IBCvariables)
      assign("SeedNumberEff", SeedNumberCheck$getActive(), envir=IBCvariables)
      # if source is a txt-file
      if (active == 1){
        assign("IBCherbeffect", "txt-file", envir = IBCvariables)
        # if no effect data exist (e.g. if previous settings were loaded)
        if (is.null(get("EffectData", envir=IBCvariables))){
          df<-NULL
          #####
          # create the table
          #####
          # row for biomass
          if (BiomassCheck$getActive()) {
            if (!exists("df")) { 
              df <- data.frame (Biomass=c(rep(0.0,DurationSlider$getValue())))
            } else {
              df <- cbind(df, Biomass=c(rep(0.0,DurationSlider$getValue())))
            }
          }
          # row for seedling biomass
          if (SeedlingBiomassCheck$getActive()) {
            if (!exists("df")) { 
              df <- data.frame (SeedlingBiomass=c(rep(0.0,DurationSlider$getValue())))
            } else {
              df <- cbind(df, SeedlingBiomass=c(rep(0.0,DurationSlider$getValue())))
            }
          }
          # row for survival
          if (SurvivalCheck$getActive()) {
            if (!exists("df")) { 
              df <- data.frame (Mortality=c(rep(0.0,DurationSlider$getValue())))
            } else {
              df <- cbind(df, Mortality=c(rep(0.0,DurationSlider$getValue())))
            }
          }
          # row for establishment
          if (EstablishmentCheck$getActive()) {
            if (!exists("df")) { 
              df <- data.frame (Establishment=c(rep(0.0,DurationSlider$getValue())))
            } else {
              df <- cbind(df, Establishment=c(rep(0.0,DurationSlider$getValue())))
            }
          }
          # row for seed sterility
          if (SeedSterilityCheck$getActive()) {
            if (!exists("df")) { 
              df <- data.frame (SeedSterility=c(rep(0.0,DurationSlider$getValue())))
            } else {
              df <- cbind(df, SeedSterility=c(rep(0.0,DurationSlider$getValue())))
            }
          }
          # row for seed number
          if (SeedNumberCheck$getActive()) {
            if (!exists("df")) { 
              df <- data.frame (SeedNumber=c(rep(0.0,DurationSlider$getValue())))
            } else {
              df <- cbind(df, SeedNumber=c(rep(0.0,DurationSlider$getValue())))
            }
          }
          
          col.name<-colnames(df)
          df <-data.frame(df, row.names = NULL)
        } else {
          # load previous effect data
          df <- get("EffectData", envir=IBCvariables)
        }
        # create a dataframe object
        obj <- gtkDfEdit(df, update=T, envir=IBCvariables)
        
        #####
        # What to do
        #####
        label_txtfile<-gtkLabel()
        label_txtfile$setMarkup('
                                <span weight=\"bold\" size=\"large\">Herbicide effects</span>
                                <span size=\"large\">Please insert the herbicide effects for each of the selected attributes.
                                The effect occurs in one week each year.
                                The effect needs to be between 0-1. 0: no effect, 1: 100% effect.</span><span weight=\"bold\"></span>')
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
          if(is.null(test[test>1])){
            dialog1 <- gtkMessageDialog(parent=win,
                                        flags = "destroy-with-parent",
                                        type="warning" ,
                                        buttons="ok" ,
                                        "Please make sure, that all effects are not higher than 1.")
            color <-gdkColorToString('white')
            dialog1$ModifyBg("normal", color)
            gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
          } else{
            # close windows
            win$destroy()
            HerbicideWindow$destroy()
            # save the table
            test<-df[,-1]
            df_ref<-data.frame(Biomass=c(rep(0,0)), SeedlingBiomass=c(rep(0,0)), 
                               Mortality=c(rep(0,0)), Establishment=c(rep(0,0)),
                               SeedSterility=c(rep(0,0)), SeedNumber=c(rep(0,0)))
            df_save <- merge(test, df_ref, all=T, sort=F)
            df_save[is.na(df_save)] <- 0
            df_save <- df_save[c("Biomass", "Mortality", "SeedlingBiomass", "Establishment", "SeedSterility", "SeedNumber")]
            assign("EffectData", df_save, envir=IBCvariables)
            write.table(df_save, "HerbFact.txt", row.names=F, quote=F, sep="\t")
            # call the sensitivity window
            SensitivityTXT()
          }
        }
        # return to the herbicide settings
        ReturnButton <- gtkButton('Back')
        ReturnButton$setTooltipText("Go back to the previous step.")
        ClickOnReturn <- function(button){
          # destroy current windows
          win$destroy()
          HerbicideWindow$destroy()
          # call herbicide window
          HerbicideSettings()
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
      # if selected source is dose response
      if (active == 2){
        assign("IBCherbeffect", "dose-response", envir = IBCvariables)
        rep.col<-function(x,n){
          matrix(rep(x,each=n), ncol=n, byrow=TRUE)
        }
        #####
        # Go through all selected attributes
        #####
        BiomassEffect<-function(button){
          assign("nb_data", entry_nb_doseresponses$getText(), envir = IBCvariables)
          win$destroy()
          #####
          # biomass
          #####
          # if biomass was selected
          if (BiomassCheck$getActive()){
            #####
            # create the dataframe
            #####
            # if no data has been reloaded
            if (is.null(get("BiomassEffFile", envir=IBCvariables))){
              column_name <- c()
              nb_data <- as.numeric(get("nb_data", envir = IBCvariables))
              for (i in 1:nb_data){
                column_name_help <- c(paste('ApplicationRate_Spec',i,sep=""), paste('Effect_Spec',i, sep=""))
                column_name <- c(column_name, column_name_help)
              }
              col <- c(rep(0.0, 3))
              df <- as.data.frame(rep.col(col, length(column_name)))
              colnames(df)<-column_name
            } else{
              # otherwise load the data
              df <- get("BiomassEffFile", envir=IBCvariables)
            }
            # data frame object
            obj <- gtkDfEdit(df)
            #####
            # What to do
            #####
            label_txtfile<-gtkLabel()
            label_txtfile$setMarkup('
                                    <span weight=\"bold\" size=\"large\">Shoot mass effects</span>
                                    <span size=\"large\">Please insert the tested herbicide application rates and the measured effect data
                                    on shoot mass for each of the tested species.
                                    The effect data should give the relation to control [0-1, 1 meaning no effect].
                                    Missing values should be NAs.</span>')
            label_txtfile['height.request'] <- 110
            #####
            # Buttons and their functions
            #####
            SaveCloseButtonBiomass_help <- gtkButton('Save shoot mass effects & continue')
            # create data.frame for data input, save and continue
            SaveCloseBiomass_help <- function(button){
              df<-obj$getModel()
              test<-data.frame(df)
              # calculate expected column number
              col_exp <- as.numeric(get("nb_data", IBCvariables))*2
              # delete everything greater than the expected column number
              test<-test[,c(2:(col_exp+1))]
              
              if (all(test==0)){
                # if there are only 0's
                dialog1 <- gtkMessageDialog(parent=winBiomass_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are values.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else if(any(test[test<0], na.rm = TRUE)){
                # if there are negative values..
                dialog1 <- gtkMessageDialog(parent=winBiomass_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are no negative effects.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else{
                # save effect data
                write.table(df, "BiomassEffects.txt", row.names=F, quote=F, sep="\t")
                test<-data.frame(df)
                # calculate expected column number
                col_exp <- as.numeric(get("nb_data", IBCvariables))*2
                # delete everything greater than the expected column number
                test<-test[,c(2:(col_exp+1))]
                assign("BiomassEffFile", test, IBCvariables)
                # close window and go to next attribute
                winBiomass_help$destroy()
                SeedlingEffect()
              }
            } # end save and close go biomass entry window
            # return to previous step
            ReturnButtonBiomass <- gtkButton('Back')
            ReturnButtonBiomass$setTooltipText('Go back to the previous step.')
            ClickOnReturnBiomass <- function(button){
              # close windows
              HerbicideWindow$destroy()
              winBiomass_help$destroy()
              # call herbicide settings
              HerbicideSettings()
            }
            
            gSignalConnect(SaveCloseButtonBiomass_help, "clicked", SaveCloseBiomass_help)
            gSignalConnect(ReturnButtonBiomass, "clicked", ClickOnReturnBiomass)
            #####
            # put it together
            #####
            vboxBiomass_help <- gtkVBoxNew()
            vboxBiomass_help$setBorderWidth(10)
            vboxBiomass_help$packStart(label_txtfile)
            vboxBiomass_help$packStart(obj)
            vboxBiomass_help$packStart(SaveCloseButtonBiomass_help,fill=F)
            vboxBiomass_help$packStart(ReturnButtonBiomass,fill=F)
            
            color <-gdkColorToString('white')
            winBiomass_help <- gtkWindowNew(show=F)
            winBiomass_help["title"] <- "IBC-grass GUI"
            winBiomass_help$setPosition('GTK_WIN_POS_CENTER')
            winBiomass_help$ModifyBg("normal", color)
            winBiomass_help$add(vboxBiomass_help)
            winBiomass_help$show()
          } else SeedlingEffect()
        }
        #####
        # Seedling biomass
        #####
        # if seedling biomass was selected
        SeedlingEffect <- function(){
          if (SeedlingBiomassCheck$getActive()){
            #####
            # create the dataframe
            #####
            # if no previous data was loaded
            if (is.null(get("SeedlingBiomassEffFile", envir=IBCvariables))){
              column_name <- c()
              nb_data <- as.numeric(get("nb_data", envir = IBCvariables))
              for (i in 1:nb_data){
                column_name_help <- c(paste('ApplicationRate_Spec',i,sep=""), paste('Effect_Spec',i, sep=""))
                column_name <- c(column_name, column_name_help)
                # df <- cbind(df, c(rep(0.0,10)))
              }
              col <- c(rep(0.0, 3))
              df <- as.data.frame(rep.col(col, length(column_name)))
              colnames(df)<-column_name
            } else{
              # otherwise load previous data
              df <- get("SeedlingBiomassEffFile", envir=IBCvariables)
            }
            # data frame object
            obj <- gtkDfEdit(df)
            #####
            # What to do
            #####
            label_txtfile_Seedling<-gtkLabel()
            label_txtfile_Seedling$setMarkup('
                                             <span weight=\"bold\" size=\"large\">Seedling shoot mass effects</span>
                                             <span size=\"large\">Please insert the tested herbicide application rates and the measured effect data
                                             on seedling shoot mass for each of the tested species.
                                             The effect data should give the relation to control [0-1, 1 meaning no effect].
                                             Missing values should be NAs.</span>')
            label_txtfile_Seedling['height.request'] <- 110
            #####
            # Buttons and their functions
            #####
            SaveCloseButtonSeedlingBiomass_help <- gtkButton('Save seedling shoot mass effects & continue')
            SaveCloseSeedlingBiomass_help <- function(button){
              df<-obj$getModel()
              test<-data.frame(df)
              # calculate expected column number
              col_exp <- as.numeric(get("nb_data", IBCvariables))*2
              # delete everything greater than the expected column number
              test<-test[,c(2:(col_exp+1))]
              if (all(test==0)){
                # if there are only 0's
                dialog1 <- gtkMessageDialog(parent=winBiomass_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are values.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else if(any(test[test<0], na.rm = TRUE)){
                # if there are negative values..
                dialog1 <- gtkMessageDialog(parent=winSeedlingBiomass_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are no negative effects.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else{
                # save data
                write.table(df, "SeedlingBiomassEffects.txt", row.names=F, quote=F, sep="\t")
                test<-data.frame(df)
                # calculate expected column number
                col_exp <- as.numeric(get("nb_data", IBCvariables))*2
                # delete everything greater than the expected column number
                test<-test[,c(2:(col_exp+1))]
                assign("SeedlingBiomassEffFile", test, IBCvariables)
                winSeedlingBiomass_help$destroy()
                # call survival
                SurvivalEffect()
              }
            } # end save and close go biomass entry window
            # return to previous step
            ReturnButtonSeedlingBiomass <- gtkButton('Back')
            ReturnButtonSeedlingBiomass$setTooltipText("Go back to the previous step.")
            ClickOnReturnSeedlingBiomass <- function(button){
              # close windows
              HerbicideWindow$destroy()
              winSeedlingBiomass_help$destroy()
              # call herbicide settings
              HerbicideSettings()
            }
            
            gSignalConnect(SaveCloseButtonSeedlingBiomass_help, "clicked", SaveCloseSeedlingBiomass_help)
            gSignalConnect(ReturnButtonSeedlingBiomass, "clicked", ClickOnReturnSeedlingBiomass)
            #####
            # put it together
            #####
            vboxSeedlingBiomass_help <- gtkVBoxNew()
            vboxSeedlingBiomass_help$setBorderWidth(10)
            vboxSeedlingBiomass_help$packStart(label_txtfile_Seedling)
            vboxSeedlingBiomass_help$packStart(obj)
            vboxSeedlingBiomass_help$packStart(SaveCloseButtonSeedlingBiomass_help,fill=F)
            vboxSeedlingBiomass_help$packStart(ReturnButtonSeedlingBiomass,fill=F)
            winSeedlingBiomass_help <- gtkWindowNew(show=F)
            winSeedlingBiomass_help$setPosition('GTK_WIN_POS_CENTER')
            winSeedlingBiomass_help["title"] <- "IBC-grass GUI"
            winSeedlingBiomass_help$ModifyBg("normal", color)
            winSeedlingBiomass_help$add(vboxSeedlingBiomass_help)
            winSeedlingBiomass_help$show()
          } # end if seedling biomass affected
          else SurvivalEffect()
        }
        #####
        # Survival
        #####
        SurvivalEffect <- function(){
          # if survival was selected
          if (SurvivalCheck$getActive()){
            #####
            # create the dataframe
            #####
            if (is.null(get("SurvivalEffFile", envir=IBCvariables))){
              column_name <- c()
              nb_data <- as.numeric(get("nb_data", envir = IBCvariables))
              for (i in 1:nb_data){
                column_name_help <- c(paste('ApplicationRate_Spec',i,sep=""), paste('Effect_Spec',i, sep=""))
                column_name <- c(column_name, column_name_help)
              }
              col <- c(rep(0.0, 3))
              df <- as.data.frame(rep.col(col, length(column_name)))
              colnames(df)<-column_name
            } else{
              df <- get("SurvivalEffFile", envir=IBCvariables)
            }
            # data frame object
            obj <- gtkDfEdit(df)
            #####
            # What to do
            #####
            label_txtfile_Survival<-gtkLabel()
            label_txtfile_Survival$setMarkup('
                                             <span weight=\"bold\" size=\"large\">Survival effects</span>
                                             <span size=\"large\"> Please insert the tested herbicide application rates and the measured effect data
                                             on survival for each of the tested species.
                                             The effect data should give the relation to control [0-1, 1 meaning no effect].
                                             Missing values should be NAs.</span>')
            label_txtfile_Survival['height.request'] <- 110
            #####
            # Buttons and their functions
            #####
            SaveCloseButtonSurvival_help <- gtkButton('Save survival effects & continue')
            # save and go to next attribute
            SaveCloseSurvival_help <- function(button){
              df<-obj$getModel()
              test<-data.frame(df)
              # calculate expected column number
              col_exp <- as.numeric(get("nb_data", IBCvariables))*2
              # delete everything greater than the expected column number
              test<-test[,c(2:(col_exp+1))]
              if (all(test==0)){
                # if there are only 0's
                dialog1 <- gtkMessageDialog(parent=winBiomass_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are values.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else if(any(test[test<0], na.rm = TRUE)){
                # if there are negative values..
                dialog1 <- gtkMessageDialog(parent=winSurvival_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are no negative effects.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else{
                # save effects
                write.table(df, "SurvivalEffects.txt", row.names=F, quote=F, sep="\t")
                test<-data.frame(df)
                # calculate expected column number
                col_exp <- as.numeric(get("nb_data", IBCvariables))*2
                # delete everything greater than the expected column number
                test<-test[,c(2:(col_exp+1))]
                assign("SurvivalEffFile", test, IBCvariables)
                winSurvival_help$destroy()
                # go to next attribute
                EstablishmentEffect()
              }
            } # end save and close go biomass entry window
            
            ReturnButtonSurvival <- gtkButton('Back')
            ReturnButtonSurvival$setTooltipText('Go back to previous step.')
            # return to herbicide settings
            ClickOnReturnSurvival <- function(button){
              # close windows
              HerbicideWindow$destroy()
              winSurvival_help$destroy()
              # call herbicide settings
              HerbicideSettings()
            }
            
            gSignalConnect(SaveCloseButtonSurvival_help, "clicked", SaveCloseSurvival_help)
            gSignalConnect(ReturnButtonSurvival, "clicked", ClickOnReturnSurvival)
            #####
            # put it together
            #####
            vboxSurvival_help <- gtkVBoxNew()
            vboxSurvival_help$setBorderWidth(10)
            vboxSurvival_help$packStart(label_txtfile_Survival)
            vboxSurvival_help$packStart(obj)
            vboxSurvival_help$packStart(SaveCloseButtonSurvival_help,fill=F)
            vboxSurvival_help$packStart(ReturnButtonSurvival, fill=F)
            winSurvival_help <- gtkWindowNew(show=F)
            winSurvival_help$setPosition('GTK_WIN_POS_CENTER')
            winSurvival_help["title"] <- "IBC-grass GUI"
            winSurvival_help$ModifyBg("normal", color)
            winSurvival_help$add(vboxSurvival_help)
            winSurvival_help$show()
          } # end if seedling biomass affected
          else EstablishmentEffect()
        }
        #####
        # Establishment
        #####
        EstablishmentEffect <- function(){
          # if establishment was selected
          if (EstablishmentCheck$getActive()){
            #####
            # create the dataframe
            #####
            # if no data can be loaded
            if (is.null(get("EstablishmentEffFile", envir=IBCvariables))){
              column_name <- c()
              nb_data <- as.numeric(get("nb_data", envir = IBCvariables))
              for (i in 1:nb_data){
                column_name_help <- c(paste('ApplicationRate_Spec',i,sep=""), paste('Effect_Spec',i, sep=""))
                column_name <- c(column_name, column_name_help)
                # df <- cbind(df, c(rep(0.0,10)))
              }
              col <- c(rep(0.0, 3))
              df <- as.data.frame(rep.col(col, length(column_name)))
              colnames(df)<-column_name
            } else{
              # otherwise load the data
              df <- get("EstablishmentEffFile", envir=IBCvariables)
            }
            # data frame object
            obj <- gtkDfEdit(df)
            #####
            # What to do
            #####
            label_txtfile_Establishment<-gtkLabel()
            label_txtfile_Establishment$setMarkup('
                                                  <span weight=\"bold\" size=\"large\">Establishment effects</span>
                                                  <span size=\"large\"> Please insert the tested herbicide application rates and the measured effect data
                                                  on seed establishment for each of the tested species.
                                                  The effect data should give the relation to control [0-1, 1 meaning no effect].
                                                  Missing values should be NAs.</span>')
            label_txtfile_Establishment['height.request'] <- 110
            #####
            # Buttons and their functions
            #####
            SaveCloseButtonEstablishment_help <- gtkButton('Save establishment effects & continue')
            # save effects and continue
            SaveCloseEstablishment_help <- function(button){
              df<-obj$getModel()
              test<-data.frame(df)
              # calculate expected column number
              col_exp <- as.numeric(get("nb_data", IBCvariables))*2
              # delete everything greater than the expected column number
              test<-test[,c(2:(col_exp+1))]
              if (all(test==0)){
                # if there are only 0's
                dialog1 <- gtkMessageDialog(parent=winBiomass_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are values.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else if(any(test[test<0], na.rm = TRUE)){
                # if there are negative values..
                dialog1 <- gtkMessageDialog(parent=winEstablishment_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are no negative effects.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else{
                # save data
                write.table(df, "EstablishmentEffects.txt", row.names=F, quote=F, sep="\t")
                test<-data.frame(df)
                # calculate expected column number
                col_exp <- as.numeric(get("nb_data", IBCvariables))*2
                # delete everything greater than the expected column number
                test<-test[,c(2:(col_exp+1))]
                assign("EstablishmentEffFile", test, IBCvariables)
                winEstablishment_help$destroy()
                # go to next attribute
                SeedSterilityEffect()
              }
            } # end save and close go biomass entry window
            ReturnButtonEstablishment <- gtkButton('Back')
            ReturnButtonEstablishment$setTooltipText('Go back to previous step.')
            # return to herbicide settings
            ClickOnReturnEstablishment <- function(button){
              #close windows
              HerbicideWindow$destroy()
              winEstablishment_help$destroy()
              # call herbicide settings
              HerbicideSettings()
            }
            gSignalConnect(SaveCloseButtonEstablishment_help, "clicked", SaveCloseEstablishment_help)
            gSignalConnect(ReturnButtonEstablishment,"clicked", ClickOnReturnEstablishment)
            #####
            # put it together
            #####
            vboxEstablishment_help<- gtkVBoxNew()
            vboxEstablishment_help$setBorderWidth(10)
            vboxEstablishment_help$packStart(label_txtfile_Establishment)
            vboxEstablishment_help$packStart(obj)
            vboxEstablishment_help$packStart(SaveCloseButtonEstablishment_help,fill=F)
            vboxEstablishment_help$packStart(ReturnButtonEstablishment, fill=F)
            
            winEstablishment_help <- gtkWindowNew(show=F)
            winEstablishment_help$setPosition('GTK_WIN_POS_CENTER')
            winEstablishment_help["title"] <- "IBC-grass GUI"
            winEstablishment_help$ModifyBg("normal", color)
            winEstablishment_help$add(vboxEstablishment_help)
            winEstablishment_help$show()
          } # end if seedling biomass affected
          else SeedSterilityEffect()
        }
        #####
        # Seed Sterility
        #####
        SeedSterilityEffect <- function(){
          # if seed sterility was selected
          if (SeedSterilityCheck$getActive()){
            #####
            # create the dataframe
            #####
            # if no data can be loaded
            if (is.null(get("SeedSterilityEffFile", envir=IBCvariables))){
              column_name <- c()
              nb_data <- as.numeric(get("nb_data", envir = IBCvariables))
              for (i in 1:nb_data){
                column_name_help <- c(paste('ApplicationRate_Spec',i,sep=""), paste('Effect_Spec',i, sep=""))
                column_name <- c(column_name, column_name_help)
                # df <- cbind(df, c(rep(0.0,10)))
              }
              col <- c(rep(0.0, 3))
              df <- as.data.frame(rep.col(col, length(column_name)))
              colnames(df)<-column_name
            } else{
              # load data
              df <- get("SeedSterilityEffFile", envir=IBCvariables)
            }
            # data frame object
            obj <- gtkDfEdit(df)
            #####
            # What to do
            #####
            label_txtfile_SeedSterility<-gtkLabel()
            label_txtfile_SeedSterility$setMarkup('
                                                  <span weight=\"bold\" size=\"large\">Seed sterility effects</span>
                                                  <span size=\"large\"> Please insert the tested herbicide application rates and the measured effect data
                                                  on seed sterility (i.e. seeds are not germinating) for each of the tested species.
                                                  The effect data should give the relation to control [0-1, 1 meaning no effect].
                                                  Missing values should be NAs.</span>')
            label_txtfile_SeedSterility['height.request'] <- 110
            #####
            # Buttons and their functions
            #####
            SaveCloseButtonSeedSterility_help <- gtkButton('Save seed sterility effects & continue')
            # save effects and continue
            SaveCloseSeedSterility_help <- function(button){
              df<-obj$getModel()
              test<-data.frame(df)
              # calculate expected column number
              col_exp <- as.numeric(get("nb_data", IBCvariables))*2
              # delete everything greater than the expected column number
              test<-test[,c(2:(col_exp+1))]
              if (all(test==0)){
                # if there are only 0's
                dialog1 <- gtkMessageDialog(parent=winBiomass_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are values.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else if(any(test[test<0], na.rm = TRUE)){
                # if there are negative values..
                dialog1 <- gtkMessageDialog(parent=winSeedSterility_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are no negative effects.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else{
                # save data
                write.table(df, "SeedSterilityEffects.txt", row.names=F, quote=F, sep="\t")
                test<-data.frame(df)
                # calculate expected column number
                col_exp <- as.numeric(get("nb_data", IBCvariables))*2
                # delete everything greater than the expected column number
                test<-test[,c(2:(col_exp+1))]
                assign("SeedSterilityEffFile", test, IBCvariables)
                winSeedSterility_help$destroy()
                # call seed number effects
                SeedNumberEffect()
              }
            } # end save and close go biomass entry window
            ReturnButtonSeedSterility <- gtkButton('Back')
            ReturnButtonSeedSterility$setTooltipText('Go back to previous step.')
            # return to herbicide settings
            ClickOnReturnSeedSterility <- function(button){
              # close windows
              HerbicideWindow$destroy()
              winSeedSterility_help$destroy()
              # call herbicide settings
              HerbicideSettings()
            }
            
            gSignalConnect(SaveCloseButtonSeedSterility_help, "clicked", SaveCloseSeedSterility_help)
            gSignalConnect(ReturnButtonSeedSterility, "clicked", ClickOnReturnSeedSterility)
            #####
            # put it together
            #####
            vboxSeedSterility_help<- gtkVBoxNew()
            vboxSeedSterility_help$setBorderWidth(10)
            vboxSeedSterility_help$packStart(label_txtfile_SeedSterility)
            vboxSeedSterility_help$packStart(obj)
            vboxSeedSterility_help$packStart(SaveCloseButtonSeedSterility_help,fill=F)
            vboxSeedSterility_help$packStart(ReturnButtonSeedSterility)
            
            winSeedSterility_help <- gtkWindowNew(show=F)
            winSeedSterility_help$setPosition('GTK_WIN_POS_CENTER')
            winSeedSterility_help["title"] <- "IBC-grass GUI"
            winSeedSterility_help$ModifyBg("normal", color)
            winSeedSterility_help$add(vboxSeedSterility_help)
            winSeedSterility_help$show()
          } # end if seedling biomass affected
          else SeedNumberEffect()
        }
        #####
        # Seed Number
        #####
        SeedNumberEffect <- function(){
          # if seed number was selected
          if (SeedNumberCheck$getActive()){
            #####
            # create the dataframe
            #####
            # if no data can be loaded
            if (is.null(get("SeedNumberEffFile", envir=IBCvariables))){
              column_name <- c()
              nb_data <- as.numeric(get("nb_data", envir = IBCvariables))
              for (i in 1:nb_data){
                column_name_help <- c(paste('ApplicationRate_Spec',i,sep=""), paste('Effect_Spec',i, sep=""))
                column_name <- c(column_name, column_name_help)
              }
              col <- c(rep(0.0, 3))
              df <- as.data.frame(rep.col(col, length(column_name)))
              colnames(df)<-column_name
            } else{
              # load previous data
              df <- get("SeedNumberEffFile", envir=IBCvariables)
            }
            # data frame object
            obj <- gtkDfEdit(df)
            #####
            # What to do
            #####
            label_txtfile_SeedNumber<-gtkLabel()
            label_txtfile_SeedNumber$setMarkup('
                                               <span weight=\"bold\" size=\"large\">Seed number effects</span>
                                               <span size=\"large\">Please insert the tested herbicide application rates and the measured effect data
                                               on seed number for each of the tested species.
                                               The effect data should give the relation to control [0-1, 1 meaning no effect].
                                               Missing values should be NAs.</span>')
            label_txtfile_SeedNumber['height.request'] <- 110
            #####
            # Buttons and their functions
            #####
            SaveCloseButtonSeedNumber_help <- gtkButton('Save seed number effects & continue')
            # save and continue
            SaveCloseSeedNumber_help <- function(button){
              df<-obj$getModel()
              test<-data.frame(df)
              # calculate expected column number
              col_exp <- as.numeric(get("nb_data", IBCvariables))*2
              # delete everything greater than the expected column number
              test<-test[,c(2:(col_exp+1))]
              if (all(test==0)){
                # if there are only 0's
                dialog1 <- gtkMessageDialog(parent=winBiomass_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are values.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else if(any(test[test<0], na.rm = TRUE)){
                # if there are negative values..
                dialog1 <- gtkMessageDialog(parent=winSeedNumber_help,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "Please make sure, that there are no negative effects.")
                color <-gdkColorToString('white')
                dialog1$ModifyBg("normal", color)
                gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
              } else{
                # save data
                write.table(df, "SeedNumberEffects.txt", row.names=F, quote=F, sep="\t")
                test<-data.frame(df)
                # calculate expected column number
                col_exp <- as.numeric(get("nb_data", IBCvariables))*2
                # delete everything greater than the expected column number
                test<-test[,c(2:(col_exp+1))]
                assign("SeedNumberEffFile", test, IBCvariables)
                # close window
                winSeedNumber_help$destroy()
                # call calculate dose responses
                CalculateDR()
                # close window
                HerbicideWindow$destroy()
                # call sensitivity settings
                SensitivityDR()
              }
            } # end save and close go biomass entry window
            ReturnButtonSeedNumber <- gtkButton('Back')
            ReturnButtonSeedNumber$setTooltipText('Go back to previous step.')
            # return to herbicide settings
            ClickOnReturnSeedNumber <- function(button){
              # close windows
              HerbicideWindow$destroy()
              winSeedNumber_help$destroy()
              # call herbicide settings
              HerbicideSettings()
            }
            
            gSignalConnect(SaveCloseButtonSeedNumber_help, "clicked", SaveCloseSeedNumber_help)
            gSignalConnect(ReturnButtonSeedNumber, "clicked", ClickOnReturnSeedNumber)
            #####
            # put it together
            #####
            vboxSeedNumber_help <- gtkVBoxNew()
            vboxSeedNumber_help$setBorderWidth(10)
            vboxSeedNumber_help$packStart(label_txtfile_SeedNumber)
            vboxSeedNumber_help$packStart(obj)
            vboxSeedNumber_help$packStart(SaveCloseButtonSeedNumber_help,fill=F)
            vboxSeedNumber_help$packStart(ReturnButtonSeedNumber, fill=F)
            
            winSeedNumber_help <- gtkWindowNew(show=F)
            winSeedNumber_help$setPosition('GTK_WIN_POS_CENTER')
            winSeedNumber_help["title"] <- "IBC-grass GUI"
            winSeedNumber_help$ModifyBg("normal", color)
            winSeedNumber_help$add(vboxSeedNumber_help)
            winSeedNumber_help$show()
          } else {# end if seed number affected
            # close window
            HerbicideWindow$destroy()
            # calculate dose responses
            CalculateDR()
            # call sensitivities
            SensitivityDR()
          }
        }
        #####
        # How many test species?
        #####
        label_nb_doseresponses <- gtkLabel()
        label_nb_doseresponses$setMarkup('<span weight=\"bold\"size=\"large\">How many species were tested?</span>')
        label_nb_doseresponses['height.request'] <- 20
        entry_nb_doseresponses <- gtkEntryNew()
        entry_nb_doseresponses$setText(get("nb_data", envir=IBCvariables))
        #####
        # Buttons
        #####
        GoButton <- gtkButton('Go')
        ReturnButton <- gtkButton('Back')
        ReturnButton$setTooltipText('Go back to the previous step.')
        # go back to herbicide settings
        ClickOnReturn <- function(button){
          # close windows
          win$destroy()
          HerbicideWindow$destroy()
          # call herbicide settings
          HerbicideSettings()
        }
        
        gSignalConnect(GoButton, "clicked", BiomassEffect)
        gSignalConnect(ReturnButton, "clicked", ClickOnReturn)
        #####
        # put it together
        #####
        vbox <- gtkVBoxNew()
        vbox$setBorderWidth(10)
        vbox$packStart(label_nb_doseresponses)
        vbox$packStart(entry_nb_doseresponses)
        vbox$packStart(GoButton,fill=F)
        vbox$packStart(ReturnButton,fill=F)
        
        win <- gtkWindowNew(show=F)
        win$setPosition('GTK_WIN_POS_CENTER')
        win["title"] <- "IBC-grass GUI"
        color <-gdkColorToString('white')
        win$ModifyBg("normal", color)
        win$add(vbox)
        win$show()
      }
    }
  }
  # return to environmental settings
  ClickOnReturn <- function(button){
    # close window
    HerbicideWindow$destroy()
    if (get("IBCcommunity", envir=IBCvariables)=="Community.txt"){
      # call environmental settings
      setEnvironmentaParametersforNewCommunity()
    } else {
      # call environmental settings
      RunPreSet()
    }
  }
  #####
  # Buttons
  #####  
  ReturnButton <- gtkButton('Back')
  ContinueButton <- gtkButton('Continue')
  
  vbox5$packStart(ContinueButton,fill=F)
  vbox5$packStart(ReturnButton,fill=F)
    
  gSignalConnect(ReturnButton, "clicked", ClickOnReturn)
  gSignalConnect(ContinueButton, "clicked", ClickOnContinue)
  
  ##################################################
  ### put it together
  ##################################################
  # create a new window
  HerbicideWindow <- gtkWindow(show=F)
  HerbicideWindow$setPosition('GTK_WIN_POS_CENTER')
  HerbicideWindow["title"] <- "IBC-grass GUI"
  color <-gdkColorToString('white')
  HerbicideWindow$ModifyBg("normal", color)
  
  vbox <- gtkVBoxNew()
  vbox$packStart(vbox1)
  vbox$packStart(vbox2)
  vbox$packStart(vbox3)
  vbox$packStart(vbox4)
  vbox$packStart(vbox5)
  
  event <- gtkEventBox()
  color <-gdkColorToString('white')
  event$ModifyBg("normal", color)
  event$setBorderWidth(10)
  event$add(vbox)
  HerbicideWindow$add(event)
  HerbicideWindow$show()
}

