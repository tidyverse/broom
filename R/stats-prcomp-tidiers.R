#' @templateVar class prcomp
#' @template title_desc_tidy
#'
#' @param x A `prcomp` object returned by [stats::prcomp()].
#' @param matrix Character specifying which component of the PCA should be
#'   tidied. 
#'   
#'   - `"u"`, `"samples"`, or `"x"`: returns information about the map from
#'     the original space into principle components space.
#'   
#'   - `"v"`, `"rotation"`, or `"variables"`: returns information about the
#'     map from principle components space back into the original space.
#'   
#'   - `"d"` or `"pcs"`: returns information about the eigenvalues.
#'        
#' @template param_unused_dots
#'
#' @return A [tibble::tibble] with columns depending on the component of 
#'   PCA being tidied.
#'   
#'   If `matrix` is `"u"`, `"samples"`, or `"x"` each row in the tidied
#'   output corresponds to the original data in PCA space. The columns are:
#'   
#'   \item{`row`}{ID of the original observation (i.e. rowname from original
#'     data).}
#'   \item{`PC`}{Integer indicating a principle component.}
#'   \item{`value`}{The score of the observation for that particular principle
#'     component. That is, the location of the observation in PCA space.}
#'     
#'   If `matrix` is `"v"`, `"rotation"`, or `"variables"`, each row in the
#'   tidied ouput corresponds to information about the principle components
#'   in the original space. The columns are:
#'   
#'   \item{`row`}{The variable labels (colnames) of the data set on
#'   which PCA was performed}
#'   \item{`PC`}{An integer vector indicating the principal component}
#'   \item{`value`}{The value of the eigenvector (axis score) on the
#'   indicated principal component}
#'   
#'   If `matrix` is `"d"` or `"pcs"`, the columns are:
#'   
#'   \item{`PC`}{An integer vector indicating the principal component}
#'   \item{`std.dev`}{Standard deviation explained by this PC}
#'   \item{`percent`}{Percentage of variation explained}
#'   \item{`cumulative`}{Cumulative percentage of variation explained}
#' 
#' @details See https://stats.stackexchange.com/questions/134282/relationship-between-svd-and-pca-how-to-use-svd-to-perform-pca
#'   for information on how to interpret the various tidied matrices. Note
#'   that SVD is only equivalent to PCA on centered data.
#'
#' @examples
#'
#' pc <- prcomp(USArrests, scale = TRUE)
#'
#' # information about rotation
#' tidy(pc)
#'
#' # information about samples (states)
#' tidy(pc, "samples")
#'
#' # information about PCs
#' tidy(pc, "pcs")
#'
#' # state map
#' library(dplyr)
#' library(ggplot2)
#'
#' pc %>%
#'   tidy(matrix = "samples") %>%
#'   mutate(region = tolower(row)) %>%
#'   inner_join(map_data("state"), by = "region") %>%
#'   ggplot(aes(long, lat, group = group, fill = value)) +
#'   geom_polygon() +
#'   facet_wrap(~ PC) +
#'   theme_void() +
#'   ggtitle("Principal components of arrest data")
#'
#' au <- augment(pc, data = USArrests)
#' au
#'
#' ggplot(au, aes(.fittedPC1, .fittedPC2)) +
#'   geom_point() +
#'   geom_text(aes(label = .rownames), vjust = 1, hjust = 1)
#'
#' @aliases prcomp_tidiers
#' @export
#' @seealso [stats::prcomp()], [svd_tidiers]
#' @family svd tidiers
tidy.prcomp <- function(x, matrix = "u", ...) {
  if (length(matrix) > 1) {
    stop("Must select a single matrix to tidy.", call. = FALSE)
  }

  MATRIX <- c("rotation", "x", "variables", "samples", "v", "u", "pcs", "d")
  matrix <- match.arg(matrix, MATRIX)

  ncomp <- NCOL(x$rotation)
  if (matrix %in% c("pcs", "d")) {
    nn <- c("std.dev", "percent", "cumulative")
    ret <- fix_data_frame(t(summary(x)$importance),
      newnames = nn,
      newcol = "PC"
    )
  } else if (matrix %in% c("rotation", "variables", "v")) {
    labels <- if (is.null(rownames(x$rotation))) {
      1:nrow(x$rotation)
    } else {
      rownames(x$rotation)
    }
    variables <- tidyr::gather(as.data.frame(x$rotation))
    ret <- data.frame(
      label = rep(labels, times = ncomp),
      variables,
      stringsAsFactors = FALSE
    )
    names(ret) <- c("column", "PC", "value")
  } else if (matrix %in% c("x", "samples", "u")) {
    labels <- if (is.null(rownames(x$x))) 1:nrow(x$x) else rownames(x$x)
    samples <- tidyr::gather(as.data.frame(x$x))
    ret <- data.frame(
      label = rep(labels, times = ncomp),
      samples
    )
    names(ret) <- c("row", "PC", "value")
  }

  ## change the PC to a numeric
  ret <- mutate(ret, PC = as.numeric(stringr::str_replace(PC, "PC", "")))
  as_tibble(ret)
}


#' @templateVar class prcomp
#' @template title_desc_augment
#' 
#' @inheritParams tidy.prcomp
#' @template param_data
#' @template param_newdata
#'
#' @return A [tibble::tibble] containing the original data along with 
#'   additional columns containing each observation's projection into
#'   PCA space.
#'
#' @export
#' @seealso [stats::prcomp()], [svd_tidiers]
#' @family svd tidiers
#' 
augment.prcomp <- function(x, data = NULL, newdata = NULL, ...) {
  ret <- if (!missing(newdata)) {
    ret <- data.frame(.rownames = rownames(newdata))
    pred <- as.data.frame(predict(x, newdata = newdata))
    names(pred) <- paste0(".fitted", names(pred))
    cbind(ret, newdata, pred)
  } else {
    pred <- as.data.frame(predict(x))
    names(pred) <- paste0(".fitted", names(pred))
    if (!missing(data) && !is.null(data)) {
      cbind(.rownames = rownames(data), data, pred)
    } else {
      data.frame(.rownames = rownames(x$x), pred)
    }
  }
  as_tibble(ret)
}
