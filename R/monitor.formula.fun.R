#' Default formula to monitor genetic evolution
#'
#' @param obj The solution object of the `GA` package.
#' @seealso genetic.search
#'
#' @export
#'
monitor.formula.fun<- function(obj) {
  max.fitness <- max(obj@fitness)
  avg.fitness <- mean(obj@fitness)
  best.vars.arr <- which(obj@fitness == max(obj@fitness))
  best.vars.l <- unique(lapply(best.vars.arr, function(best.vars.pos){
    curbest.bin <- obj@population[best.vars.pos, ]
    obj@names[which(curbest.bin == 1)]
  }))
  equivalent.formulas <- paste(lapply(best.vars.l, function(arr){paste(arr, collapse=" + ")}), collapse=" | ")
  print(paste0("Iteration: ",obj@iter, " Mean/Max fitness:", formatC(avg.fitness, format = "e", digits = 2), " / ", formatC(max.fitness, format = "e", digits = 2)," Best: ",equivalent.formulas))
}
