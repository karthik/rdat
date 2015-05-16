#' Dat repository
#'
#' Create and modify a dat repository.
#'
#' @export
#' @param path directory of the dat repository
#' @param dat name of the 'dat' executable  (possibly with path)
#' @param verbose gives some more output
#' @importFrom jsonlite stream_in stream_out
#' @examples # init a temporary repo
#' repo <- dat(tempdir())
#'
#' # insert some data
#' repo$insert(cars[1:20,])
#' v1 <- repo$heads()
#'
#' # insert some more data
#' repo$insert(cars[21:25,])
#' v2 <- repo$heads()
#'
#' # get the data
#' data1 <- repo$get(v1)
#' data2 <- repo$get(v2)
#' diff <- repo$diff(v1, v2)
#' diff$key
#'
#' # create fork
#' repo$checkout(v1)
#' repo$insert(cars[40:42,])
#' repo$heads()
#'
#' # go back
#' repo$checkout(v2)
#' repo$get()
dat <- function(path = tempdir(), dat = "dat-beta", verbose = FALSE){

  # Holds dir with the dat repository
  dat_path <- normalizePath(path)
  repo <- file.path(dat_path, ".dat")

  # Run a command in the dat dir
  in_datdir <- function(...){
    oldpath <- getwd()
    on.exit(setwd(oldpath))
    setwd(dat_path)
    eval(...)
  }

  # Executes a dat command and returs stdout.
  dat_command <- function(args){
    in_datdir({
      tmp1 <- tempfile()
      on.exit(unlink(tmp1), add=TRUE)
      tmp2 <- tempfile()
      on.exit(unlink(tmp2), add=TRUE)
      err <- system2(dat, args, stdout = tmp1, stderr = tmp2)
      if(err)
        stop(readLines(tmp2), " (", err, ")")
      if(file.exists(tmp2) && length(txt2 <- readLines(tmp2)))
        message(txt2)
      if(file.exists(tmp1))
        readLines(tmp1)
    })
  }

  # Stream data from dat in R
  dat_stream_in <- function(args){
    args <- paste(args, collapse = " ")
    in_datdir({
      con <- pipe(paste(dat, args), open = "r")
      on.exit({
        res <- close(con)
        if(length(res) && res) stop("dat error ", res)
      })
      jsonlite::stream_in(con, verbose = verbose)
    })
  }

  # Stream something into dat
  dat_stream_out <- function(data, args){
    args <- paste(args, collapse = " ")
    in_datdir({
      con <- pipe(paste(dat, args), open = "w")
      on.exit({
        res <- close(con)
        if(length(res) && res) stop("dat error ", res)
      })
      invisible(jsonlite::stream_out(data, con, verbose = verbose))
    })
  }

  # Initiate the dat repository
  dat_command("init")

  # Show dat version
  if(verbose)
    message("This is dat version ", dat_command("--version"))

  # Control object
  self <- local({

    insert <- function(data){
      stopifnot(is.data.frame(data))
      invisible(dat_stream_out(data, "import -"))
    }

    get <- function(version = NULL){
      out <- if(is.null(version)){
        dat_stream_in("export")
      } else {
        dat_stream_in(c("export -c", version))
      }
      data <- out$value
      data$key <- out$key
      as.data.frame(data)
    }

    checkout <- function(key)
      dat_command(c("checkout", key))

    heads <- function()
      dat_command("heads")

    diff <- function(version1, version2)
      dat_stream_in(c("diff", version1, version2))

    path <- function()
      return(dat_path)

    environment();
  })

  # Create the object
  lockEnvironment(self, TRUE)
  structure(self, class=c("dat", "jeroen", class(self)))
}

#' @export
print.dat <- function(x, ...){
  print.jeroen(x, title = paste0("<Dat> '", x$path(), "'"))
}
