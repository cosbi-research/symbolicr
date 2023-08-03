empty.sample <- function(){
  data.frame(base.pe=double(),base.cor=double(),base.r.squared=double(),
             base.max.pe=double(), base.iqr.pe=double(), base.max.cooksd=double(), base.max.cooksd.name=character(),
             glmnet.pe=double(),glmnet.r.squared=double(),
             vars=character(), n.squares=integer(), formula.len=integer())
}
