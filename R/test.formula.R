#' Test a non-linear formula, get an aggregated result.
#'
#' Test using K-fold cross-validation repeated N times
#'
#' @param complete.X.df The dataset to be used for the test
#' @param y The independent variable
#' @param cur.vars An array of non-linear formula terms to be tested. `cur.vars <- c('a','mul.a.b')` will test the formula `y ~ a + a*b`
#' @param custom.abs.mins A list of user-defined minimum values for dataset columns.
#' @param K The number of parts the dataset is split into for K-fold cross-validation.
#' @param N The number of times the K-fold validation is repeated, shuffling the dataset row orders before each time.
#' @param transformations A list of potentially non-linear transformations allowed in `cur.vars`.
#' @param cv.norm Normalize regressors after train-validation split in inner cross-validation loop.
#'
#' @export
#' @return A 1-row data.frame with error metrics: base.pe, base.cor, base.r.squared, base.max.pe, base.iqr.pe, base.max.cooksd, base.max.cooksd.name
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
#'  test.formula(
#'       X, y,
#'       cur.vars=c('inv.x1','x2'),
#'       custom.abs.mins=list(),
#'       K=2,
#'       N=3,
#'       transformations=list(
#'       # stats:
#'       #    list(
#'       #       "min"=..,
#'       #       "absmin"=..,
#'       #       # zero in original space projected in std space
#'       #       "projzero"=prjzero
#'       #    )
#'         "log10"=function(rdf, x, stats){
#'             log10(0.1+abs(stats$min)+x)
#'         },
#'         "inv"=function(rdf, x, stats){
#'             1/(0.1+abs(stats$min)+x)
#'         }
#'       ),
#'       cv.norm=FALSE
#'  )
#'}
test.formula <- function(
    complete.X.df, y, cur.vars, custom.abs.mins, K, N,
    transformations=list(
      "log10"=function(rdf, x, z){ log10(0.1+abs(z$min)+x) },
      "inv"=function(rdf, x, z){ 1/(0.1+abs(z$min)+x) }
    ),
    cv.norm=TRUE
){
  # impose lexicographical order
  cur.vars <- sort(cur.vars)
  cur.vars.str <- paste(sort(cur.vars), collapse=",")
  message(paste0("Regression on ", cur.vars.str))
  experiments <- cross.validate(complete.X.df, y, cur.vars, custom.abs.mins, K, N,
                                transformations, cv.norm)
  errs.m <- stats::aggregate(
    cbind(base.pe, base.cor, base.r.squared, base.max.pe, base.iqr.pe, base.max.cooksd)~1,
    data=experiments, FUN=mean, na.action="na.pass")

  errs.m$base.max.cooksd.name <- paste(unique(experiments$base.max.cooksd.name), collapse=",")
  errs.m$vars <- cur.vars.str

  return(errs.m)
}
