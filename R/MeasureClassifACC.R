#' @title Accuracy Classification Measure
#'
#' @aliases mlr_measures_classif.acc
#' @format [R6::R6Class()] inheriting from [MeasureClassif].
#' @include MeasureClassif.R
#'
#' @description
#' Calls [Metrics::accuracy()].
#'
#' @export
MeasureClassifACC = R6Class("MeasureClassifACC",
  inherit = MeasureClassif,
  cloneable = FALSE,
  public = list(
    initialize = function() {
      super$initialize(
        id = "classif.acc",
        range = 0:1,
        minimize = FALSE,
        packages = "Metrics"
      )
    },

    calculate = function(experiment = NULL, prediction = experiment$prediction) {
      Metrics::accuracy(actual = prediction$truth, predicted = prediction$response)
    }
  )
)
