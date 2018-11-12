expect_same_address = function(x, y) {
  testthat::expect_identical(data.table::address(x), data.table::address(y))
}

expect_different_address = function(x, y) {
  testthat::expect_false(identical(data.table::address(x), data.table::address(y)))
}

expect_hash = function(x, len = NULL) {
  checkmate::expect_character(x, len = len, any.missing = FALSE, min.chars = 4L, pattern = "^[0-9a-z]{16}$", unique = TRUE)
}

expect_dictionary = function(d, contains = NA_character_, min.items = 0L) {
  checkmate::expect_r6(d, "Dictionary")
  testthat::expect_output(print(d), "Dictionary")
  checkmate::expect_environment(d$items)
  checkmate::expect_character(d$keys(), any.missing = FALSE, min.len = min.items, min.chars = 1L)
  if (!is.na(contains)) {
    checkmate::expect_list(d$mget(d$keys()), types = contains, names = "unique")
  }
}

expect_backend = function(b) {
  checkmate::expect_r6(b, cloneable = FALSE, public = c("nrow", "ncol", "colnames", "rownames", "head", "data"))
  expect_output(print(b), "^DataBackend")

  n = checkmate::expect_count(b$nrow)
  p = checkmate::expect_count(b$ncol)
  cn = checkmate::expect_atomic_vector(b$colnames, any.missing = FALSE, len = p, unique = TRUE)
  rn = checkmate::expect_atomic_vector(b$rownames, any.missing = FALSE, len = n, unique = TRUE)

  x = b$data(rows = rn, cols = cn[1L])
  checkmate::expect_data_table(x, ncol = 1L, nrow = n)
  x = x[[cn[1L]]]
  checkmate::expect_atomic_vector(x, len = n)

  # extra cols are ignored
  x = b$data(rows = rn[1L], cols = c(cn[1L], "_not_existing_"))
  checkmate::expect_data_table(x, nrow = 1L, ncol = 1L)

  # zero cols matching
  x = b$data(rows = rn[1L], cols = "_not_existing_")
  checkmate::expect_data_table(x, nrow = 0L, ncol = 0L)

  # extra rows are ignored
  query_rows = c(rn[1L], if (is.integer(rn)) -1L else "_not_existing_")
  x = b$data(query_rows, cols = cn[1L])
  checkmate::expect_data_table(x, nrow = 1L, ncol = 1L)

  # zero rows matching
  query_rows = if (is.integer(rn)) -1L else "_not_existing_"
  x = b$data(rows = query_rows, cols = cn[1L])
  checkmate::expect_data_table(x, nrow = 0L, ncol = 1L)

  # rows are duplicated
  x = b$data(rows = rep(rn[1L], 2L), cols = b$colnames)
  checkmate::expect_data_table(x, nrow = 2L, ncol = p)

  # rows are returned in the right order
  i = sample(rn, min(n, 10L))
  x = b$data(rows = i, cols = b$primary_key)
  testthat::expect_equal(i, x[[1L]])

  # duplicated cols raise exception
  testthat::expect_error(b$data(rows = rn[1L], cols = rep(cn[1L], 2L)), "uniquely")

  # argument n of head
  checkmate::expect_data_table(b$head(3), nrow = 3, ncol = p)

  # primary_key is distinct
  d = b$distinct(b$primary_key)[[1L]]
  checkmate::expect_atomic_vector(d, len = n)
}

