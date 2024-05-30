complete.square.names <- function(regressors.list){
  combinations<-expand.grid(regressors.list)
  combinations[] <- t(apply(combinations, MARGIN=1, FUN=sort))
  combinations <- unique(combinations)
  len <- ncol(combinations)

  new.regressors <- apply(combinations, MARGIN=1, FUN=function(row){
    rrow <- rev(row)
    var <- ""
    for(i in seq(len)){
      if(i == 1){
        if(len == 1){
          var <- rrow[i]
        }else if(len >= 2){
          var <- paste0('mul.',rrow[i+1],'.',rrow[i])
        }
      }else if(i < len){
        var <- paste0('mul.',rrow[i+1],'.', var)
      }
    }
    return(var)
  })
  names(new.regressors)<-NULL

  return(new.regressors)
}
