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
#'
#' @examples
#' \dontrun{
#'    # do actual cross-validation experiments and
#'    # plot results as observed vs predicted values (out-of-sample)
#'    # NOTE: complete.X.df should contain the columns
#'    # `patch_hyd_2`, `patch_pos_.` and `patch_hyd_5`
#'    experiments.0 <- pred.vs.obs(
#'                       complete.X.df, y,
#'                       cur.vars=c('inv.patch_hyd_2','patch_hyd_5'),
#'                       custom.abs.mins=list(),
#'                       K=7,
#'                       N=10,
#'                       transformations=list(
#'                             "log10"=function(rdf, x, min.val){
#'                                            log10(0.1+abs(min.val)+x)
#'                                     },
#'                             "inv"=function(rdf, x, min.val){
#'                                            1/(0.1+abs(min.val)+x)
#'                                   }
#'                       )
#'                     )
#'}
pred.vs.obs <- function(
    complete.X.df,
    y, cur.vars, custom.abs.mins, K, N,
    transformations=list(
      "log10"=function(rdf, x, z){ log10(0.1+abs(z$min)+x) },
      "inv"=function(rdf, x, z){ 1/(0.1+abs(z$min)+x) }
    ),
    cv.norm=T,
    errors.x=3.2,
    errors.y=5.0,
    with.names=F
){
  cur.vars <- sort(cur.vars)
  cur.vars.str <- paste(sort(cur.vars), collapse=",")
  base.formula <- stats::reformulate(cur.vars, 'y')
  base.formula.str<-deparse(base.formula)
  base.formula.plus.pos <- as.integer(regexpr("+", base.formula.str, fixed=T))
  base.formula.c <- c(substr(base.formula.str, 0, base.formula.plus.pos-1), substr(base.formula.str, base.formula.plus.pos-1, nchar(base.formula.str)))

  print(paste0("Regression on ", cur.vars.str))
  experiments <- cross.validate(complete.X.df, y, cur.vars, custom.abs.mins, K, N,
                                transformations, cv.norm)


  # create dataframe for plot
  p.vs.r.experiments.by.alpha.m <- stats::aggregate(
    cbind(real,base.pred, base.pe, base.r.squared)~BioReg,
    data=experiments, FUN=function(x){
      q<-stats::quantile(x, probs=c(0.5))
      q[['50%']]
    })
  names(p.vs.r.experiments.by.alpha.m) <- c('BioReg','real','base.pred.m', 'base.pe','base.r.squared')
  p.vs.r.experiments.by.alpha.sd <- stats::aggregate(
    cbind(real,base.pred,base.pe, base.r.squared)~BioReg,
    data=experiments, FUN=stats::sd)
  names(p.vs.r.experiments.by.alpha.sd) <- c('BioReg','real.sd','base.pred.sd','base.pe.sd','base.r.squared.sd')
  p.vs.r.experiments.by.alpha.ld <- stats::aggregate(
    cbind(real,base.pred,base.pe, base.r.squared)~BioReg,
    data=experiments, FUN=function(x){
      q<-stats::quantile(x, probs=c(0.025, 0.975))
      q[['2.5%']]
    })
  names(p.vs.r.experiments.by.alpha.ld) <- c('BioReg','real.ld','base.pred.ld','base.pe.ld','base.r.squared.ld')
  p.vs.r.experiments.by.alpha.ud <- stats::aggregate(
    cbind(real,base.pred,base.pe, base.r.squared)~BioReg,
    data=experiments, FUN=function(x){
      q<-stats::quantile(x, probs=c(0.025, 0.975))
      q[['97.5%']]
    })
  names(p.vs.r.experiments.by.alpha.ud) <- c('BioReg','real.ud','base.pred.ud','base.pe.ud','base.r.squared.ud')

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

  g<-ggplot2::ggplot(p.vs.r.by.alpha, ggplot2::aes(x = base.pred.m, y = real, xmin=base.pred.ld, xmax=base.pred.ud, label=BioReg)) +
    ggplot2::ggtitle(paste0('Estimated with N=',N,' ',K,"-fold CV\n",paste(base.formula.c, collapse='\n'))) +
    ggplot2::theme_light()+ggplot2::theme(text = ggplot2::element_text(size=20)) +
    ggplot2::geom_point(size=3) +
    ggplot2::xlab("Predicted") +
    ggplot2::ylab("Observed") +
    ggplot2::geom_errorbarh(colour="#000000", linetype="dashed") +
    ggplot2::geom_abline(ggplot2::aes(intercept=0, slope=1)) +
    ggplot2::geom_text(data=base.best.errors, size=6, ggplot2::aes(x=errors.x, y=errors.y, label=paste0('PE=',base.pe,'±',base.pe.sd,'\nR^2=',base.r.squared,'±',base.r.squared.sd)), color="red", inherit.aes = F)
   #   scale_color_manual(values=colours)

  if(with.names)
    g <- g + ggplot2::geom_text(nudge_x=0.3)

  return(g)
}
