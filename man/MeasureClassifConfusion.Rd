% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MeasureClassifConfusion.R
\docType{data}
\name{MeasureClassifConfusion}
\alias{MeasureClassifConfusion}
\alias{mlr_measures_classif.confusion}
\alias{mlr_measures_classif.tp}
\alias{mlr_measures_classif.fn}
\alias{mlr_measures_classif.fp}
\alias{mlr_measures_classif.tn}
\alias{mlr_measures_classif.tpr}
\alias{mlr_measures_classif.fnr}
\alias{mlr_measures_classif.fpr}
\alias{mlr_measures_classif.tnr}
\alias{mlr_measures_classif.ppv}
\alias{mlr_measures_classif.fdr}
\alias{mlr_measures_classif.for}
\alias{mlr_measures_classif.npv}
\alias{mlr_measures_classif.precision}
\alias{mlr_measures_classif.recall}
\alias{mlr_measures_classif.sensitivity}
\alias{mlr_measures_classif.specificity}
\alias{confusion_measures}
\title{Binary Classification Measures Derived from a Confusion Matrix}
\format{\code{\link[R6:R6Class]{R6::R6Class()}} inheriting from \link{MeasureClassif}.}
\usage{
MeasureClassifConfusion

confusion_measures(m, type = NULL)
}
\arguments{
\item{m}{(\code{matrix()})\cr
Confusion matrix, e.g. as returned by field \code{confusion} of \link{PredictionClassif}.
Truth is in columns, predicted response is in rows.}

\item{type}{(\code{character()})\cr
Selects the measure to use. See description.}
}
\description{
Based on a confusion matrix for binary classification problems, allows to calculate various performance measures.
Implemented are the following measures based on \url{https://en.wikipedia.org/wiki/Template:DiagnosticTesting_Diagram}:
\itemize{
\item \code{"tp"}: True Positives.
\item \code{"fn"}: False Negatives.
\item \code{"fp"}: False Positives.
\item \code{"tn"}: True Negatives.
\item \code{"tpr"}: True Positive Rate.
\item \code{"fnr"}: False Negative Rate.
\item \code{"fpr"}: False Positive Rate.
\item \code{"tnr"}: True Negative Rate.
\item \code{"ppv"}: Positive Predictive Value.
\item \code{"fdr"}: False Discovery Rate.
\item \code{"for"}: False Omission Rate.
\item \code{"npv"}: Negative Predictive Value.
\item \code{"precision"}: Alias for \code{"ppv"}.
\item \code{"recall"}: Alias for \code{"tpr"}.
\item \code{"sensitivity"}: Alias for \code{"tpr"}.
\item \code{"specificity"}: Alias for \code{"tnr"}.
}

If the denominator is 0, the score is returned as \code{NA}.
}
\examples{
task = mlr_tasks$get("wine")
e = Experiment$new("wine", "classif.rpart")$train()$predict()
m = e$prediction$confusion
confusion_measures(m, type = c("precision", "recall"))
}
\keyword{datasets}
