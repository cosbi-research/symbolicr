#' Return an empty data.frame with the columns returned by `random.search`
#'
#' @seealso random.search
#'
#' @return An empty data.frame
#' @export
#'
empty.sample <- function(){
  data.frame(base.pe=double(),base.cor=double(),base.r.squared=double(),
             base.max.pe=double(), base.iqr.pe=double(), base.max.cooksd=double(), base.max.cooksd.name=character(),
             vars=character(), n.squares=integer(), formula.len=integer())
}
