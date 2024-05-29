#' Explore all combinations of formula terms
#'
#' Given a set of formulas, this function systematically evaluates
#' all combinations of formula terms, of a given length.
#'
#' @param complete.X.df The dataset that contains the base variables the formula is composed of (column-wise)
#' @param y The independent variable to be predicted with the formula
#' @param formulas.l The list of formulas whose terms will be considered
#' @param formula.len The number of terms in the formulas that will be randomly sampled.
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
comb.search <- function(
    complete.X.df,
    y,
    formulas.l,
    formula.len=3,
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
  t.vars <- unique(do.call(c, formulas.l))
  combinations <- RcppAlgos::comboGrid(rep(list(t.vars), formula.len), repetition = F)
  inner.comb.search(complete.X.df, y, combinations, K, N, seed, transformations, custom.abs.mins, cv.norm)
}
