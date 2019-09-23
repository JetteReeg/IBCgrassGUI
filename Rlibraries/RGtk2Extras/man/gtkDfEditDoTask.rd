\name{gtkDfEditDoTask}
\alias{gtkDfEditDoTask}
\title{Editor change handling.}
\usage{gtkDfEditDoTask(x, task)}
\description{Implement defined spreadsheet actions}
\arguments{
\item{x}{The RGtk2DfEdit object}
\item{task}{The task list to implement.}
}
\note{
An action item is a list containing the action function name and its arguments: 

\code{list(func=action.name, arg=list(arg1=value1, arg2=value2, ...))}

A task is a list of one or more action items.

When the task is passed to \code{x$doTask} the backing data frame will be 
updated sequentially with each action and the model updated after the action 
list is complete. This way, sequences of commands can be built up, performed 
and undone in a single step.

The following action names and function argument lists are available.
                                        
ChangeCells: function(nf, row.idx, col.idx, do.coercion=T)

SetFactorAttributes: function(idx, info)

CoerceColumns: function(theClasses, idx)

ChangeColumnNames: function(theNames, idx)

ChangeRowNames: function(theNames, idx)

DeleteRows: function(idx) 

InsertRows: function(nf, idx)

InsertNARows: function(idx)

DeleteColumns: function(idx) 

InsertColumns: function(nf, idx)

InsertNAColumns: function(idx, NA.opt="")   

nf is the new data frame being passed to the function, if any.

do.coercion is the flag which tells the editor whether to coerce the new frame 
(nf) to the type of the old data frame or not.

theClasses and theNames are the new classes or new names being applied to the 
function.

idx is the indices at which to insert or change new columns or rows, or column 
or row names.

theNames and theClasses must have the same length as idx, and when "nf" is 
present nf must have the same number of rows as idx if InsertColumns is called, 
and the same number of columns as idx if InsertRows is being called.

info is a list of form list(levels, contrasts, contrast.names). contrasts and 
contrast.names may or may not be present.

NA.opt is an optional NA to pass to InsertNAColumns to coerce to a particular
type, for example NA.opt=NA_real_ will make the NA columns inserted numeric.
}

\examples{

win = gtkWindowNew("gtkDfEdit Demo")
obj <- gtkDfEdit(iris)
win$add(obj)
win$show()


task <- list(
  list(func="ChangeCells", 
    arg=list(nf=array(4, c(2,2)), row.idx=1:2, col.idx=1:2))
)

obj$doTask(task)

task <- list(
  list(func="InsertRows", 
     arg=list(nf=iris[1,], row.idx=1))
)
obj$doTask(task)
obj$undo()

task <- list(
  list(func="InsertColumns", 
     arg=list(nf=iris[,1], col.idx=1))
)

obj$doTask(task)
obj$undo()

task <- list(
  list(func="InsertNARows", arg=list(row.idx=2)),
  list(func="InsertNAColumns", arg=list(col.idx=2))
)

obj$doTask(task)
obj$undo()

task <- list(
  list(func="ChangeRowNames", 
     arg=list(theNames=c("hi", "there"), row.idx=1:2))
)

obj$doTask(task)

task <- list(
  list(func="ChangeColumnNames", 
arg=list(theNames=c("1", "2"), 
col.idx=2:3))
)

obj$doTask(task)

task <- list(
  list(func="CoerceColumns", 
    arg=list(theClasses = c("character", "integer"), col.idx=1:2))
)
obj$doTask(task)

}
