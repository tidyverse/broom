context("mclust")

skip_if_not_installed("modeltests")
library(modeltests)

skip_if_not_installed("mclust")
library(mclust)
dat <- iris[, 1:4]

fit <- Mclust(dat, G = 7, modelNames = "EII", verbose = FALSE)
fit2 <- Mclust(dat, G = 1, verbose = FALSE)

test_that("mclust tidier arguments", {
  check_arguments(tidy.Mclust)
  check_arguments(glance.Mclust)
  check_arguments(augment.Mclust)
})

test_that("tidy.Mclust", {
  td <- tidy(fit)
  td2 <- tidy(fit2)
  
  check_tidy_output(td, strict = FALSE)
  check_tidy_output(td2, strict = FALSE)
  
  check_dims(td, 7, 8)
  check_dims(td2, 1, 7)
})

test_that("glance.Mclust", {
  gl <- glance(fit)
  gl2 <- glance(fit2)
  
  check_glance_outputs(gl, gl2)
})

test_that("augment.Mclust", {
  
  check_augment_function(
    aug = augment.Mclust,
    model = fit,
    data = dat,
    newdata = dat
  )
  
  check_augment_function(
    aug = augment.Mclust,
    model = fit2,
    data = dat,
    newdata = dat
  )
})
