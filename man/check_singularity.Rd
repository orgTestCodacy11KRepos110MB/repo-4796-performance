% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_singularity.R
\name{check_singularity}
\alias{check_singularity}
\title{Check mixed models for boundary fits}
\usage{
check_singularity(x, tolerance = 1e-05, ...)
}
\arguments{
\item{x}{A mixed model.}

\item{tolerance}{Indicates up to which value the convergence result is
accepted. The larger \code{tolerance} is, the stricter the test
will be.}

\item{...}{Currently not used.}
}
\value{
\code{TRUE} if the model fit is singular.
}
\description{
Check mixed models for boundary fits.
}
\details{
If a model is "singular", this means that some dimensions of the
variance-covariance matrix have been estimated as exactly zero. This
often occurs for mixed models with complex random effects structures.
\cr \cr
\dQuote{While singular models are statistically well defined (it is
theoretically sensible for the true maximum likelihood estimate to
correspond to a singular fit), there are real concerns that (1) singular
fits correspond to overfitted models that may have poor power; (2) chances
of numerical problems and mis-convergence are higher for singular models
(e.g. it may be computationally difficult to compute profile confidence
intervals for such models); (3) standard inferential procedures such as
Wald statistics and likelihood ratio tests may be inappropriate.}
(\cite{lme4 Reference Manual})
\cr \cr
There is no gold-standard about how to deal with singularity and which
random-effects specification to choose. Beside using fully Bayesian methods
(with informative priors), proposals in a frequentist framework are:
-ize{
\itemize{
\item avoid fitting overly complex models, such that the
variance-covariance matrices can be estimated precisely enough
(\cite{Matuschek et al. 2017})
\item use some form of model selection to choose a model that balances
predictive accuracy and overfitting/type I error (\cite{Bates et al. 2015},
\cite{Matuschek et al. 2017})
\item \dQuote{keep it maximal}, i.e. fit the most complex model consistent
with the experimental design, removing only terms required to allow a
non-singular fit (\cite{Barr et al. 2013})
}
Note the different meaning between singularity and convergence: singularity
indicates an issue with the "true" best estimate, i.e. whether the maximum
likelihood estimation for the variance-covariance matrix of the random
effects is positive definite or only semi-definite. Convergence is a
question of whether we can assume that the numerical optimization has
worked correctly or not.
}
}
\examples{
\dontshow{if (require("lme4")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
library(lme4)
data(sleepstudy)
set.seed(123)
sleepstudy$mygrp <- sample(1:5, size = 180, replace = TRUE)
sleepstudy$mysubgrp <- NA
for (i in 1:5) {
  filter_group <- sleepstudy$mygrp == i
  sleepstudy$mysubgrp[filter_group] <-
    sample(1:30, size = sum(filter_group), replace = TRUE)
}

model <- lmer(
  Reaction ~ Days + (1 | mygrp / mysubgrp) + (1 | Subject),
  data = sleepstudy
)

check_singularity(model)
\dontshow{\}) # examplesIf}
}
\references{
\itemize{
\item Bates D, Kliegl R, Vasishth S, Baayen H. Parsimonious Mixed Models.
arXiv:1506.04967, June 2015.
\item Barr DJ, Levy R, Scheepers C, Tily HJ. Random effects structure for
confirmatory hypothesis testing: Keep it maximal. Journal of Memory and
Language, 68(3):255-278, April 2013.
\item Matuschek H, Kliegl R, Vasishth S, Baayen H, Bates D. Balancing type
I error and power in linear mixed models. Journal of Memory and Language,
94:305-315, 2017.
\item lme4 Reference Manual, \url{https://cran.r-project.org/package=lme4}
}
}
