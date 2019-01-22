#' @templateVar class kmeans
#' @template title_desc_tidy
#'
#' @param x A `kmeans` object created by [stats::kmeans()].
#' @param col.names Dimension names. Defaults to the names of the variables in x.  Set to NULL to get names `x1, x2, ...`.
#' @template param_unused_dots
#'
#' @evalRd return_tidy("size", "withinss", "cluster")
#' 
#' @details For examples, see the kmeans vignette.
#'
#' @aliases kmeans_tidiers
#' @export
#' @seealso [tidy()], [stats::kmeans()]
#' @family kmeans tidiers
tidy.kmeans <- function(x, col.names = colnames(x$centers), ...) {
  
  if(is.null(col.names)){
    col.names <- paste0("x", 1:ncol(x$centers))
  }
  ret <- as.data.frame(x$centers)
  colnames(ret) <- col.names
  ret$size <- x$size
  ret$withinss <- x$withinss
  ret$cluster <- factor(seq_len(nrow(ret)))
  as_tibble(ret)
}


#' @templateVar class kmeans
#' @template title_desc_augment
#' 
#' @inherit tidy.kmeans params examples
#' @template param_data
#'
#' @evalRd return_augment(
#'   ".cluster",
#'   .fitted = FALSE,
#'   .resid = FALSE
#' )
#'
#' @export
#' @seealso [augment()], [stats::kmeans()]
#' @family kmeans tidiers
augment.kmeans <- function(x, data = NULL, ...) {
  if (is.null(data)) {
    stop("Must specify `data` argument.", call. = FALSE)
  }
  fix_data_frame(data, newcol = ".rownames") %>% 
    mutate(.cluster = factor(x$cluster))
}


#' @templateVar class kmeans
#' @template title_desc_glance
#' 
#' @inherit tidy.kmeans params examples
#'
#' @evalRd return_glance("totss", "tot.withinss", "betweenss", "iter")
#'
#' @export
#' @seealso [glance()], [stats::kmeans()]
#' @family kmeans tidiers
glance.kmeans <- function(x, ...) {
  as_tibble(x[c("totss", "tot.withinss", "betweenss", "iter")])
}
