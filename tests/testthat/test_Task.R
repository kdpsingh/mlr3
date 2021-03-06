context("Task")

test_that("Task duplicates rows", {
  task = mlr_tasks$get("iris")
  data = task$data(c(1L, 1L))
  expect_data_table(data, nrow = 2L, any.missing = FALSE)
})

test_that("Rows return ordered", {
  x = load_dataset("nhtemp", "datasets", TRUE)
  data = as.data.frame(x)
  data$x = as.numeric(data$x)
  data$t = as.integer(time(x))
  data = data[rev(seq_row(data)), ]
  rownames(data) = NULL
  b = as_data_backend(data)
  task = TaskRegr$new(id = "nhtemp", b, target = "x")

  x = task$data()
  expect_true(is.unsorted(x$t))

  task$set_col_role("t", "order", exclusive = FALSE)
  x = task$data()
  expect_integer(x$t, sorted = TRUE, any.missing = FALSE)

  x = task$data(rows = sample(nrow(data), 50))
  expect_integer(x$t, sorted = TRUE, any.missing = FALSE)
})

test_that("Rows return ordered with multiple order cols", {
  task = mlr_tasks$get("iris")

  x = task$data()
  expect_true(is.unsorted(x$Petal.Length))

  task$set_col_role("Petal.Length", "order", exclusive = FALSE)
  task$set_col_role("Petal.Width", "order", exclusive = FALSE)
  expect_equal(task$col_roles$order, c("Petal.Length", "Petal.Width"))

  x = task$data()
  expect_numeric(x$Petal.Length, sorted = TRUE, any.missing = FALSE)

  expect_true(x[, is.unsorted(Petal.Width)])
  expect_true(all(x[, is.unsorted(Petal.Width), by = Petal.Width]$V1 == FALSE))
})


test_that("Task rbind", {
  task = mlr_tasks$get("iris")
  data = iris[1:10, ]
  task$rbind(iris[1:10, ])
  expect_task(task)
  expect_equal(task$nrow, 160)

  task$rbind(iris[integer(0), ])
  expect_equal(task$nrow, 160)

  # 185
  task = mlr_tasks$get("iris")
  task$select("Petal.Length")
  task$rbind(task$data())
})

test_that("Task cbind", {
  task = mlr_tasks$get("iris")
  data = cbind(data.frame(foo = 150:1), data.frame(..row_id = task$row_ids))
  task$cbind(data)
  expect_task(task)
  expect_equal(task$ncol, 6L)
  expect_names(task$feature_names, must.include = "foo")

  data = data.frame(bar = runif(150))
  task$cbind(data)
  expect_task(task)
  expect_equal(task$ncol, 7L)
  expect_names(task$feature_names, must.include = "bar")

  data = data.frame(..row_id = task$row_ids)
  task$cbind(data)
  expect_equal(task$ncol, 7L)

  task$cbind(iris[, character(0)])
  expect_equal(task$ncol, 7L)
})

test_that("task$replace_features", {
  task = mlr_tasks$get("iris")$filter(1:120)
  data = task$data(cols = c("Petal.Length", "Petal.Width"))
  task$replace_features(data)
  expect_task(task)
})

test_that("task$feature_types preserves key (#193)", {
  task = mlr_tasks$get("iris")$select(character(0))$cbind(iris[1:4])
  expect_data_table(task$feature_types, ncol = 2L, nrow = 4L, key = "id")
})

test_that("cbind/rbind works", {
  task = mlr_tasks$get("iris")
  data = data.table(..row_id = 1:150, foo = 150:1)

  task$cbind(data)
  expect_task(task)
  expect_set_equal(c(task$feature_names, task$target_names), c(names(iris), "foo"))
  expect_data_table(task$data(), ncol = 6, any.missing = FALSE)

  task$rbind(cbind(data.table(..row_id = 201:210, foo = 99L), iris[1:10, ]))
  expect_task(task)
  expect_set_equal(task$row_ids, c(1:150, 201:210))
  expect_data_table(task$data(), ncol = 6, nrow = 160, any.missing = FALSE)

  # auto generate char ids
  task = mlr_tasks$get("zoo")
  newdata = task$data("wasp")
  task$rbind(newdata)
  expect_equal(sum(grepl("^rbind_[0-9a-z]+_1", task$row_ids)), 1L)
})

