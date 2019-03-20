###############################################################################
# Function for calculating dose response curves according to                  #
# effect = App_rate^b/(EC50^b+App_rate^b)                                     # 
###############################################################################
CalculateDR<- function(){
  ##################################################
  ### title
  ##################################################
  label_title <- gtkLabel()
  label_title$setMarkup('<span weight=\"bold\">   Please wait while dose responses are calculated.</span>')
  ##################################################
  ### spinner
  ##################################################
  please_wait <- gtkSpinnerNew()
  please_wait['width.request'] <- 20
  ##################################################
  ### put it together
  ##################################################
  hbox <- gtkHBoxNew()
  hbox$setBorderWidth(20)
  hbox$packStart(please_wait)
  hbox$packStart(label_title)
  
  w <- gtkWindow(show=F)
  w$setPosition('GTK_WIN_POS_CENTER')
  w["title"] <- "IBC-grass 2.0"
  color <-gdkColorToString('white')
  w$ModifyBg("normal", color)
  w$add(hbox)
  w$show()
  ##################################################
  ### start spinner
  ##################################################
  gtkSpinnerStart(please_wait)
  ##################################################
  ### Apprate function
  ##################################################
  App_rate_function <-function(x){
    EC50 = x[1]
    b = x[2]

    Eff_help <- Eff[Eff$Species==Spec,]
    Eff_help <- Eff_help[complete.cases(Eff_help),]
    Eff_control <- Eff_help[Eff_help$AppRate==0,-1]
    colnames(Eff_control) <- c("control", "Species") 
    # calculate relative values
    Eff_help <- merge(Eff_help, Eff_control, all=T)
    Eff_help$Effect <- Eff_help$Effect/Eff_help$control
    Eff_help <- Eff_help[,c(2,3,1)]
    
    App_rate = Eff_help[duplicated(Eff_help$AppRate)==FALSE,1]
    App_rate = App_rate[complete.cases(App_rate)]
    Effect_Array = matrix(data = 0, ncol = 2, nrow = length(App_rate))
    count = 0
    
    # for all tested application rates
    for(App_rate in App_rate){
      count = sum(count,1)
      effect = App_rate^b/(EC50^b+App_rate^b) #This is the effect function
      Effect_Array[count,1] = effect
      Effect_Array[count,2] = App_rate
    }  
    
    App_rate = Eff_help[duplicated(Eff_help$AppRate)==FALSE,1]
    App_rate = App_rate[complete.cases(App_rate)]
    
    Results_array = matrix(data = 0, ncol = 3, nrow = nrow(Eff_help))
    Results_array[,1] = Eff_help$AppRate
    Results_array[,2] = Eff_help$Effect
    Results_array[,2] = Results_array[,2]*-1+1 #transformation 
    Results_array[,2][Results_array[,2]<0] = 0 #for the fit all values < 0 are ignored as they describe growth promotion
    
    count2 = 0
    for(App_rate in App_rate){
      count2 = sum(count2,1)
      Results_array[,3][which(Results_array[,1]==App_rate)] = rep(Effect_Array[count2,1],length(which(Results_array[,1]==App_rate)))
    }
    
    # return the sum of squared differences
    SQ_diff = sum((Results_array[,2]-Results_array[,3])^2)
    return(SQ_diff)
  }
  ##################################################
  ### Biomass dose response
  ##################################################
  if (!is.null(get("BiomassEffFile", IBCvariables))){
    # if a file with effects on biomass exists
      # calculate dose response
      Eff <- get("BiomassEffFile", IBCvariables)
      select_AppRate_columns <- Eff[,seq(1,ncol(Eff),2)]
      AppRate<-stack(select_AppRate_columns)[,1]
      select_Effect_columns <- Eff[,seq(2,ncol(Eff),2)]
      col.names <- c()
      for(i in 1:ncol(select_Effect_columns)){
        col.names <- c(col.names, paste("Spec", i, sep=""))
      }
      colnames(select_Effect_columns)<-col.names
      Effect<-stack(select_Effect_columns)
      colnames(Effect) <-c("Effect", "Species")
      Eff <- cbind(AppRate,Effect)
      Specs <- levels(Eff$Species)
      # calculate dose responses for all PFTs and save values
      output <- data.frame()
      for (file in Specs){
        Spec<-file
        x <- c(2,2) #inital values
        xmin <- tryCatch(optim(par = x, fn = App_rate_function),
                 warnings = function(w) {print("no dose response can be calculated")}, 
                 error = function(e) {
                   dialog1 <- gtkMessageDialog(parent=w,
                              flags = "destroy-with-parent",
                              type="warning" ,
                              buttons="ok" ,
                              "No dose responses for the attribute shoot mass could be calculated. Please review your data.")
                   gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy(); w$destroy(); HerbicideSettings();})
                   })
        # not accounting for the error..
          error_b <- 0
          error_EC50 <- 0
        # optimized parameter values
        b<-xmin$par[2]
        EC50<-xmin$par[1]
        output <- rbind(output, cbind(Spec, EC50, error_EC50, b, error_b))
      }
  
      output$EC50<-as.numeric(levels(output$EC50))[output$EC50]
      output$error_EC50<-as.numeric(levels(output$error_EC50))[output$error_EC50]
      output$b<-as.numeric(levels(output$b))[output$b]
      output$error_b<-as.numeric(levels(output$error_b))[output$error_b]
  
      #calculate mean EC50 and slope value
      average<-cbind(Spec="mean",EC50=mean(output[,2]), b=mean(output[,4]))
      stdv<-cbind(Spec="sd",EC50=sd(output[,2]), b=sd(output[,4]))
  
      output_wrap<-data.frame(output[,-c(3,5)])
      output_wrap <- rbind(output_wrap, average)
      output_wrap<-data.frame(rbind(output_wrap, stdv))
      # save dose response for biomass
      write.table(output_wrap, "EC50andslope_Biomass.txt", sep = "\t")
    }# End if exists
  rm(Eff)
  ##################################################
  ### Seedling biomass dose response
  ##################################################
  if (!is.null(get("SeedlingBiomassEffFile", IBCvariables))){
    # if effect data for seedling biomass exists
    # calculate the dose response
    Eff <- get("SeedlingBiomassEffFile", IBCvariables)
    select_AppRate_columns <- Eff[,seq(1,ncol(Eff),2)]
    AppRate<-stack(select_AppRate_columns)[,1]
    select_Effect_columns <- Eff[,seq(2,ncol(Eff),2)]
    col.names <- c()
    for(i in 1:ncol(select_Effect_columns)){
      col.names <- c(col.names, paste("Spec", i, sep=""))
    }
    colnames(select_Effect_columns)<-col.names
    Effect<-stack(select_Effect_columns)
    colnames(Effect) <-c("Effect", "Species")
    Eff <- cbind(AppRate,Effect)

    Specs <- levels(Eff$Species)
    # calculate dose responses for all PFTs and save values
    output <- data.frame()
    for (file in Specs){
      Spec<-file
      x <- c(2,2) #inital values
      xmin <- tryCatch(optim(par = x, fn = App_rate_function),
                       warnings = function(w) {print("no dose response can be calculated")}, 
                       error = function(e) {
                         dialog1 <- gtkMessageDialog(parent=w,
                                                     flags = "destroy-with-parent",
                                                     type="warning" ,
                                                     buttons="ok" ,
                                                     "No dose responses for the attribute seedling shoot mass could be calculated. Please review your data.")
                         gSignalConnect (dialog1, "response", function(dialog1, response, user.data){  dialog1$Destroy(); w$destroy(); HerbicideSettings();})
                       })
      # not accounting for error..
      error_b <- 0
      error_EC50 <- 0
      # optimized parameters
      b<-xmin$par[2]
      EC50<-xmin$par[1]
      output <- rbind(output, cbind(Spec, EC50, error_EC50, b, error_b))
    }
    
    output$EC50<-as.numeric(levels(output$EC50))[output$EC50]
    output$error_EC50<-as.numeric(levels(output$error_EC50))[output$error_EC50]
    output$b<-as.numeric(levels(output$b))[output$b]
    output$error_b<-as.numeric(levels(output$error_b))[output$error_b]
    
    #calculate mean EC50 and slope value
    average<-cbind(Spec="mean",EC50=mean(output[,2]), b=mean(output[,4]))
    stdv<-cbind(Spec="sd",EC50=sd(output[,2]), b=sd(output[,4]))
    
    output_wrap<-data.frame(output[,-c(3,5)])
    output_wrap <- rbind(output_wrap, average)
    output_wrap<-data.frame(rbind(output_wrap, stdv))
    # save dose response
    write.table(output_wrap, "EC50andslope_SeedlingBiomass.txt", sep = "\t")
  }# End if exists
  rm(Eff)
  ##################################################
  ### Survival dose response
  ##################################################
  if (!is.null(get("SurvivalEffFile", IBCvariables))){
    # if effect data for survival exists
    # calculate the dose response
    Eff <- get("SurvivalEffFile", IBCvariables)
    select_AppRate_columns <- Eff[,seq(1,ncol(Eff),2)]
    AppRate<-stack(select_AppRate_columns)[,1]
    select_Effect_columns <- Eff[,seq(2,ncol(Eff),2)]
    col.names <- c()
    for(i in 1:ncol(select_Effect_columns)){
      col.names <- c(col.names, paste("Spec", i, sep=""))
    }
    colnames(select_Effect_columns)<-col.names
    Effect<-stack(select_Effect_columns)
    colnames(Effect) <-c("Effect", "Species")
    Eff <- cbind(AppRate,Effect)
    Specs <- levels(Eff$Species)
    # calculate dose responses for all PFTs and save values
    output <- data.frame()
    for (file in Specs){
      Spec<-file
      x <- c(2,2) #inital values
      xmin <- tryCatch(optim(par = x, fn = App_rate_function),
                       warnings = function(w) {print("no dose response can be calculated")}, 
                       error = function(e) {
                         dialog1 <- gtkMessageDialog(parent=w,
                                                     flags = "destroy-with-parent",
                                                     type="warning" ,
                                                     buttons="ok" ,
                                                     "No dose responses for the attribute survival could be calculated. Please review your data.")
                         gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy(); w$destroy();HerbicideSettings();})
                       })
      # not accounting for error...
      error_b <- 0
      error_EC50 <- 0
      # optimized parameters
      b<-xmin$par[2]
      EC50<-xmin$par[1]
      output <- rbind(output, cbind(Spec, EC50, error_EC50, b, error_b))
    }
    
    output$EC50<-as.numeric(levels(output$EC50))[output$EC50]
    output$error_EC50<-as.numeric(levels(output$error_EC50))[output$error_EC50]
    output$b<-as.numeric(levels(output$b))[output$b]
    output$error_b<-as.numeric(levels(output$error_b))[output$error_b]
    
    #calculate mean EC50 and slope value
    average<-cbind(Spec="mean",EC50=mean(output[,2]), b=mean(output[,4]))
    stdv<-cbind(Spec="sd",EC50=sd(output[,2]), b=sd(output[,4]))
    
    output_wrap<-data.frame(output[,-c(3,5)])
    output_wrap <- rbind(output_wrap, average)
    output_wrap<-data.frame(rbind(output_wrap, stdv))
    # save dose response
    write.table(output_wrap, "EC50andslope_Survival.txt", sep = "\t")
  }# End if exists
  rm(Eff)
  ##################################################
  ### Establishment dose response
  ##################################################
  # if effect data for establishment exists
  # calculate the dose response
  if (!is.null(get("EstablishmentEffFile", IBCvariables))){
    Eff <- get("EstablishmentEffFile", IBCvariables)
    select_AppRate_columns <- Eff[,seq(1,ncol(Eff),2)]
    AppRate<-stack(select_AppRate_columns)[,1]
    select_Effect_columns <- Eff[,seq(2,ncol(Eff),2)]
    col.names <- c()
    for(i in 1:ncol(select_Effect_columns)){
      col.names <- c(col.names, paste("Spec", i, sep=""))
    }
    colnames(select_Effect_columns)<-col.names
    Effect<-stack(select_Effect_columns)
    colnames(Effect) <-c("Effect", "Species")
    Eff <- cbind(AppRate,Effect)
    Specs <- levels(Eff$Species)
    # calculate dose responses for all PFTs and save values
    output <- data.frame()
    for (file in Specs){
      Spec<-file
      x <- c(2,2) #inital values
      xmin <- tryCatch(optim(par = x, fn = App_rate_function),
                       warnings = function(w) {print("no dose response can be calculated")}, 
                       error = function(e) {
                         dialog1 <- gtkMessageDialog(parent=w,
                                                     flags = "destroy-with-parent",
                                                     type="warning" ,
                                                     buttons="ok" ,
                                                     "No dose responses for the attribute establishment could be calculated. Please review your data.")
                         gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy(); w$destroy();HerbicideSettings();})
                       })
      # not accounting for error...
      error_b <- 0
      error_EC50 <- 0
      # optimized parameters
      b<-xmin$par[2]
      EC50<-xmin$par[1]
      output <- rbind(output, cbind(Spec, EC50, error_EC50, b, error_b))
    }
    
    output$EC50<-as.numeric(levels(output$EC50))[output$EC50]
    output$error_EC50<-as.numeric(levels(output$error_EC50))[output$error_EC50]
    output$b<-as.numeric(levels(output$b))[output$b]
    output$error_b<-as.numeric(levels(output$error_b))[output$error_b]
    
    #calculate mean EC50 and slope value
    average<-cbind(Spec="mean",EC50=mean(output[,2]), b=mean(output[,4]))
    stdv<-cbind(Spec="sd",EC50=sd(output[,2]), b=sd(output[,4]))
    
    output_wrap<-data.frame(output[,-c(3,5)])
    output_wrap <- rbind(output_wrap, average)
    output_wrap<-data.frame(rbind(output_wrap, stdv))
    # save dose response
    write.table(output_wrap, "EC50andslope_Establishment.txt", sep = "\t")
  }# End if exists
  rm(Eff)
  ##################################################
  ### Seed Sterility dose response
  ##################################################
  # if effect data for seed sterility exists
  # calculate the dose response
  if (!is.null(get("SeedSterilityEffFile", IBCvariables))){
    Eff <- get("SeedSterilityEffFile", IBCvariables)
    select_AppRate_columns <- Eff[,seq(1,ncol(Eff),2)]
    AppRate<-stack(select_AppRate_columns)[,1]
    select_Effect_columns <- Eff[,seq(2,ncol(Eff),2)]
    col.names <- c()
    for(i in 1:ncol(select_Effect_columns)){
      col.names <- c(col.names, paste("Spec", i, sep=""))
    }
    colnames(select_Effect_columns)<-col.names
    Effect<-stack(select_Effect_columns)
    colnames(Effect) <-c("Effect", "Species")
    Eff <- cbind(AppRate,Effect)
    Specs <- levels(Eff$Species)
    # calculate dose responses for all PFTs and save values
    output <- data.frame()
    for (file in Specs){
      Spec<-file
      x <- c(2,2) #inital values
      xmin <- tryCatch(optim(par = x, fn = App_rate_function),
                       warnings = function(w) {print("no dose response can be calculated")}, 
                       error = function(e) {
                         dialog1 <- gtkMessageDialog(parent=w,
                                                     flags = "destroy-with-parent",
                                                     type="warning" ,
                                                     buttons="ok" ,
                                                     "No dose responses for the attribute seed sterility could be calculated. Please review your data.")
                         gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy(); w$destroy();HerbicideSettings();})
                       })
      # not accounting for error...
      error_b <- 0
      error_EC50 <- 0
      # optimized parameters
      b<-xmin$par[2]
      EC50<-xmin$par[1]
      output <- rbind(output, cbind(Spec, EC50, error_EC50, b, error_b))
    }
    
    output$EC50<-as.numeric(levels(output$EC50))[output$EC50]
    output$error_EC50<-as.numeric(levels(output$error_EC50))[output$error_EC50]
    output$b<-as.numeric(levels(output$b))[output$b]
    output$error_b<-as.numeric(levels(output$error_b))[output$error_b]
    
    #calculate mean EC50 and slope value
    average<-cbind(Spec="mean",EC50=mean(output[,2]), b=mean(output[,4]))
    stdv<-cbind(Spec="sd",EC50=sd(output[,2]), b=sd(output[,4]))
    
    output_wrap<-data.frame(output[,-c(3,5)])
    output_wrap <- rbind(output_wrap, average)
    output_wrap<-data.frame(rbind(output_wrap, stdv))
    # save dose response
    write.table(output_wrap, "EC50andslope_SeedSterility.txt", sep = "\t")
  }# End if exists
  rm(Eff)
  ##################################################
  ### Seed number dose response
  ##################################################
  # if effect data for seed number exists
  # calculate the dose response
  if (!is.null(get("SeedNumberEffFile", IBCvariables))){
    Eff <- get("SeedNumberEffFile", IBCvariables)
    select_AppRate_columns <- Eff[,seq(1,ncol(Eff),2)]
    AppRate<-stack(select_AppRate_columns)[,1]
    select_Effect_columns <- Eff[,seq(2,ncol(Eff),2)]
    col.names <- c()
    for(i in 1:ncol(select_Effect_columns)){
      col.names <- c(col.names, paste("Spec", i, sep=""))
    }
    colnames(select_Effect_columns)<-col.names
    Effect<-stack(select_Effect_columns)
    colnames(Effect) <-c("Effect", "Species")
    Eff <- cbind(AppRate,Effect)
    Specs <- levels(Eff$Species)
    # calculate dose responses for all PFTs and save values
    output <- data.frame()
    for (file in Specs){
      Spec<-file
      x <- c(2,2) #inital values
      xmin <- tryCatch(optim(par = x, fn = App_rate_function),
                       warnings = function(w) {print("no dose response can be calculated")}, 
                       error = function(e) {
                         dialog1 <- gtkMessageDialog(parent=w,
                                                     flags = "destroy-with-parent",
                                                     type="warning" ,
                                                     buttons="ok" ,
                                                     "No dose responses for the attribute seed number could be calculated. Please review your data.")
                         gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy(); w$destroy();HerbicideSettings();})
                       })
      # not accounting for error...
      error_b <- 0
      error_EC50 <- 0
      # optimized parameters
      b<-xmin$par[2]
      EC50<-xmin$par[1]
      output <- rbind(output, cbind(Spec, EC50, error_EC50, b, error_b))
    }
    
    output$EC50<-as.numeric(levels(output$EC50))[output$EC50]
    output$error_EC50<-as.numeric(levels(output$error_EC50))[output$error_EC50]
    output$b<-as.numeric(levels(output$b))[output$b]
    output$error_b<-as.numeric(levels(output$error_b))[output$error_b]
    
    #calculate mean EC50 and slope value
    average<-cbind(Spec="mean",EC50=mean(output[,2]), b=mean(output[,4]))
    stdv<-cbind(Spec="sd",EC50=sd(output[,2]), b=sd(output[,4]))
    
    output_wrap<-data.frame(output[,-c(3,5)])
    output_wrap <- rbind(output_wrap, average)
    output_wrap<-data.frame(rbind(output_wrap, stdv))
    # save dose response
    write.table(output_wrap, "EC50andslope_SeedNumber.txt", sep = "\t")
  }# End if exists
  rm(Eff)
  ##################################################
  ### example dose resonse to present as a graphic
  ##################################################
    samplesize <- 100
    #####
    # read the first file that exists
    #####
    DR<-"EC50andslope_Biomass.txt"
    if (DR %in% list.files())  {
      output_wrap<-read.table(DR, header=T, sep="\t")
      } else {
          DR<-"EC50andslope_Survival.txt"
          if (DR %in% list.files()){
            output_wrap<-read.table(DR, header=T, sep="\t")
          } else{
              DR<-"EC50andslope_Establishment.txt"
              if (DR %in% list.files()){
                output_wrap<-read.table(DR, header=T, sep="\t")
              } else{
                  DR<-"EC50andslope_SeedlingBiomass.txt"
                  if (DR %in% list.files()){
                    output_wrap<-read.table(DR, header=T, sep="\t")
                  } else{
                      DR<-"EC50andslope_SeedSterility.txt"
                      if (DR %in% list.files()){
                        output_wrap<-read.table(DR, header=T, sep="\t")
                      } else{
                          DR<-"EC50andslope_SeedNumber.txt"
                          if (DR %in% list.files()){
                            output_wrap<-read.table(DR, header=T, sep="\t")
                          } else{
                              dialog1 <- gtkMessageDialog(parent=w,
                                              flags = "destroy-with-parent",
                                              type="warning" ,
                                              buttons="ok" ,
                                              "No dose responses were calculated. Please go back to ensure your dose response data are correct.")
                              gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy();
                              w$destroy();HerbicideSettings();})
                                }
                            }
                        }
                    }
                }
      }
    #####
    # example dose responses based on mean
    #####
    EC50_runif<-runif(samplesize, min = (output_wrap[output_wrap$Spec=="mean",2]-output_wrap[output_wrap$Spec=="sd",2]), max = (output_wrap[output_wrap$Spec=="mean",2]+output_wrap[output_wrap$Spec=="sd",2]))
    b_runif<-runif(samplesize, min = (output_wrap[output_wrap$Spec=="mean",3]-output_wrap[output_wrap$Spec=="sd",3]), max = (output_wrap[output_wrap$Spec=="mean",3]+output_wrap[output_wrap$Spec=="sd",3]))
    #####
    # combine data sets
    #####
    Spec <- c(rep("sample",samplesize))
    samples<-cbind(Spec, EC50=EC50_runif, b=b_runif)
    # to exclude negative slopes
    samples<-samples[samples[,3]>0,]
    output_wrap <- output_wrap[output_wrap$Spec!="sd",]
    output_wrap <- rbind(output_wrap, samples)
    #####
    # calculate effect values and prepare for plotting
    #####
    Array_graph = data.frame()
    max_App_rate <- "BiomassEffects.txt"
    if (max_App_rate %in% list.files()){
      max_App_rate<-read.table(max_App_rate, header=T, sep="\t")[,2]
    } else {
        max_App_rate<-"SurvivalEffects.txt"
        if (max_App_rate %in% list.files()){
          max_App_rate<-read.table(max_App_rate, header=T, sep="\t")[,2]
        } else{
            max_App_rate<-"EstablishmentEffects.txt"
            if (max_App_rate %in% list.files()){
              max_App_rate<-read.table(max_App_rate, header=T, sep="\t")[,2]
            } else{
                max_App_rate<-"SeedlingBiomassEffects.txt"
                if (max_App_rate %in% list.files()){
                  max_App_rate<-read.table(max_App_rate, header=T, sep="\t")[,2]
                } else{
                    max_App_rate<-"SeedSterilityEffects.txt"
                    if (max_App_rate %in% list.files()){
                      max_App_rate<-read.table(max_App_rate, header=T, sep="\t")[,2]
                    } else{
                        max_App_rate<-"SeedNumberEffects.txt"
                        if (max_App_rate %in% list.files()){
                          max_App_rate<-read.table(max_App_rate, header=T, sep="\t")[,2]
                        } else{
                            dialog1 <- gtkMessageDialog(parent=w,
                                            flags = "destroy-with-parent",
                                            type="warning" ,
                                            buttons="ok" ,
                                            "No dose responses were calculated. Please go back to ensure your dose response data are correct.")
                            gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy();
                            w$destroy();HerbicideSettings();})
                              }
                          }
                      }
                  }
              }
          }
    max_App_rate <- max_App_rate[complete.cases(max_App_rate)]
    max_App_rate = max(max_App_rate[duplicated(max_App_rate)==FALSE])
    
    # graphical visualisation of all dose responses
    for (curves in 1:nrow(output_wrap))
    {
      count_g = 0
      b<-as.numeric(output_wrap[curves,3])
      EC50<-as.numeric(output_wrap[curves,2])
      for(App_rate in seq(0,max_App_rate,1)){
        count_g = sum(count_g,1)
        effect_graph = App_rate^b/(EC50^b+App_rate^b) # effect function with fitted value
        Array_graph[count_g,1] = App_rate
        Array_graph[count_g,curves+1] = effect_graph
      }
    }
  
    plotting <- Array_graph
    
    # tranform dataset for plotting
    plotting<-melt(plotting, id="V1")
    
    # stuff for plotting
    plotting$variable <- as.character(plotting$variable)
    # depending of the number of tested species: first rows are the test species
    nb_specs <- as.numeric(get("nb_data", envir = IBCvariables))
    for (i in 1:nb_specs){
      assign(paste("Spec_", i, sep=""),plotting[plotting$variable == paste("V",i+1, sep=""),])
      plotting[plotting$variable == paste("V",i+1, sep=""),2] <- paste("dose response of test species ", i, sep="")
    }
    # the following is the meanEC50
    mean_dr <- plotting[plotting$variable == paste("V",i+2, sep=""),]
    plotting[plotting$variable == paste("V",i+1, sep=""),2] <-"mean dose response"
    
    #####
    # plot
    #####
    g <- ggplot()+
      theme_tufte(base_family = "sans")+
      # sample dose responses
      geom_line(data=plotting, aes(x = V1, y = as.numeric(value)*100, group=factor(variable), color="random samples"), size=0.05)+
      geom_line(data= mean_dr , aes(x = V1, y = as.numeric(value)*100, color="mean dose response"),size=0.4) +
      xlab("Application rate") +
      ylab("Effect [%]") +
      ggtitle("")
    for ( i in 1:nb_specs){
      df<-eval(parse(text=paste("Spec_",i,sep="")))
      x_val <- df$V1
      y_val <- as.numeric(df$value)*100
      color_val <- paste("Spec_",i,sep="")
      g <- g+geom_line(aes_string(x = x_val, y = y_val, color=as.factor(color_val)), size=0.4)
    }
    
    g <-  g +
      theme(text = element_text(size=4), axis.ticks = element_line(size=0.1) ,legend.position = "bottom", legend.direction = "horizontal",
            legend.title = element_blank(), 
            legend.key.size = unit (0.1, "cm")) +
      theme(axis.line = element_line(color = 'black', size=0.1))
    
    ggsave("Example_doseresponse.png",height=2, width=2, g)
  ##################################################
  ### start spinner
  ##################################################
  gtkSpinnerStop(please_wait)
  w$destroy()
}