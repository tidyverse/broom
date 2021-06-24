context("gee-gee")

skip_if_not_installed("modeltests")
library(modeltests)

test_that("gee tidier arguments", {
  check_arguments(tidy.gee)
  check_arguments(glance.gee)
})

g1 <- gee::gee(mpg ~ wt + hp, id = cyl, data = mtcars, corstr = "exchangeable")

# Tidy
test_that("tidy.gee works", {
  tg <- tidy(g1)
  check_tidy_output(tg)
  check_dims(tg, expected_rows = 3)
  expect_equal(tg$term, c("(Intercept)", "wt", "hp"))
})

# Glance
test_that("glance.gee", {
  gg <- glance(g1)
  check_glance_outputs(gg)
})


# Augment missing
