#' Get transformed regressors names
#'
#' @param regressors array of regressors of type string
#' @param transformations list of transformations
#'
#' @return array of transformed regressors
#' @export
#'
transformations.names <- function(regressors, transformations){
  real.regressors <- regressors[!grepl('^is\\.', regressors, fixed=F)]
  new.regressors <- c()
  for(v in real.regressors){
    new.regressors <- c(new.regressors, paste(names(transformations), v, sep="."))
  }
  return(new.regressors)
}
