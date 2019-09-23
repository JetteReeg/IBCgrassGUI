\name{dfedit}
\alias{dfedit}
\title{Convenience function for editing a data frame in its own window}
\usage{dfedit(items, 
dataset.name = deparse(substitute(items)), 
size=c(600, 300), col.width=64, 
editable=TRUE,   
autosize = is.null(dim(items))||ncol(items)<25,
update=TRUE, modal=TRUE)}
\description{Convenience function for editing a data frame in a window.}
\details{IF set to NULL, is the name of the dataset.}
\value{Returns the edited data frame after running modally}
\arguments{\item{items}{The data frame to edit}
\item{dataset.name}{Optional name to assign the dataset when updating}
\item{size}{Optional window size request}
\item{col.width}{Optional column size}
\item{editable}{Allow user editing of the frame}
\item{autosize}{Columns automatically size to fit headers}
\item{update}{Update the frame on the fly with editing}
\item{modal}{TRUE for the editor to halt R and return an object}
}        

