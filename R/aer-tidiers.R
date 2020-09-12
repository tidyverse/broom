#' @templateVar class tobit
#' @template title_desc_tidy
#'
#' @param x A `tobit` object created by a call to [AER::tobit()].
#' @template param_confint
#' @template param_unused_dots
#' 
#' @details This tidier currently only supports `ivreg`-classed objects
#' outputted by the `AER` package. The `ivreg` package also outputs
#' objects of class `ivreg`, and will be supported in a later release.
#'
#' @evalRd return_tidy(regression = TRUE)
#'
#' @examples
#'
#' library(AER)
#'
#' data("Affairs", package = "AER")
#'
#' tob <- tobit(affairs ~ age + yearsmarried + religiousness + occupation + rating,
#'              data = Affairs)
#'
#' tidy(tob)
#' tidy(tob, conf.int = TRUE)
#' @export
#' @seealso [tidy()], [AER::tobit()]
#' @family AER tidiers
#' @aliases AER_tidiers
tidy.tobit <- function(x, conf.int = FALSE, conf.level = 0.95, ...) {
  
  ret <- as_tibble(unclass(summary(x)$coefficients), rownames = "term")
  colnames(ret) <- c("term", "estimate", "std.error", "statistic", "p.value")
  
  if (conf.int) {
    ci <- broom_confint_terms(summary(x)$coefficients, level = conf.level)
    ret <- dplyr::left_join(ret, ci, by = "term")
  }
  
  ret
}
