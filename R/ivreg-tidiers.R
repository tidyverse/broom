#' @templateVar class ivreg
#' @template title_desc_tidy
#'
#' @param x An `ivreg` object created by a call to [ivreg::ivreg()].
#' @template param_confint
#' @param component Character indicating which component of the 2SLS regression 
#'   to tidy. One of "stage2" (the default), "stage1", or "instruments". See
#'   examples.
#' @param ... Further arguments to be passed to [ivreg::ivreg.fit()], e.g.
#'   specifying an alternate variance-covariance structure. Currently, only
#'   supported for the default "stage2" component (above). See examples.
#'
#' @evalRd return_tidy(
#'   regression = TRUE
#' )
#'
#' @examples
#'
#' library(ivreg)
#'
#' data("CigaretteDemand", package = "ivreg")
#'
#' m <- ivreg(log(packs) ~ log(rprice) + log(rincome) | salestax + log(rincome),
#'            data = CigaretteDemand)
#'
#' summary(m)
#'
#' tidy(m)
#' tidy(m, conf.int = TRUE)
#' 
#' # Specify alternate error structures by passing through an appropriate
#' # "vcov" argument. Here we use HC (i.e. robust) standard errors from the
#' # sandwich package.
#' tidy(m, vcov = sandwich::vcovHC)
#' 
#' # By default, the stage-2 component of the 2SLS regression is returned and
#' # tidied. But we can easily obtain the stage-1 component instead.
#' tidy(m, component = "stage1")
#' 
#' # If only the instrumental variables from stage-1 are desired, e.g. as
#' # supplementary information for a regression table.
#' tidy(m, component = "instruments")
#' 
#' augment(m)
#' augment(m, se_fit = TRUE)
#' augment(m, se_fit = TRUE, interval = "confidence")
#' augment(m, newdata = CigaretteDemand[1:10, ], interval = "prediction")
#' 
#' # As with tidy.ivreg, we can specify alternate error structures by passing
#' # on a "vcov" argument from the sandwich package that ivreg objects 
#' # understand.
#' augment(m, se_fit = TRUE, vcov = sandwich::vcovHC)
#' 
#' # The "interval" and "vcov" arguments above can be combined. Among other
#' # things, this can be useful for visually inspecting the impact of different 
#' # standard errors on our model predictions.
#' library(ggplot2)
#' ggplot(
#'   data = augment(m, interval = 'confidence'), 
#'   aes(x=.rownames, y=.fitted, ymin=.lower, ymax=.upper)
#'   ) + 
#'   geom_pointrange() +
#'   ylim(4, 5) +
#'   labs(title = "Predicted values; regular standard errors")
#' ggplot(
#'   data = augment(m, interval = 'confidence', vcov = sandwich::vcovHC),
#'   aes(x=.rownames, y=.fitted, ymin=.lower, ymax=.upper)
#'   ) + 
#'   geom_pointrange() +
#'   ylim(4, 5) +
#'   labs(title = "Predicted values; robust standard errors")
#'
#' glance(m)
#' # Include stage-1 diagnostics tests
#' glance(m, diagnostics = TRUE)
#' # Specify alternate error structure (e.g. HC robust standard errors)
#' glance(m, vcov = sandwich::vcovHC)
#' @export
#' @seealso [tidy()], [ivreg::ivreg()]
#' @family ivreg tidiers
#' @aliases ivreg_tidiers
tidy.ivreg <- function(x,
                       conf.int = FALSE,
                       conf.level = 0.95,
                       component = c("stage2", "stage1", "instruments"),
                       ...) {
  
  ## Warn users about deprecated "instruments" argument.
  dots = list(...)
  if (!is.null(dots$instruments)) {
    warning('\nThe "instruments" argument has been deprecated for tidy.ivreg and will be ignored. Please use the "component" argument instead.\n')
  }
  
  component = match.arg(component)
  
  # case 1: user asks for stage 1 component
  if (component %in% c("stage1", "instruments")) {
    # extract components from ivreg stage 1 and calc stats
    c1 <- coef(x, component = 'stage1')
    v1 <- stats::vcov(x, component = 'stage1')
    se1 <- sqrt(diag(v1))
    t1 <- c1/se1
    p1 <- 2*stats::pt(-abs(t1),df=x$df.residual1)
    # put into tibble
    ret <- tibble::tibble(term = names(c1), estimate = c1, std.error = se1,
                          statistic = t1, p.value = p1)
    if (conf.int) {
      # currently no confint method for first stage. but easy to calc manually.
      # https://github.com/john-d-fox/ivreg/issues/1#issuecomment-687686364
      ret <- ret %>%
        mutate(
          conf.low = estimate - stats::qt(1-(1-conf.level)/2, df=x$df.residual1)*std.error,
          conf.high = estimate + stats::qt(1-(1-conf.level)/2, df=x$df.residual1)*std.error
        )
    }
    # Special case: Only want to tidy the IVs
    if (component=="instruments") {
      instr_vars = names(x$instruments)
      ret <- filter(ret, term %in% instr_vars)
    }
  } else {
    # case 2: user asks for stage 2 component, or just defaults to this
    ret <- as_tibble(summary(x, ...)$coefficients, rownames = "term")
    colnames(ret) <- c("term", "estimate", "std.error", "statistic", "p.value")
    if (conf.int) {
      # Default confint method doesn't support alternate vcov matrices, so we'll
      # calculate manually. Alternatively, could use lmtest::coefci(x, ...),
      # coerce to tibble and join, but that ends up being more work.
      ret <- ret %>%
        mutate(
          conf.low = estimate - stats::qt(1-(1-conf.level)/2, df=x$df.residual)*std.error,
          conf.high = estimate + stats::qt(1-(1-conf.level)/2, df=x$df.residual)*std.error
        )
    }
  }
  ret
}

