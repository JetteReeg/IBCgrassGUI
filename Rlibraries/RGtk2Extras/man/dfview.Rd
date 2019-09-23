\name{dfview}
\alias{dfview}
\title{Convenience function for viewing a data frame in its own window}
\usage{dfview(items, 
dataset.name = deparse(substitute(items)), 
size=c(600, 300), col.width=64, 
editable=FALSE, 
autosize = is.null(dim(items)) || ncol(items) < 25,
update=FALSE)}
\description{Convenience function for viewing a data frame in a window.}
\details{IF set to NULL, is the name of the dataset.}
\value{Returns the edited data frame after running modally}
\arguments{\item{items}{The data frame to edit}
\item{dataset.name}{Optional name to assign the dataset when updating}
\item{size}{Optional window size request}
\item{col.width}{Optional column size}
\item{editable}{Allow user editing of the frame}
\item{autosize}{Columns automatically size to fit headers}
\item{update}{Update the data frame on the fly}
}        

