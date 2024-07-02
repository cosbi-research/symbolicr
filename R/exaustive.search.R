#' Explore all combinations of formula terms
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
#' @param glob.filepath The path to an rDdata object containing the results of potentially multiple independent previous run, that will be excluded from the current run. The file will be automatically updated whith the new formula evaluation results.
#' @param chunk.size If null, compute all missing formulas. If a number, compute only that number of missing formulas.
#' @param cv.norm Normalize regressors after train-validation split in inner cross-validation loop.
#'
#' @return A data.frame of formulas and the corresponding cross-validation performance measures (R-squared, absolute relative error, max cooks distance). See also `empty.sample`.
#' @export
#'
#' @examples
#' \dontrun{
#' base.filepath <- paste0('regression/regression',type,'.exploration.l',formula.len,'.rData')
#' res.new <- exaustive.search(regressors.df, l.Fn,
#'                             n.squares=1,
#'                             formula.len=3,
#'                             K=15, N=10, seed=NULL,
#'                             transformations=list(
#'                               "log10"=function(rdf, x, z){ log10(0.1+abs(z)+x) },
#'                               "inv"=function(rdf, x, z){ 1/(0.1+abs(z)+x) }
#'                             ),
#'                             custom.abs.mins=list(),
#'                             glob.filepath = base.filepath,
#'                             chunk.size=NULL, cv.norm=T)
#' }
exaustive.search <- function(
    complete.X.df,
    y,
    n.squares=1,
    formula.len=3,
    K=7,
    N=10,
    seed=NULL,
    transformations=list(
      "log10"=function(rdf, x, z){ log10(0.1+abs(z)+x) },
      "inv"=function(rdf, x, z){ 1/(0.1+abs(z)+x) }
    ),
    custom.abs.mins=list(),
    glob.filepath=NULL,
    chunk.size=NULL,
    cv.norm=F
){
  if(!is.null(glob.filepath)){
    res <- readRDS(glob.filepath)
  }
  complete.regressors <- compute.regressors.names(complete.X.df, n.squares, transformations)
  # compute combinations up to length formula.len
  regressors.list <- lapply(seq(formula.len), function(x) complete.regressors)
  combinations <- RcppAlgos::comboGrid(regressors.list, repetition = F)
  combinations <- apply(combinations, MARGIN=1, FUN=function(row){
    paste(sort(row), collapse=",")
  })
  names(combinations)<-NULL
  # get missing formulas
  if(!is.null(glob.filepath)){
    missing <- setdiff(combinations, res$vars)
  }else{
    missing <- combinations
  }
  print(paste0("Computing missing formulas: ", length(missing)))
  if(!is.null(chunk.size))
    missing <- missing[seq(1, chunk.size)]
  if(length(missing)>0){
    # compute exaustively all missing formulas
    res.new <- comb.search(complete.X.df, y,
                           # data.frame of n.missing.values x formula.len
                           combinations=t(as.data.frame(strsplit(missing,",",fixed=T))),
                           K=K, N=N, seed=seed,
                           transformations=transformations, custom.abs.mins=list(), cv.norm=T)
    res <- rbind(res, res.new)
    saveRDS(res, glob.filepath)
  }
  return(res.new)
}
