\name{safe.eval}
\alias{safe.eval}
\title{Return all tables}
\description{
Equivalent to get(x) for x of the form (i) "object" (ii) "list\$object"
}
\usage{
safe.eval(text, envir=parent.env(environment()))
}
\arguments{
\item{text}{text to eval}
\item{envir}{env to evaluate in}
}
\details{
Evaluates get(x) for x of the form (i) "object" (ii) "list\$object"
}
\keyword{interface}
