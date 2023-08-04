#' Parse text representation of a non-linear formula term
#'
#' Return a list with the non-linear function applied and the base terms of the formula.
#' @seealso random.search
#' @seealso genetic.search
#'
#' @param cur.vars An array of non-linear formula terms. Ex. `cur.vars <- c('a','mul.a.b')` represents the formula `y ~ a + a*b`
#' @param base.regressors The `names(X)` where X is the input dataset.
#' @param transformations A list of potentially non-linear transformations allowed in `cur.vars`.
#'
#' @return A list with the base regressors and the transformation function to be applied
#' @export
#'
#' @examples
#' parse.vars(
#'  c('log.a', 'mul.a.mul.b.c'),
#'  base.regressors=c('a','b','c'),
#'  transformations=list('log'=log)
#' )
#'
parse.vars <- function(cur.vars, base.regressors, transformations=list()){
  lapply(cur.vars, function(curvar){
    # at top-level we may have a transformation
    cur.transformation.name <- NULL
    var <- curvar
    for(transname in names(transformations)){
      m <- regexpr(paste0(transname, '.'), curvar, fixed=T)
      match.start <- as.integer(m)
      if(match.start > 0){
        # matched
        cur.transformation.name <- transname
        new.start <- match.start + attr(m, "match.length")
        # cleave away the transformation name
        var <- substr(curvar, new.start, nchar(curvar))
        break
      }
    }
    # now look for the number of mul.
    mul.len<-4
    ms <- gregexpr('mul.', var, fixed=T)[[1]]
    ms.len <- length(ms)
    n.mul <- 0
    if(ms[ms.len] > 0){
      n.mul <- ms.len
      var <- gsub('mul.', '', var, fixed=T)
    }
    # substitute with base regressors number
    # trick to avoid regressors that are substring of others:
    # reorder regressors by name length, decreasing
    names.regressors <- names(sort(sapply(base.regressors, nchar), decreasing = T))
    values.regressors <- as.character(seq(length(names.regressors)))
    names(values.regressors) <- names.regressors
    indexes <- stringr::str_replace_all(var, stringr::fixed(values.regressors))
    cur.var.regressors <- names.regressors[as.integer(strsplit(indexes, ".", fixed=T)[[1]])]
    # return the parsed version, with indication of top-level transformation and variables
    # to be multiplied
    list(transformation.name=cur.transformation.name, prods=cur.var.regressors)
  })
}
