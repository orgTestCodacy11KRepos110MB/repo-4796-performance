#' @title Binned residuals for logistic regression
#' @name binned_residuals
#'
#' @description Check model quality of logistic regression models.
#'
#' @param model A \code{glm}-object with binomial-family.
#' @param term Name of independent variable from \code{x}. If not \code{NULL},
#'   average residuals for the categories of \code{term} are plotted; else,
#'   average residuals for the estimated probabilities of the response are
#'   plotted.
#' @param n_bins Numeric, the number of bins to divide the data. If
#'   \code{n_bins = NULL}, the square root of the number of observations is
#'   taken.
#' @param ... Further argument like \code{size} (for point-size) or
#'   \code{color} (for point-colors).
#'
#' @return A data frame representing the data that is mapped to the plot, which is
#'   automatically plotted. In case all residuals are inside the error bounds,
#'   points are black. If some of the residuals are outside the error bounds
#'   (indicates by the grey-shaded area), blue points indicate residuals that
#'   are OK, while red points indicate model under- or overfitting for the
#'   related range of estimated probabilities.
#'
#' @details Binned residual plots are achieved by \dQuote{dividing the data into
#'   categories (bins) based on their fitted values, and then plotting
#'   the average residual versus the average fitted value for each bin.}
#'   \cite{(Gelman, Hill 2007: 97)}. If the model were true, one would
#'   expect about 95\% of the residuals to fall inside the error bounds.
#'   \cr \cr
#'   If \code{term} is not \code{NULL}, one can compare the residuals in
#'   relation to a specific model predictor. This may be helpful to check
#'   if a term would fit better when transformed, e.g. a rising and falling
#'   pattern of residuals along the x-axis (the pattern is indicated by
#'   a green line) is a signal to consider taking the logarithm of the
#'   predictor (cf. Gelman and Hill 2007, pp. 97ff).
#'
#' @note Since \code{binned_residuals()} returns a data frame, the default
#'   action for the result is \emph{printing}. However, the `print()`-method for
#'   \code{binned_residuals()} actually creates a plot. For further modifications
#'   of the plot, use `print()` and add ggplot-layers to the return values,
#'   e.g \code{plot(binned_residuals(model)) + see::scale_color_pizza()}.
#'
#' @references Gelman, A., & Hill, J. (2007). Data analysis using regression and multilevel/hierarchical models. Cambridge; New York: Cambridge University Press.
#'
#' @examples
#' model <- glm(vs ~ wt + mpg, data = mtcars, family = "binomial")
#' binned_residuals(model)
#' @importFrom stats fitted sd complete.cases
#' @importFrom insight get_data get_response find_response
#' @export
binned_residuals <- function(model, term = NULL, n_bins = NULL, ...) {
  fv <- stats::fitted(model)
  mf <- insight::get_data(model)

  if (is.null(term)) {
    pred <- fv
  } else {
    pred <- mf[[term]]
  }

  y <- .recode_to_zero(insight::get_response(model)) - fv

  if (is.null(n_bins)) n_bins <- round(sqrt(length(pred)))

  breaks.index <- floor(length(pred) * (1:(n_bins - 1)) / n_bins)
  breaks <- unique(c(-Inf, sort(pred)[breaks.index], Inf))

  model.binned <- as.numeric(cut(pred, breaks))

  d <- suppressWarnings(lapply(1:n_bins, function(.x) {
    items <- (1:length(pred))[model.binned == .x]
    model.range <- range(pred[items], na.rm = TRUE)
    xbar <- mean(pred[items], na.rm = TRUE)
    ybar <- mean(y[items], na.rm = TRUE)
    n <- length(items)
    sdev <- stats::sd(y[items], na.rm = TRUE)

    data.frame(
      xbar = xbar,
      ybar = ybar,
      n = n,
      x.lo = model.range[1],
      x.hi = model.range[2],
      se = 2 * sdev / sqrt(n)
    )
  }))

  d <- do.call(rbind, d)
  d <- d[stats::complete.cases(d), ]

  gr <- abs(d$ybar) > abs(d$se)
  d$group <- "yes"
  d$group[gr] <- "no"

  resid_ok <- sum(d$group == "yes") / length(d$group)

  if (resid_ok < .8) {
    insight::print_color(sprintf("Warning: Probably bad model fit. Only about %g%% of the residuals are inside the error bounds.\n", round(100 * resid_ok)), "red")
  } else if (resid_ok < .95) {
    insight::print_color(sprintf("Warning: About %g%% of the residuals are inside the error bounds (~95%% or higher would be good).\n", round(100 * resid_ok)), "yellow")
  } else {
    insight::print_color(sprintf("Ok: About %g%% of the residuals are inside the error bounds.\n", round(100 * resid_ok)), "green")
  }

  add.args <- lapply(match.call(expand.dots = FALSE)$`...`, function(x) x)
  size <- if ("size" %in% names(add.args)) add.args[["size"]] else 2
  color <- if ("color" %in% names(add.args)) add.args[["color"]] else c("#d11141", "#00aedb")

  class(d) <- c("binned_residuals", "see_binned_residuals", class(d))
  attr(d, "resp_var") <- insight::find_response(model)
  attr(d, "term") <- term
  attr(d, "geom_size") <- size
  attr(d, "geom_color") <- color

  d
}