context("stats-prcomp")

skip_if_not_installed("modeltests")
library(modeltests)

pc <- prcomp(USArrests, scale = TRUE)

test_that("prcomp tidier arguments", {
  check_arguments(tidy.prcomp)
  check_arguments(augment.prcomp)
})


test_that("tidy.prcomp", {
  td <- tidy(pc, matrix = "d")
  
  check_tidy_output(td)
  check_dims(td, 4, 4)
  expect_identical(tidy(pc, matrix = "pcs"), td)
  
  td2 <- tidy(pc, matrix = "v")
  
  check_tidy_output(td2, strict = FALSE)
  check_dims(td2, 16, 3)
  
  expect_identical(
    tidy(pc, matrix = "rotation"),
    tidy(pc, matrix = "variables")
  )
  expect_identical(tidy(pc, matrix = "rotation"), td2)
  expect_identical(tidy(pc, matrix = "variables"), td2)
  
  td3 <- tidy(pc, matrix = "u")
  
  check_tidy_output(td3)
  check_dims(td3, 200, 3)
  expect_identical(tidy(pc, matrix = "x"), tidy(pc, matrix = "samples"))
  expect_identical(tidy(pc, matrix = "x"), td3)
  expect_identical(tidy(pc, matrix = "samples"), td3)
  
  expect_error(
    tidy(pc, matrix = c("d", "u")),
    regexp = "Must select a single matrix to tidy."
  )
  
  no_row_nm <- as.data.frame(matrix(1:9, ncol = 3) + rnorm(n = 9, sd = 0.25))
  pca <- prcomp(no_row_nm)
  expect_error(tidy(pca, matrix = "u"), NA)
})

test_that("augment.prcomp", {
  check_augment_function(
    aug = augment.prcomp,
    model = pc,
    data = USArrests,
    newdata = USArrests,
    strict = FALSE
  )
})
