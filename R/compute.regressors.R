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
