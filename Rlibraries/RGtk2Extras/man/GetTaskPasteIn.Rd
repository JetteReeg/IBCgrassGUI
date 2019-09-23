\name{GetTaskPasteIn}
\alias{GetTaskPasteIn}
\title{Return all tables}
\description{
This function returns a list of all tables in .GlobalEnv, 
including those within lists.
}
\usage{
GetTaskPasteIn(theFrame, dat, 
insert.row, insert.col, 
do.rownames=F, 
do.colnames=F, 
do.coercion=T)
}
\arguments{
\item{theFrame}{Dataset to use}
\item{dat}{insertion frame}
\item{insert.row}{row to insert}
\item{insert.col}{col to insert}
\item{do.rownames}{do colnames}
\item{do.colnames}{do colnames}
\item{do.coercion}{coercion}
}
\details{
This is a helper function used to generate a task list to allow reversible 
  pasting of data into the frame.
}
\keyword{interface}
