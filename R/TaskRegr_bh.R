#' @title Boston Housing Regression Task
#'
#' @name mlr_tasks_bh
#' @format [R6::R6Class] inheriting from [TaskRegr].
#' @include mlr_tasks.R
#'
#' @section Usage:
#' ```
#' mlr_tasks$get("bh")
#' ```
#'
#' @description
#' A regression task for the [mlbench::BostonHousing2] data set.
NULL

load_task_bh = function(id = "bh") {
  b = as_data_backend(load_dataset("BostonHousing2", "mlbench"))
  b$hash = "_mlr3_tasks_bh_"
  TaskRegr$new(id, b, target = "medv")
}
