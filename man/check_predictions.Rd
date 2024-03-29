% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pp_check.R
\name{check_predictions}
\alias{check_predictions}
\alias{check_predictions.default}
\alias{posterior_predictive_check}
\alias{check_posterior_predictions}
\title{Posterior predictive checks}
\usage{
check_predictions(object, iterations = 50, check_range = FALSE, ...)

\method{check_predictions}{default}(
  object,
  iterations = 50,
  check_range = FALSE,
  re_formula = NULL,
  verbose = TRUE,
  ...
)

posterior_predictive_check(object, iterations = 50, check_range = FALSE, ...)

check_posterior_predictions(object, iterations = 50, check_range = FALSE, ...)
}
\arguments{
\item{object}{A statistical model.}

\item{iterations}{The number of draws to simulate/bootstrap.}

\item{check_range}{Logical, if \code{TRUE}, includes a plot with the minimum
value of the original response against the minimum values of the replicated
responses, and the same for the maximum value. This plot helps judging whether
the variation in the original data is captured by the model or not
(\emph{Gelman et al. 2020, pp.163}). The minimum and maximum values of \code{y} should
be inside the range of the related minimum and maximum values of \code{yrep}.}

\item{...}{Passed down to \code{simulate()}.}

\item{re_formula}{Formula containing group-level effects (random effects) to
be considered in the simulated data. If \code{NULL} (default), condition
on all random effects. If \code{NA} or \code{~0}, condition on no random
effects. See \code{simulate()} in \strong{lme4}.}

\item{verbose}{Toggle warnings.}
}
\value{
A data frame of simulated responses and the original response vector.
}
\description{
Posterior predictive checks mean "simulating replicated data
under the fitted model and then comparing these to the observed data"
(\emph{Gelman and Hill, 2007, p. 158}). Posterior predictive checks
can be used to "look for systematic discrepancies between real and
simulated data" (\emph{Gelman et al. 2014, p. 169}).

\strong{performance} provides posterior predictive check methods for a variety
of frequentist models (e.g., \code{lm}, \code{merMod}, \code{glmmTMB}, ...). For Bayesian
models, the model is passed to \code{\link[bayesplot:pp_check]{bayesplot::pp_check()}}.
}
\details{
An example how posterior predictive checks can also be used for model
comparison is Figure 6 from \emph{Gabry et al. 2019, Figure 6}.

\if{html}{\cr \figure{pp_check.png}{options: width="90\%" alt="Posterior Predictive Check"} \cr}
The model shown in the right panel (b) can simulate new data that are more
similar to the observed outcome than the model in the left panel (a). Thus,
model (b) is likely to be preferred over model (a).
}
\note{
Every model object that has a \code{simulate()}-method should work with
\code{check_predictions()}. On R 3.6.0 and higher, if \strong{bayesplot} (or a
package that imports \strong{bayesplot} such as \strong{rstanarm} or \strong{brms})
is loaded, \code{pp_check()} is also available as an alias for \code{check_predictions()}.
}
\examples{
library(performance)
model <- lm(mpg ~ disp, data = mtcars)
if (require("see")) {
  check_predictions(model)
}
}
\references{
\itemize{
\item Gabry, J., Simpson, D., Vehtari, A., Betancourt, M., and Gelman, A. (2019).
Visualization in Bayesian workflow. Journal of the Royal Statistical Society:
Series A (Statistics in Society), 182(2), 389–402. https://doi.org/10.1111/rssa.12378
\item Gelman, A., and Hill, J. (2007). Data analysis using regression and
multilevel/hierarchical models. Cambridge; New York: Cambridge University Press.
\item Gelman, A., Carlin, J. B., Stern, H. S., Dunson, D. B., Vehtari, A., and
Rubin, D. B. (2014). Bayesian data analysis. (Third edition). CRC Press.
\item Gelman, A., Hill, J., and Vehtari, A. (2020). Regression and Other Stories.
Cambridge University Press.
}
}
