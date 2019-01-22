#' @templateVar class betareg
#' @template title_desc_tidy
#' 
#' @param x A `betareg` object produced by a call to [betareg::betareg()].
#' @template param_confint
#' @template param_unused_dots
#' 
#' @evalRd return_tidy(regression = TRUE,
#'   component = "Whether a particular term was used to model the mean or the
#'     precision in the regression. See details."
#' )
#'
#' @details The tibble has one row for each term in the regression. The
#'   `component` column indicates whether a particular
#'   term was used to model either the `"mean"` or `"precision"`. Here the
#'   precision is the inverse of the variance, often referred to as `phi`.
#'   At least one term will have been used to model the precision `phi`.
#'
#' @examples
#'
#' library(betareg)
#' data("GasolineYield", package = "betareg")
#'
#' mod <- betareg(yield ~ batch + temp, data = GasolineYield)
#'
#' mod
#' tidy(mod)
#' tidy(mod, conf.int = TRUE)
#' tidy(mod, conf.int = TRUE, conf.level = .99)
#'
#' augment(mod)
#'
#' glance(mod)
#'
#' @export
#' @seealso [tidy()], [betareg::betareg()]
#' @family betareg tidiers
#' @aliases betareg_tidiers
tidy.betareg <- function(x, conf.int = FALSE, conf.level = .95, ...) {
  ret <- purrr::map_df(
    coef(summary(x)),
    fix_data_frame,
    newnames = c("estimate", "std.error", "statistic", "p.value"),
    .id = "component")

  if (conf.int) {
    conf <- unrowname(confint(x, level = conf.level))
    colnames(conf) <- c("conf.low", "conf.high")
    ret <- cbind(ret, conf)
  }
  
  as_tibble(ret)
}


#' @templateVar class betareg
#' @template title_desc_augment
#'
#' @inherit tidy.betareg params examples
#' @template param_data
#' @template param_newdata
#' @template param_type_predict
#' @template param_type_residuals
#' 
#' @evalRd return_augment(".cooksd")
#'
#' @details For additional details on Cook's distance, see 
#'   [stats::cooks.distance()].
#' 
#' @seealso [augment()], [betareg::betareg()]
#' @export
augment.betareg <- function(x, data = model.frame(x), newdata = NULL,
                            type.predict = c("response", "link", "precision", "variance", "quantile"),
                            type.residuals = c("sweighted2", "deviance", "pearson", "response", "weighted", "sweighted"),
                            ...) {
  augment_columns(
    x, data, newdata,
    type.predict = type.predict,
    type.residuals = type.residuals
  )
}


#' @templateVar class betareg
#' @template title_desc_glance
#' 
#' @inherit tidy.betareg params examples
#' @template param_unused_dots
#' 
#' @evalRd return_glance(
#'   "pseudo.r.squared",
#'   "df.null", 
#'   "logLik", 
#'   "AIC",
#'   "BIC",
#'   "df.residual"
#' )
#' 
#' @seealso [glance()], [betareg::betareg()]
#' @export
glance.betareg <- function(x, ...) {
  s <- summary(x)
  ret <- tibble(
    pseudo.r.squared = s$pseudo.r.squared,
    df.null = s$df.null
  )
  ret <- finish_glance(ret, x)
  as_tibble(ret)
}
