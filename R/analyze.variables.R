#' Analyze Variables
#' Get information on the relative importance of each variable included in your formula.
#'
#' This works by removing one variable at a time from the formula and measuring its new (cross-validation) fitness.
#'
#' @param regressors.df The dataset that contains the base variables the formula is composed of (column-wise)
#' @param y The independent variable
#' @param test.formula.df A dataset of formulas (contained in 'vars' column) and their fitness values (error measures)
#' @param fitness.column The test.formula.df column containing the target fitness value to be used for analysis
#' @param transformations A list of potentially non-linear transformations that can be applied on top of the squares. Ex. `order 0, transformation=log10 = log10.a`. Input values are x and z, the array of numbers to be transformed (training set only), and the min max statistics (on the global dataset) respectively.
#' @param transformations_replacement_map A list of rules to remove a variable from a term. Ex. `"log_empty_well_p"=c("log10", "empty_well")`
#' @param custom.abs.mins A list of user-defined minimum values for dataset columns.
#' @param K The number of parts the dataset is split into for K-fold cross-validation.
#' @param N The number of times the K-fold validation is repeated, shuffling the dataset row orders before each time.
#' @param direction 'max' if the higher the objective in fitness.column the better, 'min' on the contrary.
#' @param max.formula.len The maximum number of terms in the formula
#' @param fitness.fun The function that determine the fitness of a given formula. Defaults to `pe.r.squared.formula.len.fitness`
#' @param cv.norm Normalize regressors after train-validation split in inner cross-validation loop.
#'
#' @returns A list of "terms that"loss" and "gain" variables, with a measure of the (relative) gain/loss of removing each variable from the initial formula.
#' @export
#'
#' @examples
#' \donttest{
#' # set-up a toy example dataset
#' x1<-runif(100, min=2, max=67)
#' x2<-runif(100, min=0.01, max=0.1)
#' X <- data.frame(x1=x1, x2=x2)
#' # set up a "true" non-linear relationship
#' # with some noise
#' y <- log10(x1^2*x2) + rnorm(100, 0, 0.001)
#'
#' max.formula.len=1
#' transformations=list(
#'   "log"=function(rdf, x, stats){ log(x) },
#'   "log_x1_p"=function(rdf, x, stats){ log(rdf$x1 + x) },
#'   "inv"=function(rdf, x, stats){ 1/x }
#' )
#' random.results <- random.search(
#'   X, y,
#'   n.squares=2,
#'   formula.len = max.formula.len,
#'   N=2,
#'   K=10,
#'   transformations = transformations,
#'   cv.norm=FALSE
#' )
#' # compute a unique objective function
#' random.results$obj <- apply(random.results, MARGIN=1,
#'   FUN=function(row) pe.r.squared.formula.len.fitness(as.data.frame(t(row)), max.formula.len)
#' )
#'
#' # sort by top-N functions (according to obj)
#' ordered.res <- random.results[order(random.results$obj,decreasing=TRUE),]
#'
#' # max fitness on all computed formulas
#' best.obj <- ordered.res[1,'obj']
#' # analyze top-10 formulas
#' # select formulas according to criterion above
#' eligible.res <- ordered.res[seq(10), ]
#'
#' direction = 'max' # obj should be maximized
#' sensitivity <- analyze.variables(
#'   X, y, eligible.res, fitness.column='obj',
#'   # a list of available term transformations
#'   transformations=transformations,
#'   # a list of rules to remove a variable from a term
#'   # ex.
#'   #   orig transformation -> base transformation, removed term
#'   #   "log_empty_well_p"=c("log10", "empty_well")
#'   transformations_replacement_map=list(
#'     "log_x1_p"=c("log", "x1")
#'   ),
#'   custom.abs.mins=list(),
#'   K=10,
#'   N=2,
#'   direction=direction,
#'   max.formula.len=max.formula.len,
#'   fitness.fun=pe.r.squared.formula.len.fitness,
#'   cv.norm=FALSE
#' )
#'
#' # plottable data.frame of quantile losses per-variable
#' variable.importance.df <- sensitivity[['var.imp']]
#' }
analyze.variables <- function(regressors.df, y, test.formula.df, fitness.column, transformations, transformations_replacement_map, custom.abs.mins=list(), K=7, N=10, direction='max', max.formula.len=max.formula.len, fitness.fun=pe.r.squared.formula.len.fitness, cv.norm=TRUE){
  n.formulas <- nrow(test.formula.df)
  if(n.formulas <= 0){
    stop("Empty data.frame of formulas. Stop.")
  }

  f.relative <- apply(test.formula.df, MARGIN=1, FUN=function(row){
    test.f <- strsplit(row[['vars']], ",")[[1]]
    test.f.fitness <- as.double(row[[fitness.column]])
    if(test.f.fitness < 0){
      stop("Can't run on negative-fitness formula. Stop.")
    }

    message(paste0("Analyzing ", row[['vars']]))
    parsed.vars <- symbolicr::parse.vars(test.f, names(regressors.df), transformations)
    # generate "similar" formulas for sensitivity
    # delete a term and evaluate the relative difference in performance
    term.idxs <- seq_along(parsed.vars)
    l <- lapply(term.idxs, function(term.idx){
      f.relative.loss <- list()
      f.relative.gain <- list()
      term <- parsed.vars[[term.idx]]
      # term is a term of the formula test.f

      ## start removing non-linear input data
      cur.transformation.name <- term$transformation.name
      while(!is.null(cur.transformation.name) && !is.null(transformations_replacement_map[[cur.transformation.name]])){
        transformation_replacement <- transformations_replacement_map[[cur.transformation.name]]
        # apply replacement and measure relative performance difference
        new_transformation <- transformation_replacement[1]
        removed_term <- transformation_replacement[2]

        # measure the relative impact of removing "removed_term"
        new.term <- term
        cur.transformation.name <- new_transformation
        new.term$transformation.name <- cur.transformation.name

        new.test.f <- c(list(new.term), parsed.vars[setdiff(term.idxs, c(term.idx))])

        cur.res <- analyze.candidate.formula(new.test.f, regressors.df, y, transformations, custom.abs.mins, K, N, fitness.fun, max.formula.len, cv.norm)
        new.test.f.fitness <- cur.res$obj

        # relative loss
        if(new.test.f.fitness >= 0){
          if( direction=='max' ){
            # case 1: the higher the better (my.fitness)
            rel.loss <- (test.f.fitness - new.test.f.fitness)/test.f.fitness
          }else{
            # case 2: the lower the better (my.sim.fitness)
            rel.loss <- (new.test.f.fitness - test.f.fitness)/test.f.fitness
          }
        }else{
          # negative new fitness, means we lost all predictive power
          rel.loss <- 1.0
        }

        if(is.null(f.relative.loss[[removed_term]])){
          f.relative.loss[[removed_term]] <- c()
        }
        # record loss by term
        f.relative.loss[[removed_term]] <- c(f.relative.loss[[removed_term]], max(0,rel.loss))

        if(rel.loss<0){
          if(is.null(f.relative.loss[[removed_term]])){
            f.relative.gain[[removed_term]] <- data.frame(removed.term=character(), new.formula=character(), gain=double())
          }
          # record gain by term
          f.relative.gain[[removed_term]] <- rbind(f.relative.loss[[removed_term]],
                                                   data.frame(removed.term=removed_term,
                                                              new.formula=paste(sort(symbolicr::serialize.vars(new.test.f)), collapse=','),
                                                              gain=-rel.loss)
          )
        }
      }

      ## remove prods
      prod.idxs <- seq_along(term$prods)
      if(length(prod.idxs)>1){
        for(prod.idx in prod.idxs){
          removed_term <- term$prods[prod.idx]
          new.term <- term
          new.term$prods <- term$prods[setdiff(prod.idxs, prod.idx)]

          new.test.f <- c(list(new.term), parsed.vars[setdiff(term.idxs, c(term.idx))])
          cur.res <- analyze.candidate.formula(new.test.f, regressors.df, y, transformations, custom.abs.mins, K, N, fitness.fun, max.formula.len, cv.norm)
          new.test.f.fitness <- cur.res$obj
          # relative loss
          if(new.test.f.fitness >= 0){
            if( direction=='max' ){
              # case 1: the higher the better (my.fitness)
              rel.loss <- (test.f.fitness - new.test.f.fitness)/test.f.fitness
            }else{
              # case 2: the lower the better (my.sim.fitness)
              rel.loss <- (new.test.f.fitness - test.f.fitness)/test.f.fitness
            }
          }else{
            # negative new fitness, means we lost all predictive power
            rel.loss <- 1.0
          }

          if(is.null(f.relative.loss[[removed_term]])){
            f.relative.loss[[removed_term]] <- c()
          }
          # record loss by term
          f.relative.loss[[removed_term]] <- c(f.relative.loss[[removed_term]], max(0,rel.loss))

          if(rel.loss<0){
            if(is.null(f.relative.loss[[removed_term]])){
              f.relative.gain[[removed_term]] <- data.frame(removed.term=character(), new.formula=character(), gain=double())
            }
            # record gain by term
            f.relative.gain[[removed_term]] <- rbind(f.relative.loss[[removed_term]],
                                                     data.frame(removed.term=removed_term,
                                                                new.formula=paste(sort(symbolicr::serialize.vars(new.test.f)), collapse=','),
                                                                gain=-rel.loss)
            )
          }

        }
      }

      return(list(loss=f.relative.loss, gain=f.relative.gain))
    })

    losses <- lapply(l, function(sl){
      sl[['loss']]
    })

    keys <- unique(unlist(lapply(losses, names)))
    loss.terms <- stats::setNames(do.call(mapply, c(FUN=c, lapply(losses, `[`, keys))), keys)

    gain.terms <- do.call(rbind,lapply(l, function(sl){
      sl[['gain']]
    }))

    return(
      list(
        formula.loss=loss.terms,
        formula.gain=gain.terms
      )
    )
  })

  f.relative.gain.ls <- lapply(f.relative, function(l){
    l[['formula.gain']]
  })

  f.relative.loss.ls <- lapply(f.relative, function(l){
    l[['formula.loss']]
  })

  # losses by variable
  keys <- unique(unlist(lapply(f.relative.loss.ls, names)))
  keys <- keys[sapply(keys, function(x) !is.na(x))]
  var.relative.loss <- stats::setNames(do.call(mapply, c(FUN=c, lapply(f.relative.loss.ls, `[`, keys))), keys)

  # variable importance statistics
  global.relative.losses.df <- do.call(rbind, lapply(names(var.relative.loss), function(term){
    losses<-var.relative.loss[[term]]
    neg.losses<- losses[!is.na(losses)]
    p <- stats::quantile(neg.losses,probs=c(0.05,0.25,0.5,0.75,0.95)) * 100
    #                     exclude positive gains..                                 convert percentage loss to positive
    data.frame(variable=term, mean.occurrences=length(neg.losses)/n.formulas,
               lowest.loss.p=p[['5%']], lower.loss.p=p[['25%']], mean.loss.p=p[['50%']], higher.loss.p=p[['75%']], highest.loss.p=p[['95%']])
  }))

  return(
    list(
      var.imp=global.relative.losses.df,
      formula.loss=f.relative.loss.ls,
      formula.gain=f.relative.gain.ls
    )
  )
}
