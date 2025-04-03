analyze.candidate.formula <- function(new.test.f, regressors.df, y, transformations, custom.abs.mins, K, N, fitness.fun, max.formula.len, cv.norm=T){
  new.test.f.str <- sort(symbolicr::serialize.vars(new.test.f, names(regressors.df), transformations))
  cur.res <- test.formula(regressors.df, y, new.test.f.str, custom.abs.mins, K, N, transformations, cv.norm = cv.norm)
  cur.res$n.squares <- unlist(lapply(strsplit(cur.res$vars, ",", fixed=T), function(x) {
    max(unlist(lapply(sapply(x, function(y) strsplit(y, "mul.", fixed=T)), length)))-1
  }))
  cur.res$formula.len <- unlist(lapply(strsplit(cur.res$vars, ",", fixed=T), length))
  cur.res$obj <- fitness.fun(cur.res, max.formula.len)
  return(cur.res)
}
