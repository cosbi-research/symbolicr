#' Compute regressors of a given non-linear formula
#'
#'
#' @seealso random.search
#' @seealso genetic.search
#'
#' @param base.X.df.std A data.frame with the base variables that compose the terms of the non-linear formula
#' @param parsed.vars The results of the symbolicr::parsed.vars
#' @param transformations A list of potentially non-linear transformations that can be used in the formula terms.
#' @param X.mean.sd The `mean.sd` list entry of the returned value of `normalize`
#' @param regressors.min.values The output of `dataset.min.maxs`. If NULL, minimum values are computed on `base.X.df.std`. Use this parameter if you want to fix the minimum values, for instance if you compute it in a subset of the full dataset, as happens in the cross-validation.
#'
#' @return Return a data.frame with the columns corresponding to each formula term.
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
#' symbolicr::regressors(X.std, parsed.vars,
#'                    transformations, X.mean.sd, regressors.min.values=NULL)
#' }
#'
regressors <- function(base.X.df.std, parsed.vars, transformations, X.mean.sd, regressors.min.values=NULL){
  regressors <- names(base.X.df.std)

  # multiplication only
  X.df.std.mul <- do.call(cbind, lapply(parsed.vars, function(parsed.var){
    n.mul<-length(parsed.var$prods)
    if(n.mul > 1){
      rev.prods <- rev(parsed.var$prods)
      var.name <- paste(c('mul', rev.prods[2], rev.prods[1]), collapse=".")
      if(n.mul>2){
        for(new.prod in rev.prods[seq(3,n.mul)]){
          var.name <- paste(c('mul', new.prod, var.name), collapse=".")
        }
      }
      col <- as.data.frame(apply(base.X.df.std[ ,parsed.var$prods, drop=F], MARGIN=1, function(row){
        prod(row)
      }))
    }else{
      var.name <- parsed.var$prods[1]
      col <- base.X.df.std[, c(var.name), drop=F]
    }

    names(col)<-var.name
    return(col)
  }))

  # get min values
  if(is.null(regressors.min.values))
    regressors.min.values <- dataset.min.maxs(X.df.std.mul, X.mean.sd)

  X.df.std.mul.transf <- do.call(cbind, lapply(seq(length(parsed.vars)), FUN=function(col_idx){
    if(is.null(parsed.vars[[col_idx]]$transformation.name)){
      df <- X.df.std.mul[, col_idx, drop=F]
    }else{
      # apply transformations on top
      transf <- transformations[[parsed.vars[[col_idx]]$transformation.name]]
      v<-names(X.df.std.mul)[col_idx]
      x<-X.df.std.mul[[v]]
      x.min <- regressors.min.values[[v]]
      # create new column with the result of the transformation
      df <- as.data.frame( transf(base.X.df.std, x, x.min) )
      names(df) <- paste0(parsed.vars[[col_idx]]$transformation.name, '.', v)
      row.names(df) <- row.names(X.df.std.mul)
    }
    return(df)
  }))

  return(list(min.values=regressors.min.values, regressors=X.df.std.mul.transf))
}
