\name{my_choose_files}
\alias{my_choose_files}
\title{Return all tables}
\description{
Platform independent file chooser
}
\usage{
my_choose_files(fn = "*.*", 
multi=FALSE, 
filters=NULL, 
type = "open", 
caption=NULL)
}
\arguments{
\item{fn}{filename}
\item{multi}{multiple}
\item{filters}{Win filters}
\item{type}{type of dialog}
\item{caption}{optional dialog caption}
}
\details{
This is a wrapper which allows the user to select a file under Windows, Mac and
  Linux. The type can be "open", "save" or "selectdir". Multiple selectdir 
  isn't supported.
}
\keyword{interface}
