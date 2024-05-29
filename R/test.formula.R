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
#'
#' @examples
#' \dontrun{
#'    # do actual cross-validation experiments, record in experiments data.frame
#'    # all the validation-set performances.
#'    # NOTE: complete.X.df should contain the column `patch_hyd_2`, `patch_pos_.` and `patch_hyd_5`
#'    experiments.0 <- test.formula(
#'                       complete.X.df, y,
#'                       cur.vars=c('inv.patch_hyd_2','patch_hyd_5'),
#'                       custom.abs.mins=list(),
#'                       K=7,
#'                       N=10,
#'                       transformations=list(
#'                             "log10"=function(x, min.val){
#'                                            log10(0.1+abs(min.val)+x)
#'                                     },
#'                             "inv"=function(x, min.val){
#'                                            1/(0.1+abs(min.val)+x)
#'                                   }
#'                       )
#'                     )
#'}
test.formula <- function(
    complete.X.df, y, cur.vars, custom.abs.mins, K, N,
    transformations=list(
      "log10"=function(x, z){ log10(0.1+abs(z$min)+x) },
      "inv"=function(x, z){ 1/(0.1+abs(z$min)+x) }
    ),
    cv.norm=T
){
  # impose lexicographical order
  cur.vars <- sort(cur.vars)
  cur.vars.str <- paste(sort(cur.vars), collapse=",")
  print(paste0("Regression on ", cur.vars.str))

  experiments <- cross.validate(complete.X.df, y, cur.vars, custom.abs.mins, K, N,
                                transformations, cv.norm)

  errs.m <- stats::aggregate(
    cbind(base.pe, base.cor, base.r.squared, base.max.pe, base.iqr.pe, base.max.cooksd)~1,
    data=experiments, FUN=mean)

  errs.m$base.max.cooksd.name <- paste(unique(experiments$base.max.cooksd.name), collapse=",")
  errs.m$vars <- cur.vars.str

  return(errs.m)
}
