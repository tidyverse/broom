context("ivreg")

skip_on_cran()

skip_if_not_installed("modeltests")
library(modeltests)

skip_if_not_installed("ivreg")
library(ivreg)
library(dplyr)
library(modeltests)

skip_if_not_installed("sandwich")
library(sandwich)

data("CigaretteDemand", package = "ivreg")

fit <- ivreg(log(packs) ~ log(rprice) + log(rincome) | salestax + log(rincome),
             data = CigaretteDemand)

test_that("ivreg tidier arguments", {
  check_arguments(tidy.ivreg)
  check_arguments(glance.ivreg)
  check_arguments(augment.ivreg, strict = FALSE)
})

test_that("tidy.ivreg", {
  td1 <- tidy(fit)
  td2 <- tidy(fit, conf.int = TRUE)
  td3 <- tidy(fit, conf.int = TRUE, vcov = sandwich::vcovHC)
  td4 <- tidy(fit, component = "stage1")
  td5 <- tidy(fit, component = "instruments")

  check_tidy_output(td1)
  check_tidy_output(td2)
  check_tidy_output(td3)
  check_tidy_output(td4)
  check_tidy_output(td5)
})

test_that("glance.ivreg", {
  gl1 <- glance(fit)
  gl2 <- glance(fit, diagnostics = TRUE)

  check_glance_outputs(gl1) # separately because diagnostics = TRUE adds cols
  check_glance_outputs(gl2)
})

test_that("augment.ivreg", {
  check_augment_function(
    aug = augment.ivreg,
    model = fit,
    data = CigaretteDemand,
    newdata = CigaretteDemand,
    strict = FALSE
  )

  au1 <- augment(fit, CigaretteDemand)
  expect_true(all(c(".resid", ".fitted") %in% names(au1)))
  au2 <- augment(fit, se_fit = TRUE, interval = "confidence")
  expect_true(all(c(".se.fit", ".lower", ".upper") %in% names(au2)))
  au3 <- augment(fit, se_fit = TRUE, interval = "prediction")
  expect_true(all(c(".se.fit", ".lower", ".upper") %in% names(au3)))
})
