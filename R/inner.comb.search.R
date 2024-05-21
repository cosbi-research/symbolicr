inner.comb.search <- function(
    complete.X.df,
    y,
    combinations,
    K=7,
    N=10,
    seed=NULL,
    transformations=list(
      "log10"=function(x, z){ log10(0.1+abs(z)+x) },
      "inv"=function(x, z){ 1/(0.1+abs(z)+x) }
    ),
    custom.abs.mins=list(),
    cv.norm=F
){

  do.call(rbind, apply(combinations, MARGIN=1, simplify = F, FUN=function(cur.vars){
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

}
