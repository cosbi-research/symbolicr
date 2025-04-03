#' Test a non-linear formula
#'
#' Test using K-fold cross-validation repeated N times
#'
#' @param cur.dataset The dataset to be used for the test
#' @param y The independent variable
#' @param cur.vars An array of non-linear formula terms to be tested. `cur.vars <- c('a','mul.a.b')` will test the formula `y ~ a + a*b`
#' @param custom.abs.mins A list of user-defined minimum values for dataset columns.
#' @param K The number of parts the dataset is split into for K-fold cross-validation.
#' @param N The number of times the K-fold validation is repeated, shuffling the dataset row orders before each time.
#' @param transformations A list of potentially non-linear transformations allowed in `cur.vars`.
#' @param cv.norm Normalize regressors after train-validation split in inner cross-validation loop.
#'
#' @return A data.frame with cross-validation results for each fold (K) and for each round (N).
#' @export
#'
#' @examples
#' \dontrun{
#'    # do actual cross-validation experiments, record in experiments data.frame
#'    # all the validation-set performances.
#'    # NOTE: complete.X.df should contain the column `patch_hyd_2`, `patch_pos_.` and `patch_hyd_5`
#'    experiments.0 <- cross.validate(
#'                       complete.X.df, y,
#'                       cur.vars=c('inv.patch_hyd_2','patch_hyd_5'),
#'                       custom.abs.mins=list(),
#'                       K=7,
#'                       N=10,
#'                       transformations=list(
#'                             "log10"=function(x, min.val){
#'                                            log10(0.1+abs(min.val)+x)
#'                                     },
#'                             "inv"=function(x, min.val){
#'                                            1/(0.1+abs(min.val)+x)
#'                                   }
#'                       )
#'                     )
#'
#'    experiments.1 <- cross.validate(
#'                       complete.X.df, y,
#'                       cur.vars=c('inv.mul.patch_hyd_2.patch_hyd_2','patch_pos_.'),
#'                       custom.abs.mins=list(),
#'                       K=7,
#'                       N=10
#'                     )
#'
#'      # summarize cross-validation results by averaging
#'      errs.m <- stats::aggregate(
#'                      cbind(base.pe, base.cor, base.r.squared,
#'                            base.max.pe, base.iqr.pe, base.max.cooksd)~1,
#'                      data=experiments.1, FUN=mean
#'                )
#'}
#'
cross.validate <- function(cur.dataset, y, cur.vars, custom.abs.mins, K, N, transformations, cv.norm){
  regressors <- names(cur.dataset)
  dataset.len <- nrow(cur.dataset)
  predictors.len <- length(cur.vars)
  cur.formula.str <- paste0('y',"~",paste(cur.vars, collapse=' + '))
  ns <- nrow(cur.dataset)

  ### compute actual regressors from base regressors by parsing cur.vars
  parsed.vars <- parse.vars(cur.vars, regressors, transformations)

  do.call(rbind, lapply(1:N, function(i){
    # execute N K-fold cross-validations...

    folds <- split(sample(1:ns),1:K)
    # K-fold CV
    #regressors.names <- regressors
    cv.results.l <- lapply(names(folds), FUN=function(foldid){
      # every CV round...
      fold_idx <- folds[[foldid]]
      train.set <- cur.dataset[-fold_idx, ]
      train.len <- nrow(train.set)
      y.train <- y[-fold_idx]
      test.set <- cur.dataset[fold_idx, ]
      test.len <- nrow(test.set)
      y.test <- y[fold_idx]

      if(is.null(names(y.test))){
        names(y.test) <- row.names(test.set)
      }
      test.set.name <- paste(names(y.test), collapse=", ")
      #print(paste0(" == computing ",test.set.name))
      # train set
      X.df <- train.set[ , regressors]
      # test set
      X.df.test <- test.set[ , regressors]

      # standardize, and keep mean/sd for every regressor for testing
      #print("Standardize base regressors...")
      if(cv.norm){
        norm.res <- normalize(X.df, custom.abs.mins)
        X.df.std <- norm.res$X.std
        X.mean.sd <-norm.res$mean.sd

        # normalize test with mean/sd from train
        X.df.test.std <- normalize.test(X.df.test, X.mean.sd)
      }else{
        X.df.std <- X.df
        X.df.test.std <- X.df.test
        X.mean.sd <- NULL
      }

      # compute min values on complete dataset to avoid out of domain errors
      regressors.def <- regressors(rbind(X.df.std, X.df.test.std), parsed.vars, transformations, X.mean.sd)
      regressors.min.values <- regressors.def$min.values
      complete.X.df.std <- regressors.def$regressors

      # split again in two the two parts
      X.df.std <- complete.X.df.std[seq(to=train.len), , drop=F]
      X.df.test.std <- complete.X.df.std[seq(from=train.len+1, to=ns), , drop=F]

      #print("Computing combinatorial regressors...")
      # compute tranformations of all base variables
      # add complete set of 2nd order variables
      y.df <- data.frame(y=y.train)
      df.std <- cbind(y.df, X.df.std)

      #Replace NaN & Inf with NA
      df.std[is.na(df.std) | df.std=="Inf"] <- NA
      # train
      # == FIXED FORMULA
      base.lm <- tryCatch({ stats::lm(stats::as.formula(cur.formula.str), data=df.std) },
                          error=function(e){
                              # use intercept-only model
                              stop(paste0("Regressors contains NaN/Inf values in formula '",cur.formula.str,"': ", e))
                              #stats::lm(y~1, data=df.std)
                          },
                          message=paste0("Regressors contains NaN/Inf values in formula '",cur.formula.str,"'"))
      s.base.lm <- summary(base.lm)
      s.df <- as.data.frame(s.base.lm$coefficients)
      base.full.coef <-as.data.frame(s.df$Estimate)
      row.names(base.full.coef) <- paste('base.',row.names(s.df),sep="")
      row.names(base.full.coef)[1] <- 'base.Intercept'
      names(base.full.coef) <- c('base.coef')

      #dt.lm <- lm(dt.formula, data=df.std)
      #s.dt.lm <- summary(dt.lm)

      # == GLMNET
      # convert factor variable to 1-hot encoding
      #x_train <- as.matrix(X.df.std) # [,-ncol(X.df.std)]
      # NO CV
      #glm.fit<-cv.glmnet(x_train, y.df$y, alpha=alpha, grouped=F)
      # SET BEST LAMBDA AND ALPHA FOUND TRHOUGH CV
      #glm.fit<-glmnet(x_train, y.df$y, lambda=best.lambda.cv, alpha=best.alpha.cv)
      # get R^2
      #glmnet.train.pred<-as.data.frame(predict(glm.fit, newx=x_train, s = "lambda.min"))
      #s.glm.fit <- summary(lm(y.df$y ~ glmnet.train.pred[,1]))
      #lasso.full.coef<- as.data.frame(as.matrix(coef(glm.fit, s = "lambda.min")))
      #row.names(lasso.full.coef)[1] <- 'Intercept'
      #names(lasso.full.coef) <- c('coef')

      # test
      # return predicted
      #dt.pred<-predict(dt.lm, newdata=X.df.test.std)
      base.pred<-stats::predict(base.lm, newdata=X.df.test.std)
      #glmnet.pred<-as.data.frame(predict(glm.fit, newx=as.matrix(X.df.test.std), s = "lambda.min"))
      #names(glmnet.pred) <- "lambda.min"
      local.df <- data.frame(
        foldid=foldid,
        BioReg=names(y.test),
        # base
        base.train.r.squared=s.base.lm$r.squared,
        base.train.adj.r.squared=s.base.lm$adj.r.squared,
        base.pred=base.pred,
        # dt
        #dt.train.r.squared=s.dt.lm$r.squared,
        #dt.train.adj.r.squared=s.dt.lm$adj.r.squared,
        #dt.pred=dt.pred,
        # glmnet
        # CV ONLY
        # best.lambda=glm.fit$lambda.min,
        glmnet.train.r.squared=NA,#s.glm.fit$r.squared,
        glmnet.train.adj.r.squared=NA,#s.glm.fit$adj.r.squared,
        glmnet.pred=NA#glmnet.pred$lambda.min
      )

      #local.df.coefs <- cbind(local.df, t(base.full.coef))
      return(local.df)
    })
    cv.results<- do.call(rbind, cv.results.l)
    #saveRDS(cv.results, out.file)

    # get overall R^2 for this prediction
    real.df <- data.frame(BioReg=row.names(cur.dataset), real=y)
    df <- merge(cv.results,real.df, by='BioReg', sort=F, all=F)
    row.names(df) <- df$BioReg
    # remove NA
    df.nona <- df[!is.na(df$base.pred) & df$base.pred!="Inf", ]
    # evaluate overall R^2 of K-fold crossvalidation
    #t.glmnet.lm <- lm(real~glmnet.pred, data=df)
    #s.t.glmnet.lm<-summary(t.glmnet.lm)
    #t.dt.lm <- lm(real~dt.pred, data=df)
    #s.t.dt.lm<-summary(t.dt.lm)

    t.base.lm <- tryCatch({ stats::lm(real~base.pred, data=df.nona) },
      error=function(e){
        # use intercept-only model
        stop(paste0("Predictions contains NaN/Inf values in formula '",cur.formula.str,"': ", e))
        #stats::lm(y~1, data=df.std)
      },
      message=paste0("Predictions contains NaN/Inf values in formula '",cur.formula.str,"'"))
    #s.t.base.lm<-summary(t.base.lm)
    base.lm.cor <- stats::cor(df.nona$base.pred, df.nona$real, use="pairwise.complete.obs")
    base.lm.r.squared <- 1 - sum((df.nona$base.pred-df.nona$real)^2, na.rm = T) / sum((df.nona$real - mean(df.nona$real))^2, na.rm = T)
    # https://www.statology.org/adjusted-r-squared-interpretation/
    #base.lm.adj.r.squared <- 1 - ((1-base.lm.r.squared)*(dataset.len-1)/(dataset.len-predictors.len-1))

    base.cooksd <- stats::cooks.distance(t.base.lm)
    max.base.cooksd <- base.cooksd[which(base.cooksd==max(base.cooksd))]
    l.max.base.cooksd <- length(max.base.cooksd)
    if(l.max.base.cooksd==1){
      max.base.outlayer.name <- names(max.base.cooksd)
    }else if(l.max.base.cooksd>1){
      max.base.cooksd <- max.base.cooksd[1]
      max.base.outlayer.name <- names(max.base.cooksd)[1]
    }else{
      max.base.cooksd <- NA
      max.base.outlayer.name <- ""
    }

    # store N K-fold validation number
    cv.results[['N']] <- i
    # cv.results[['alpha']] <- a
    #cv.results[['lambda']] <-l
    cv.results[['real']] <- df$real
    cv.results[['base.pred']] <- df$base.pred
    cv.results[['glmnet.pred']] <- df$glmnet.pred
    cv.results[['glmnet.r.squared']] <- NA#s.t.glmnet.lm$r.squared
    cv.results[['glmnet.adj.r.squared']] <- NA#s.t.glmnet.lm$adj.r.squared
    cv.results[['glmnet.pe']] <- NA#median( abs(df$real-df$glmnet.pred)/abs(df$real) )

    cv.results[['dt.r.squared']] <- NA#s.t.dt.lm$r.squared
    cv.results[['dt.adj.r.squared']] <- NA#s.t.dt.lm$adj.r.squared

    cv.results[['base.cor']] <- base.lm.cor
    cv.results[['base.r.squared']] <- base.lm.r.squared
    base.pe<-abs(df.nona$real-df.nona$base.pred)/abs(df.nona$real)
    cv.results[['base.pe']] <- stats::median( base.pe )
    cv.results[['base.max.pe']] <- max( base.pe )
    cv.results[['base.iqr.pe']] <- tryCatch({
      stats::IQR( base.pe )
    }, error=function(e){
      NA
    })
    cv.results[['base.max.cooksd']] <- max.base.cooksd
    cv.results[['base.max.cooksd.name']] <- max.base.outlayer.name

    return(cv.results)
  }))

}
