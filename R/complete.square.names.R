complete.square.names <- function(regressors.list){
  order.zero <- regressors.list[[1]]
  complete.regressors <- order.zero
  maxlen <- length(regressors.list)
  if(maxlen > 1){

  }
  for(len in seq(from=2, to=length(regressors.list), by=1)){
    cur.regressors.list <- regressors.list[seq(len)]
    combinations<-expand.grid(cur.regressors.list)
    combinations[] <- t(apply(combinations, MARGIN=1, FUN=sort))
    combinations <- unique(combinations)

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
    complete.regressors <- c(complete.regressors, new.regressors)
  }

  return(complete.regressors)
}
