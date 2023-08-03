cross.validate <- function(cur.dataset, y, cur.vars, custom.abs.mins, K, N, n.squares, transformations){
  regressors <- names(cur.dataset)
  dataset.len <- nrow(cur.dataset)
  predictors.len <- length(cur.vars)
  ns <- nrow(cur.dataset)

  ### compute actual regressors from base regressors by parsing cur.vars
  parsed.vars <- parse.vars(cur.vars, regressors, transformations)

  do.call(rbind, lapply(1:N, function(i){
    # execute N K-fold cross-validations...

    folds <- split(sample(1:ns),1:K)
    # K-fold CV
    #regressors.names <- regressors
    cv.results.l <<- lapply(names(folds), FUN=function(foldid){
      # every CV round...
      fold_idx <- folds[[foldid]]
      train.set <- cur.dataset[-fold_idx, ]
      train.len <- nrow(train.set)
      y.train <- y[-fold_idx]
      test.set <- cur.dataset[fold_idx, ]
      test.len <- nrow(test.set)
      y.test <- y[fold_idx]

      test.set.name <- paste(names(y.test), collapse=", ")
      #print(paste0(" == computing ",test.set.name))

      # train set
      X.df <- train.set[ , regressors]
      # test set
      X.df.test <- test.set[ , regressors]

      # standardize, and keep mean/sd for every regressor for testing
      #print("Standardize base regressors...")
      norm.res <- normalize(X.df, custom.abs.mins)
      X.df.std <- norm.res$X.std
      X.mean.sd <-norm.res$mean.sd

      # normalize test with mean/sd from train
      X.df.test.std <- normalize.test(X.df.test, X.mean.sd)

      # compute min values on complete dataset to avoid out of domain errors
      regressors.def <- compute.regressors(rbind(X.df.std, X.df.test.std), parsed.vars, transformations, X.mean.sd)
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

      # train
      cur.formula.str <- paste0('y',"~",paste(cur.vars, collapse=' + '))

      # == FIXED FORMULA
      base.lm <- lm(as.formula(cur.formula.str), data=df.std)
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
      base.pred<-predict(base.lm, newdata=X.df.test.std)
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
    df <- merge(cv.results,real.df, by='BioReg', sort=F)
    row.names(df) <- df$BioReg

    # evaluate overall R^2 of K-fold crossvalidation
    #t.glmnet.lm <- lm(real~glmnet.pred, data=df)
    #s.t.glmnet.lm<-summary(t.glmnet.lm)
    #t.dt.lm <- lm(real~dt.pred, data=df)
    #s.t.dt.lm<-summary(t.dt.lm)

    t.base.lm <- lm(real~base.pred, data=df)
    #s.t.base.lm<-summary(t.base.lm)
    base.lm.cor <- cor(df$base.pred, df$real)
    base.lm.r.squared <- 1 - sum((df$base.pred-df$real)^2) / sum((df$real - mean(df$real))^2)
    # https://www.statology.org/adjusted-r-squared-interpretation/
    #base.lm.adj.r.squared <- 1 - ((1-base.lm.r.squared)*(dataset.len-1)/(dataset.len-predictors.len-1))

    base.cooksd <- cooks.distance(t.base.lm)
    max.base.cooksd <- base.cooksd[which(base.cooksd==max(base.cooksd))]
    max.base.outlayer.name <- names(max.base.cooksd)

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
    base.pe<-abs(df$real-df$base.pred)/abs(df$real)
    cv.results[['base.pe']] <- median( base.pe )
    cv.results[['base.max.pe']] <- max( base.pe )
    cv.results[['base.iqr.pe']] <- IQR( base.pe )
    cv.results[['base.max.cooksd']] <- max.base.cooksd
    cv.results[['base.max.cooksd.name']] <- max.base.outlayer.name

    return(cv.results)
  }))

}
