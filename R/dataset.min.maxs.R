dataset.min.maxs <- function(X.df.std, X.mean.sd){
  # regressors are the names not shifted
  regressors <- names(X.df.std)

  l<-lapply(regressors, function(v){
    # account for all future values where the minimum is
    # at least 2 sd from current dataset minimum
    vals <- X.df.std[[v]]
    if(v %in% names(X.mean.sd))
      prjzero <- -X.mean.sd[[v]]$mean/X.mean.sd[[v]]$sd
    else
      prjzero <- 0
    list("min"=min(vals),"absmin"=min(abs(vals)),"absmax"=max(abs(vals)),
         # zero in original space projected in std space
         "projzero"=prjzero)
  })
  names(l)<-regressors
  return(l)
}
