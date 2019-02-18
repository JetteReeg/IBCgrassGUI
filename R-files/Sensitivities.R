SensitivityTXT <- function(){
  ###################################################
  ### chunk number 2: callBackEdit
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
  ### chunk number 3: AddColumnWithType
  ###################################################
  #line 58 "ex-RGtk2-rGtkDataFrame.Rnw"
  gtkTreeViewAddColumnWithType <-
    function(view,
             name="",
             type=c("character","factor"),
             viewCol,                     # 1-based column of view
             storeCol                     # 1-based column for rGtkDataFrame
    ) {
      
      type = match.arg(type)
      
      ## define the cell renderer
      cr <- switch(type,
                   gtkCellRendererText(), #if not factor --> only Text
                   "factor" = gtkCellRendererCombo() # if type=factor --> add a combo box
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
        
        for(i in levels(vals)) {
          iter <- cstore$append()
          cstore$setValue(iter$iter,column=0, i)
        }
        cr['model'] <- cstore
        cr['text-column'] <- 0
        
        if(is.null(get("PFTSensitivityFile", envir=IBCvariables))){
          
          newValue <- "Please select sensitivity"
          rGtkstore[,storeCol] <- newValue
        }
        
      }
      
      
      ## connect callback to edited/toggled signal
      QT <- gSignalConnect(cr, signal =
                             if(type != "logical") "edited" else "toggled",
                           f = editCallBack, 
                           data = list(view=view,type=type,column=storeCol))
    }
  
  
  ###################################################
  ### chunk number 4: keyNav
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
  ### Tooltips for Treeview
  ###################################################
  on_tooltip <- function (widget, x, y, keyboard_tip, tooltip) {
    model <- widget$getModel()
    
    ctx <- widget$getTooltipContext(x, y, keyboard_tip)
    
    if (!ctx$retval)
      return(FALSE)
    
    # value in the cell
    tmp <- model$get(ctx$iter, 0)[[1]]
    # search for PFT ID in the txt file
    lookuptable <- get("PFTtoSpecies", envir=IBCvariables)
    Species <- lookuptable[which(lookuptable$Species == tmp),2]
    
    markup <- paste("<b>e.g. </b> <i>", Species,"</i>", sep=" ")
    tooltip$setMarkup(markup)
    
    widget$setTooltipRow(tooltip, ctx$path)
    
    return(TRUE)
  }
  
  ###################################################
  ### sensitivity options
  ###################################################
  if(is.null(get("PFTSensitivityFile", envir=IBCvariables))){
    PFTfile <- get("IBCcommunityFile", envir = IBCvariables)
    Sensitivity <- c("random", "not affected", "low", "medium", "high", "full")
    length(Sensitivity) = length(PFTfile$Species)
    df <- data.frame(Species = as.character(PFTfile$Species), Sensitivity=Sensitivity, stringsAsFactors=F)
    df[is.na(df)] <- "Please select sensitivity"
    df$Sensitivity<-factor(df$Sensitivity)
    print(levels(df$Sensitivity))
  } else {
    Sensitivity <- c("random", "not affected", "low", "medium", "high", "full", "Please select sensitivity")
    factor(Sensitivity)
    df <- get("PFTSensitivityFile", envir = IBCvariables)
    df[is.na(df)] <- "Please select sensitivity"
    df$Sensitivity<-factor(df$Sensitivity)
    levels(df$Sensitivity) <- c(levels(df$Sensitivity),Sensitivity)
  }
  ###################################################
  ### show data frame
  ###################################################
  store <- rGtkDataFrame(df)
  view <- gtkTreeView(store)
  ###################################################
  ### add new column
  ###################################################
  nms <- names(df)
  QT <- sapply(1:ncol(df), function(i) {
    type <- class(df[,i])[1]
    view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
  })
  ###################################################
  ### add tooltips
  ###################################################
  view['has-tooltip'] <- TRUE
  gSignalConnect(view,'query-tooltip', on_tooltip)

  ##################################################
  ### ComboBox + button all to 1 type
  ##################################################
  rGtkstore <- view$getModel()
  storeCol = 2
  vals <- levels(rGtkstore[,storeCol])
  SensitivityOptions <- unique(vals)
  combosensitivity <- gtkComboBoxNewText()
  combosensitivity$show()
  for (sens in SensitivityOptions) combosensitivity$appendText(sens)
  combosensitivity$setActive(0)
  combosensitivity$setTooltipText('Potential sensitivities of the PFTs. Random means that sensitivities are randomly distributed between PFTs for each repetition.')
  combosensitivity$setBorderWidth(10)
  
  cb<-gtkButton('Set all')
  cb$setBorderWidth(10)
  cb$setTooltipText('Sets all PFTs to the selected sensitivity option.')
  SetAll <- function(button){
    storeCol = 2
    rGtkstore <- view$getModel()
    newValue <- SensitivityOptions[combosensitivity$getActive()+1]
    rGtkstore[,storeCol] <- newValue
  }
  
  gSignalConnect(cb, signal = "clicked", SetAll)
  ##################################################
  ### button 'save and next'
  ##################################################
  sc<-gtkButton('Save & continue')
  sc$setTooltipText('Save the current selection and go to the next step')
  
  Close <- function(button){
    rGtkstore <- view$getModel()
    assign("PFTSensitivityFile", data.frame(rGtkstore), envir=IBCvariables)
    # write.table(rGtkstore,"PFTsensitivity.txt", sep="\t")
    w$destroy()
    SimulationSpecifics()
  }
  
  gSignalConnect(sc, signal = "clicked", Close)
  ##################################################
  ### button 'return'
  ##################################################
  ReturnButton<-gtkButton('Back')
  ReturnButton$setTooltipText('Go back to previous step.')
  
  ClickOnReturn <- function(button){
    
    w$destroy()
    HerbicideSettings()
    
  }
  
  gSignalConnect(ReturnButton, signal = "clicked", ClickOnReturn)
  
  
  ##################################################
  ### label title
  ##################################################
  vbox1 <- gtkVBoxNew()
  vbox1$setBorderWidth(10)
  label_title <- gtkLabel()
  label_title$setMarkup('<span weight=\"bold\" size=\"x-large\">PFT specific sensitivities</span>')
  vbox1$packStart(label_title)
  ##################################################
  ### label set all
  ##################################################
  label_setall<-gtkLabel('Set all values to')
  label_setall$setWidthChars(20)
  ###################################################
  ### put it all together
  ###################################################
  vbox <- gtkVBoxNew(homogeneous = F)
  hboxinvbox <- gtkHBoxNew(homogeneous = F)
  topvbox<-gtkVBoxNew()
  topvbox$setBorderWidth(10)
  
  sw <- gtkScrolledWindow()
  sw['height.request'] <- 400
  sw$setPolicy("never","automatic")
  sw$add(view) #view is the table
  
  hboxinvbox$packStart(label_setall, fill = F, expand=F)
  hboxinvbox$packStart(combosensitivity, fill = F, expand=F)
  hboxinvbox$packStart(cb)
  
  vbox$packStart(hboxinvbox, fill = F, expand=F)
  vbox$packStart(sw,expand=T, fill=T)
  vbox$packStart(sc, fill = F, expand=F)
  vbox$packStart(ReturnButton, fill = F, expand=F)
  
  topvbox$packStart(vbox1)
  topvbox$packStart(vbox)
  
  w <- gtkWindow(show=F)
  w$setPosition('GTK_WIN_POS_CENTER')
  w["title"] <- "IBC-grass 2.0"
  color <-gdkColorToString('white')
  w$ModifyBg("normal", color)
  w$add(topvbox)
  w$show()
}

