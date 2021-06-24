#' @templateVar class gee
#' @template title_desc_tidy
#'
#' @param x A `gee` object returned from a call to [gee::gee()].
#' @param conf.int 	Logical indicating whether or not to include a confidence
#'   interval in the tidied output. Defaults to FALSE.
#' @param conf.level The confidence level to use for the confidence interval if
#'   conf.int = TRUE. Must be strictly greater than 0 and less than 1. Defaults
#'   to 0.95, which corresponds to a 95 percent confidence interval.
#' @param exponentiate Logical indicating whether or not to exponentiate the the
#'   coefficient estimates. This is typical for logistic and multinomial
#'   regressions, but a bad idea if there is no log or logit link. Defaults to
#'   FALSE.
#' @param ... Additional arguments. Not used. Needed to match generic signature
#'   only. Cautionary note: Misspelled arguments will be absorbed in ..., where
#'   they will be ignored. If the misspelled argument has a default value, the
#'   default value will be used. For example, if you pass conf.level = 0.9, all
#'   computation will proceed using conf.level = 0.95. Additionally, if you pass
#'   newdata = my_tibble to an augment() method that does not accept a newdata
#'   argument, it will use the default value for the data argument.
#' @details If `conf.int = TRUE`, the confidence interval is computed with an
#'   internal `confint.gee()` function.
#'
#'   If you have missing values in your model data, you may need to refit the
#'   model with `na.action = na.exclude` or deal with the missingness in the
#'   data beforehand.
#'   
#' @examples
#'
#' library(gee)
#' 
#' df <- mtcars
#'
#' gee_mod <- gee(
#'   mpg ~ hp + wt, id = cyl, data = df, 
#'   family = gaussian, corstr = "independence"
#' )
#' 
#' tidy(gee_mod)
#' tidy(gee_mod, conf.int = TRUE)
#' glance(gee_mod)
#' augment(gee_mod)
#'
#' @evalRd return_tidy(regression = TRUE)
#'
#' @export
#' @aliases gee_tidiers 
#' @seealso [tidy()], [gee::gee()]
tidy.gee <- function(x, conf.int = FALSE, conf.level = .95, exponentiate = FALSE, ...) {
  
  coefs <-
    stats::coef(summary(x)) %>%
    tibble::as_tibble(rownames = "term") %>%
    dplyr::select(-c(`Naive S.E.`, `Naive z`)) 
  
  # Remove naive estimators
  names(coefs) <- c("term", "estimate", "std.error", "statistic")
  
  if (conf.int) {
    zstat <- qnorm((1 + conf.level)/2)
    coefs$conf.low <- coefs$estimate - zstat * coefs$std.error
    coefs$conf.high <- coefs$estimate + zstat * coefs$std.error
  }
  
  if (exponentiate) {
    if (is.null(x$familcoefs) ||
        (x$familcoefs$link != "logit" && x$familcoefs$link != "log")) {
      warning(paste(
        "Exponentiating coefficients, but model did not use",
        "a log or logit link function"
      ))
    }
    
    coefs$estimate <- exp(coefs$estimate)
    coefs$std.error <- exp(coefs$std.error)
    
    if ("conf.low" %in% colnames(coefs)) {
      coefs$conf.low <- exp(coefs$conf.low)
      coefs$conf.high <- exp(coefs$conf.high)
    }
  }
  
  # Return
  return(coefs)
}

#' @templateVar class gee
#' @template title_desc_glance
#'
#' @inherit tidy.gee params examples
#'
#' @evalRd return_glance("nobs", "n.clusters", "iterations")
#'
#' @export
#' @seealso [glance()], [gee::gee()]
#' @family gee tidiers
glance.gee <- function(x, ...) {
  tibble::tibble(
    nobs = x$nobs,
    n.clusters = x$max.id,
    iterations = x$iterations
  )
  
}

#' @templateVar class gee
#' @template title_desc_augment
#'
#' @template augment_NAs
#'
#' @inherit tidy.gee params examples
#'
#' @evalRd return_augment(
#'   ".hat",
#'   ".lower",
#'   ".upper", 
#'   ".sigma",
#'   ".cooksd",
#'   ".se.fit",
#'   ".std.resid"
#' )
#'
#' @export
#' @seealso [augment()], [gee::gee()]
#' @family gee tidiers
augment.gee <- function(x, ...) {
  
  tibble::tibble(
    id = x$id,
    .y = x$y,
    .fitted = x$fitted.values,
    .resid = x$residuals[,1]
  )
  
}
