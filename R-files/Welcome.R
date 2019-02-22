###############################################################################
# This function will start the Welcome screen of the                          #
###############################################################################
Welcomefct <- function(){
  ##################################################
  ### Title
  ################################################## 
  WelcomeTitle <- gtkLabel()
  WelcomeTitle$setMarkup("<span weight=\"bold\" size=\"x-large\">Welcome to the IBC-grass herbicide GUI!</span>")
  
  ##################################################
  ### Picture of IBCgrass model
  ##################################################
  PicBox <- gtkVBoxNew(F, 1)
  PicBox$setBorderWidth(10)
  WelcomePic <- gtkImageNewFromFile('Input-files/ZOIs.jpg')
  PicBox$add(WelcomePic)
  
  ##################################################
  ### Base information on the GUI
  ##################################################
  WelcomeText <- gtkLabel()
  WelcomeText$setMarkup('This is the graphical user interface (GUI) to run and analyse herbicide impacts on a plant community using the IBCgrass model,
an individual-based and spatially-explicit plant community model. 
A detailed model description can be found in the Manual folder incl. GMP document, ODD proctocoll and DoxyGen model documentation. 
See the user manual for detailed informations on the GUI.

<u>Author of the GUI:</u> 
  Jette Reeg, contact: jreeg@uni-potsdam.de

<u>References of IBCgrass:</u> 
  May F, Grimm V, Jeltsch F. 2009. Reversed effects of grazing on plant diversity: the role 
      of below-ground competition and size symmetry. Oikos 118:1830-1843. doi: 10.1111/j.1600-0706.2009.17724.x
  Weiss L, Pfestorf H, May F, Körner K, Boch S, Fischer M, Müller J, Prati D, Socher SA, Jeltsch F. 2014. Grazing response 
      patterns indicate isolation of semi-natural European grasslands.Oikos 123:599-612 . doi: 10.1111/j.1600-0706.2013.00957.x
  Körner K, Pfestorf H, May F, Jeltsch F. 2014. Modelling the effect of belowground herbivory on grassland diversity. 
      Ecol Modell 273:79-85 . doi: 10.1016/j.ecolmodel.2013.10.025
  Reeg J, Schad T, Preuss TG, Solga A, Körner K, Mihan C, Jeltsch F. 2017. Modelling direct and indirect 
      effects of herbicides on non-target grassland communities. Ecol. Modell. 348, 44-55. doi:10.1016/j.ecolmodel.2017.01.010
  Reeg J, Heine S, Mihan C, Preuss TG, McGee S, Jeltsch F. 2018. Potential impact of effects on reproductive attributes induced 
      by herbicides on a plant community. Environmental Toxicology and Chemistry. doi: 10.1002/etc.4122
  Reeg J, Heine S, Mihan C, McGee S, Preuss TG, Jeltsch F. 2018. Simulation of herbicide impacts on a plant community: 
      comparing model predictions of the plant community model IBC-grass to empirical data. Environ Sci Eur. 30:44. 
      doi: 10.1186/s12302-018-0174-9

<u>Version:</u> 0.1.0')
  
  WelcomeBox <- gtkVBoxNew(F, 1)
  WelcomeBox$setBorderWidth(10)
  WelcomeBox$add(WelcomeText)
  
  ##################################################
  ### buttons 
  ################################################## 
  StartBox <- gtkVBoxNew()
  StartBox$setBorderWidth(10)
  
  # new project
  StartNewButton <- gtkButton('Start new project')
  StartNewButton$setTooltipText('Start a new set of IBC-grass simulations. You will be able to modify several enivronmental and herbicide specific parameters.')
  StartBox$packStart(StartNewButton,fill=F) #button which will start 
  
  StartNewButtonClick <- function(button){
    Welcome$destroy()
    Selection()
  }
  
  gSignalConnect(StartNewButton, "clicked", StartNewButtonClick)
  
  # existing project
  StartExistButton <- gtkButton('Open existing project')
  StartExistButton$setTooltipText('If you saved an earlier simulation, you can look again at the results and analyses.')
  StartBox$packStart(StartExistButton,fill=F) #button which will start 
  
  # start an existing project will open the analyse window of the GUI
  # function checks if the selected folder includes output files of an IBCgrass project
  # warning message if the selected folder does not include an IBCgrass project
  StartExistButtonClick <- function(button){
      dialog <- gtkFileChooserDialog ( title = "Select project" ,
                                       parent = Welcome , action = "select-folder" ,
                                       "gtk-ok" , GtkResponseType [ "ok" ] ,
                                       "gtk-cancel" , GtkResponseType [ "cancel" ] ,
                                       show = FALSE )
      color <-gdkColorToString('white')
      dialog$ModifyBg("normal", color)
      gSignalConnect ( dialog , "response" ,
                       f = function ( dialog , response , data ) {
                         if ( response == GtkResponseType [ "ok" ] ) {
                           # copy all files to that location
                           filename <- dialog$getFilename ( )
                           setwd(filename)
                           if ("effect.timestep.PFT.txt" %in% list.files()){
                             Welcome$destroy()
                           Results()
                           } else{
                             setwd('..')
                             dialog1 <- gtkMessageDialog(parent=NULL,
                                                        flags = "destroy-with-parent",
                                                        type="question" ,
                                                        buttons="ok" ,
                                                        "The folder you have chosen does not include an IBC project.")
                             gSignalConnect (dialog1, "response", function(dialog1, response, user.data){ dialog1$Destroy()})
                           }
                           
                         }
                         dialog$destroy ( )
                       } )
      dialog$run()
      }
  
  gSignalConnect(StartExistButton, "clicked", StartExistButtonClick)
  
  # exit the GUI
  ExitButton <- gtkButton('Exit IBC-grass')
  ExitButton$setTooltipText('Exit the IBC-grass GUI.')
  StartBox$packStart(ExitButton,fill=F) #button which will start 
  
  # function will close the GUI and deletes all files of the current session, that are not saved previously
  ExitButtonClick <- function(button){
    Welcome$destroy()
    assign("GUIopen", "close", envir = IBCvariables)
    rm(list=ls())
    gc()
    if (length(list.files("currentSimulation/"))>0){
      setwd('currentSimulation')
      unlink(list.files(getwd()), recursive=TRUE)
      setwd('..')
    }
    to.remove <- list.files(getwd())
    to.keep <- c("ExampleAnalyses", "Model-files", "Input-files", "Manual, GMP, ODD, Literature", "R", "R-files", "IBCgrassGUI.log", "RunIBCgrassGUI_Windows.bat", "RunIBCgrassGUI_Linux.sh")
    to.remove <- to.remove[!(to.remove %in% to.keep)]
    unlink(to.remove, recursive=TRUE)
  }
  
  gSignalConnect(ExitButton, "clicked", ExitButtonClick)
  
  ##################################################
  ### put all parts of the window together
  ##################################################
  BaseInformationBox <- gtkVBoxNew(F, 1) # a new box
  BaseInformationBox$setBorderWidth(10)
  BaseInformationBox$packStart(WelcomeTitle)
  BaseInformationBox$packStart(PicBox)   
  BaseInformationBox$packStart(WelcomeBox)
  BaseInformationBox$packStart(StartBox)   
  
  Welcome <- gtkWindow(show=F)
  Welcome$setPosition('GTK_WIN_POS_CENTER')
  Welcome["title"] <- "IBC-grass 2.0"
  color <-gdkColorToString('white')
  Welcome$ModifyBg("normal", color)
  Welcome$add(BaseInformationBox)
  
  Welcome$show()
  # make sure the GUI will not close
  while(get("GUIopen", envir=IBCvariables)=="open") Sys.sleep(1)
}