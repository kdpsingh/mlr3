context("TaskGenerator")

test_that("TaskGenerators", {
  ids = mlr_task_generators$ids()
  n = 10L

  for (id in ids) {
    gen = mlr_task_generators$get(id)
    expect_r6(gen, "TaskGenerator", private = ".generate_task")
    expect_choice(gen$task_type, mlr_reflections$task_types)
    expect_function(gen$generate, args = "n")
    expect_class(gen$param_set, "ParamSet")
    expect_list(gen$param_vals, names = "unique")

    task = gen$generate(n)
    expect_task(task)
    expect_equal(gen$task_type, task$task_type)
    expect_equal(task$nrow, n)
  }
})