test_that("filter works", {
  task = mlr_tasks$get("iris")
  task$filter(1:100)
  expect_equal(task$nrow, 100L)

  task$filter(91:150)
  expect_equal(task$nrow, 10L)

  expect_equal(task$row_ids, 91:100)
})

test_that("select works", {
  task = mlr_tasks$get("iris")
  task$select(setdiff(task$feature_names, "Sepal.Length"))
  expect_equal(task$ncol, 4L)

  task$select(c("Sepal.Width", "foobar"))
  expect_equal(task$ncol, 2L)

  expect_equal(task$feature_names, "Sepal.Width")

  expect_error(task$select(1:4), "character")
})

test_that("groups/weights work", {
  b = as_data_backend(data.table(x = runif(20), y = runif(20), w = runif(20), g = sample(letters[1:2], 20, replace = TRUE)))
  task = TaskRegr$new("test", b, target = "y")
  task$set_row_role(16:20, character(0))

  expect_null(task$groups)
  expect_null(task$weights)

  task$set_col_role("w", "weights")
  expect_subset("weights", task$properties)
  expect_data_table(task$weights, ncol = 2, nrow = 15)
  expect_numeric(task$weights$weight, any.missing = FALSE)

  task$set_col_role("w", "feature", exclusive = TRUE)
  expect_true("weights" %nin% task$properties)

  task$set_col_role("g", "groups")
  expect_subset("groups", task$properties)
  expect_data_table(task$groups, ncol = 2, nrow = 15)
  expect_subset(task$groups$group, c("a", "b"))

  task$set_col_role("g", "feature", exclusive = TRUE)
  expect_true("groups" %nin% task$properties)

  expect_error(task$set_col_role(c("w", "g"), "weights"), "Multiple columns with role")
})

test_that("ordered factors (#95)", {
  df = data.frame(x = c(1, 2, 3), y = factor(letters[1:3], ordered = TRUE), z = c("M", "R", "R"))
  b = as_data_backend(df)
  task = TaskClassif$new(id = "id", backend = b, target = "z")
  expect_subset(c("numeric", "ordered", "factor"), task$col_info$type)
  expect_set_equal(task$col_info[id == "z", levels][[1L]], c("M", "R"))
  expect_set_equal(task$col_info[id == "y", levels][[1L]], letters[1:3])
})

test_that("as.data.table", {
  task = mlr_tasks$get("iris")
  expect_data_table(as.data.table(task), nrow = 150, ncol = 5)
})

test_that("extra factor levels are stored (#179)", {
  dt = data.table(
    x1 = factor(letters[1:5], levels = letters[5:1]),
    x2 = factor(letters[1:5], levels = letters),
    x3 = letters[1:5],
    target = 1:5)
  task = TaskRegr$new("extra_factor_levels", as_data_backend(dt), "target")
  expect_equal(task$levels("x2")$x2, letters)
})

test_that("task$droplevels works", {
  dt = data.table(
    x1 = letters[1:3],
    target = 1:3
  )
  task = TaskRegr$new("droplevels", as_data_backend(dt), "target")

  task$filter(1:2)
  expect_equal(task$nrow, 2L)
  expect_equal(task$levels("x1")$x1, letters[1:3])
  task$droplevels()
  expect_equal(task$levels("x1")$x1, letters[1:2])
})

test_that("task$missings() works", {
  task = mlr_tasks$get("pima")
  x = task$missings()
  y = map_int(task$data(), function(x) sum(is.na(x)))
  expect_equal(x, y[match(names(x), names(y))])
})
