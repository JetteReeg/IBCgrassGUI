\name{set.value}
\alias{set.value}
\title{Set widget value}
\description{
generic value setting method
}
\usage{
set.value(dlg.item, ...)
}
\arguments{
\item{dlg.item}{gtkWidget}
\item{...}{args}
}
\details{
Complementary to get.value(), this is the generic function for setting the value
of a widget. See ?run.dialog for details.
set.value comes with an optional \code{propagate} argument which is TRUE by
default. If it's set to FALSE, then calling \code{set.value(widget, value, propagate=FALSE)}
will not trigger the widgets's \code{default} signal if this is bound, which
can be useful for more complex behaviors.
}
\keyword{interface}
