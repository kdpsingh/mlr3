% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Generator.R
\docType{data}
\name{Generator}
\alias{Generator}
\title{Generator Class}
\format{\link[R6:R6Class]{R6::R6Class} object.}
\description{
Creates a \link{Task} of arbitrary size.
Predefined task generators are stored in \link{mlr_generators}.
}
\section{Construction}{
\preformatted{g = Generator$new(id, task_type, packages = character(0L), param_set = ParamSet$new(), param_vals = list())
}
\itemize{
\item \code{id} :: \code{character(1)}\cr
Identifier for the learner.
\item \code{task_type} :: \code{character(1)}\cr
Type of the task the learner can operator on. E.g., \code{"classif"} or \code{"regr"}.
\item \code{packages} :: \code{character()}\cr
Set of required packages.
Note that these packages will be loaded via \code{\link[=requireNamespace]{requireNamespace()}}, and are not attached.
\item \code{param_set} :: \link[paradox:ParamSet]{paradox::ParamSet}\cr
Set of hyperparameters.
\item \code{param_vals} :: named \code{list()}\cr
List of hyperparameter settings.
}
}

\section{Fields}{

\itemize{
\item \code{id} :: \code{character(1)}\cr
Stores the identifier of the learner.
\item \code{packages} :: \code{character()}\cr
Stores the names of required packages.
\item \code{param_set} :: \link[paradox:ParamSet]{paradox::ParamSet}\cr
Description of available hyperparameters and hyperparameter settings.
\item \code{task_type} :: \code{character(1)}\cr
Stores the type of class this learner can operate on, e.g. \code{"classif"} or \code{"regr"}.
A complete list of task types is stored in \code{mlr_reflections$task_types}.
}
}

\section{Methods}{

\itemize{
\item \code{generate(n)}\cr
\code{integer(1)} -> \link{Task}\cr
Creates a task of type \code{task_type} with \code{n} observations, possibly using additional settings stored in \code{param_set}.
}
}

\concept{Generators}
\keyword{datasets}
