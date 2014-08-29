#' Initialize a dat repository
#'
#' This function will initialize a dat repository
#' @param path Path to data store. use \code{"."} for current dir.
#' @export
#' @keywords initialize
#' @examples \dontrun{
#' dat_init('.')
#'}
dat_init  <- function(path = ".") {
	# Needs a better dir tester
	dir.status <- system(paste("test -d", paste0(path, "/.dat")), intern = FALSE) == 0

	if(!file.exists(path)) {
	message("Creating new dir? ")	
	create <- readline(": ")
	if(create == "Y") {
	dir.create(path)
	setwd(path) } 

}

	if(dir.status) {
	stop("A dat store already exists here") } else {
		out = dat_init_internal()
    if(out==0) {message(out$stdout)} else {stop(out$stderr)}
	}

}

#' @import rnodejs
dat_init_internal = node_fn("dat", "init")



# Need to be able to pass name, desc, and publisher