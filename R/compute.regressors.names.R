#' Compute all possible formula terms from a given dataset
#'
#' @param complete.X.df The dataset that contains the base variables the formula is composed of (column-wise)
#' @param n.squares The maximum order of the polynomial composition of base variables. Ex. `order 0 = a`, `order 1 = a*b`, `order 2 = a*b*c`
#' @param transformations A list of potentially non-linear transformations that can be applied on top of the squares. Ex. `order 0, transformation=log10 = log10.a`. Input values are x and z, the array of numbers to be transformed (training set only), and the min max statistics (on the global dataset) respectively.
#'
#' @export
#' @return An array of character with all the generated names for the generated variables
#'
#' @examples
#' \donttest{
#' # set-up a toy example dataset
#' x1<-runif(100, min=2, max=67)
#' x2<-runif(100, min=0.01, max=0.1)
#' X <- data.frame(x1=x1, x2=x2)
#'
#' n.squares=2
#'
#' transformations=list(
#'   "log"=function(rdf, x, stats){ log(x) },
#'   "log_x1_p"=function(rdf, x, stats){ log(rdf$x1 + x) },
#'   "inv"=function(rdf, x, stats){ 1/x }
#' )
#'
#' regressors <- c('x1','x2')
#'
#' regressors.names(X, n.squares, transformations)
#' }
regressors.names <- function(complete.X.df, n.squares, transformations){
  regressors <- names(complete.X.df)
  complete.regressors <- regressors
  if(n.squares>0){
    l <- lapply(seq(n.squares+1), function(i){regressors})
    complete.regressors <- complete.square.names(l)
  }
  if(length(transformations)>0)
    complete.regressors <- c(complete.regressors, transformations.names(complete.regressors, transformations))
  return(complete.regressors)
}
