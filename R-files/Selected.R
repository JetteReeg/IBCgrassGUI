################################################################################
#                                                                              #
# This function will run simulations on preset communities.                    #
# The communities are based on the publications Reeg et al. 2017, 2018a, 2018b #
#                                                                              #
################################################################################
RunPreSet <- function(){
  # delete old files of previous simulations
  if (length(list.files("currentSimulation/"))>0){
    setwd('currentSimulation')
    unlink(list.files(getwd()), recursive=TRUE)
    setwd('..')
  }
  ##################################################
  ### Title
  ##################################################
  vbox1 <- gtkVBoxNew()
  vbox1$setBorderWidth(10)
  label_title <- gtkLabel()
  label_title$setMarkup('<span weight=\"bold\" size=\"x-large\">Run simulation on given communities</span>')
  vbox1$packStart(label_title)
  
  ##################################################
  ### Communities
  ##################################################
  vbox2 <- gtkVBoxNew()
  vbox2$setBorderWidth(5)
  label_communities<-gtkLabel()
  label_communities$setMarkup('<span underline=\"single\"size=\"large\">Please select one of the given communities</span>')
  label_communities['height.request'] <- 20
  vbox2$packStart(label_communities)
  
  communities <- c("Field boundary" , "Calthion" , "Arrhenatherethalia")
  radio_buttons <- NULL
  for (community in communities){
    button <- gtkRadioButton(radio_buttons, community)
    if (community == communities[1]) button$setTooltipText("Representing a field boundary community with high nutrient input and medium disturbances.")
    if (community == communities[2]) button$setTooltipText("Representing a meadow with medium nutrient input and only few disturbances.")
    if (community == communities[3]) button$setTooltipText("Representing a grassland community with high nutrient input and high disturbances by trampling.")

    vbox2$packStart(button)
    radio_buttons<- c(radio_buttons, button)
  }
  
  if(get("IBCcommunity", envir = IBCvariables)=="Fieldedge.txt") {vbox2[[2]]$setActive(T)}
  if(get("IBCcommunity", envir = IBCvariables)=="Calthion.txt") {vbox2[[3]]$setActive(T)}
  if(get("IBCcommunity", envir = IBCvariables)=="Arrhenatheretalia.txt") {vbox2[[4]]$setActive(T)}
  
  ##################################################
  ### presetting button
  ##################################################
  hbox <- gtkHBoxNew()
  hbox$setBorderWidth(5)
  
  label_settings <- gtkLabel()
  label_settings$setMarkup('<span weight=\"bold\"size=\"large\">Environmental settings</span>')
  
  PresettingsButton <- gtkButton('presettings')
  PresettingsButton$setTooltipText("Suggests suitable environmental parameters for the selected community.")

  ClickOnButtonPresettings <- function(button){
    # field boundary
    if(vbox2[[2]]$getActive()==T) {
      ResourceSliderBelow$setValue(90)
      ResourceSliderAbove$setValue(100)
      GrazingSlider$setValue(1)
      TramplingSlider$setValue(10)
      vbox4[[7]]$setActive(T)
    }
    
    if(vbox2[[3]]$getActive()==T) {
      ResourceSliderBelow$setValue(60)
      ResourceSliderAbove$setValue(100)
      GrazingSlider$setValue(10)
      TramplingSlider$setValue(10)
      vbox4[[8]]$setActive(T)
    }
    if(vbox2[[4]]$getActive()==T) {
      ResourceSliderBelow$setValue(90)
      ResourceSliderAbove$setValue(100)
      GrazingSlider$setValue(10)
      TramplingSlider$setValue(10)
      vbox4[[9]]$setActive(T)
    }
    
  }
  
  hbox$packStart(label_settings)
  hbox$packStart(PresettingsButton)
  
  gSignalConnect(PresettingsButton, "clicked", ClickOnButtonPresettings)

  ##################################################
  ### settings resources
  ##################################################
  # normal resource settings
  # label
  vbox3 <- gtkVBoxNew()
  vbox3$setBorderWidth(5)
  label_resources<-gtkLabel()
  label_resources$setMarkup('<span underline=\"single\"size=\"large\">Resource settings</span>')
  label_resources['height.request'] <- 20
  vbox3$packStart(label_resources)
  
  # belowground resources
  label_below<-gtkLabel('Belowground resource level')
  label_below$setTooltipText("Belowground resources may vary from nutrient poor [40] to rich [100].")
  
  ResourceSliderBelow <- gtkHScale(min = 40, max = 100, step = 5)
  ResourceSliderBelow$setTooltipText("Belowground resources may vary from nutrient poor [40] to rich [100].")
  ResourceSliderBelow$setValue(get("IBCbelres", envir=IBCvariables))

  vbox3$packStart(label_below)
  vbox3$packStart(ResourceSliderBelow)
  
  #aboveground resources
  hbox1 <- gtkHBoxNew()
  vbox3.1 <- gtkVBoxNew()
  
  label_above<-gtkLabel('Aboveground resource level')
  label_above$setTooltipText("Aboveground resources may vary from shaded [40] to sunny [100].")
  
  ResourceSliderAbove <- gtkHScale(min = 40, max = 100, step = 5)
  ResourceSliderAbove$setTooltipText("Aboveground resources may vary from shaded [40] to sunny [100].")
  ResourceSliderAbove$setValue(get("IBCabres", envir=IBCvariables))
  
  vbox3.1$packStart(label_above)
  vbox3.1$packStart(ResourceSliderAbove)
  
  # box amplitude for aboveground seasonal variation of resources
  vbox3.2 <- gtkVBoxNew()
  label_aboveampl<-gtkLabel('Amplitude for aboveground seasonality')
  label_aboveampl$setTooltipText("Amplitude for aboveground resource distribution over 1 growing season")
  AboveAmplitudeSlider <- gtkHScaleNewWithRange(min = 0, max = 0.9, step = 0.1)
  AboveAmplitudeSlider$setValue(get("IBCabampl", envir=IBCvariables))
  
  vbox3.2$packStart(label_aboveampl)
  vbox3.2$packStart(AboveAmplitudeSlider)
  
  hbox1$packStart(vbox3.1, padding = 5)
  hbox1$packStart(vbox3.2, padding = 5)
  
  vbox3$packStart(hbox1, padding = 5)
  
  ##################################################
  ### settings disturbances
  ##################################################
  vbox4 <- gtkVBoxNew()
  vbox4$setBorderWidth(5)
  
  label_disturbances<-gtkLabel()
  label_disturbances$setMarkup('<span underline=\"single\"size=\"large\">Disturbance settings</span>')
  label_disturbances['height.request'] <- 20
  vbox4$packStart(label_disturbances)
  
  
  # slider for trampling
  label_tramp<-gtkLabel('Trampling [% area trampled]')
  label_tramp$setTooltipText("Trampling causes the destruction of aboveground shootmass.")
  label_tramp['height.request'] <- 20
  vbox4$packStart(label_tramp)
  TramplingSlider <- gtkHScale(min = 0, max = 50, step = 0.1)
  TramplingSlider$setTooltipText("Trampling causes the destruction of aboveground shootmass.")
  TramplingSlider$setValue(get("IBCtramp", envir=IBCvariables)*100)
  vbox4$packStart(TramplingSlider)
  
  # slider for grazing
  label_graz<-gtkLabel('Grazing [% area grazed]')
  label_graz$setTooltipText("During the grazing process, parts of the aboveground shoot mass is removed. The proportion of grazed shoot mass is PFT specific.")
  label_graz['height.request'] <- 20
  vbox4$packStart(label_graz)
  GrazingSlider <- gtkHScale(min = 0, max = 50, step = 0.1)
  GrazingSlider$setTooltipText("During the grazing process, parts of the aboveground shoot mass is removed. The proportion of grazed shoot mass is PFT specific.")
  GrazingSlider$setValue(get("IBCgraz", envir=IBCvariables)*100)
  vbox4$packStart(GrazingSlider)
  
  # radio button selection of the cutting events
  label_cuts<-gtkLabel('Cutting events')
  label_cuts$setTooltipText("During a cutting event, the aboveground shoot mass is removed to a certain level above the surface.")
  label_cuts['height.request'] <- 20
  vbox4$packStart(label_cuts)
  cuts <- c("In autumn" , " In spring and autumn" , " In spring, summer and autumn", "No cutting event")
  radio_buttons_cut <- NULL
  for (cuts in cuts){
    button_cuts <- gtkRadioButton(radio_buttons_cut, cuts)
    vbox4$packStart(button_cuts)
    radio_buttons_cut<- c(radio_buttons_cut, button_cuts)
  }
  
  if(get("IBCcut",envir = IBCvariables)== 1) {vbox4[[7]]$setActive(T)}
  if(get("IBCcut",envir = IBCvariables)== 2) {vbox4[[8]]$setActive(T)}
  if(get("IBCcut",envir = IBCvariables)== 3) {vbox4[[9]]$setActive(T)}
  if(get("IBCcut",envir = IBCvariables)== 0) {vbox4[[10]]$setActive(T)}
  ##################################################
  ### buttons
  ##################################################
  vbox5 <- gtkVBoxNew()
  vbox5$setBorderWidth(5)
  # go one step further..
  ContinueButton<-gtkButton('Continue')
  ContinueButton$setTooltipText("Go to the next step.")
  ClickOnButtonContinue <- function(button){
    # save IBC parameters
    if(vbox2[[2]]$getActive()==T) {
      assign("IBCcommunity", "Fieldedge.txt", envir = IBCvariables)
      community <- read.table("Input-files/Fieldedge.txt", sep="\t", header=T)
      assign("IBCcommunityFile", community, envir = IBCvariables)
    }
    
    if(vbox2[[3]]$getActive()==T) {
      assign("IBCcommunity", "Calthion.txt", envir = IBCvariables)
      community <- read.table("Input-files/Calthion.txt", sep="\t", header=T)
      assign("IBCcommunityFile", community, envir = IBCvariables)
    }
    if(vbox2[[4]]$getActive()==T) {
      assign("IBCcommunity", "Arrhenatheretalia.txt", envir = IBCvariables)
      community <- read.table("Input-files/Arrhenatheretalia.txt", sep="\t", header=T)
      assign("IBCcommunityFile", community, envir = IBCvariables)
    }
    assign("IBCbelres", ResourceSliderBelow$getValue(), envir = IBCvariables)
    assign("IBCabres", ResourceSliderAbove$getValue(), envir = IBCvariables)
    assign("IBCgraz", GrazingSlider$getValue()/100, envir = IBCvariables)
    assign("IBCtramp", TramplingSlider$getValue()/100, envir = IBCvariables)

    if(vbox4[[7]]$getActive()==T) {
      assign("IBCcut", 1, envir = IBCvariables)
    }
    
    if(vbox4[[8]]$getActive()==T) {
      assign("IBCcut", 2, envir = IBCvariables)
    }
    if(vbox4[[9]]$getActive()==T) {
      assign("IBCcut", 3, envir = IBCvariables)
    }
    if(vbox4[[10]]$getActive()==T) {
      assign("IBCcut", 0, envir = IBCvariables)
    }
    # go to the herbicide settings
    HerbicideSettings()
    # close the current window
    RunPreSetWindow$destroy()
  }
  
  # return to previous window
  ReturnButton <- gtkButton('Back')
  ReturnButton$setTooltipText("Go back to the previous window.")
  ClickOnReturn <- function(button){
    # close current window
    RunPreSetWindow$destroy()
    # open previous window
    Selection()
    
  }
  
  vbox5$packStart(ContinueButton)
  vbox5$packStart(ReturnButton,fill=F)
  
  gSignalConnect(ContinueButton, "clicked", ClickOnButtonContinue)
  gSignalConnect(ReturnButton, "clicked", ClickOnReturn)
  ##################################################
  ### put it together
  ##################################################
  vbox <- gtkVBoxNew()
  vbox$setBorderWidth(10)
  vbox$packStart(vbox1)
  vbox$packStart(vbox2)
  
  vbox1.1 <- gtkVBoxNew()
  vbox1.1$packStart(hbox)
  vbox1.1$packStart(vbox3)
  vbox1.1$packStart(vbox4)
  vbox1.1$packStart(vbox5)
  
  event <- gtkEventBox()
  color <-gdkColorToString('#fafafa')
  event$ModifyBg("normal", color)
  event$add(vbox1.1)
  
  vbox$packStart(event)
  RunPreSetWindow <- gtkWindow(show=F) 
  RunPreSetWindow["title"] <- "IBC-grass GUI"
  RunPreSetWindow$setPosition('GTK_WIN_POS_CENTER')
  color <-gdkColorToString('white')
  RunPreSetWindow$ModifyBg("normal", color)
  RunPreSetWindow$add(vbox)
  RunPreSetWindow$show()
}
################################################################################
#                                                                              #
# This function will create a new community/regional species pool.             #
# A list with all already classified plant species is given, but the user has  #
# the possibility to add new species                                           #
#                                                                              #
################################################################################
CreateNew <- function(){
  ##################################################
  ### Title
  ##################################################
  label_title <- gtkLabel()
  label_title$setJustify('center')
  label_title$setMarkup('<span weight=\"bold\" size=\"x-large\">
Create a new community</span> 
Please select the species occuring in the regional species pool, add new species or load previously saved community file.')

  ###################################################
  ### Edit the entry of a table
  ### Code is adapted from 
  ### https://github.com/lawremi/RGtk2/blob/master/books/rgui/ProgGUIInR/inst/Examples/ch-RGtk2/ex-RGtk2-rGtkDataFrame.R
  ### Author: John Verzani
  ###################################################
  #line 17 "ex-RGtk2-rGtkDataFrame.Rnw"
  editCallBack <- function(cell, path, arg3, ...) {
    if(nargs() == 3) {
      userData <- arg3; newValue <- NA    # no newValue (toggle)
    } else {
      newValue <- arg3; userData = ..1    # ..1 is first component of ...
    }
    rGtkStore <- userData$view$getModel()
    i <- as.numeric(path) + 1
    j <- userData$column
    newValue <- try(switch(userData$type,
                           "integer" = as.integer(as.numeric(newValue)),
                           "character" = as.character(newValue),
                           "numeric" = as.numeric(newValue),
                           "factor"  = as.character(newValue),
                           "logical" =  !as.logical(rGtkStore[i,j])),
                    silent=TRUE)
    
    if(inherits(newValue,"try-error")) {
      sprintf("Failed to coerce new value to type %s",userData$type)
      return(FALSE)
    }
    
    if(userData$type == "factor") {
      curLevels <- levels(rGtkStore[,j])
      if(! newValue %in% curLevels) {
        cat(gettext("Can't add level to a factor."))
        return(FALSE)
      }
    }
    
    rGtkStore[i,j] <- newValue            # assign value
    return(FALSE)
  }
  
  
  ###################################################
  ### Add column of a table
  ### Code is adapted from 
  ### https://github.com/lawremi/RGtk2/blob/master/books/rgui/ProgGUIInR/inst/Examples/ch-RGtk2/ex-RGtk2-rGtkDataFrame.R
  ### Author: John Verzani
  ###################################################
  #line 58 "ex-RGtk2-rGtkDataFrame.Rnw"
  gtkTreeViewAddColumnWithType <-
    function(view,
             name="",
             type=c("character","logical","factor"),
             viewCol,                     # 1-based column of view
             storeCol                     # 1-based column for rGtkDataFrame
    ) {
      
      type = match.arg(type)
      
      ## define the cell renderer
      cr <- switch(type,
                   "logical" = gtkCellRendererToggle(),
                   "factor" = gtkCellRendererCombo(), # if type=factor --> add a combo box
                   gtkCellRendererText() #if not factor --> only Text
      )
      
      ## the new column we will add
      vc <- gtkTreeViewColumn()
      vc$packStart(cr, TRUE)
      vc$setTitle(name)
      vc$setResizable(TRUE); vc$setClickable(TRUE)
      view$InsertColumn(vc, viewCol - 1)  # viewCol is 1-based
      
      ## add attributes
      switch(type,
             "logical" =  vc$addAttribute(cr, "active",storeCol - 1), # only if logical
             vc$addAttribute(cr, "text",storeCol - 1) # everything else
      )
      if(type == "numeric") cr['xalign'] <- 1 # only if numeric
      
      ## set editable/activatable property
      switch(type,
             "logical" = cr["activatable"] <- TRUE, # only if logical
             cr["editable"] <- TRUE) # everything else
      
      if(type == "factor") {              # combo box needs a data store
        cstore <- gtkListStore("gchararray")
        rGtkstore <- view$getModel()
        vals <- rGtkstore[,storeCol, drop=TRUE]
        if(storeCol==9){
          vals <- c(as.character(unique(vals)), "summer", "spring")
        }
        for(i in as.character(unique(vals))) {
          iter <- cstore$append()
          cstore$setValue(iter$iter,column=0, i)
        }
        cr['model'] <- cstore
        cr['text-column'] <- 0
      }
      
      
      ## connect callback to edited/toggled signal
      QT <- gSignalConnect(cr, signal =
                             if(type != "logical") "edited" else "toggled",
                           f = editCallBack, 
                           data = list(view=view,type=type,column=storeCol))
    }
  ###################################################
  ### Edit the entry of a table
  ### Code is adapted from 
  ### https://github.com/lawremi/RGtk2/blob/master/books/rgui/ProgGUIInR/inst/Examples/ch-RGtk2/ex-RGtk2-rGtkDataFrame.R
  ### Author: John Verzani
  ###################################################
  #line 58 "ex-RGtk2-rGtkDataFrame.Rnw"
  gtkTreeViewAddColumnWithTypeLastEntry <-
    function(view,
             name="",
             type=c("character","logical","factor"),
             viewCol,                     # 1-based column of view
             storeCol                     # 1-based column for rGtkDataFrame
    ) {
      
      type = match.arg(type)
      
      ## define the cell renderer
      cr <- switch(type,
                   "logical" = gtkCellRendererToggle(),
                   "factor" = gtkCellRendererCombo(), # if type=factor --> add a combo box
                   gtkCellRendererText() #if not factor --> only Text
      )
      
      ## the new column we will add
      vc <- gtkTreeViewColumn()
      vc$packStart(cr, TRUE)
      vc$setTitle(name)
      vc$setResizable(TRUE); vc$setClickable(TRUE)
      view$InsertColumn(vc, viewCol - 1)  # viewCol is 1-based
      
      ## add attributes
      switch(type,
             "logical" =  vc$addAttribute(cr, "active",storeCol - 1), # only if logical
             vc$addAttribute(cr, "text",storeCol - 1) # everything else
      )
      if(type == "numeric") cr['xalign'] <- 1 # only if numeric
      
      ## set editable/activatable property
      switch(type,
             "logical" = cr["activatable"] <- TRUE, # only if logical
             cr["editable"] <- TRUE) # everything else
      
      if(type == "factor") {              # combo box needs a data store
        cstore <- gtkListStore("gchararray")
        rGtkstore <- view$getModel()
        vals <- levels(rGtkstore[,storeCol, drop=TRUE])
        
        for(i in as.character(unique(vals))) {
          iter <- cstore$append()
          cstore$setValue(iter$iter,column=0, i)
        }
        cr['model'] <- cstore
        cr['text-column'] <- 0

        newValue <- "please select"
        rGtkstore[,storeCol] <- newValue
        
      }
      
      
      ## connect callback to edited/toggled signal
      QT <- gSignalConnect(cr, signal =
                             if(type != "logical") "edited" else "toggled",
                           f = editCallBack, 
                           data = list(view=view,type=type,column=storeCol))
    }
  
  
  ###################################################
  ### Add key navigation in a table
  ### Code is adapted from 
  ### https://github.com/lawremi/RGtk2/blob/master/books/rgui/ProgGUIInR/inst/Examples/ch-RGtk2/ex-RGtk2-rGtkDataFrame.R
  ### Author: John Verzani
  ###################################################
  #line 116 "ex-RGtk2-rGtkDataFrame.Rnw"
  ### -- bug with this when not editing
  gtkTreeViewAddKeyNavigations <- function(view) {
    ## keyMotionHandler example.
    connectSignal(view,"key-release-event",
                  f = function(view, event, userData,...) {
                    
                    keyval = event$getKeyval()
                    cursor = view$getCursor()
                    ## i,j are current positions,
                    i = as.numeric(cursor$path$toString()) + 1
                    vc = cursor[['focus.column']] ## might be focus_column!!
                    j = which(sapply(view$getColumns(), function(i) i == vc))
                    d = dim(view$getModel()) # rGtkStore method
                    
                    setCursorAtCell <- function(view, i, j) {
                      path <- gtkTreePathNewFromString(i-1)
                      vc <- view$getColumn(j - 1)
                      view$setCursor(path=path, focus.column=vc, start.editing=TRUE)
                    }
                    
                    if(keyval == GDK_Return) {
                      ## what do do with return?
                    } else if(keyval == GDK_Up) {
                      setCursorAtCell(view,max(1, i - 1), j)
                    } else if(keyval == GDK_Down) {
                      if(i < d[1])
                        setCursorAtCell(view,i + 1, j)
                    } else if(keyval == GDK_Tab) {
                      if(j < d[2])
                        setCursorAtCell(view,i, j + 1)
                    }
                  },
                  data=list(view = view)
    )
    
  }
  
  ###################################################
  ### Data frame with all Trait options and classified species
  ###################################################
  PFTfile <- read.table("Input-files/CompleteSpeciesList.txt", header=T, sep="\t")
  df <- PFTfile[,-2]
  for( i in 2: ncol(df)){
    df[,i] <- factor(df[,i])
  }
  levels(df[,8])<-c(levels(df[,8]),"spring", "summer")
  select <- c(rep(F, nrow(df)))
  df <- cbind(select, df)
  
  ###################################################
  ### show data frame with given species
  ###################################################
  store <- rGtkDataFrame(df)
  view <- gtkTreeView(store)
  
  ###################################################
  ### add new column to df with given species
  ###################################################
  nms <- names(df)
  QT <- sapply(1:ncol(df), function(i) {
    type <- class(df[,i])[1]
    view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
  })
  
  ##################################################
  ### create data.frame to append a species
  ##################################################
  PFTfile <- read.table("Input-files/CompleteSpeciesList.txt", header=T, sep="\t")
  Species <- "Add species name"
  plant.size <- c(levels(factor(PFTfile$plant.size)),"please select")
  growth.form <- c(levels(factor(PFTfile$growth.form)),"please select")
  resource.response <- c(levels(factor(PFTfile$resource.response)),"please select")
  grazing.response <- c(levels(factor(PFTfile$grazing.response)),"please select")
  clonal.type <- c(levels(factor(PFTfile$clonal.type)),"please select")
  flowering.type <- c(levels(factor(PFTfile$flowering.type)),"please select")
  germination.periods <- c(levels(factor(c("spring and summer", "spring", "summer"))),"please select")
  df.new<-data.frame(cbind(Species, plant.size, growth.form, resource.response, grazing.response, clonal.type, flowering.type, germination.periods))
  df.new[,1] <- as.character(df.new[,1])
  for( i in 2: ncol(df.new)){
    df.new[,i] <- factor(df.new[,i])
  }
  df.new <- df.new[1,]
  ### show to append a species
  store.append <- rGtkDataFrame(df.new)
  view.append <- gtkTreeView(store.append)
  ### add columns to append a species
  nms <- colnames(df.new)
  QT <- sapply(1:ncol(df.new), function(i) {
    type <- class(df.new[,i])[1]
    view.append$addColumnWithTypeLastEntry(name = nms[i], type, viewCol = i, storeCol = i)
  })
  ##################################################
  ### button to append species to data.frame
  ##################################################
  appendButton <- gtkButton("Add to list")
  append <- function(button){
    ### new data frame
    df.toappend <- data.frame(sw$getChildren()[[1]]$getModel())

    rGtkstore <- view.append$getModel()
    rGtkstore <- cbind(select=F, data.frame(rGtkstore))
    df.toappend <- rbind(df.toappend, rGtkstore)
    print(tail(df.toappend))
    ### show data frame
    store.refresh <- rGtkDataFrame(df.toappend)
    view.refresh <- gtkTreeView(store.refresh)
    ### add new column
    nms <- names(df.toappend)
    QT <- sapply(1:ncol(df.toappend), function(i) {
      type <- class(df.toappend[,i])[1]
      view.refresh$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
    })
    # delete entry
    if(length(sw$getChildren())!=0) sw$remove(sw$getChildren()[[1]])
    sw$add(view.refresh)
  }
  
  gSignalConnect(appendButton, 'clicked', append)

  ##################################################
  ### buttons for community file
  ##################################################
  # 1 button for saving the community
  SaveSelectedCommunityButton <- gtkButton('Save selected species as new community')
  SaveSelectedCommunity <- function(button){
    dialog <- gtkFileChooserDialog ( title = "Save a file" ,
                                     parent = NULL , action = "save" ,
                                     "gtk-ok" , GtkResponseType [ "ok" ] ,
                                     "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                     show = FALSE )
    color <-gdkColorToString('white')
    dialog$ModifyBg("normal", color)
    dialog$setCurrentName ("NewCommunity.txt")
    gSignalConnect ( dialog , "response" ,
                     f = function ( dialog , response , data ) {
                       if ( response == GtkResponseType [ "ok" ] ) {
                         filename <- dialog$getFilename ( )
                         dev1 <- unlist(strsplit(filename, "[\\]"))
                         dev <- dev1[length(dev1)]
                         dev <- unlist(strsplit(dev, "[.]"))[2]
                         dev.ok <- c("txt", "cvs")
                         if (dev %in% dev.ok){
                           df <- data.frame(sw$getChildren()[[1]]$getModel())
                           df <- df[df$select==T,]
                           print(df)
                           write.table(df, filename, sep="\t", row.names=F, quote=F)
                           dialog$destroy ( )
                         } else {
                           dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                          flags = "destroy-with-parent",
                                                          type="warning" ,
                                                          buttons="ok" ,
                                                          "Please ensure that you save the file as 
                                                          'txt'or 'cvs'.")
                           color <-gdkColorToString('white')
                           dialog_tmp$ModifyBg("normal", color)
                           gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                         }
                       }
                       if (response == GtkResponseType [ "cancel"]){dialog$destroy ( )}
                     } )
    dialog$run()
  }
  # 2 button for saving/updating the classified species
  SaveAllClassifiedSpeciesButton <- gtkButton('Save the updated list of all classified species')
  SaveAllClassifiedSpecies <- function(button){
    df <- data.frame(sw$getChildren()[[1]]$getModel())
    write.table(df, "Input-files/CompleteSpeciesList.txt", sep="\t")
  }
  
  # 3 button to continue
  ContinueButton <- gtkButton('Continue')
  Continue <- function(button){
    df <- data.frame(sw$getChildren()[[1]]$getModel())
    df <- df[df$select==T,]
    Community <- data.frame()
    # set IBC trait parameters
    for(spec in 1:nrow(df)){
      ID <- spec
      Species	<- c(1:7)
      MaxAge <- 100	
      AllocSeed	<- 0.05
      pEstab <- 0.5
      RAR <- 1
      growth <- 0.25
      mThres <- 0.2
      sens <- 0
      allocroot <- 1
      allocshoot <- 1
      EC50_biomass <- 0
      slope_biomass <- 0
      EC50_SEbiomass <- 0
      slope_SEbiomass <- 0
      EC50_survival <- 0
      slope_survival <- 0
      EC50_establishment <- 0
      slope_establishment <- 0
      EC50_sterility <- 0
      slope_sterility <- 0
      EC50_seednumber <- 0
      slope_seednumber <- 0
      
      # plant size
      if(df[spec,3]=="large"){
        MaxMass = 5000
        mSeed	= 1
        Dist = 0.1
        Species[1] = "L"
      }
      if(df[spec,3]=="medium"){
        MaxMass = 3000
        mSeed	= 0.3
        Dist = 0.3
        Species[1] = "M"
      }
      if(df[spec,3]=="small"){
        MaxMass = 1000
        mSeed	= 0.1
        Dist = 0.6
        Species[1] = "S"
      }
      
      # growth form
      if(df[spec,4]=="erect"){
        LMR = 0.5
        Species[2] = "E"
      }
      if(df[spec,4]=="semi-rosette"){
        LMR = 0.75
        Species[2] = "S"
      }
      if(df[spec,4]=="rosette"){
        LMR = 1.0
        Species[2] = "R"
      }
      
      # resource response
      if(df[spec,5]=="stress-tolerator"){
        Gmax = 20
        memo = 6
        Species[3] = "S"
      }
      if(df[spec,5]=="intermediate"){
        Gmax = 40
        memo = 4
        Species[3] = "I"
      }
      if(df[spec,5]=="competitor"){
        Gmax = 60
        memo = 2
        Species[3] = "C"
      }
      
      # grazing response
      if(df[spec,6]=="avoider"){
        SLA = 0.5
        palat = 0.25
        Species[4] = "A"
      }
      if(df[spec,6]=="intermediate"){
        SLA = 0.75
        palat = 0.5
        Species[4] = "I"
      }
      if(df[spec,6]=="tolerator"){
        SLA = 1
        palat = 1
        Species[4] = "T"
      }
      
      # clonality
      if (df[spec,7]=="aclonal"){
        Species[5] = ""
        clonal = 0
        propSex = 0
        meanSpacerLength = 0
        sdSpacerLength = 0
        Resshare = 0
        AllocSpacer = 0
        mSpacer = 0
      }
      if (df[spec,7]=="short spacer, with resource sharing"){
        Species[5] = "cl1"
        clonal = 1
        propSex = 1
        meanSpacerLength = 2.5
        sdSpacerLength = 2.5
        Resshare = 1
        AllocSpacer = 0.05
        mSpacer = 70
      }
      if (df[spec,7]=="short spacer, no resource sharing"){
        Species[5] = "cl2"
        clonal = 1
        propSex = 1
        meanSpacerLength = 2.5
        sdSpacerLength = 2.5
        Resshare = 0
        AllocSpacer = 0.05
        mSpacer = 70
        
      }
      if (df[spec,7]=="long spacer, with resource sharing"){
        Species[5] = "cl3"
        clonal = 1
        propSex = 1
        meanSpacerLength = 17.5
        sdSpacerLength = 12.5
        Resshare = 1
        AllocSpacer = 0.05
        mSpacer = 70
      }
      if (df[spec,7]=="long spacer, no resource sharing"){
        Species[5] = "cl4"
        clonal = 1
        propSex = 1
        meanSpacerLength = 17.5
        sdSpacerLength = 12.5
        Resshare = 0
        AllocSpacer = 0.05
        mSpacer = 70
      }
      
      # flowering type
      if (df[spec,8]=="late"){
        FlowerWeek = 16
        DispWeek = 20
        Species[6] = "l"
      }
      if (df[spec,8]=="early"){
        FlowerWeek = 1
        DispWeek = 5
        Species[6] = "e"
      }
      
      # germination type
      if (df[spec,9]=="spring and summer"){
        GermPeriod = 1
        Species[7] = "b"
      }
      if (df[spec,9]=="summer"){
        GermPeriod = 3
        Species[7] = "l"
      }
      if (df[spec,9]=="spring"){
        GermPeriod = 2
        Species[7] = "e"
      }
      
      m0 = mSeed
     	
      Overwintering = 1
      ID <- spec
      Species <- paste(Species[1],Species[2],Species[3],Species[4],Species[5],Species[6],Species[7], sep="")
      if (!(Species %in% Community$Species))
      {
        rowtoadd <- data.frame(ID,	Species,	MaxAge,	AllocSeed,	LMR,	m0,	MaxMass,	mSeed,	Dist,	pEstab,	Gmax,	SLA,
                               palat,	memo,	RAR,	growth,	mThres,	clonal,	propSex,	meanSpacerLength,	sdSpacerLength,
                               Resshare,	AllocSpacer,	mSpacer,	sens,	allocroot,	allocshoot,	EC50_biomass,	slope_biomass,
                               EC50_SEbiomass,	slope_SEbiomass,	EC50_survival,	slope_survival,	EC50_establishment,	
                               slope_establishment,	EC50_sterility,	slope_sterility,	EC50_seednumber,	slope_seednumber,	
                               FlowerWeek,	DispWeek,	GermPeriod, Overwintering)
        Community <- rbind(Community, rowtoadd)
      }
    }
    write.table(Community, "Model-files/Community.txt", sep="\t", row.names=F, quote = F)
    assign("IBCcommunity", "Community.txt", envir = IBCvariables)
    assign("IBCcommunityFile", Community, envir = IBCvariables)
    # close current window
    CreateNewCommunityWindow$destroy()
    # open the environmental settings window
    setEnvironmentaParametersforNewCommunity()
  }
  
  # 4 button to return
  ReturnButton <- gtkButton('Back')
  ReturnButton$setTooltipText("Go back to the previous window.")
  ClickOnReturn <- function(button){

    CreateNewCommunityWindow$destroy()
    Selection()

  }
  
  gSignalConnect(SaveSelectedCommunityButton, 'clicked', SaveSelectedCommunity)
  gSignalConnect(SaveAllClassifiedSpeciesButton, 'clicked', SaveAllClassifiedSpecies)
  gSignalConnect(ContinueButton, 'clicked', Continue)
  gSignalConnect(ReturnButton, 'clicked', ClickOnReturn)
  ###################################################
  ### packing
  ###################################################
  sw <- gtkScrolledWindow()
  sw['height.request'] <- 400
  sw$setPolicy("never","automatic")
  sw$add(view) #view is the table
  
  label_addingspecies <- gtkLabel()
  label_addingspecies$setMarkup('<span size=\"large\">
Add a species to the list above ... </span>')
  
  hbox.append <- gtkHBoxNew()
  hbox.append$packStart(view.append, padding=5) #view is the table
  hbox.append$packStart(appendButton, padding=5) #view is the table
  
  
  ##################################################
  ### put it together
  ##################################################
  vbox.event <- gtkVBoxNew()
  vbox.event$packStart(sw, padding=10)
  vbox.event$packStart(label_addingspecies, padding=5)
  vbox.event$packStart(hbox.append, padding=5)
  
  event <- gtkEventBox()
  color <-gdkColorToString('white')
  event$ModifyBg("normal", color)
  event$add(vbox.event)
  
  hbox <- gtkHBoxNew()
  hbox$packStart(ReturnButton, padding=5)
  hbox$packStart(SaveSelectedCommunityButton, padding=5)
  hbox$packStart(SaveAllClassifiedSpeciesButton, padding=5)
  hbox$packStart(ContinueButton, padding=5)
  
  vbox <- gtkVBoxNew()
  vbox$packStart(label_title, padding=5)
  vbox$packStart(event, padding=5)
  vbox$packStart(hbox, padding=5)
  
  
  CreateNewCommunityWindow <- gtkWindow(show=F) 
  CreateNewCommunityWindow["title"] <- "IBC-grass GUI"
  CreateNewCommunityWindow$setPosition('GTK_WIN_POS_CENTER')
  color <-gdkColorToString('white')
  CreateNewCommunityWindow$ModifyBg("normal", color)
  CreateNewCommunityWindow$add(vbox)
  CreateNewCommunityWindow$show()
}
################################################################################
#                                                                              #
# This function will load a previously saved community/regional species pool.  #
#                                                                              #
################################################################################
LoadNew <- function(){
  ##################################################
  ### Choose file
  ##################################################
  dialog <- gtkFileChooserDialog ( title = "Select a file" ,
                                   parent = NULL , action = "select" ,
                                   "gtk-ok" , GtkResponseType [ "ok" ] ,
                                   "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                   show = FALSE )
  color <-gdkColorToString('white')
  dialog$ModifyBg("normal", color)
  gSignalConnect ( dialog , "response" ,
                   f = function ( dialog , response , data ) {
                     if ( response == GtkResponseType [ "ok" ] ) {
                       filename <- dialog$getFilename ( )
                       dev1 <- unlist(strsplit(filename, "[\\]"))
                       dev <- dev1[length(dev1)]
                       dev <- unlist(strsplit(dev, "[.]"))[2]
                       dev.ok <- c("txt", "cvs")
                       if (dev %in% dev.ok){
                         df <- read.table(filename, header=T, sep="\t")
                         Community <- data.frame()
                         # set IBC trait parameters
                         for(spec in 1:nrow(df)){
                           ID <- spec
                           Species	<- c(1:7)
                           MaxAge <- 100	
                           AllocSeed	<- 0.05
                           pEstab <- 0.5
                           RAR <- 1
                           growth <- 0.25
                           mThres <- 0.2
                           sens <- 0
                           allocroot <- 1
                           allocshoot <- 1
                           EC50_biomass <- 0
                           slope_biomass <- 0
                           EC50_SEbiomass <- 0
                           slope_SEbiomass <- 0
                           EC50_survival <- 0
                           slope_survival <- 0
                           EC50_establishment <- 0
                           slope_establishment <- 0
                           EC50_sterility <- 0
                           slope_sterility <- 0
                           EC50_seednumber <- 0
                           slope_seednumber <- 0
                           
                           # plant size
                           if(df[spec,3]=="large"){
                             MaxMass = 5000
                             mSeed	= 1
                             Dist = 0.1
                             Species[1] = "L"
                           }
                           if(df[spec,3]=="medium"){
                             MaxMass = 3000
                             mSeed	= 0.3
                             Dist = 0.3
                             Species[1] = "M"
                           }
                           if(df[spec,3]=="small"){
                             MaxMass = 1000
                             mSeed	= 0.1
                             Dist = 0.6
                             Species[1] = "S"
                           }
                           
                           # growth form
                           if(df[spec,4]=="erect"){
                             LMR = 0.5
                             Species[2] = "E"
                           }
                           if(df[spec,4]=="semi-rosette"){
                             LMR = 0.75
                             Species[2] = "S"
                           }
                           if(df[spec,4]=="rosette"){
                             LMR = 1.0
                             Species[2] = "R"
                           }
                           
                           # resource response
                           if(df[spec,5]=="stress-tolerator"){
                             Gmax = 20
                             memo = 6
                             Species[3] = "S"
                           }
                           if(df[spec,5]=="intermediate"){
                             Gmax = 40
                             memo = 4
                             Species[3] = "I"
                           }
                           if(df[spec,5]=="competitor"){
                             Gmax = 60
                             memo = 2
                             Species[3] = "C"
                           }
                           
                           # grazing response
                           if(df[spec,6]=="avoider"){
                             SLA = 0.5
                             palat = 0.25
                             Species[4] = "A"
                           }
                           if(df[spec,6]=="intermediate"){
                             SLA = 0.75
                             palat = 0.5
                             Species[4] = "I"
                           }
                           if(df[spec,6]=="tolerator"){
                             SLA = 1
                             palat = 1
                             Species[4] = "T"
                           }
                           
                           # clonality
                           if (df[spec,7]=="aclonal"){
                             Species[5] = ""
                             clonal = 0
                             propSex = 0
                             meanSpacerLength = 0
                             sdSpacerLength = 0
                             Resshare = 0
                             AllocSpacer = 0
                             mSpacer = 0
                           }
                           if (df[spec,7]=="short spacer, with resource sharing"){
                             Species[5] = "cl1"
                             clonal = 1
                             propSex = 1
                             meanSpacerLength = 2.5
                             sdSpacerLength = 2.5
                             Resshare = 1
                             AllocSpacer = 0.05
                             mSpacer = 70
                           }
                           if (df[spec,7]=="short spacer, no resource sharing"){
                             Species[5] = "cl2"
                             clonal = 1
                             propSex = 1
                             meanSpacerLength = 2.5
                             sdSpacerLength = 2.5
                             Resshare = 0
                             AllocSpacer = 0.05
                             mSpacer = 70
                             
                           }
                           if (df[spec,7]=="long spacer, with resource sharing"){
                             Species[5] = "cl3"
                             clonal = 1
                             propSex = 1
                             meanSpacerLength = 17.5
                             sdSpacerLength = 12.5
                             Resshare = 1
                             AllocSpacer = 0.05
                             mSpacer = 70
                           }
                           if (df[spec,7]=="long spacer, no resource sharing"){
                             Species[5] = "cl4"
                             clonal = 1
                             propSex = 1
                             meanSpacerLength = 17.5
                             sdSpacerLength = 12.5
                             Resshare = 0
                             AllocSpacer = 0.05
                             mSpacer = 70
                           }
                           
                           # flowering type
                           if (df[spec,8]=="late"){
                             FlowerWeek = 16
                             DispWeek = 20
                             Species[6] = "l"
                           }
                           if (df[spec,8]=="early"){
                             FlowerWeek = 1
                             DispWeek = 5
                             Species[6] = "e"
                           }
                           
                           # germination type
                           if (df[spec,9]=="spring and summer"){
                             GermPeriod = 1
                             Species[7] = "b"
                           }
                           if (df[spec,9]=="summer"){
                             GermPeriod = 3
                             Species[7] = "l"
                           }
                           if (df[spec,9]=="spring"){
                             GermPeriod = 2
                             Species[7] = "e"
                           }
                           
                           m0 = mSeed
                           
                           Overwintering = 1
                           ID <- spec
                           Species <- paste(Species[1],Species[2],Species[3],Species[4],Species[5],Species[6],Species[7], sep="")
                           
                           rowtoadd <- data.frame(ID,	Species,	MaxAge,	AllocSeed,	LMR,	m0,	MaxMass,	mSeed,	Dist,	pEstab,	Gmax,	SLA,
                                                  palat,	memo,	RAR,	growth,	mThres,	clonal,	propSex,	meanSpacerLength,	sdSpacerLength,
                                                  Resshare,	AllocSpacer,	mSpacer,	sens,	allocroot,	allocshoot,	EC50_biomass,	slope_biomass,
                                                  EC50_SEbiomass,	slope_SEbiomass,	EC50_survival,	slope_survival,	EC50_establishment,	
                                                  slope_establishment,	EC50_sterility,	slope_sterility,	EC50_seednumber,	slope_seednumber,	
                                                  FlowerWeek,	DispWeek,	GermPeriod, Overwintering)
                           Community <- rbind(Community, rowtoadd)
                         }
                         write.table(Community, "Model-files/Community.txt", sep="\t", row.names=F, quote = F)
                         assign("IBCcommunity", "Community.txt", envir = IBCvariables)
                         assign("IBCcommunityFile", Community, envir = IBCvariables)
                         # close dialog
                         dialog$destroy()
                         # open environmental settings window
                         setEnvironmentaParametersforNewCommunity()
                       } else {
                         dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                        flags = "destroy-with-parent",
                                                        type="question" ,
                                                        buttons="ok" ,
                                                        "Please ensure that you select a 
                                                          'txt'or 'cvs' file.")
                         color <-gdkColorToString('white')
                         dialog_tmp$ModifyBg("normal", color)
                         gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                       }
                     }
                     if ( response == GtkResponseType [ "cancel" ] ) {
                       dialog$destroy ( )
                       Selection()
                     }
                     
                   } )
  dialog$run()
}
################################################################################
#                                                                              #
# This function will load previous simulation settings.                        #
#                                                                              #
################################################################################
LoadPrev <- function(){
  ##################################################
  ### Choose simulation settings file
  ##################################################
  dialog <- gtkFileChooserDialog ( title = "Select a file" ,
                                   parent = NULL , action = "select" ,
                                   "gtk-ok" , GtkResponseType [ "ok" ] ,
                                   "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                   show = FALSE )
  color <-gdkColorToString('white')
  dialog$ModifyBg("normal", color)
  gSignalConnect ( dialog , "response" ,
                   f = function ( dialog , response , data ) {
                     if ( response == GtkResponseType [ "ok" ] ) {
                       filename <- dialog$getFilename ( )
                       if (grepl('SimulationSettings.Rdata', filename)){
                         assign("IBCloadedSettings", filename, IBCvariables)
                         load(filename)
                         for(el in ls(SaveEnvironment)) assign(el, get(el, SaveEnvironment), envir=IBCvariables)
                         # close current window
                         dialog$destroy ( )
                         # open environmental settings window
                         setEnvironmentaParametersforNewCommunity()
                       } else {
                         dialog_tmp <- gtkMessageDialog(parent=dialog,
                                                        flags = "destroy-with-parent",
                                                        type="question" ,
                                                        buttons="ok" ,
                                                        "Please ensure that you select a 
                                                        'SimulationSettings.RData' file.")
                         color <-gdkColorToString('white')
                         dialog_tmp$ModifyBg("normal", color)
                         gSignalConnect (dialog_tmp, "response", function(dialog_tmp, response, user.data){ dialog_tmp$Destroy()})
                       }
                     }
                     if ( response == GtkResponseType [ "cancel" ] ) {
                       # close current window
                       dialog$destroy ( )
                       # open selection window
                       Selection()
                     }
                     
                   } )
  dialog$run()
}
################################################################################
#                                                                              #
# This function will open the environmental settings window for new PFT        #
# communities.                                                                 #
#                                                                              #
################################################################################
setEnvironmentaParametersforNewCommunity <- function(){
   # delete old files
   if (length(list.files("currentSimulation/"))>0){
     setwd('currentSimulation')
     unlink(list.files(getwd()), recursive=TRUE)
     setwd('..')
   }
   ##################################################
   ### Title
   ##################################################
   vbox1 <- gtkVBoxNew()
   vbox1$setBorderWidth(10)
   label_title <- gtkLabel()
   label_title$setMarkup('<span weight=\"bold\" size=\"x-large\">Set environmental parameters</span>')
   vbox1$packStart(label_title)
   ##################################################
   ### settings resources
   ##################################################
   # normal resource settings
   # label
   vbox2 <- gtkVBoxNew()
   vbox2$setBorderWidth(5)
   label_resources<-gtkLabel()
   label_resources$setMarkup('<span underline=\"single\"size=\"large\">Resource settings</span>')
   label_resources['height.request'] <- 20
   vbox2$packStart(label_resources)
   
   # belowground resources
   label_below<-gtkLabel('Belowground resource level')
   label_below$setTooltipText("Belowground resources may vary from nutrient poor [40] to rich [100].")
   
   ResourceSliderBelow <- gtkHScale(min = 40, max = 100, step = 5)
   ResourceSliderBelow$setTooltipText("Belowground resources may vary from nutrient poor [40] to rich [100].")
   ResourceSliderBelow$setValue(get("IBCbelres", envir=IBCvariables))
   
   vbox2$packStart(label_below)
   vbox2$packStart(ResourceSliderBelow)
   
   #aboveground resources
   hbox1 <- gtkHBoxNew()
   vbox2.1 <- gtkVBoxNew()
   
   label_above<-gtkLabel('Aboveground resource level')
   label_above$setTooltipText("Aboveground resources may vary from shaded [40] to sunny [100].")
   
   ResourceSliderAbove <- gtkHScale(min = 40, max = 100, step = 5)
   ResourceSliderAbove$setTooltipText("Aboveground resources may vary from shaded [40] to sunny [100].")
   ResourceSliderAbove$setValue(get("IBCabres", envir=IBCvariables))
   
   vbox2.1$packStart(label_above)
   vbox2.1$packStart(ResourceSliderAbove)
   
   # box amplitude of aboveground seasonal variation in resources
   vbox2.2 <- gtkVBoxNew()
   label_aboveampl<-gtkLabel('Amplitude for aboveground seasonality')
   label_aboveampl$setTooltipText("Amplitude for aboveground resource distribution over 1 growing season")
   AboveAmplitudeSlider <- gtkHScaleNewWithRange(min = 0, max = 0.9, step = 0.1)
   AboveAmplitudeSlider$setValue(get("IBCabampl", envir=IBCvariables))
   
   vbox2.2$packStart(label_aboveampl)
   vbox2.2$packStart(AboveAmplitudeSlider)
   
   hbox1$packStart(vbox2.1, padding = 5)
   hbox1$packStart(vbox2.2, padding = 5)
   
   vbox2$packStart(hbox1, padding = 5)
   
   ##################################################
   ### settings disturbances
   ##################################################
   vbox3 <- gtkVBoxNew()
   vbox3$setBorderWidth(5)

   label_disturbances<-gtkLabel()
   label_disturbances$setMarkup('<span underline=\"single\"size=\"large\">Disturbance settings</span>')
   label_disturbances['height.request'] <- 20
   vbox3$packStart(label_disturbances)

   #slider for trampling
   label_tramp<-gtkLabel('Trampling [% area trampled]')
   label_tramp$setTooltipText("Trampling causes the destruction of aboveground shootmass.")
   label_tramp['height.request'] <- 20
   vbox3$packStart(label_tramp)
   TramplingSlider <- gtkHScale(min = 0, max = 50, step = 0.1)
   TramplingSlider$setTooltipText("Trampling causes the destruction of aboveground shootmass.")
   TramplingSlider$setValue(get("IBCtramp", envir=IBCvariables)*100) 
   vbox3$packStart(TramplingSlider)

   # slider for grazing
   label_graz<-gtkLabel('Grazing [% area grazed]')
   label_graz$setTooltipText("During the grazing process, parts of the aboveground shoot mass is removed. The proportion of grazed shoot mass is PFT specific.")
   label_graz['height.request'] <- 20
   vbox3$packStart(label_graz)
   GrazingSlider <- gtkHScale(min = 0, max = 50, step = 0.1)
   GrazingSlider$setTooltipText("During the grazing process, parts of the aboveground shoot mass is removed. The proportion of grazed shoot mass is PFT specific.")
   GrazingSlider$setValue(get("IBCgraz", envir=IBCvariables)*100)
   vbox3$packStart(GrazingSlider)
    
   # radio button selection of the cutting events
   label_cuts<-gtkLabel('Cutting events')
   label_cuts$setTooltipText("During a cutting event, the aboveground shoot mass is removed to a certain level above the surface.")
   label_cuts['height.request'] <- 20
   vbox3$packStart(label_cuts)
   cuts <- c("In autumn" , " In spring and autumn" , " In spring, summer and autumn", "No cutting event")
   radio_buttons_cut <- NULL
   for (cuts in cuts){
     button_cuts <- gtkRadioButton(radio_buttons_cut, cuts)
     vbox3$packStart(button_cuts)
     radio_buttons_cut<- c(radio_buttons_cut, button_cuts)
   }

   if(get("IBCcut",envir = IBCvariables)== 1) {vbox3[[7]]$setActive(T)}
   if(get("IBCcut",envir = IBCvariables)== 2) {vbox3[[8]]$setActive(T)}
   if(get("IBCcut",envir = IBCvariables)== 3) {vbox3[[9]]$setActive(T)}
   if(get("IBCcut",envir = IBCvariables)== 0) {vbox3[[10]]$setActive(T)}
   ##################################################
   ### buttons
   ##################################################
   vbox4 <- gtkVBoxNew()
   vbox4$setBorderWidth(5)

   ContinueButton<-gtkButton('Continue')
   ContinueButton$setTooltipText("Go to the next step.")
   ClickOnButtonContinue <- function(button){
     
     assign("IBCbelres", ResourceSliderBelow$getValue(), envir = IBCvariables)
     assign("IBCabres", ResourceSliderAbove$getValue(), envir = IBCvariables)
     assign("IBCgraz", GrazingSlider$getValue()/100, envir = IBCvariables)
     assign("IBCtramp", TramplingSlider$getValue()/100, envir = IBCvariables)

     if(vbox3[[7]]$getActive()==T) {
       assign("IBCcut", 1, envir = IBCvariables)
     }

     if(vbox3[[8]]$getActive()==T) {
       assign("IBCcut", 2, envir = IBCvariables)
     }
     if(vbox3[[9]]$getActive()==T) {
       assign("IBCcut", 3, envir = IBCvariables)
     }
     if(vbox3[[10]]$getActive()==T) {
       assign("IBCcut", 0, envir = IBCvariables)
     }
     # go to herbicide settings window
     HerbicideSettings()
     # close current window
     RunPreSetWindow$destroy()
   }

   ReturnButton <- gtkButton('Back')
   ReturnButton$setTooltipText("Go back to the previous window.")
   ClickOnReturn <- function(button){
     # close current window
     RunPreSetWindow$destroy()
     # open selection window
     Selection()

   }

   vbox4$packStart(ContinueButton)
   vbox4$packStart(ReturnButton,fill=F) #button which will start

   gSignalConnect(ContinueButton, "clicked", ClickOnButtonContinue)
   gSignalConnect(ReturnButton, "clicked", ClickOnReturn)
   
   ##################################################
   ### put it together
   ##################################################
   vbox <- gtkVBoxNew()
   vbox$setBorderWidth(10)
   # pack title
   vbox$packStart(vbox1)
   
   vbox1.1 <- gtkVBoxNew()
   vbox1.1$packStart(vbox2)
   vbox1.1$packStart(vbox3)
   vbox1.1$packStart(vbox4)
   
   event <- gtkEventBox()
   color <-gdkColorToString('white')
   event$ModifyBg("normal", color)
   event$add(vbox1.1)
   
   vbox$packStart(event)
   RunPreSetWindow <- gtkWindow(show=F) 
   RunPreSetWindow["title"] <- "IBC-grass GUI"
   RunPreSetWindow$setPosition('GTK_WIN_POS_CENTER')
   color <-gdkColorToString('white')
   RunPreSetWindow$ModifyBg("normal", color)
   RunPreSetWindow$add(vbox)
   RunPreSetWindow$show()
 }