expect_iris_backend = function(b) {
  testthat::expect_equal(b$nrow, 150L)
  testthat::expect_equal(b$ncol, 6L)
  checkmate::expect_set_equal(b$colnames, c(names(iris), b$primary_key))
  checkmate::expect_set_equal(b$rownames, seq_len(150L))

  x = b$head(2)
  checkmate::expect_data_table(x, nrow = 2L, ncol = 6L, any.missing = FALSE)
  checkmate::expect_set_equal(names(x), c(names(iris), b$primary_key))

  x = b$distinct("Species")
  checkmate::expect_list(x, "character", len = 1)
  checkmate::expect_set_equal(x$Species, levels(iris$Species))

  x = b$data(rows = 2:10, cols = c(b$primary_key, "Species", "Sepal.Width"))
  checkmate::expect_data_table(x, nrow = 9L, ncol = 3L)
  checkmate::expect_set_equal(names(x), c(b$primary_key, "Species", "Sepal.Width"))
  checkmate::expect_set_equal(x[[b$primary_key]], 2:10)

  if (is.factor(x$Species))
    checkmate::expect_factor(x$Species, levels = levels(iris$Species))
  else
    checkmate::expect_character(x$Species, any.missing = FALSE)

  testthat::expect_true(all(x$Species == "setosa"))
  checkmate::expect_numeric(x$Sepal.Width, any.missing = FALSE)

  # invalid row ids
  x = b$data(rows = 150:151, cols = c(b$primary_key, "Species"))
  checkmate::expect_data_table(x, nrow = 1L, ncol = 2L)
  testthat::expect_equal(x[[b$primary_key]], 150L)
  testthat::expect_equal(as.character(x[["Species"]]), "virginica")

  # duplicated row ids
  x = b$data(rows = c(1L, 1L), cols = c(b$primary_key, "Species"))
  checkmate::expect_data_table(x, nrow = 2L, ncol = 2L)
  testthat::expect_equal(x[[b$primary_key]], c(1L, 1L))
  testthat::expect_equal(as.character(x[["Species"]]), c("setosa", "setosa"))
}

expect_task = function(task) {
  checkmate::expect_r6(task, "Task", cloneable = TRUE, public = c("id", "backend", "task_type", "row_roles", "col_roles", "col_info", "head", "row_ids", "feature_names", "target_names", "formula", "nrow", "ncol", "feature_types"))
  testthat::expect_output(print(task), "Task")
  checkmate::expect_string(task$id, min.chars = 1L)
  checkmate::expect_count(task$nrow)
  checkmate::expect_count(task$ncol)
  checkmate::expect_data_table(task$data())
  checkmate::expect_data_table(task$head(1), nrow = 1L)


  cols = c("id", "type", "levels")
  checkmate::expect_data_table(task$col_info, key = "id", ncol = length(cols))
  checkmate::expect_names(names(task$col_info), permutation.of = cols)
  checkmate::expect_character(task$col_info$id, any.missing = FALSE, unique = TRUE)
  checkmate::expect_subset(task$col_info$type, mlr3::mlr_reflections$task_feature_types)
  checkmate::expect_list(task$col_info$levels)

  checkmate::expect_list(task$col_roles, names = "unique", any.missing = FALSE)
  checkmate::expect_names(names(task$col_roles), permutation.of = mlr3::mlr_reflections$task_col_roles)
  lapply(task$col_roles, expect_character, any.missing = FALSE, unique = TRUE, min.chars = 1L)
  checkmate::expect_subset(unlist(task$col_roles), task$col_info$id)

  checkmate::expect_list(task$row_roles, names = "unique", types = c("integer", "character"), any.missing = FALSE)
  checkmate::expect_names(names(task$row_roles), permutation.of = mlr3::mlr_reflections$task_row_roles)
  lapply(task$row_roles, expect_atomic_vector, any.missing = FALSE, unique = TRUE)

  types = task$feature_types
  checkmate::expect_data_table(types, ncol = 2, nrow = length(task$feature_names))
  checkmate::expect_set_equal(types$id, task$feature_names)
  checkmate::expect_subset(types$type, mlr3::mlr_reflections$task_feature_types)

  properties = task$properties
  checkmate::expect_subset(properties, mlr3::mlr_reflections$task_properties[[task$task_type]])

  expect_hash(task$hash, 1L)
}

expect_task_supervised = function(task) {
  checkmate::expect_r6(task, "TaskSupervised", cloneable = TRUE)
  checkmate::expect_choice(task$target_names, task$col_info$id)

  checkmate::expect_class(task$formula, "formula")
  testthat::expect_null(environment(task$formula))
  tf = terms(task$formula)
  checkmate::expect_set_equal(labels(tf), task$feature_names) # rhs
  checkmate::expect_set_equal(setdiff(all.vars(tf), labels(tf)), task$target_names) # lhs
  checkmate::expect_subset(task$feature_names, colnames(task$head()))
  expect_hash(task$hash, 1L)
}

