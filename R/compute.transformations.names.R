compute.transformations.names <- function(regressors, transformations){
  real.regressors <- regressors[!grepl('^is\\.', regressors, fixed=F)]
  new.regressors <- c()
  for(v in real.regressors){
    new.regressors <- c(new.regressors, paste(names(transformations), v, sep="."))
  }
  return(new.regressors)
}
