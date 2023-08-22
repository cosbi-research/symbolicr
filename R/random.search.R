#' Random search for non-linear formula optimization
#'
#' Randomly sample and test different formulas with cross-validation.
#' @seealso genetic.search
#' @seealso cross.validate
#' @seealso empty.sample
#'
#' @param complete.X.df The dataset that contains the base variables the formula is composed of (column-wise)
#' @param y The independent variable to be predicted with the formula
#' @param n.squares The maximum order of the polynomial composition of base variables. Ex. `order 0 = a`, `order 1 = a*b`, `order 2 = a*b*c`
#' @param formula.len The number of terms in the formulas that will be randomly sampled.
#' @param K The number of parts the dataset is split into for K-fold cross-validation.
#' @param N The number of times the K-fold validation is repeated, shuffling the dataset row orders before each time.
#' @param seed An (optional) seed for deterministic run
#' @param transformations A list of potentially non-linear transformations that can be applied on top of the squares. Ex. `order 0, transformation=log10 = log10.a`
#' @param custom.abs.mins A list of user-defined minimum values for dataset columns.
#' @param maxiter Maximum number of genetic evolution epochs
#' @param glob.filepath Has effect only if memoization=TRUE. The path to an rDdata object containing the results of potentially multiple independent previous run.
#' @param local.filepath Has effect only if memoization=TRUE. The path to an rData object where the results of the current run will be stored. If it already exists, the new results will be appended.
#' @param memoization.interval The number of formulas to sample at each iteration, and the frequency of update of `res.filepath` if memoization=TRUE.
#' @param memoization If TRUE test results will be stored in `res.filepath`
#' @param cv.norm Normalize regressors after train-validation split in inner cross-validation loop.
#'
#' @return A data.frame of formulas and the corresponding cross-validation performance measures (R-squared, absolute relative error, max cooks distance). See also `empty.sample`.
#' @export
#'
#' @examples
#' \dontrun{
#'   new.sample.res <- random.search(
#'      complete.X.df, l.F2,
#'      n.squares=1,
#'      formula.len=3,
#'      maxiter=1000000,
#'      glob.filepath = base.filepath,
#'      res.filepath = res.filepath, memoization=T
#'  )
#'}
random.search <- function(
    complete.X.df,
    y,
    n.squares=1,
    formula.len=3,
    K=7,
    N=10,
    seed=NULL,
    transformations=list(
      "log10"=function(x, z){ log10(0.1+abs(z)+x) },
      "inv"=function(x, z){ 1/(0.1+abs(z)+x) }
    ),
    custom.abs.mins=list(),
    maxiter=100,
    glob.filepath=NULL,
    local.filepath=NULL,
    memoization.interval=50,
    memoization=F,
    cv.norm=F){
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
  tot.rows <- choose(regressors.len,formula.len)

  new.sample.res <- empty.sample()
  prev.vars=NULL
  if(memoization){
    prev.sample.res <- readRDS(glob.filepath)
    # restore from previously interrupted run
    if(file.exists(local.filepath)){
      prev.sample.res <- rbind(prev.sample.res, readRDS(local.filepath))
    }
    prev.vars<-sort(prev.sample.res$vars, decreasing=F)
  }

  cur.start <- 0

  # COMPLETELY RANDOMIZED ALGORITHM, WITH 'MANUAL' OPTIMIZATION AT THE END
  while(cur.start < maxiter && cur.start < tot.rows){
    max.r.comb <- RcppAlgos::comboSample(complete.regressors, formula.len, n=min(tot.rows, memoization.interval),
                                         nThreads = 2, seed=seed)# seed=seed)

    l <- apply(max.r.comb, MARGIN=1, simplify = F, FUN=function(cur.vars){
      # impose lexicographical order
      cur.vars <- sort(cur.vars)
      cur.vars.str <- paste(sort(cur.vars), collapse=",")
      print(paste0("Regression on ", cur.vars.str))
      if(!is.null(prev.vars) && length(prev.vars) > 0){
        res <- gtools::binsearch(function(i){
          test.vars <- prev.vars[i]
          ifelse(cur.vars.str<test.vars, -1,
                 ifelse(cur.vars.str>test.vars, 1, 0))
        }, range=c(1, length(prev.vars)), target=0)
      }else{
        res=list(flag='missing')
      }
      if(res$flag != 'Found'){
        experiments <- cross.validate(complete.X.df, y, cur.vars, custom.abs.mins, K, N, n.squares,
                                      transformations, cv.norm)

        errs.m <- stats::aggregate(
          cbind(base.pe, base.cor, base.r.squared, base.max.pe, base.iqr.pe, base.max.cooksd)~1,
          data=experiments, FUN=mean)

        errs.m$base.max.cooksd.name <- paste(unique(experiments$base.max.cooksd.name), collapse=",")
        errs.m$vars <- paste(cur.vars, collapse=',')
        errs.m$n.squares <- n.squares
        errs.m$formula.len <- formula.len

        errs.m <- errs.m[, c('base.pe','base.cor','base.r.squared',
                             'base.max.pe', 'base.iqr.pe', 'base.max.cooksd', 'base.max.cooksd.name',
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
      saveRDS(new.sample.res, local.filepath)
    }
    cur.start <- cur.start + memoization.interval
  }

  return(new.sample.res)
}
