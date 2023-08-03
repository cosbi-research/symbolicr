pe.r.squared.formula.len.fitness <- function(errs.m, max.formula.len){
  x0 <- 0.4
  denominator <- exp(10*errs.m$formula.len/max.formula.len*errs.m$base.pe)
  numerator <- sign(errs.m$base.r.squared)*(errs.m$base.r.squared/x0)^2
  numerator / denominator
}
