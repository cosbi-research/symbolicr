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
#' \donttest{
#' # set-up a toy example dataset
#' x1<-runif(100, min=2, max=67)
#' x2<-runif(100, min=0.01, max=0.1)
#' X <- data.frame(x1=x1, x2=x2)
#' # set up a "true" non-linear relationship
#' # with some noise
#' y <- log10(x1^2*x2) + rnorm(100, 0, 0.001)
#' regressors <- c('x1','x2')
#' best.vars <- c('inv.mul.x1.x2','mul.x1.x2','x2')
#'
#' transformations=list(
#'   "log"=function(rdf, x, stats){ log(x) },
#'   "log_x1_p"=function(rdf, x, stats){ log(rdf$x1 + x) },
#'   "inv"=function(rdf, x, stats){ 1/x }
#' )
#'
#' # parse variables
#' parsed.vars <- symbolicr::parse.vars(best.vars, regressors, transformations)
#' # standardize
#' norm.res <- symbolicr::normalize(X, custom.mins=list())
#' X.std <- norm.res$X.std
#' X.mean.sd <-norm.res$mean.sd
#' # compute regressors
#' X.def <- symbolicr::regressors(X.std, parsed.vars,
#'                    transformations, X.mean.sd, regressors.min.values=NULL)
#' X.min.values <- X.def$min.values
#' formula.df <- X.def$regressors
#'
#' # extract coefficients of given formula
#' dataset.std <- cbind(formula.df, y)
#' cur.formula.str <- paste0('y',"~",paste(best.vars, collapse=' + '))
#' base.lm <- lm(as.formula(cur.formula.str), data=formula.df)
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
