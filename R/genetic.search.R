genetic.search <- function(
    best.vars.l,
    complete.X.df,
    n.squares,
    y,
    seed=NULL,
    max.formula.len=4,
    fitness.fun=pe.r.squared.formula.len.fitness,
    transformations=list(
      "log10"=function(x, z){ log10(0.1+abs(z)+x) },
      "inv"=function(x, z){ 1/(0.1+abs(z)+x) }
    ),
    custom.abs.mins=list(),
    base.filepath=NULL,
    res.filepath=NULL,
    memoization=T,
    monitor=monitor.formula.fun,
    maxiter=100,
    N = 2,
    K = 7,
    pcrossover=0.2,
    popSize=50,
    pmutation=0.8,
    keepBest=F
){

  if(memoization){
    prev.sample.res <- readRDS(base.filepath)
    # restore from previously interrupted run
    if(file.exists(res.filepath)){
      new.sample.res <- readRDS(res.filepath)
    }else{
      new.sample.res <- empty.sample()
    }
  }else{
    prev.sample.res<-NULL
    new.sample.res <- empty.sample()
  }

  # compute regressors on full dataset
  regressors <- names(complete.X.df)
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
  # cross-validation parameters
  ns <- nrow(complete.X.df)
  optim_fun <- function(x, dt.sample.res, memoization, max.formula.len){
    Inf.value <- 1e+8
    # return the combination given by par
    formula.num <- which(x==1)
    cur.formula.len <- length(formula.num)
    if(cur.formula.len <= 0 || cur.formula.len > max.formula.len)
      return(-Inf.value)
    #formula.num <- sapply(par, function(p){ max(min(round(abs(p), 0), regressors.len), 1) })
    cur.vars <- sapply(formula.num, function(i){ complete.regressors[i] })
    # impose lexicographical order
    cur.vars <- sort(cur.vars)
    cur.vars.str <- paste(cur.vars, collapse=",")
    #print(paste0("Regression on ", cur.vars.str))
    prev.res <- empty.sample()
    if(!is.null(dt.sample.res))
      prev.res <- dt.sample.res[dt.sample.res$vars==cur.vars.str, ]
    if(!is.null(new.sample.res) && nrow(prev.res) == 0) # check in local df
      prev.res <- new.sample.res[new.sample.res$vars==cur.vars.str, ]

    if(nrow(prev.res) == 0){
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
      errs.m$formula.len <- cur.formula.len

      errs.m <- errs.m[, c('base.pe','base.cor','base.r.squared',
                           'base.max.pe', 'base.iqr.pe', 'base.max.cooksd', 'base.max.cooksd.name',
                           'glmnet.pe','glmnet.r.squared',
                           'vars', 'n.squares', 'formula.len')]
      # save
      if(memoization){
        new.sample.res <<- rbind(new.sample.res,errs.m)
      }
      #print(paste0("Regression DONE"))
    }else{
      #print("NOTICE: Skipping already computed..")
      errs.m <- data.frame(base.pe=prev.res$base.pe[1],base.cor=prev.res$base.cor[1],base.r.squared=prev.res$base.r.squared[1],
                           base.max.pe=prev.res$base.max.pe[1], base.iqr.pe=prev.res$base.iqr.pe[1], base.max.cooksd=prev.res$base.max.cooksd[1], base.max.cooksd.name=prev.res$base.max.cooksd.name[1],
                           glmnet.pe=prev.res$glmnet.pe[1],glmnet.r.squared=prev.res$glmnet.r.squared[1],
                           vars=prev.res$vars[1], n.squares=prev.res$n.squares[1], formula.len=prev.res$formula.len[1])
    }

    # fitness
    return(fitness.fun(errs.m, max.formula.len))
  }

  if(memoization){
    dt.sample.res <- as.data.table(prev.sample.res)
    setkeyv(dt.sample.res, cols="vars", physical = T)
  }else{
    dt.sample.res<-NULL
  }

  # for every multistart point in best.vars.l
  # apply GA
  # binary encoding for genetic algorithm
  best.results.m <- as.matrix(do.call(rbind, lapply(best.vars.l, function(best.vars){
    optim_results.perturbed <- sapply(best.vars, function(var){
      v.esc <- regex.escape(var)
      grep(paste0('^',v.esc,'$'), complete.regressors)
    }, USE.NAMES = F)
    optim_results.perturbed.bin <- rep(0, regressors.len)
    optim_results.perturbed.bin[optim_results.perturbed] <- 1
    optim_results.perturbed.bin
  })))

  if(typeof(monitor) == "closure"){
    monitor.fun <- monitor
  }else{
    monitor.fun <- FALSE
  }

  optim_results <- GA::ga(type="binary",
                          fitness=optim_fun,
                          dt.sample.res=dt.sample.res,
                          memoization=memoization,
                          max.formula.len=max.formula.len,
                          nBits=regressors.len,
                          popSize=popSize,
                          pcrossover = pcrossover,
                          pmutation = pmutation,
                          suggestions=best.results.m,
                          maxiter=maxiter,
                          run=maxiter,
                          seed=seed,
                          names=complete.regressors,
                          monitor=monitor.fun,
                          keepBest=keepBest
  )
  if(memoization)
    saveRDS(new.sample.res, res.filepath)

  best.iter<-NULL
  if(keepBest)
    best.iter <- lapply(optim_results@bestSol, function(sol){ complete.regressors[which(sol == 1)] })

  s<-summary(optim_results)
  # return best formula
  return(list(
    best=complete.regressors[which(s$solution == 1)],
    best.iter=best.iter,
    results=optim_results
  )
  )
}
