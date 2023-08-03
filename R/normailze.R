#' Normalize a dataset
#'
#' @param X.df The input dataset to be normalized
#' @param custom.mins list of user-defined minimum values for dataset columns.
#'
#' @return A list with two values:
#'
#'         The input dataset normalized by subtracting the mean and dividing by the standard deviation.
#'
#'         A list with some column statistic: std.min, mean, sd
#'
normalize <- function(X.df, custom.mins){
  # is variables are categorical, don't standardize
  regressors <- names(X.df[, !grepl('^is\\.', names(X.df), fixed=F)])

  norm.values<-lapply(regressors, function(name){
    col <- X.df[[name]]
    colmean<-mean(col)
    colsd<-stats::sd(col)
    std.min.eps <- abs( min((col - colmean)/colsd) )
    if(name %in% names(custom.mins)){
      std.min.eps <- custom.mins[[name]]
    }

    list("std.min"=std.min.eps,
         "mean"=colmean,
         "sd"=colsd)
  })

  names(norm.values)<-regressors

  df1<- as.data.frame( lapply(regressors, FUN=function(name){
    col <- X.df[[name]]
    colmean<-mean(col)
    colsd<-stats::sd(col)

    (col - colmean)/colsd
  }) )
  names(df1) <- regressors
  # add is.* variables untouched
  df <- cbind(df1,X.df[, grepl('^is\\.', names(X.df), fixed=F)])
  row.names(df) <- row.names(X.df)

  return(list("X.std"=df,"mean.sd"=norm.values))
}