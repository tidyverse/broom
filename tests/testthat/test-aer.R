context("aer")

skip_on_cran()

skip_if_not_installed("modeltests")
library(modeltests)

skip_if_not_installed("aer")
library(AER)
library(dplyr)
library(modeltests)

data("Affairs", package = "AER")

tob1 <- tobit(affairs ~ age + yearsmarried + religiousness + occupation + rating,
              data = Affairs)

tob2 <- tobit(affairs ~ age + yearsmarried + religiousness + occupation + rating,
              right = 4, data = Affairs)

test_that("aer tidier arguments", {
  check_arguments(tidy.tobit)
})

test_that("tidy.aer", {
  td1 <- tidy(tob1)
  td1_ci <- tidy(tob1, conf.int = TRUE)
  td2 <- tidy(tob2)
  
  check_tidy_output(td1)
  check_tidy_output(td1_ci)
  check_tidy_output(td2)
})
