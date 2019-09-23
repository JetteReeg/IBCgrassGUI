\name{gtkDfEditSetActionHandler}
\alias{gtkDfEditSetActionHandler}
\title{Setting user defined functions on the editor}
\usage{gtkDfEditSetActionHandler(object, 
func.name, 
handler=NULL, 
data=NULL)}
\description{Set a user function to call when some action is performed}
\details{IF set to NULL, no handler is called.}
\arguments{
\item{object}{The RGtk2DfEdit object}
\item{func.name}{The name of the spreadsheet action which triggers the function.}
\item{handler}{Function to call when the action occurs. Signature varies, see 
below. If NULL (default) no handler is called.}
\item{data}{Optional data to pass to the function.}
}
\note{
The following action names and function signatures for the handler can be used. 
"Selection" means a cell range is selected and a selection rectangle is drawn.
                                  
Selection: function(rows, cols, data=NULL) 

ChangeCells: function(obj, nf, row.idx, col.idx, do.coercion=T, data=NULL)

SetFactorAttributes: function(obj, idx, info, data=NULL)

CoerceColumns: function(obj, theClasses, col.idx, data=NULL)

ChangeColumnNames: function(obj, theNames, col.idx, data=NULL)

ChangeRowNames: function(obj, theNames, row.idx, data=NULL)

DeleteRows: function(obj, row.idx, data=NULL) 

InsertRows: function(obj, nf, row.idx, data=NULL)

InsertNARows: function(obj, row.idx, data=NULL)

DeleteColumns: function(obj, col.idx, data=NULL) 

InsertColumns: function(obj, nf, col.idx, data=NULL)

InsertNAColumns: function(obj, col.idx, NA.opt="", data=NULL)   

obj is the gtkDfEdit object being edited.

data is optional user data to pass to the function.

nf is the new data frame being passed to the function, if any.

do.coercion is the flag which tells the editor whether to coerce the new frame 
(nf) to the type of the old data frame or not.

theClasses and theNames are the new classes or new names being applied to the 
function.

row.idx and col.idx are the row and column indices where the action occurred.

idx is the row or column index where the action occurred, for some actions which
have only one kind of index.

theNames and theClasses must have the same length as idx, and when "nf" is 
present nf must have the same number of rows as idx if InsertColumns is called, 
and the same number of columns as idx if InsertRows is being called.                                         
                                         
info is a list containing factor information of form 
  list(levels, contrasts, contrast.names, is.ordered). contrasts and 
  contrast.names may or may not be present.

NA.opt is an optional NA to pass to InsertNAColumns to coerce to a particular
type, for example NA.opt=NA_real_ will make the NA columns inserted numeric.
}

\examples{

win = gtkWindowNew("gtkDfEdit Demo")
obj <- gtkDfEdit(iris)
win$add(obj)
win$show()

obj$setActionHandler("ChangeCells", 
  handler=function(obj, nf, row.idx, col.idx, do.coercion)
   print(paste("Cells changed at R", 
if(!missing(row.idx)) row.idx, ", C", 
if(!missing(col.idx)) col.idx, sep="")))

obj$setActionHandler("SetFactorAttributes", 
handler=function(obj, col.idx, info) {
print(paste("factor changed at", col.idx, 
"new levels", paste(info$levels, 
collapse=", ")))
})

obj$setActionHandler("CoerceColumns", function(obj, theClasses, col.idx)
print(paste("columns", col.idx, 
"of", obj$getDatasetName(), "coerced to", 
theClasses)))

obj$setActionHandler("ChangeColumnNames", 
function(obj, theNames, col.idx) {
print(paste("column names at", col.idx, 
"changed to", theNames))
})

obj$setActionHandler("ChangeRowNames", function(obj, theNames, row.idx) {
print(paste("row names at", row.idx, 
"changed to", theNames))
})

obj$setActionHandler("DeleteRows", function(obj, row.idx) {
print(paste("rows at", row.idx, "deleted"))
})


obj$setActionHandler("InsertRows", function(obj, nf, row.idx) {
print(paste("rows inserted at", row.idx))
print(nf)
})

obj$setActionHandler("InsertNARows", function(df, row.idx) {
print(paste("rows inserted at", row.idx))
})


obj$setActionHandler("DeleteColumns", function(obj, col.idx) {
print(paste("columns at", col.idx, "deleted"))
})

obj$setActionHandler("InsertColumns", function(obj, nf, col.idx) {
print(paste("cols inserted at", col.idx))
})

obj$setActionHandler("InsertNAColumns", function(obj, nf, col.idx, 
  NA.opt) { print(paste("cols inserted at", col.idx))
})

obj$setActionHandler("Selection", function(obj, row.idx, col.idx) {
  print(paste(paste(length(row.idx), "R", sep=""), 
"x", paste(length(col.idx), 
"C", sep="")))
})

obj$setActionHandler("RowClicked", function(obj, idx) print(obj[idx,]))

obj$setActionHandler("ColumnClicked", function(idx, data) 
  print(obj[,idx]))
}
