#' Compute dataset column-wise statistics: min, absmin, absmax, projzero
#'
#' @param X.df.std input dataset
#' @param X.mean.sd pre-computed column-wise statistics for the dataset, mean and sd
#'
#' @return A list of statistics for each column.
#'
#'  min: the minimum of the column values
#'  absmin: the minimum of the absolute values of the columns
#'  absmax: the maximum of the absolute values of the columns
#'  projzero: -mean/sd of the columns, that is the position of the zero in the original, non-normalized space.
#'
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