SensitivityDR <- function(){
  ###################################################
  ### chunk number 2: callBackEdit
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
  ### chunk number 3: AddColumnWithType
  ###################################################
  #line 58 "ex-RGtk2-rGtkDataFrame.Rnw"
  gtkTreeViewAddColumnWithType <-
    function(view,
             name="",
             type=c("character","factor"),
             viewCol,                     # 1-based column of view
             storeCol                     # 1-based column for rGtkDataFrame
    ) {
      
      type = match.arg(type)
      
      ## define the cell renderer
      cr <- switch(type,
                   gtkCellRendererText(), #if not factor --> only Text
                   "factor" = gtkCellRendererCombo() # if type=factor --> add a combo box
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
        
        for(i in levels(vals)) { # it will append also some numbers??
          iter <- cstore$append()
          cstore$setValue(iter$iter,column=0, i)
        }
        cr['model'] <- cstore
        cr['text-column'] <- 0
        
        if(is.null(get("PFTSensitivityFile", envir=IBCvariables))){
          newValue <- i
          rGtkstore[,storeCol] <- newValue
        }
        
        
      }
      
      
      ## connect callback to edited/toggled signal
      QT <- gSignalConnect(cr, signal =
                             if(type != "logical") "edited" else "toggled",
                           f = editCallBack, 
                           data = list(view=view,type=type,column=storeCol))
    }
  
  
  ###################################################
  ### chunk number 4: keyNav
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
  ### Tooltips for Treeview
  ###################################################
  on_tooltip <- function (widget, x, y, keyboard_tip, tooltip) {
    model <- widget$getModel()
    
    ctx <- widget$getTooltipContext(x, y, keyboard_tip)
    
    if (!ctx$retval)
      return(FALSE)
    
    # value in the cell
    tmp <- model$get(ctx$iter, 0)[[1]]
    # search for PFT ID in the txt file
    lookuptable <- get("PFTtoSpecies", envir=IBCvariables)
    Species <- lookuptable[which(lookuptable$Species == tmp),2]
    # cell number
    # pathstring <- ctx$path$toString()
    # print(pathstring)
    
    
    markup <- paste("<b>e.g. </b> <i>", Species,"</i>", sep=" ")
    tooltip$setMarkup(markup)
    
    widget$setTooltipRow(tooltip, ctx$path)
    
    return(TRUE)
  }
  
  ###################################################
  ### sensitivity options
  ###################################################
  if(is.null(get("PFTSensitivityFile", envir=IBCvariables))){
    PFTfile <- get("IBCcommunityFile", envir = IBCvariables)
    Sensitivity <- c("random", "not affected")
    for (i in 1:get("nb_data", envir=IBCvariables)){
      Sensitivity <- c(Sensitivity, paste("dose response based on Spec ", i, sep=""))
    }
    length(Sensitivity) = length(PFTfile$Species)
    df <- data.frame(Species = as.character(PFTfile$Species), Sensitivity=Sensitivity, stringsAsFactors=F)
    df[is.na(df)] <- "Please select sensitivity"
    df$Sensitivity<-factor(df$Sensitivity)
  } else {
    Sensitivity <- c("random", "not affected")
    for (i in 1:get("nb_data", envir=IBCvariables)){
      Sensitivity <- c(Sensitivity, paste("dose response based on Spec ", i, sep=""))
    }
    Sensitivity <- c(Sensitivity, "Please select sensitivity")
    factor(Sensitivity)
    df <- get("PFTSensitivityFile", envir = IBCvariables)
    df[is.na(df)] <- "Please select sensitivity"
    df$Sensitivity<-factor(df$Sensitivity)
    levels(df$Sensitivity) <- c(levels(df$Sensitivity),Sensitivity)
  }
  ###################################################
  ### create the df to be shown
  ###################################################
  store <- rGtkDataFrame(df)
  view <- gtkTreeView(store)
  ###################################################
  ### add columns
  ###################################################
  nms <- names(df)
  QT <- sapply(1:ncol(df), function(i) {
    type <- class(df[,i])[1]
    view$addColumnWithType(name = nms[i], type, viewCol = i, storeCol = i)
  })
  ###################################################
  ### add tooltips
  ###################################################
  view['has-tooltip'] <- TRUE
  gSignalConnect(view,'query-tooltip', on_tooltip)

  ##################################################
  ### button all to 1 type
  ##################################################
  rGtkstore <- view$getModel()
  storeCol = 2
  vals <- levels(rGtkstore[,storeCol])
  SensitivityOptions <- unique(vals)
  combosensitivity <- gtkComboBoxNewText()
  combosensitivity$show()
  for (sens in SensitivityOptions) combosensitivity$appendText(sens)
  
  combosensitivity$setActive(0)
  combosensitivity$setTooltipText('Dose responses on which the effects are based on. You can select either by the species you have entered in, or create a random dose response curve, which is within the variation of the measured dose responses (see Figure).')
  combosensitivity$setBorderWidth(10)
  
  cb<-gtkButton('Set all')
  cb$setTooltipText('Applies the selected option to all PFTs.')
  cb$setBorderWidth(10)
  
  SetAll <- function(button){
    storeCol = 2
    rGtkstore <- view$getModel()
    newValue <- SensitivityOptions[combosensitivity$getActive()+1]
    rGtkstore[,storeCol] <- newValue
  }
  
  gSignalConnect(cb, signal = "clicked", SetAll)
  ##################################################
  ### button 'save and next'
  ##################################################
  sc<-gtkButton('Save & continue')
  sc$setTooltipText('Save the current selection and continue to the next step.')
  sc$setBorderWidth(10)
  Close <- function(button){
    rGtkstore <- view$getModel()
    assign("PFTSensitivityFile", data.frame(rGtkstore), envir = IBCvariables)
    w$destroy()
    SimulationSpecifics()
  }
  
  gSignalConnect(sc, signal = "clicked", Close)
  ##################################################
  ### button 'return'
  ##################################################
  ReturnButton<-gtkButton('Back')
  ReturnButton$setTooltipText('Go back to previous step.')
  ReturnButton$setBorderWidth(10)
  ClickOnReturn <- function(button){
    w$destroy()
    HerbicideSettings()
  }
  
  gSignalConnect(ReturnButton, signal = "clicked", ClickOnReturn)
  ###################################################
  ### dose responses
  ###################################################
  ExampleDR <- gtkImageNewFromFile('Example_doseresponse.png')
  ExampleDR$setTooltipText('This figure shows the calculated dose responses for all of the provided species, the mean dose response curve over all species and 100 random dose responses based on the variations within the provided ones.')
  gtkImageSetPixelSize(ExampleDR, 300)
  ##################################################
  ### label title
  ##################################################
  vbox1 <- gtkVBoxNew()
  vbox1$setBorderWidth(10)
  label_title <- gtkLabel()
  label_title$setMarkup('<span weight=\"bold\" size=\"x-large\">PFT specific sensitivities</span>')
  vbox1$packStart(label_title)
  ##################################################
  ### label set all
  ##################################################
  label_setall<-gtkLabel('Set all values to')
  label_setall$setWidthChars(20)
  ###################################################
  ### put it all together
  ###################################################
  
  topvbox<-gtkVBoxNew() #incl the title and a hbox
  topvbox$setBorderWidth(10)
  hbox <- gtkHBoxNew(homogeneous=F) #incl the picture and a vbox
  vbox <- gtkVBoxNew(homogeneous = F) # incl a hbox and the scrolled box and the buttons
  hboxinvbox <- gtkHBoxNew(homogeneous = F)
  hboxinvbox$setBorderWidth(10)
  
  sw <- gtkScrolledWindow()
  sw['height.request'] <- 400
  sw$setBorderWidth(10)
  sw$setPolicy("never","automatic")
  sw$add(view) #view is the table

  hboxinvbox$packStart(label_setall, fill = F, expand=F)
  hboxinvbox$packStart(combosensitivity, fill = F, expand=F)
  hboxinvbox$packStart(cb)
  
  vbox$packStart(hboxinvbox, fill = F, expand=F)
  vbox$packStart(sw,expand=T, fill=T)
  vbox$packStart(sc, fill = F, expand=F)
  vbox$packStart(ReturnButton, fill = F, expand=F)
  
  hbox$packStart(ExampleDR)
  hbox$packStart(vbox)
  
  topvbox$packStart(vbox1)
  topvbox$packStart(hbox)
  
  w <- gtkWindow(show=F)
  w$setPosition('GTK_WIN_POS_CENTER')
  w["title"] <- "IBC-grass 2.0"
  color <-gdkColorToString('white')
  w$ModifyBg("normal", color)
  w$add(topvbox)
  w$show()
}
