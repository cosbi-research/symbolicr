#' Default fitness formula for `genetic.search`
#'
#' @param errs.m a 1-row data.frame with cross-validation results
#' @param max.formula.len the maximum length of the formula we are searching for
#'
#' @return A single double value, the bigger the value the better the formula.
#' @export
#'
#' @examples
#' \dontrun{
#'  best.finetuned <- genetic.search(
#'                      best.vars.l=list(
#'                         c('inv.mul.patch_hyd_2.patch_hyd_2',
#'                           'mul.patch_hyd_5.patch_pos_.'),
#'                           ...
#'                          ),
#'                      complete.X.df=X,
#'                      n.squares=1,
#'                      max.formula.len=4,
#'                      y=Y,
#'                      maxiter=1000,
#'                      fitness.fun=pe.r.squared.formula.len.fitness
#'                   )
#'}
pe.r.squared.formula.len.fitness <- function(errs.m, max.formula.len){
  x0 <- 0.4
  denominator <- exp(10*errs.m$formula.len/max.formula.len*errs.m$base.pe)
  numerator <- sign(errs.m$base.r.squared)*(errs.m$base.r.squared/x0)^2
  numerator / denominator
}
