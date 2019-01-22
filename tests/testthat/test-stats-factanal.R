context("stats-factanal")

skip_if_not_installed("modeltests")
library(modeltests)

n_factors <- 3
n_factors2 <- 3

fit <- factanal(mtcars, n_factors)
fit2 <- factanal(mtcars, n_factors2)

test_that("factanal tidier arguments", {
  check_arguments(tidy.factanal)
  check_arguments(glance.factanal)
  check_arguments(augment.factanal)
})

test_that("tidy.factanal", {
  td <- tidy(fit)
  td2 <- tidy(fit2)
  
  check_tidy_output(td, strict = FALSE)
  check_tidy_output(td2, strict = FALSE)
  check_dims(td, ncol(mtcars), 2 + n_factors)
  
  expect_equal(td$variable, colnames(mtcars))
  expect_equal(ncol(td2), 2 + n_factors2)
})

test_that("glance.factanal works", {
  gl <- glance(fit)
  gl2 <- glance(fit2)
  
  check_glance_outputs(gl, gl2)
  check_dims(gl, 1, 8)
  
  expect_equal(gl$n.factors, n_factors)
})

test_that("augment.factanal works", {
  
  fit_reg <- factanal(mtcars, n_factors, scores = "regression")
  fit_bart <- factanal(mtcars, n_factors, scores = "Bartlett")
  
  check_augment_function(
    aug = augment.factanal,
    model = fit_reg,
    data = mtcars,
    strict = FALSE
  )
  
  check_augment_function(
    aug = augment.factanal,
    model = fit_bart,
    data = mtcars,
    strict = FALSE
  )
  
  # errors for `scores = "none"`
  fit_none <- factanal(mtcars, n_factors, scores = "none")
  expect_error(
    augment(fit_none),
    regexp = "Cannot augment factanal objects fit with `scores = 'none'`."
  )
  
  au_reg0 <- augment(fit_reg)
  au_reg1 <- augment(fit_reg, data = mtcars)
  check_dims(au_reg0, expected_cols = n_factors + 1)
  check_dims(au_reg1, expected_cols = ncol(mtcars) + n_factors + 1)
})
