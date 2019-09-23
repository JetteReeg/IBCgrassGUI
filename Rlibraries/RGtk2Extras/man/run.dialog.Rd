\name{run.dialog}
\alias{run.dialog}
\title{Simple Dialog Maker package for RGtk2}
\description{
  An RGtk2/gWidgetsRGtk2 based package for quick and easy dialog development.
}
\usage{
run.dialog(func, 
   pos = -1,
   envir = as.environment(pos),
   dlg.list = tryCatch(
   get(paste(func.name, "dialog", sep="."), 
   envir=envir), 
   error =function(e) NULL),   
   var.browser=NULL,
   parent.window=NULL, 
   auto.assign=TRUE, 
   do.long.running=FALSE,
   OK_handler= default.handler,
   output.name.rule = "append",
   output.name = NULL,
   do.logging = TRUE,
   log.handler = NULL,
   user.args = NULL,
   ...)
}
\arguments{
  \item{func}{Function to be run when "OK" is pressed}
  \item{pos}{where to look for the dialog markup (see the details section)}
  \item{envir}{alternative specification of environment} 
  \item{dlg.list}{Optional list containing dialog markup}
  \item{var.browser}{An optional gWidgets gvarbrowser}
  \item{parent.window}{An optional parent window to set modal}
  \item{auto.assign}{Assign the function return value, if it 
    exists, to the global environment with an automatically assigned name}
  \item{output.name.rule}{Rule for assigning output name}
  \item{do.long.running}{Use long running task routine for Windows}
  \item{OK_handler}{Function to pass do.call(func, args to)}
  \item{output.name}{Name of return value; overrides 
    auto.assign and output.name.rule}
  \item{do.logging}{Send the deparsed function call to an external function?}
  \item{log.handler}{Function to take the deparsed function call}
  \item{user.args}{Optional values to pass to the dialog which overrule those in dialog}  
  \item{\dots}{Additional arguments}
}
\details{
  
  This package is intended to assist rapid development of simple
  dialogs to serve as front-ends to existing R functions. It is a riff 
  off (or rip off) of ideas from John Verzani's traitr toolkit where 
  flexibility is sacrificed for ease of use. Complex layouts are not 
  supported; this package is for getting things working quickly, not
  necessarily looking beautiful.

  To create a working dialog that calls a function, a corresponding markup list is needed specifying how each argument of 
  the function should look on the screen - in other words, what widgets to use. Then \code{run.dialog()} 
  can be called on the function.

  \bold{Calling \code{run.dialog()}}

  If your function is called \code{MyFunction} and the markup list is called 
  \code{MyFunction.dialog} or \code{.MyFunction.dialog} then calling
  \code{run.dialog(MyFunction)} will attempt to locate the corresponding markup list and create and show the dialog. When the user presses "OK" 
  the dialog will call the function with the specified arguments.

  The dialog will be modal and centered on the gtkWindow parent.window if this 
 is specified. The R main loop will be blocked until the dialog is destroyed.

  Alternatively, run.dialog(MyFunction, 
dlg.list=MyMarkupList) will
  explicitly specify the dialog markup list for \code{MyFunction}.

  \bold{Return Values}\cr
  \code{run.dialog()} returns a list 
  containing \code{retval} and \code{args}, where retval is the return value
  of the function call and args is a list containing the named arguments 
  specified from the dialog.

  \bold{Dialog Markup Specification}

  For a function MyFunction with signature
 
  \code{MyFunction = function(arg1, arg2, ...)} 
  
  the dialog markup list is specified by
  
  MyFunction.dialog = list(\cr
   dialog_markup = value0, ...,\cr
   arg1.dialogItem1 = value_of_arg1, markup1 = value1, ...,\cr
   arg2.dialogItem2 = value_of_arg2, markup2 = value2, ...,\cr
   ...\cr
 )\cr

 The only necessary items in the markup list are those of form 

\code{argn.dialogItem = value_of_argn}

The name \code{arg1.dialogItem} in the MyFunction.dialog markup list  
 tells \code{run.dialog()} to display a widget of type \code{dialogItem} corresponding to \code{arg1}.  This widget is initialized 
 to \code{value_of_arg1} and passes this value as the \code{arg1} parameter to \code{MyFunction} when "OK" is clicked.
  
 Optional markup elements that affect the entire dialog 
 are specified by \code{dialog_markup} items before the first \code{arg.dialogItem}, 
 and markup elements affecting individual dialogItems are specified between them and the
 next dialogItem (or in the case of the last item, the end of the list).\cr
 
 dialogItem can be any one of the following: integerItem, numericItem, 
  rangeItem, stringItem, 
  trueFalseItem, choiceItem, 
  radiobuttonItem, objectItem, 
  dataframeItem, fileItem,
  variableSelectorItem, listItem, 
  buttonItem. Each of these Items displays a different commonly used dialog GUI widget which 
 are listed below.

 Most widgets are also set into a small rectangular frame which contains a label. By default the label is set to the name of the corresponding function argument, but this can be set using the \code{label} markup.

 The widgets are laid out very simply within the dialog GUI, set top to bottom in 
 a column. If the column layout is told to break using the \code{BREAK=TRUE} markup, 
 another column is added to the left hand side and the widgets after that point are laid out into the new column. An optional label for the entire
 dialog can be added to the top over all columns.\cr

\bold{Markup}\cr

   \bold{Markups affecting the entire dialog}\cr
  These are set before the first 
   \code{arg.dialogItem}\cr

 \code{label = "This GUI does x"} sets the label centered over all columns.\cr

 \code{title = "My Function"} sets the title of the dialog window.\cr

 \code{keep.open = TRUE} tells the dialog to stay open after "OK" is pressed.\cr
   This can be useful if your function plots something, and the user 
   is likely to want to try different plot settings.\cr

 \code{show.progress = TRUE} tells run.dialog that the function should display 
  a dialog while it is executing to allow monitoring of progress and cancellation.
  This is based on Felix Andrews' interrupt.c from playwith. If this markup is 
  present then when "OK" is pressed a small modal Progress dialog will appear 
  with a cancel button. When this button is pressed, an interrupt signal is sent 
  and the Progress dialog is destroyed and the main dialog is destroyed if 
  appropriate. This is not guaranteed to stop all running R processes.
  Moreover, if your function arguments contain \code{progressbar} or \code{progresslabel},
  then \code{run.dialog} will pass your function a gtkProgressBar and a gtkLabel
  respectively, to allow user monitoring of progress via \code{progressbar$setFraction()}
  or \code{progressbar$setText()}. See ?gtkProgressBar and ?gtkLabel. \cr
  Note 1: if your function updates the progress bar or progress label, it should
  give these arguments default NULL values and check they are not missing before
  using them, otherwise it will break if run without a dialog.\cr
  Note 2: if your dialog markup (as opposed to your function) contains progressbar 
  or progresslabel arguments, then run.dialog will not pass those widgets to 
  your function automatically.\cr

                     
 \code{long.running = TRUE} tells run.dialog that the function will 
  run for a long time before returning. This is fairly experimental, and doesn't
  work anywhere but Windows yet. In Windows, it will do the following things:\cr
   1. Save the R session to the current working directory.\cr
   2. Create a batch file containing a command to load the R session,
     delete the session file, carry out the function call, and a command 
     to save the session after the function returns.\cr
   3. Spawn a separate R process and call \code{exec(R CMD BATCH batch_file)} to 
     perform the function, and record that process's process ID (PID).\cr
   4. Show a modal window over the dialog with an endlessly repeating 
     progress bar, and a Cancel button. If the Cancel button is pressed, it
     will kill the spawned R process using \code{taskkill PID} 
     and close the progress window. \cr
   5. Monitor periodically for the saved session file to appear in the 
     working directory, and then load the session file and close the 
     progress window.\cr

 \bold{Dialog markups that work for all items}\cr

 \code{arg_name.dialogItem = arg_value} sets the dialog item value, OR,\cr
   \code{arg_name.dialogItem = substitute(expression)}\cr 
   sets the value of the widget to the evaluated expression.\cr

 \code{label = "This widget specifies x"} sets the label for the widget frame.

 \code{tooltip = "the tooltip string"} sets a tooltip over the dialog item

 \code{BREAK = TRUE} stops adding widgets to the end of the column and 
  starts a new column.

 \code{indent= 10} adds a 10 pixel indentation to the left hand side of 
  the widget frame which can be useful to show hierarchical organization. signal = c(signal_type, signal_function, 
   widget1, widget2, ...,  user_data=NULL) specifies a widget signal (see below). More than one signal can be 
  set for each widget.\cr

 \code{signal.at.startup = FALSE} will NOT send the "default" signal from
  this dialog element when the dialog is initialized.\cr

 \code{set.sensitive=FALSE} will gray out the corresponding widget\cr

 \code{suppress=TRUE} will prevent the widget's value from being passed to the 
   function. This is useful for "dummy" widgets that contain lists of values
   to choose from.\cr

 \code{visible=FALSE} will just not display the widget. Its value will still 
  be passed to the function and it can be called normally by signaling functions.\cr
   
 \bold{Dialog Items}\cr

  This is a list of the currently available widgets that can be specified 
  using markup, together with additional markup that can be used to specify 
  their behavior. \cr

  As well as that, there are set.value() and get.value() methods that work on 
  most widgets, and also signals which they can emit (see Signal Handling).
  set.value() takes an optional \code{propagate} argument which is TRUE by 
  default. If this is set to FALSE, then the widget won't emit its signal.\cr
  
  This list specifies what the set.value and get.value methods return for each
  widget and what behavior leads to each widget emitting a signal.\cr

  stringItem: An entry box which can take text input.\cr
\code{x.stringItem = "hi there"}\cr
 Set and Get Calls:\cr
   get.value(item) returns the string value.\cr
 Signals:\cr
   "default" is emitted when Enter is pressed.\cr

 numericItem: A stringItem which coerces the value to a number.\cr
\code{x.numericItem = 1.3}\cr 
Set and Get Calls:\cr
   get.value(item) returns the numeric value.\cr

 rangeItem: A horizontal slider for returning a numeric value.\cr
 \code{x.rangeItem = c(value=1, from=0, to=2, by=0.1)}\cr
 The value sets the value, min, max and step.\cr
 Set and Get Calls:\cr
   get.value(item) returns the numeric value.\cr
 Signals:\cr
   "default" is emitted when the range is altered.\cr

 integerItem: a spin button which takes an integer value.\cr
 \code{z.integerItem = 1}\cr
 \code{z.integerItem = c(value=1, from=0, to=10, by=1)}\cr
 Set and Get Calls:\cr
   get.value(item) returns the integer value.\cr
 The value can be specified in two ways, first using a single number, \cr
   second with a named vector containing the value and the min, max and
   step of the spin button.\cr

 trueFalseItem: A check box.\cr
 \code{an.option.trueFalseItem = TRUE}\cr
 This widget will not be put in a frame but rather have its label set to 
 any label markup.\cr
 Set and Get Calls:\cr
   get.value(item) returns the check box state.\cr
   set.value(item, value, propagate=TRUE) sets the item to the logical value.\cr
 Signals:\cr
   "default" is emitted when the check box is changed.\cr
 
 choiceItem: A combo box allowing selection of a value. \cr
 \code{x.choiceItem = c(choice1, value=choice2, choice3, ...)} \cr
   where "value=" sets the initial choice.     \cr
 Additional markup: \cr
 by.index=T will return the selected indices rather than their strings.\cr
 item.labels = c("A", "B", "C") will display the choices as these labels
   rather than the values given.
 The item.labels vector must be the same length as the values vector if it exists.\cr 
 Set and Get Calls:\cr
   get.value(item) returns the selected choice.\cr
   get.value(item, selected=F) returns all of the choices in the choiceItem.\cr
   set.value(item, value, propagate=TRUE) sets the available choices in the choiceItem to 
    the vector (or possibly NULL) value.\cr
 Signals:\cr
   "default" is emitted when the selection is changed. Note that popping up 
   the list box will not signal.\cr

 radiobuttonItem: Identically specified to choiceItem but shows radio 
  buttons rather than a combo box. Better for small numbers of choices
  or longer choice names. Also, the choices in radiobuttonItem cannot be
  changed using set.value(), unlike choiceItem.\cr
 Markup for radiobuttonItem is the same as choiceItem.\cr
 Set and Get Calls:\cr
   get.value(item) returns the selected choice.\cr
   set.value(item, value, propagate=TRUE) sets the item to the value and throws an 
     error if it is not one of the available choices.\cr
 Signals:\cr
     "default" is emitted when the selection is changed.\cr
 fileItem: a label and a button. When the button is pressed a
  file name can be selected or typed in.\cr
 \code{fileName.fileItem = "C:/R/test.R"}\cr
   Additional markup:\cr
  extension = "xls" opens *.xls\cr
  type = "open", "save", "selectdir" gives options to open, save 
   or select directories\cr
  multiple = TRUE allows multiple file selection 
   (not compatible with type = "selectdir")\cr
  Set and Get Calls:\cr
    get.value(item) returns a string or vector of strings 
      corresponding to the selected files or directories.\cr
    No set.value() call yet.\cr
  Signals:\cr
     "default" is emitted when any file is selected.\cr

  objectItem: a label and a button. When the button is pressed a 
    chooser dialog opens allowing selection of objects from the global
    environment (using a gWidgets gvarbrowser) on either double 
    click or select and close.\cr
  Its value is a string containing the name of the default object, 
   otherwise NULL or "".\cr
  \code{data.objectItem = "iris"}\cr
  Additional markup: \cr
    data.types ="list" specifies a list of data types. If your selected object 
      from the chooser doesn't match that type, it won't change the selected 
      value.\cr
    as.character =TRUE means that the name of the selected dataset rather 
      than the symbol will get passed back to the function.\cr
  Set and Get Calls:\cr
    get.value(item) returns the selected object name(the string) rather than 
    the object itself. This is slightly inconsistent with objectItem's 
    default returned value to the function which is the object symbol. 
    No set.value() call yet.\cr
  Signals:\cr
     "default" is emitted when any object is selected.\cr

  dataframeItem: identical to objectItem with default data.type markup of 
    c("data.frame", "matrix"). Also, if a 
    gWidgetsRGtk2 gvarbrowser is specified 
    in run.dialog(..., var.browser), 
    the FIRST dataframeItem 
    in the dialog will have its value set to any 
    dataframe or array selected 
    in the gvarbrowser.\cr
   
   variableSelectorItem: a widget which displays a list with checkboxes to
   choose a subset of strings. The check box column header is labeled 
   "Select All" and clicking it will alternate between selecting and deselecting 
   all items.\cr

   \code{myColumns.variableSelectorItem = letters[1:5]}\cr
   \code{myColumns.variableSelectorItem = substitute(colnames(iris))}\cr
   A variableSelectorItem will pass to the function a 
    (possibly zero-length) vector containing the selected strings.\cr
  Set and Get Calls:\cr
    get.value(item) returns the selected values.\cr
    set.value(item, letters[1:5], propagate=TRUE) sets the values in the item.\cr
   Signals:\cr
     "default" is emitted when the check boxes are altered anywhere.\cr


  listItem: an widget containing a simple list box set in a panel with 
    buttons labeled with right and left arrows next to it.\cr
    The list allows multiple selections.\cr
  \code{myColumns.listItem = substitute(colnames(iris))}\cr
  \code{nothingYet.listItem = NULL}\cr
  Additional markup:\cr
   show.arrows = FALSE turns displaying the arrow buttons off.\cr
   max.items = 2 sets the maximum number of items the listItem can 
    contain to 2.\cr
  Set and Get Calls:\cr
    get.value(item, select=TRUE) returns the selected values only.\cr
    get.value(item, select=FALSE) returns all values.\cr
    set.value(item, letters[1:5], propagate=TRUE) sets the values in the list item.\cr
  Signals:\cr
   "default" is emitted when the list is clicked anywhere.\cr
   "add" is emitted when the right-arrow button is clicked.\cr
   "subtract" is emitted when the left-arrow button is clicked.\cr
  \cr
  buttonItem: a frameless button.\cr
  \code{button.buttonItem = "Click Me"}\cr
  Set and Get Calls:\cr
    None, yet.\cr
  Signals:\cr
   "clicked" is emitted when the button is clicked.\cr
   
   \bold{Dot Arguments}\cr
  If a markup item called ....stringItem is present, run.dialog() will 
  display it as a stringItem widget with an "Additional Arguments" label.\cr 
  When the dialog "OK" is clicked run.dialog() will run 
  eval(parse(text=get.value(text))) on whatever text is put in that markup,
  then place any additional items as additional arguments to the function.\cr


 \bold{Signaling}
  Signal handling can be specified to support some commonly required
  function dialog behaviors. For example, deselecting a checkbox might set
  another widget to insensitive (grayed out), or some items might be moved 
  between list boxes.\cr\cr

  Signaling is specified using the signaling markup, set after a dialog item: signal = c(signal_type, 
    signal_function, 
    widget1_arg, widget2_arg, ..., user_data=NULL)
  containing the following specifications:

  signal_type is a string, for example "default", "clicked", etc.\cr
   All the dialogItems will broadcast a signal called "default" 
   whenever something happens to them corresponding to a user interaction.\cr 
   This is usually what you're going to want to connect a signal to, but
   there are exceptions.\cr
  signal_function is a function or a name of a function visible in the environment run.dialog is called from. It has this signature:\cr
    
    signal_function(item, widget1, widget2, ..., user_data=NULL)\cr
      item is the widget that sent the signal;\cr
      widget1, widget2 are GtkWidget objects specified by ;\cr
      user_data is the optionally specified user data\cr\cr

  widget1_arg, widget2_arg, ... are the function argument strings 
   corresponding to the widgets being passed to the signal_function.\cr

  user_data is optional additional data to send to the function.\cr

  Within your signal_function, you're going to want to be able to get and 
  set the values your widgets take. \cr

  You can do this using the \code{get.value(widget)} and 
  \code{set.value(widget)} calls. In some cases these calls can take 
  additional arguments. See the DensityHistogram example below.\cr
      
  Actually, we could use the built-in function toggle.sensitive which does the
  same thing (the commented-out #signal line). In this case, passing a string
  as the signaling function will make run.dialog search for a function with this 
  name.\cr

  One further question is, how does run.dialog set the rangeItem to be 
  insensitive the first time it opens? By default, run.dialog()
  calls the "default" signal from every one of the widgets when it opens, 
  unless either \cr
    (a) they are set to being insensitive or \cr
    (b) the widget signal.on.startup markup is set to FALSE.\cr\cr

  Because the default signal from some widgets can set others to being
  insensitive, this allows reasonable behavior for hierarchically grouped
  toggled sensitive widgets. On the other hand, it may still be desirable to
  prevent widgets firing their signals when the dialog is starting,
  for example if you have many widgets performing some action like refreshing a
  list. In this case, setting signal.on.startup to FALSE for most of them
  should fix that problem.\cr\cr

}

\examples{
\dontrun{
 # A simple histogram plotting example:
  SimpleHistogram = function(N) hist(rnorm(N))

  SimpleHistogram.dialog = list(label = "A density-plotting histogram dialog",
   N.integerItem = 50, label = "Value of N")

  run.dialog(SimpleHistogram) 
 # end example
 
 # example 2
   # Function to plot a histogram, optionally adding a density plot with
   # adjustable bandwidth. If add.density is false, gray out the bandwidth range.

   # This is what's going on in the "signal" markup from the add.density widget:
     # We specify the "default" signal from the add.density trueFalseItem
     # Then specify the signal function, which takes the add.density 
     # trueFalseItem as its first argument and the bw.rangeItem 
     # as its second. In the function, we first of all
     # get the value of the trueFalseItem (which is TRUE or FALSE)
     # and call gtkWidgetSetSensitive on bw.widget with this value
     # (see the RGtk Help for gtkWidget)
     # The last element of the signal markup is the string "bw"
     # which run.dialog() replaces with the corresponding bw.rangeItem and
     # passes to the called signal function as its second argument.

  DensityHistogram = function(N, add.density, bw=NULL)
  \{
     x <- rnorm(N)
     hist(x, probability=add.density)
     if(add.density) points(density(x, bw=bw), type = "l")
  \}

  DensityHistogram.dialog = list(
   #keep.open = TRUE, # uncomment to keep the dialog open
   label = "A density-plotting histogram dialog",
   N.integerItem = c(value=100, from=10, to=1000, by=10), label = "Value of X",
   add.density.trueFalseItem = FALSE, label = "Add Density Plot?",
     signal = c("default", 
       function(item, bw.widget) bw.widget$setSensitive(get.value(item)), "bw"),
    # signal = c("default", "toggle.sensitive", "bw"), # using the built-in
   bw.rangeItem = c(value=0.3, from=0, to=2, by=0.05), label = "Bandwidth")

  run.dialog(DensityHistogram)
  # end example 2
  
    # Angle display demo, from Graham Williams
  demo(MakeAngle)
  
    # Cancel dialog demo
  demo(ProgressBar)

}

}
\keyword{interface}
