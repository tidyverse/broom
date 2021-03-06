#' @templateVar class anova
#' @template title_desc_tidy
#'
#' @param x An `anova` object, such as those created by [stats::anova()],
#'   [car::Anova()], or [car::leveneTest()].
#' @template param_unused_dots
#'
#' @evalRd return_tidy(
#'   "term",
#'   "df",
#'   "sumsq",
#'   "meansq",
#'   "statistic",
#'   "p.value"
#' )
#'
#' @details 
#' The `term` column of an ANOVA table can come with leading or
#' trailing whitespace, which this tidying method trims.
#'   
#' For documentation on the tidier for [car::leveneTest()] output, see
#' [tidy.leveneTest()]
#'
#' @examples
#'
#' a <- lm(mpg ~ wt + qsec + disp, mtcars)
#' b <- lm(mpg ~ wt + qsec, mtcars)
#' tidy(anova(a, b))
#' @export
#' @family anova tidiers
#' @seealso [tidy()], [stats::anova()], [car::Anova()], [car::leveneTest()]
tidy.anova <- function(x, ...) {

  # car::leveneTest returns an object of class `anova`
  if (!is.null(attr(x, "heading")) && 
      isTRUE(grepl("Levene's Test for Homogeneity of Variance", attr(x, "heading")))) {
    return(tidy(structure(x, class = c("leveneTest", class(x))), ...))
  }

  # there are many possible column names that need to be transformed
  renamers <- c(
    "AIC" = "AIC", # merMod
    "BIC" = "BIC", # merMod
    "deviance" = "deviance", # merMod
    "logLik" = "logLik", # merMod
    "Df" = "df",
    "Chi.Df" = "df",
    "Sum Sq" = "sumsq",
    "Mean Sq" = "meansq",
    "F value" = "statistic",
    "Pr(>F)" = "p.value",
    "Res.Df" = "res.df",
    "RSS" = "rss",
    "Sum of Sq" = "sumsq",
    "F" = "statistic",
    "Chisq" = "statistic",
    "P(>|Chi|)" = "p.value",
    "Pr(>|Chi|)" = "p.value",
    "Pr(>Chi)" = "p.value",
    "Pr..Chisq." = "p.value",
    "Pr..Chi." = "p.value",
    "p.value" = "p.value",
    "Chi.sq" = "statistic",
    "LR.Chisq" = "statistic",
    "LR Chisq" = "statistic",
    "edf" = "edf",
    "Ref.df" = "ref.df",
    "loglik" = "logLik",
    ".rownames" = "term"
  )

  names(renamers) <- make.names(names(renamers))

  ret <- as_augment_tibble(x)
  colnames(ret) <- make.names(names(ret))

  unknown_cols <- setdiff(colnames(ret), c("term", names(renamers)))
  if (length(unknown_cols) > 0) {
    warning(
      "The following column names in ANOVA output were not ",
      "recognized or transformed: ",
      paste(unknown_cols, collapse = ", ")
    )
  }

  colnames(ret) <- dplyr::recode(colnames(ret), !!!renamers)

  if ("term" %in% names(ret)) {
    # if rows had names, strip whitespace in them
    ret <- mutate(ret, term = stringr::str_trim(term))
  }
  as_tibble(ret)
}


#' @templateVar class aov
#' @template title_desc_tidy
#'
#' @param x An `aov` object, such as those created by [stats::aov()].
#' @template param_unused_dots
#'
#' @inherit tidy.anova return details
#'
#' @examples
#'
#' a <- aov(mpg ~ wt + qsec + disp, mtcars)
#' tidy(a)
#' @export
#' @family anova tidiers
#' @seealso [tidy()], [stats::aov()]
tidy.aov <- function(x, ...) {
  summary(x)[[1]] %>%
    tibble::as_tibble(rownames = "term") %>%
    dplyr::mutate("term" = stringr::str_trim(term)) %>%
    rename2(
      "df" = "Df",
      "sumsq" = "Sum Sq",
      "meansq" = "Mean Sq",
      "statistic" = "F value",
      "p.value" = "Pr(>F)"
    )
}


#' @templateVar class lm
#' @template title_desc_glance
#'
#' @inherit tidy.aov params examples
#'
#' @note
#' Note that `tidy.aov()` now contains the numerator and denominator degrees of 
#' freedom, which were included in the output of `glance.aov()` in some
#' previous versions of the package.
#'
#' @evalRd return_glance(
#'   "logLik",
#'   "AIC",
#'   "BIC",
#'   "deviance",
#'   "nobs"
#' )
#'
#' @export
#' @seealso [glance()]
#' @family anova tidiers
glance.aov <- function(x, ...) {
  lm_sum <- summary(lm(x))
  
  as_glance_tibble(
    logLik = as.numeric(stats::logLik(x)),
    AIC = stats::AIC(x),
    BIC = stats::BIC(x),
    deviance = stats::deviance(x),
    nobs = stats::nobs(x),
    r.squared = lm_sum$r.squared,
    na_types = "rrrrir"
  )
  
}

