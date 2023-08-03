normalize.test <- function(X.df, mean.sd){
  regressors <- names(X.df[, !grepl('^is\\.', names(X.df), fixed=F)])
  available.regressors <- intersect(names(mean.sd), regressors)
  df1<- as.data.frame( sapply(available.regressors, FUN=function(name){
    values <- X.df[, name]

    colmean <- mean.sd[[name]]$mean
    colsd <- mean.sd[[name]]$sd
    colmin <- mean.sd[[name]]$std.min

    (values - colmean)/colsd
  }, simplify = F) )
  names(df1)<-available.regressors

  df <- cbind(df1,X.df[, grepl('^is\\.', names(X.df), fixed=F)])
  row.names(df)<-row.names(X.df)

  return(df)
}
