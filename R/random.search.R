random.search <- function(
    complete.X.df,
    n.squares,
    formula.len,
    y,
    K=7,
    N=10,
    seed=NULL,
    transformations=list(
      "log10"=function(x, z){ log10(0.1+abs(z)+x) },
      "inv"=function(x, z){ 1/(0.1+abs(z)+x) }
    ),
    custom.abs.mins=list(),
    maxiter=100,
    base.filepath=NULL,
    res.filepath=NULL,
    memoization.interval=50,
    memoization=T){
  regressors <- names(complete.X.df.std)
  complete.regressors <- regressors
  if(n.squares>0){
    l <- list()
    l[[1]] <- regressors;
    for(i in seq(n.squares)){
      l[[i+1]] <- complete.square.names(l[[i]], regressors)
    }
    complete.regressors <- unlist(l)
  }
  complete.regressors <- c(complete.regressors, compute.transformations.names(complete.regressors, transformations))
  regressors.len <- length(complete.regressors)
  tot.rows <- choose(regressors.len,formula.len)

  new.sample.res <- empty.sample()
  prev.vars=NULL
  if(memoization){
    prev.sample.res <- readRDS(base.filepath)
    prev.vars<-sort(prev.sample.res$vars, decreasing=F)
  }

  cur.start <- 0

  # COMPLETELY RANDOMIZED ALGORITHM, WITH 'MANUAL' OPTIMIZATION AT THE END
  while(cur.start < maxiter && cur.start < tot.rows){
    max.r.comb <- RcppAlgos::comboSample(complete.regressors, formula.len, n=memoization.interval,
                                         nThreads = 2, seed=seed)# seed=seed)

    l <- apply(max.r.comb, MARGIN=1, simplify = F, FUN=function(cur.vars){
      # impose lexicographical order
      cur.vars <- sort(cur.vars)
      cur.vars.str <- paste(sort(cur.vars), collapse=",")
      print(paste0("Regression on ", cur.vars.str))
      if(!is.null(prev.vars) && length(prev.vars) > 0){
        res <- binsearch(function(i){
          test.vars <- prev.vars[i]
          ifelse(cur.vars.str<test.vars, -1,
                 ifelse(cur.vars.str>test.vars, 1, 0))
        }, range=c(1, length(prev.vars)), target=0)
      }else{
        res=list(flag='missing')
      }
      if(res$flag != 'Found'){
        experiments <- cross.validate(complete.X.df, y, cur.vars, custom.abs.mins, K, N, n.squares,
                                      transformations)

        errs.m <- aggregate(
          cbind(base.pe, base.cor, base.r.squared, base.max.pe, base.iqr.pe, base.max.cooksd)~1,
          data=experiments, FUN=mean)

        errs.m$base.max.cooksd.name <- paste(unique(experiments$base.max.cooksd.name), collapse=",")
        errs.m$glmnet.pe <- NA
        errs.m$glmnet.r.squared <- NA
        errs.m$vars <- paste(cur.vars, collapse=',')
        errs.m$n.squares <- n.squares
        errs.m$formula.len <- formula.len

        errs.m <- errs.m[, c('base.pe','base.cor','base.r.squared',
                             'base.max.pe', 'base.iqr.pe', 'base.max.cooksd', 'base.max.cooksd.name',
                             'glmnet.pe','glmnet.r.squared',
                             'vars', 'n.squares', 'formula.len')]
      }else{
        print("NOTICE: Skipping already computed..")
        errs.m <- empty.sample()
      }

      return(errs.m)
    })

    sample.res<-do.call(rbind,l)
    new.sample.res <- rbind(new.sample.res, sample.res)
    if(memoization){
      saveRDS(new.sample.res, res.filepath)
    }
    cur.start <- cur.start + memoization.interval
  }

  return(new.sample.res)
}
