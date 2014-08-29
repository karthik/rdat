

#' Initialize the dat API
#'
#' @param path Path to a dat store. Default to current dir
#' @export
#' @examples \dontrun{
#' dat_start()
#' dat_start('/path/to/folder')
#'}
dat_start <- function(path = ".") {
	browser()
	setwd(path)
    system("dat listen")
    invisible()
} 

dat_start('~/Desktop/foo')