expect_task_classif = function(task) {
  checkmate::expect_r6(task, "TaskClassif")
  y = task$truth()
  checkmate::expect_factor(y)

  checkmate::expect_int(task$class_n, lower = 2L)
  testthat::expect_equal(task$class_n, length(unique(y)))
  checkmate::expect_character(task$class_names, any.missing = FALSE)
  checkmate::expect_subset(task$class_names, as.character(y))
  if (task$class_n > 2L) {
    testthat::expect_identical(task$positive, NA_character_)
    testthat::expect_identical(task$negative, NA_character_)
  } else {
    checkmate::expect_set_equal(c(task$positive, task$negative), task$class_names)
    testthat::expect_true(task$positive != task$negative)
  }
  expect_hash(task$hash, 1L)
}

expect_task_regr = function(task) {
  checkmate::expect_r6(task, "TaskRegr")
  y = task$truth()
  checkmate::expect_numeric(y, any.missing = FALSE)
  expect_hash(task$hash, 1L)
}

expect_learner = function(lrn, task = NULL) {
  checkmate::expect_r6(lrn, "Learner", cloneable = TRUE)
  testthat::expect_output(print(lrn))

  checkmate::expect_choice(lrn$task_type, mlr3::mlr_reflections$task_types)
  checkmate::expect_character(lrn$packages, any.missing = FALSE, min.chars = 1L, unique = TRUE)
  checkmate::expect_class(lrn$par_set, "ParamSet")
  checkmate::expect_character(lrn$properties, any.missing = FALSE, min.chars = 1L, unique = TRUE)
  checkmate::expect_function(lrn$train, args = "task", ordered = TRUE)
  checkmate::expect_function(lrn$predict, args = c("model", "task"), ordered = TRUE)
  expect_hash(lrn$hash, 1L)

  if (!is.null(task)) {
    checkmate::expect_class(task, "Task")
    checkmate::expect_subset(lrn$properties, mlr3::mlr_reflections$learner_properties[[task$task_type]])
    testthat::expect_identical(lrn$task_type, task$task_type)
  }
}

expect_resampling = function(r, task = NULL) {
  checkmate::expect_r6(r, "Resampling")
  testthat::expect_output(print(r))
  checkmate::expect_string(r$id, min.chars = 1L)

  instance = r$instance
  if (is.null(instance)) {
    testthat::expect_false(r$is_instantiated)
    testthat::expect_error(r$train_set(1L), "instantiated")
    testthat::expect_error(r$test_set(1L), "instantiated")
    testthat::expect_identical(r$hash, NA_character_)
    if (r$id != "custom")
      checkmate::expect_count(r$iters, positive = TRUE)
  } else {
    testthat::expect_true(r$is_instantiated)
    expect_hash(r$hash, 1L)
    if (!is.null(task))
      ids = task$row_ids()
    checkmate::expect_count(r$iters, positive = TRUE)

    for (i in seq_len(r$iters)) {
      train = r$train_set(1L)
      test = r$test_set(1L)
      checkmate::expect_atomic_vector(train, any.missing = FALSE)
      checkmate::expect_atomic_vector(test, any.missing = FALSE)
      testthat::expect_length(intersect(train, test), 0L)
      if (!is.null(task)) {
        checkmate::expect_subset(train, ids)
        checkmate::expect_subset(train, ids)
      }
    }
  }
  checkmate::expect_list(r$par_vals, names = "unique")
  testthat::expect_true(qtestr(r$par_vals, "V1"))
}

