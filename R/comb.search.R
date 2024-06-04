#' Explore all combinations of formula terms
#'
#' Given a set of formulas, this function systematically evaluates
#' all combinations of formula terms, of a given length.
#'
#' @param complete.X.df The dataset that contains the base variables the formula is composed of (column-wise)
#' @param y The independent variable to be predicted with the formula
#' @param combinations A data.frame of combinations of shape (num.combinations, formula.len)
#' @param K The number of parts the dataset is split into for K-fold cross-validation.
#' @param N The number of times the K-fold validation is repeated, shuffling the dataset row orders before each time.
#' @param seed An (optional) seed for deterministic run
#' @param transformations A list of potentially non-linear transformations that can be applied on top of the squares. Ex. `order 0, transformation=log10 = log10.a`
#' @param custom.abs.mins A list of user-defined minimum values for dataset columns.
#' @param cv.norm Normalize regressors after train-validation split in inner cross-validation loop.
#'
#' @return A data.frame of formulas and the corresponding cross-validation performance measures (R-squared, absolute relative error, max cooks distance). See also `empty.sample`.
#' @export
#'
#' @examples
#' \dontrun{
#' base.filepath <- paste0('regression/regression',type,'.exploration.l',formula.len,'.rData')
#' res <- readRDS(base.filepath)
#' complete.regressors <- compute.regressors.names(regressors.df, n.squares, transformations)
#' # compute combinations up to length formula.len
#' regressors.list <- lapply(seq(formula.len), function(x) complete.regressors)
#' combinations <- RcppAlgos::comboGrid(regressors.list, repetition = F)
#' combinations <- apply(combinations, MARGIN=1, FUN=function(row){
#'   paste(row, collapse=",")
#' })
#' names(combinations)<-NULL
#' # get missing formulas
#' missing <- setdiff(combinations, res$vars)
#' # compute exaustively all missing formulas
#' res.new <- comb.search(regressors.df, l.Fn,
#'                        # data.frame of n.missing.values x formula.len
#'                        combinations=t(as.data.frame(strsplit(missing,",",fixed=T))),
#'                        K=K, N=N, seed=seed,
#'                        transformations=transformations, custom.abs.mins=list(), cv.norm=T)
#' res <- rbind(res, res.new)
#' saveRDS(res, base.filepath)
#' }
comb.search <- function(
    complete.X.df,
    y,
    combinations,
    K=7,
    N=10,
    seed=NULL,
    transformations=list(
      "log10"=function(rdf, x, z){ log10(0.1+abs(z)+x) },
      "inv"=function(rdf, x, z){ 1/(0.1+abs(z)+x) }
    ),
    custom.abs.mins=list(),
    cv.norm=F
){

  res <- do.call(rbind, apply(combinations, MARGIN=1, simplify = F, FUN=function(cur.vars){
    # impose lexicographical order
    cur.vars <- sort(cur.vars)
    cur.vars.str <- paste(sort(cur.vars), collapse=",")
    print(paste0("Regression on ", cur.vars.str))
    cur.vars.parsed <- parse.vars(cur.vars, names(complete.X.df), transformations)
    cur.n.squares <- max(sapply(cur.vars.parsed, function(cur.var.parsed) length(cur.var.parsed$prods)))-1

    experiments <- cross.validate(complete.X.df, y, cur.vars, custom.abs.mins, K, N,
                                  transformations, cv.norm=cv.norm)
    errs.m <- stats::aggregate(
      cbind(base.pe, base.cor, base.r.squared, base.max.pe, base.iqr.pe, base.max.cooksd)~1,
      data=experiments, FUN=mean, na.action = 'na.pass')

    errs.m$base.max.cooksd.name <- paste(unique(experiments$base.max.cooksd.name), collapse=",")
    errs.m$vars <- paste(cur.vars, collapse=',')
    errs.m$n.squares <- cur.n.squares
    errs.m$formula.len <- length(cur.vars)

    errs.m <- errs.m[, c('base.pe','base.cor','base.r.squared',
                         'base.max.pe', 'base.iqr.pe', 'base.max.cooksd', 'base.max.cooksd.name',
                         'vars', 'n.squares', 'formula.len')]

    return(errs.m)
  }))
  row.names(res) <- NULL
  return(res)
}
