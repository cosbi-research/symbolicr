#' Default fitness function for `genetic.search`
#'
#' @param errs.m a 1-row data.frame with cross-validation results
#' @param max.formula.len the maximum length of the formula we are searching for
#'
#' @return A single double value, the bigger the value the better the formula.
#' @export
#'
#' @examples
#' \donttest{
#' # set-up a toy example dataset
#' x1<-runif(100, min=2, max=67)
#' x2<-runif(100, min=0.01, max=0.1)
#' X <- data.frame(x1=x1, x2=x2)
#' # set up a "true" non-linear relationship
#' # with some noise
#' y <- log10(x1^2*x2) + rnorm(100, 0, 0.001)
#'
#' genetic.search(
#'  X,
#'  y,
#'  n.squares=1,
#'  maxiter=10,
#'  glob.filepath=NULL,
#'  local.filepath=NULL,
#'  memoization=FALSE,
#'  pcrossover=0.2,
#'  pmutation=0.8,
#'  seed=NULL,
#'  max.formula.len=2,
#'  keepBest=TRUE,
#'  K=2,
#'  N=3,
#'  popSize = 5,
#'  fitness.fun=pe.r.squared.formula.len.fitness,
#'  best.vars.l = list(
#'        c('x1','x2')
#'  )
#')
#'}
pe.r.squared.formula.len.fitness <- function(errs.m, max.formula.len){
  x0 <- 0.4
  r <- as.double(errs.m$base.r.squared)
  flen <- as.integer(errs.m$formula.len)
  pe <- as.double(errs.m$base.pe)
  denominator <- exp(10*flen/max.formula.len*pe)
  numerator <- sign(r)*(r/x0)^2
  numerator / denominator
}
