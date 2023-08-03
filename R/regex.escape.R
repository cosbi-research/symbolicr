regex.escape <- function(var){
  gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", var)
}
