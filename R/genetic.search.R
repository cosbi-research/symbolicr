#' Genetic Algorithm for non-linear formula optimization
#'
#' Starting from an (optional) list of promising formulas,
#' generated with other methods such as `random.search`,
#' explore combinations (crossover) and alterations (mutation)
#' of them in order maximize the value of the fitness function
#' that defaults to `pe.r.squared.formula.len.fitness`
#' @seealso random.search
#'
#'
#' @param complete.X.df The dataset that contains the base variables the formula is composed of (column-wise)
#' @param y The independent variable to be predicted with the formula
#' @param n.squares The maximum order of the polynomial composition of base variables. Ex. `order 0 = a`, `order 1 = a*b`, `order 2 = a*b*c`
#' @param max.formula.len The maximum number of terms in the formula
#' @param seed An (optional) seed for deterministic run
#' @param fitness.fun The function that determine the fitness of a given formula. Defaults to `pe.r.squared.formula.len.fitness`
#' @param transformations A list of potentially non-linear transformations that can be applied on top of the squares. Ex. `order 0, transformation=log10 = log10.a`. Input values are x and z, the array of numbers to be transformed (training set only), and the min max statistics (on the global dataset) respectively.
#' @param custom.abs.mins A list of user-defined minimum values for dataset columns.
#' @param glob.filepath Has effect only if memoization=TRUE. The path to an rDdata object containing the results of potentially multiple independent previous run.
#' @param local.filepath Has effect only if memoization=TRUE. The path to an rData object where the results of the current run will be stored. If it already exists, the new results will be appended.
#' @param memoization If TRUE test results will be stored in `res.filepath`
#' @param monitor Function that will be called on every iteration with the current solutions. Defaults to `monitor.formula.fun`
#' @param maxiter Maximum number of genetic evolution epochs
#' @param K The number of parts the dataset is split into for K-fold cross-validation.
#' @param N The number of times the K-fold validation is repeated, shuffling the dataset row orders before each time.
#' @param pcrossover The probability of crossover between pairs of chromosomes. Typically this is a large value and by default is set to 0.8.
#' @param popSize The population size, the number of formulas considered for genetic evolution.
#' @param pmutation The probability of mutation in a parent chromosome. Usually mutation occurs with a small probability, and by default is set to 0.1.
#' @param keepBest If TRUE, the value `best.iter` of the list returned, will contain a list of the best formulas at each evolution iteration.
#' @param cv.norm Normalize regressors after train-validation split in inner cross-validation loop.
#' @param best.vars.l A list of formulas. Each formula is an array of strings, each string is the textual representation of a formula term. Ex. `cur.vars.l <- list(c('a','mul.a.b'))` will test the formula `y ~ a + a*b`. This list is used as a starting point for genetic evolution. It may come from a-priori knowledge or by extracting the most promising results from `random.search`.
#'
#' @return A list with three values:
#'    list(
#'       best: the best formula found overall
#'       best.iter: a list of best formulas, one for each evolution iteration
#'       results: The output of the GA::ga function, with all the solutions, hyperparameters, etc.
#'    )
#'
#' @export
#'
#' @examples
#' \dontrun{
#'# variables  app_charge pI_Fc patch_pos_3 patch_hyd_2
#'             patch_hyd_5 ens_dipole and is.monovalent
#'# are assumed to be in the complete.X.df input dataset
#'# variables starting with 'is.' suffix won't be normalized,
#'# because assumed to be categorical variables (0/1)
#'best.vars.l <- list(
#'  #c('log10.mul.app_charge.pI_Fc','log10.patch_pos_3',
#'     'mul.patch_pos.pI_Fc'),
#'  #c('inv.mul.patch_hyd_2.patch_hyd_2'),
#'  c('inv.mul.patch_hyd_5.patch_hyd_5','log10.mul.pI_Fc.pI_Fc',
#'    'mul.ens_dipole.is.monovalent')
#')
#'best.finetuned <- genetic.search(
#'  complete.X.df,
#'  l.F2,
#'  n.squares=1,
#'  maxiter=1000,
#'  glob.filepath=file.path(...),
#'  local.filepath=file.path(...),
#'  memoization=F,
#'  pcrossover=0.2,
#'  pmutation=0.8,
#'  seed=NULL,
#'  max.formula.len=4,
#'  keepBest=T,
#'  K=17,
#'  N=10,
#'  popSize = 100,
#'  best.vars.l = best.vars.l
#')
#'}
genetic.search <- function(
    complete.X.df,
    y,
    n.squares=1,
    max.formula.len=4,
    seed=NULL,
    fitness.fun=pe.r.squared.formula.len.fitness,
    transformations=list(
      "log10"=function(rdf, x, z){ log10(0.1+abs(z$min)+x) },
      "inv"=function(rdf, x, z){ 1/(0.1+abs(z$min)+x) }
    ),
    custom.abs.mins=list(),
    glob.filepath=NULL,
    local.filepath=NULL,
    memoization=F,
    monitor=monitor.formula.fun,
    maxiter=100,
    N = 2,
    K = 7,
    pcrossover=0.2,
    popSize=50,
    pmutation=0.8,
    keepBest=F,
    cv.norm=F,
    best.vars.l=list()
){

  if(memoization){
    if(is.character(glob.filepath) & length(glob.filepath) == 1)
      prev.sample.res <- readRDS(glob.filepath)
    else if(is.character(glob.filepath))
      prev.sample.res <- do.call(rbind,lapply(glob.filepath, function(path) readRDS(path)))

    # restore from previously interrupted run
    if(file.exists(local.filepath)){
      new.sample.res <- readRDS(local.filepath)
    }else{
      new.sample.res <- empty.sample()
    }
  }else{
    prev.sample.res<-NULL
    new.sample.res <- empty.sample()
  }

  # compute regressors on full dataset
  complete.regressors <- compute.regressors.names(complete.X.df, n.squares, transformations)
  regressors.len <- length(complete.regressors)
  print(paste0("## Total number of single terms: ", regressors.len))

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
      experiments <- cross.validate(complete.X.df, y, cur.vars, custom.abs.mins, K, N,
                                    transformations, cv.norm)

      errs.m <- stats::aggregate(
        cbind(base.pe, base.cor, base.r.squared, base.max.pe, base.iqr.pe, base.max.cooksd)~1,
        data=experiments, FUN=mean)

      errs.m$base.max.cooksd.name <- paste(unique(experiments$base.max.cooksd.name), collapse=",")
      errs.m$vars <- paste(cur.vars, collapse=',')
      errs.m$n.squares <- n.squares
      errs.m$formula.len <- cur.formula.len

      errs.m <- errs.m[, c('base.pe','base.cor','base.r.squared',
                           'base.max.pe', 'base.iqr.pe', 'base.max.cooksd', 'base.max.cooksd.name',
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
                           vars=prev.res$vars[1], n.squares=prev.res$n.squares[1], formula.len=prev.res$formula.len[1])
    }

    # fitness
    return(fitness.fun(errs.m, max.formula.len))
  }

  if(memoization){
    dt.sample.res <- data.table::as.data.table(prev.sample.res)
    data.table::setkeyv(dt.sample.res, cols="vars", physical = T)
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
    saveRDS(new.sample.res, local.filepath)

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
