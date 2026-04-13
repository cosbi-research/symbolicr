#' Plot "predicted vs observed" using a given formula
#'
#' Predicted values are obtained out-of-sample using K-fold cross-validation repeated N times and averaged.
#'
#' @param complete.X.df The dataset to be used for the test
#' @param y The independent variable
#' @param cur.vars An array of non-linear formula terms to be tested. `cur.vars <- c('a','mul.a.b')` will test the formula `y ~ a + a*b`
#' @param custom.abs.mins A list of user-defined minimum values for dataset columns.
#' @param K The number of parts the dataset is split into for K-fold cross-validation.
#' @param N The number of times the K-fold validation is repeated, shuffling the dataset row orders before each time.
#' @param transformations A list of potentially non-linear transformations allowed in `cur.vars`.
#' @param cv.norm Normalize regressors after train-validation split in inner cross-validation loop.
#' @param errors.x position of R^2 and PE in plot (x axis)
#' @param errors.y position of R^2 and PE in plot (y axis)
#' @param with.names Plot also product name
#'
#' @export
#' @return ggplot2::ggplot object ready to be plotted
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
#' n.squares=1
#' K=2
#' N=2
#' seed=1001
#'
#' transformations=list(
#'   "log"=function(rdf, x, stats){ log(x) },
#'   "log_x1_p"=function(rdf, x, stats){ log(rdf$x1 + x) },
#'   "inv"=function(rdf, x, stats){ 1/x }
#' )
#'
#' best.f <- list(
#'   c('inv.mul.x1.x2','x1'),
#'   c('inv.mul.x1.x2','x2')
#' )
#' # analyze different formulas with predicted vs observed plot.
#' # the more data points align round the x=y line, the more
#' # the prediction of the corresponding formula is accurate
#' plots <- lapply(best.f, function(test.f){
#'     pred.vs.obs(X,
#'                 y, test.f,
#'                 list(), K, N,
#'                 transformations,
#'                 cv.norm = FALSE,
#'                 errors.x=2.5, errors.y=0.5
#'    )
#' })
#'}
pred.vs.obs <- function(
    complete.X.df,
    y, cur.vars, custom.abs.mins, K, N,
    transformations=list(
      "log10"=function(rdf, x, z){ log10(0.1+abs(z$min)+x) },
      "inv"=function(rdf, x, z){ 1/(0.1+abs(z$min)+x) }
    ),
    cv.norm=TRUE,
    errors.x=3.2,
    errors.y=5.0,
    with.names=FALSE
){
  base.pred.m = oos = base.pred.ld = base.pred.ud = NULL
  BioReg = base.pe = base.pe.sd = base.r.squared = base.r.squared.sd = NULL
  cur.vars <- sort(cur.vars)
  cur.vars.str <- paste(sort(cur.vars), collapse=",")
  base.formula <- stats::reformulate(cur.vars, 'y')
  base.formula.str<-deparse(base.formula)
  base.formula.plus.pos <- as.integer(regexpr("+", base.formula.str, fixed=T))
  base.formula.c <- c(substr(base.formula.str, 0, base.formula.plus.pos-1), substr(base.formula.str, base.formula.plus.pos-1, nchar(base.formula.str)))

  message(paste0("Regression on ", cur.vars.str))
  experiments <- cross.validate(complete.X.df, y, cur.vars, custom.abs.mins, K, N,
                                transformations, cv.norm)

  # rename to out of sample (oos) because R check will complain otherwise
  names(experiments)[which(names(experiments)=='real')] <- 'oos'
  # create dataframe for plot
  p.vs.r.experiments.by.alpha.m <- stats::aggregate(
    cbind(oos,base.pred, base.pe, base.r.squared)~BioReg,
    data=experiments, FUN=function(x){
      q<-stats::quantile(x, probs=c(0.5))
      q[['50%']]
    })
  names(p.vs.r.experiments.by.alpha.m) <- c('BioReg','oos','base.pred.m', 'base.pe','base.r.squared')
  p.vs.r.experiments.by.alpha.sd <- stats::aggregate(
    cbind(oos,base.pred,base.pe, base.r.squared)~BioReg,
    data=experiments, FUN=stats::sd)
  names(p.vs.r.experiments.by.alpha.sd) <- c('BioReg','oos.sd','base.pred.sd','base.pe.sd','base.r.squared.sd')
  p.vs.r.experiments.by.alpha.ld <- stats::aggregate(
    cbind(oos,base.pred,base.pe, base.r.squared)~BioReg,
    data=experiments, FUN=function(x){
      q<-stats::quantile(x, probs=c(0.025, 0.975))
      q[['2.5%']]
    })
  names(p.vs.r.experiments.by.alpha.ld) <- c('BioReg','oos.ld','base.pred.ld','base.pe.ld','base.r.squared.ld')
  p.vs.r.experiments.by.alpha.ud <- stats::aggregate(
    cbind(oos,base.pred,base.pe, base.r.squared)~BioReg,
    data=experiments, FUN=function(x){
      q<-stats::quantile(x, probs=c(0.025, 0.975))
      q[['97.5%']]
    })
  names(p.vs.r.experiments.by.alpha.ud) <- c('BioReg','oos.ud','base.pred.ud','base.pe.ud','base.r.squared.ud')

  p.vs.r.by.alpha <- merge(p.vs.r.experiments.by.alpha.m,
                                 merge(p.vs.r.experiments.by.alpha.sd,
                                       merge(p.vs.r.experiments.by.alpha.ld, p.vs.r.experiments.by.alpha.ud)), by='BioReg')

  base.best.errors <- data.frame(base.pe=round(mean(experiments[, 'base.pe']), 3),
                                 base.pe.sd=round(stats::sd(experiments[, 'base.pe']), 3),
                                 base.cor=round(mean(experiments[, 'base.cor']), 3),
                                 base.cor.sd=round(stats::sd(experiments[, 'base.cor']), 3),
                                 base.r.squared=round(mean(experiments[, 'base.r.squared']), 3),
                                 base.r.squared.sd=round(stats::sd(experiments[, 'base.r.squared']), 3))

  #colours <- hcl(seq(375,15, length=length(unique(dataset.F$dataset))+1),l = 65, c = 100)
  #colours <- sort(colours)

  g<-ggplot2::ggplot(p.vs.r.by.alpha, ggplot2::aes(x = base.pred.m, y = oos, xmin=base.pred.ld, xmax=base.pred.ud, label=BioReg)) +
    ggplot2::ggtitle(paste0('Estimated with N=',N,' ',K,"-fold CV\n",paste(base.formula.c, collapse='\n'))) +
    ggplot2::theme_light()+ggplot2::theme(text = ggplot2::element_text(size=20)) +
    ggplot2::geom_point(size=3) +
    ggplot2::xlab("Predicted") +
    ggplot2::ylab("Observed") +
    ggplot2::geom_errorbarh(colour="#000000", linetype="dashed") +
    ggplot2::geom_abline(ggplot2::aes(intercept=0, slope=1)) +
    ggplot2::geom_text(data=base.best.errors, size=6, ggplot2::aes(x=errors.x, y=errors.y, label=paste0('PE=',base.pe,'\u00B1',base.pe.sd,'\nR^2=',base.r.squared,'\u00B1',base.r.squared.sd)), color="red", inherit.aes = F)
   #   scale_color_manual(values=colours)

  if(with.names)
    g <- g + ggplot2::geom_text(nudge_x=0.3)

  return(g)
}
