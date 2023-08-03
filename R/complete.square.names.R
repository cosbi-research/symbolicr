complete.square.names <- function(regressors, base.regressors){
  combinations<-expand.grid(base.regressors,regressors)
  combinations[] <- t(apply(combinations, MARGIN=1, FUN=sort))
  combinations <- unique(combinations)

  new.regressors <- do.call(c, mapply(function(v1, v2){
    ifelse(startsWith(v1,"mul."), paste0('mul.',v2,'.',v1), paste0('mul.',v1,'.',v2))
  }, v1=combinations$Var1, v2=combinations$Var2, SIMPLIFY=F))
  names(new.regressors)<-NULL

  return(new.regressors)
}