#' @templateVar class aovlist
#' @template title_desc_tidy
#'
#' @param x An `aovlist` objects, such as those created by [stats::aov()].
#' @template param_unused_dots
#'
#' @evalRd return_tidy(
#'   "term",
#'   "df",
#'   "sumsq",
#'   "meansq",
#'   "statistic",
#'   "p.value",
#'   "stratum"
#' )
#'
#' @inherit tidy.anova details
#'
#' @examples
#'
#' a <- aov(mpg ~ wt + qsec + Error(disp / am), mtcars)
#' tidy(a)
#' @export
#' @family anova tidiers
#' @seealso [tidy()], [stats::aov()]
tidy.aovlist <- function(x, ...) {

  # must filter out Intercept stratum since it has no dimensions
  if (names(x)[1L] == "(Intercept)") {
    x <- x[-1L]
  }

  ret <- map_df(x, tidy, .id = "stratum")

  # get rid of leading and trailing whitespace in term and stratum columns
  ret <- ret %>%
    mutate(
      term = stringr::str_trim(term),
      stratum = stringr::str_trim(stratum)
    )

  as_tibble(ret)
}


#' @templateVar class manova
#' @template title_desc_tidy
#'
#' @param x A `manova` object return from [stats::manova()].
#' @param test One of "Pillai" (Pillai's trace), "Wilks" (Wilk's lambda),
#'   "Hotelling-Lawley" (Hotelling-Lawley trace) or "Roy" (Roy's greatest root)
#'   indicating which test statistic should be used. Defaults to "Pillai".
#' @inheritDotParams stats::summary.manova
#'
#' @evalRd return_tidy(
#'   "term",
#'   "num.df",
#'   "den.df",
#'   "statistic",
#'   "p.value",
#'   pillai = "Pillai's trace.",
#'   wilks = "Wilk's lambda.",
#'   hl = "Hotelling-Lawley trace.",
#'   roy = "Roy's greatest root."
#' )
#'
#'
#' @details Depending on which test statistic is specified only one of `pillai`,
#'   `wilks`, `hl` or `roy` is included.
#'
#' @examples
#'
#' npk2 <- within(npk, foo <- rnorm(24))
#' m <- manova(cbind(yield, foo) ~ block + N * P * K, npk2)
#' tidy(m)
#' @export
#' @seealso [tidy()], [stats::summary.manova()]
#' @family anova tidiers
tidy.manova <- function(x, test = "Pillai", ...) {
  test.pos <- pmatch(test, c(
    "Pillai", "Wilks",
    "Hotelling-Lawley", "Roy"
  ))
  test.name <- c("pillai", "wilks", "hl", "roy")[test.pos]

  as_tidy_tibble(
    summary(x, test = test, ...)$stats, 
    new_names = c("df", test.name, "statistic", "num.df", "den.df", "p.value")
  )
}

#' @templateVar class TukeyHSD
#' @template title_desc_tidy
#'
#' @param x A `TukeyHSD` object return from [stats::TukeyHSD()].
#' @template param_unused_dots
#'
#' @evalRd return_tidy(
#'   "term",
#'   "contrast",
#'   "null.value",
#'   "estimate",
#'   "conf.low",
#'   "conf.high",
#'   "adj.p.value"
#' )
#'
#' @examples
#'
#' fm1 <- aov(breaks ~ wool + tension, data = warpbreaks)
#' thsd <- TukeyHSD(fm1, "tension", ordered = TRUE)
#' tidy(thsd)
#'
#' # may include comparisons on multiple terms
#' fm2 <- aov(mpg ~ as.factor(gear) * as.factor(cyl), data = mtcars)
#' tidy(TukeyHSD(fm2))
#' @export
#' @seealso [tidy()], [stats::TukeyHSD()]
#' @family anova tidiers
tidy.TukeyHSD <- function(x, ...) {
  purrr::map_df(x,
    function(e) {
      null.value <- rep(0, nrow(e))
      e <- cbind(null.value, e)
      as_tidy_tibble(
        e, 
        new_names = c("null.value", "estimate", "conf.low", 
                      "conf.high", "adj.p.value"), 
        new_column = "contrast"
      )
    },
    .id = "term"
  )
}