expect_measure = function(m) {
  checkmate::expect_r6(m, "Measure", public = c("aggregate", "calculate", "id", "minimize", "packages", "range", "task_type", "task_properties", "learner_properties"))

  checkmate::expect_string(m$id, min.chars = 1L)
  checkmate::expect_subset(m$task_type, c(NA_character_, mlr3::mlr_reflections$task_types), empty.ok = FALSE)
  checkmate::expect_numeric(m$range, len = 2, any.missing = FALSE)
  testthat::expect_lt(m$range[1], m$range[2])
  checkmate::expect_flag(m$minimize)
  checkmate::expect_character(m$packages, min.chars = 1L, any.missing = FALSE, unique = TRUE)
  checkmate::expect_function(m$calculate, args = "e")
  checkmate::expect_function(m$aggregate, args = "rr")
}

expect_experiment = function(e) {
  checkmate::expect_r6(e, "Experiment")
  testthat::expect_output(print(e), "Experiment")
  state = e$state
  checkmate::expect_factor(state, ordered = TRUE)
  checkmate::expect_subset(as.character(state), levels(mlr3::mlr_reflections$experiment_slots$state))
  checkmate::expect_list(e$data, len = nrow(mlr3::mlr_reflections$experiment_slots))
  checkmate::expect_names(names(e$data), permutation.of = mlr3::mlr_reflections$experiment_slots$name)

  checkmate::expect_class(e$data$task, "Task")
  checkmate::expect_class(e$data$learner, "Learner")
  if (state >= "trained") {
    checkmate::expect_class(e$data$resampling, "Resampling")
    checkmate::expect_int(e$data$iteration, lower = 1L)
    checkmate::expect_class(e$data$train_log, "Log")
    checkmate::expect_number(e$data$train_time)
    testthat::expect_false(is.null(e$data$model))
  }

  if (state >= "predicted") {
    checkmate::expect_class(e$data$predict_log, "Log")
    checkmate::expect_number(e$data$predict_time)
    checkmate::expect_class(e$data$prediction, "Prediction")
    checkmate::expect_atomic_vector(e$data$prediction$response, len = length(e$test_set), any.missing = FALSE)
  }

  if (state >= "scored") {
    checkmate::expect_list(e$data$performance, names = "unique")
    checkmate::qassertr(e$data$performance, "N1")
  }
}

expect_resample_result = function(rr) {
  checkmate::expect_r6(rr, "ResampleResult")
  testthat::expect_output(print(rr), "ResampleResult")
  expect_task(rr$task)
  expect_learner(rr$learner, task = rr$task)
  expect_resampling(rr$resampling, task = rr$task)

  data = rr$data
  checkmate::expect_data_table(rr$data, nrow = rr$resampling$iters, ncol = nrow(mlr3::mlr_reflections$experiment_slots), any.missing = FALSE)
  checkmate::expect_names(names(rr$data), permutation.of = mlr3::mlr_reflections$experiment_slots$name)
  expect_hash(rr$hash, 1L)

  perf = rr$performance
  checkmate::expect_data_table(perf, nrow = rr$resampling$iters, min.cols = 2L)
  checkmate::expect_names(names(perf), must.include = c("iteration", mlr3::ids(rr$task$measures)))
  testthat::expect_identical(perf$iteration, seq_len(rr$resampling$iters))
  for (m in names(rr$task$measures))
    checkmate::expect_numeric(perf[[m]], any.missing = FALSE)

  e = rr$experiment(1L)
  expect_experiment(e)
  testthat::expect_true(e$state == "scored")

  measures = rr$measures
  aggr = rr$aggregated
  for (m in measures) {
    checkmate::expect_number(aggr[[m$id]], lower = m$range[1L], upper = m$range[2L], label = sprintf("measure %s", m$id))
  }
}

expect_benchmark_result = function(bmr) {
  checkmate::expect_r6(bmr, "BenchmarkResult", public = c("data", "resample_results", "resample_result", "performance"))

  rrs = bmr$resample_results
  checkmate::expect_data_table(rrs, ncol = 5L)
  checkmate::expect_names(names(rrs), permutation.of = c("task_id", "learner_id", "resampling_id", "hash", "N"))
  checkmate::expect_character(rrs$hash, any.missing = FALSE, unique = TRUE)
  checkmate::expect_integer(rrs$N, any.missing = FALSE, lower = 1L)
}