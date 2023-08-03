complete.square <- function(X.df.std, base.X.df.std){
  base.regressors <- names(base.X.df.std)
  regressors <- names(X.df.std)

  combinations<-expand.grid(base.regressors,regressors)
  combinations[] <- t(apply(combinations, MARGIN=1, FUN=sort))
  combinations <- unique(combinations)

  do.call(cbind, mapply(function(v1, v2){
    name<-ifelse(startsWith(v1,"mul."), paste0('mul.',v2,'.',v1), paste0('mul.',v1,'.',v2))

    if(v1 %in% names(X.df.std))
      new.var <- data.frame(name=X.df.std[[v1]]*base.X.df.std[[v2]])
    else
      new.var <- data.frame(name=X.df.std[[v2]]*base.X.df.std[[v1]])

    names(new.var) <- c(name)
    return(new.var)
  }, v1=combinations$Var1, v2=combinations$Var2, SIMPLIFY=F))
}
