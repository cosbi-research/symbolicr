% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/random.search.R
\name{random.search}
\alias{random.search}
\title{Random search for non-linear formula optimization}
\usage{
random.search(
  complete.X.df,
  y,
  n.squares = 1,
  formula.len = 3,
  K = 7,
  N = 10,
  seed = NULL,
  transformations = list(log10 = function(rdf, x, z) {
     log10(0.1 + abs(z$min) + x)

    }, inv = function(rdf, x, z) {
     1/(0.1 + abs(z$min) + x)
 }),
  custom.abs.mins = list(),
  maxiter = 100,
  glob.filepath = NULL,
  local.filepath = NULL,
  memoization.interval = 50,
  memoization = F,
  cv.norm = F
)
}
\arguments{
\item{complete.X.df}{The dataset that contains the base variables the formula is composed of (column-wise)}

\item{y}{The independent variable to be predicted with the formula}

\item{n.squares}{The maximum order of the polynomial composition of base variables. Ex. \verb{order 0 = a}, \verb{order 1 = a*b}, \verb{order 2 = a*b*c}}

\item{formula.len}{The number of terms in the formulas that will be randomly sampled.}

\item{K}{The number of parts the dataset is split into for K-fold cross-validation.}

\item{N}{The number of times the K-fold validation is repeated, shuffling the dataset row orders before each time.}

\item{seed}{An (optional) seed for deterministic run}

\item{transformations}{A list of potentially non-linear transformations that can be applied on top of the squares. Ex. \verb{order 0, transformation=log10 = log10.a}. Input values are x and z, the array of numbers to be transformed (training set only), and the min max statistics (on the global dataset) respectively.}

\item{custom.abs.mins}{A list of user-defined minimum values for dataset columns.}

\item{maxiter}{Maximum number of genetic evolution epochs}

\item{glob.filepath}{Has effect only if memoization=TRUE. The path to an rDdata object containing the results of potentially multiple independent previous run.}

\item{local.filepath}{Has effect only if memoization=TRUE. The path to an rData object where the results of the current run will be stored. If it already exists, the new results will be appended.}

\item{memoization.interval}{The number of formulas to sample at each iteration, and the frequency of update of \code{res.filepath} if memoization=TRUE.}

\item{memoization}{If TRUE test results will be stored in \code{local.filepath}}

\item{cv.norm}{Normalize regressors after train-validation split in inner cross-validation loop.}
}
\value{
A data.frame of formulas and the corresponding cross-validation performance measures (R-squared, absolute relative error, max cooks distance). See also \code{empty.sample}.
}
\description{
Randomly sample and test different formulas with cross-validation.
}
\examples{
\dontrun{
  transformations <- list(
     # rdf = complete regressors/predictors data.frame
     # x = the column on which we have to compute the non-linearity
     # z = list("min"=min(vals),"absmin"=min(abs(vals)),"absmax"=max(abs(vals)),
     #           zero in original space projected in normalized space,
     #           that is: -mean(vals)/sd(vals)
     #          "projzero"=prjzero)
     "log10"=function(rdf, x, z){
          log10(0.1+abs(z$min)+x)
     },
     "inv"=function(rdf, x, z){
          1/(0.1+abs(z$min)+x)
     }
  )

  new.sample.res <- random.search(
     complete.X.df, l.F2,
     n.squares=1,
     formula.len=3,
     maxiter=1000000,
     glob.filepath = base.filepath,
     res.filepath = res.filepath,
     transformations = transformations,
     memoization=T
 )
}
}
\seealso{
genetic.search

cross.validate

empty.sample
}
