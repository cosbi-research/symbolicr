#' Normalize a dataset
#'
#' @param X.df The input dataset to be normalized
#' @param custom.mins A list of user-defined minimum values for dataset columns.
#'
#' @return A list with two values:
#'
#'         The input dataset normalized by subtracting the mean and dividing by the standard deviation.
#'
#'         A list with some column statistic: std.min, mean, sd
#' @export
#'
#' @examples
#' \dontrun{
#' best.vars <- c('inv.mul.patch_hyd_5.patch_hyd_5','mul.patch_ion_3.patch_pos','patch_pos_3')
#'
#' # parse variables
#' parsed.vars <- symbolicr::parse.vars(best.vars, regressors, transformations)
#' # standardize
#' norm.res <- symbolicr::normalize(regressors.df, custom.mins=list())
#' regressors.df.std <- norm.res$X.std
#' regressors.mean.sd <-norm.res$mean.sd
#' # compute regressors
#' regressors.def <- symbolicr::compute.regressors(regressors.df.std, parsed.vars,
#'                    transformations, regressors.mean.sd, regressors.min.values=NULL)
#' regressors.min.values <- regressors.def$min.values
#' formula.df <- regressors.def$regressors
#'
#' # extract coefficients of given formula
#' dataset.std <- cbind(formula.df, y)
#' cur.formula.str <- paste0('y',"~",paste(best.vars, collapse=' + '))
#' base.lm <- lm(as.formula(base.formula), data=dataset.std)
#' base.lm$coefficients
#' }
#'
normalize <- function(X.df, custom.mins){
  # is variables are categorical, don't standardize
  regressors <- names(X.df[, !grepl('^is\\.', names(X.df), fixed=F)])

  norm.values<-lapply(regressors, function(name){
    col <- X.df[[name]]
    colmean<-mean(col, na.rm = T)
    colsd<-stats::sd(col, na.rm = T)
    std.min.eps <- abs( min((col - colmean)/colsd, na.rm = T) )
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
    colmean<-mean(col, na.rm = T)
    colsd<-stats::sd(col, na.rm = T)

    (col - colmean)/colsd
  }) )
  names(df1) <- regressors
  # add is.* variables untouched
  df <- cbind(df1,X.df[, grepl('^is\\.', names(X.df), fixed=F)])
  row.names(df) <- row.names(X.df)

  return(list("X.std"=df,"mean.sd"=norm.values))
}
