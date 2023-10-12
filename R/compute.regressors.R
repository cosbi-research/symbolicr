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
compute.regressors <- function(base.X.df.std, parsed.vars, transformations, X.mean.sd, regressors.min.values=NULL){
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
      # create new column
      df <- as.data.frame(transf(X.df.std.mul[[v]], regressors.min.values[[v]]))
      names(df) <- paste0(parsed.vars[[col_idx]]$transformation.name, '.', v)
      row.names(df) <- row.names(X.df.std.mul)
    }
    return(df)
  }))

  return(list(min.values=regressors.min.values, regressors=X.df.std.mul.transf))
}
