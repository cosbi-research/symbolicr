#' Parse text representation of a non-linear formula term
#'
#' Return a list with the non-linear function applied and the base terms of the formula.
#' @seealso random.search
#' @seealso genetic.search
#' @seealso parse.vars
#'
#' @param parsed.vars A list with the base regressors and the transformation function to be applied
#' @param base.regressors The `names(X)` where X is the input dataset.
#' @param transformations A list of potentially non-linear transformations allowed in `cur.vars`.
#'
#' @return An array of serialized non-linear formula terms. Ex. `cur.vars <- c('a','mul.a.b')` represents the formula `y ~ a + a*b`
#' @export
#'
#' @examples
#' serialize.vars(
#'  list(
#'    list("transformation.name"="log", "prods"=c("a")), 
#'    list("transformation.name"=NULL, "prods"=c("a","b","c"))
#'  ),
#'  base.regressors=c('a','b','c'),
#'  transformations=list('log'=log)
#' )
#'
serialize.vars <- function(parsed.vars, base.regressors, transformations=list()){

  serialized <- lapply(parsed.vars, function(parsed.var){
    
    n.mul<-length(parsed.var$prods)
    if(n.mul > 1){
      rev.prods <- rev(parsed.var$prods)
      var.name <- paste(c('mul', rev.prods[2], rev.prods[1]), collapse=".")
      if(n.mul>2){
        for(new.prod in rev.prods[seq(3,n.mul)]){
          var.name <- paste(c('mul', new.prod, var.name), collapse=".")
        }
      }
    }else{
      var.name <- parsed.var$prods[1]
    }
    
    # non-linear transformation?
    if(is.null(parsed.var$transformation.name)){
      nonlin.var.name <- var.name
    }else{
      nonlin.var.name <- paste0(parsed.var$transformation.name, '.', var.name)
    }
    
    return(nonlin.var.name)
  })
  
  return(unlist(serialized))
}