#' @templateVar class ivreg
#' @template title_desc_augment
#'
#' @inherit tidy.ivreg params examples
#' @template param_data
#' @template param_newdata
#' @template param_se_fit
#' @template param_interval
#' @param ... Further arguments to be passed to [ivreg::ivreg.fit()], e.g.
#'   specifying an alternate variance-covariance structure. See examples
#'
#' @evalRd return_augment(
#'   ".lower",
#'   ".upper", 
#'   ".se.fit"
#' )
#' @note Unlike other `augment()` methods, `augment.ivreg()` only returns a
#'   `.resid` column if no `newdata` is supplied.
#' @export
#' @seealso [augment()], [ivreg::ivreg()]
#' @family ivreg tidiers
augment.ivreg <- function(x, data = model.frame(x), newdata = NULL,
                          se_fit = FALSE, conf.int = 0.95,
                          interval =  c("none", "confidence", "prediction"), ...) {
  # Turn off .se_fit and interval args at first, since not supported out of the 
  # box.
  ret <- augment_newdata(x, data, newdata, .se_fit = FALSE, interval = "none")
  # While predict.ivreg doesn't support se.fit or interval arguments, we can 
  # roll our own.
  interval = match.arg (interval)
  if (se_fit || interval!="none") {
    s <- summary(x, ...)
    # Use ... to pass through potential vcov arguments in summary.ivreg
    v <- s$vcov
    # get design matrix
    if (is.null(newdata)) {
      xmat <- stats::model.matrix(x) 
    } else {
      # requires a bit more legwork if user passes newdata
      tt <- terms(x)
      Terms <- delete.response(tt)
      d <- model.frame(Terms, newdata, na.action = na.pass, xlev = x$xlevels)
      if ("(Intercept)" %in% names(x$coefficients)) {
        d <- cbind(rep(1, times = nrow(d)), d)
        colnames(d)[1] <- "(Intercept)"
      }
      xmat <- as.matrix(d)
    }
    # calc fitted point variance and se values
    v_pt <- rowSums((xmat %*% v) * xmat)
    se_pt <- sqrt(v_pt)
    # add residual variance if prediction interval is desired
    if (interval=="prediction") {
      se_pt <- sqrt(v_pt + s$sigma^2)
    }
    # add values to return object
    if (se_fit) {
      ret$.se.fit = se_pt
    }
    if (interval!="none") {
      dots = list(...)
      if (is.null(dots$level)) {
        level <- 0.95
      }
      ret$.lower = ret$.fitted - qt(1-(1-level)/2, df=x$df.residual)*se_pt
      ret$.upper = ret$.fitted + qt(1-(1-level)/2, df=x$df.residual)*se_pt
    }
  }
  ret
}

#' @templateVar class ivreg
#' @template title_desc_glance
#' @inherit tidy.ivreg params examples
#' @param diagnostics Logical indicating whether to include diagnostics tests
#'   from the first-stage regression; see Details. Defaults to `FALSE`.
#' @param ... Further arguments to be passed to [ivreg::ivreg.fit()], e.g.
#'   specifying an alternate variance-covariance structure. See Examples.
#' @details As of 0.7.1, `glance.ivreg(..., diagnostics = TRUE)` returns three
#' diagnostics tests from the first-stage regression. These are 1) a weak 
#' instruments F-test, a 2) Wu-Hausman chi-squared test of endogeneity, and 3) 
#' Sargan's J-test of overidentifying restrictions. Note that the latter test
#' requires there to be more instruments than endogenous regressors. The Sargan
#' test values will automatically return `NA` if this condition is not met.
#' @evalRd return_glance(
#'   "r.squared",
#'   "adj.r.squared",
#'   "sigma",
#'   "df",
#'   "df.residual",
#'   "nobs",
#'   "statistic" = "Wald test statistic.",
#'   "p.value" = "P-value for the Wald test.",
#'   "statistic.weak.instr" = "Weak instrument(s) F-test.",
#'   "p.value.weak.instr" = "P-value for weak instrument(s) test.",
#'   "statistic.Sargan" = "Sargan J-statistic of overidentifying restrictions.",
#'   "p.value.Sargan" = "P-value for Sargan J-test.",
#'   "statistic.Wu.Hausman" = "Wu-Hausman chi-squared test of endogeneity.",
#'   "p.value.Wu.Hausman" = "P-value for Wu-Hausman test."
#' )
#'
#' @export
#' @seealso [glance()], [AER::ivreg()]
#' @family ivreg tidiers
glance.ivreg <- function(x, diagnostics = FALSE, ...) {

  s <- summary(x, ...)
  
  ret <- as_glance_tibble(
    r.squared = s$r.squared,
    adj.r.squared = s$adj.r.squared,
    sigma = s$sigma,
    statistic = s$waldtest[1],
    p.value = s$waldtest[2],
    df = s$df[1],
    df.residual = df.residual(x),
    nobs = stats::nobs(x),
    na_types = "rrrrriii"
  )

  if (diagnostics) {
    diags <- as_glance_tibble(
      statistic.weak.instr = s$diagnostics["Weak instruments", "statistic"],
      p.value.weak.instr = s$diagnostics["Weak instruments", "p-value"],
      statistic.Wu.Hausman = s$diagnostics["Wu-Hausman", "statistic"],
      p.value.Wu.Hausman = s$diagnostics["Wu-Hausman", "p-value"],
      statistic.Sargan = s$diagnostics["Sargan", "statistic"],
      p.value.Sargan = s$diagnostics["Sargan", "p-value"],
      na_types = "rrrrrr"
    )
    
    return(bind_cols(ret, diags))
  }

  ret
}
