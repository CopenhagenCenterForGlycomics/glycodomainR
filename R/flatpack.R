#' @export
flatpack <- function() {
  targetenv=new.env()
  installed_list=sapply(grep("^gator.",installed.packages(),value = T), function(x){ data('data',package=x,envir=targetenv) })
  are_msdata=sapply( ls(targetenv), function(x) attributes(targetenv[[x]])$type == 'msdata' )
  flatpack=do.call(rbind,sapply(na.omit(ls(targetenv)[as.logical(are_msdata)]), function(x) cbind(targetenv[[x]],dataset=rep(x,nrow(targetenv[[x]])) ),simplify = F ))
  return (flatpack)
}