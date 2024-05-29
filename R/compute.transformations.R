compute.transformations <- function(X.df.std, transformations, regressors.min.values){
  # remove "is." variables
  regressors <- names(X.df.std[, !grepl('^is\\.', names(X.df.std), fixed=F)])

  do.call(cbind, lapply(regressors, function(v){
    new.regressors <- as.data.frame(lapply(names(transformations), function(prefix){
      transf <- transformations[[prefix]]
      # create new column
      transf(X.df.std, X.df.std[[v]], regressors.min.values[[v]]$min)
    }))
    names(new.regressors) <- paste(names(transformations), v, sep=".")
    return(new.regressors)
  }))
}
