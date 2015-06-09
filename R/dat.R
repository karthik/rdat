#' Dat repository
#'
#' Create and modify a dat repository.
#'
#' @export
#' @param dataset name of the dat 'dataset' (namespace)
#' @param remote path or url to clone form. Default will init a new repo.
#' @param path directory of the dat repository
#' @param dat name of the 'dat' executable  (possibly with path)
#' @param verbose gives some more output
#' @importFrom jsonlite stream_in stream_out
#' @examples # init a temporary repo
#' repo <- dat("cars")
#'
#' # insert some data
#' repo$insert(cars[1:20,])
#' v1 <- repo$status()$version
#' v1
#'
#' # insert some more data
#' repo$insert(cars[21:25,])
#' v2 <- repo$status()$version
#' v2
#'
#' # get the data
#' data1 <- repo$get(v1)
#' data2 <- repo$get(v2)
#' diff <- repo$diff(v1, v2)
#' diff$key
#'
#' # create fork
#' repo$checkout(v1)
#' repo$insert(cars[26:30,])
#' repo$forks()
#' v3 <- repo$status()$version
#'
#' # go back
#' repo$checkout(v2)
#' repo$get()
#'
#' # store binary attachements
#' repo$write(serialize(iris, NULL), "iris")
#' unserialize(repo$read("iris"))
#'
#' # Create another repo
#' dir.create(newdir <- tempfile())
#' repo2 <- dat("cars", path = newdir, remote = repo$path())
#' repo2$forks()
#' repo2$get()
#'
#' # Create a third repo
#' dir.create(newdir <- tempfile())
#' repo3 <- dat("cars", path = newdir, remote = repo$path())
#'
#' # Sync 2 with 3 via remote (1)
#' repo2$insert(cars[31:40,])
#' repo2$push()
#' repo3$pull()
#'
#' # Verify that repositories are in sync
#' mydata2 <- repo2$get()
#' mydata3 <- repo3$get()
#' stopifnot(all.equal(mydata2, mydata3))
dat <- function(dataset = "test", path = tempdir(), remote = NULL, dat = "dat", verbose = FALSE){

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

  # Stream ndjson data from dat in R
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

  # Stream ndjson into dat
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

  # Stream binary data from dat in R
  dat_read_bin <- function(args){
    args <- paste(args, collapse = " ")
    in_datdir({
      con <- pipe(paste(dat, args), open = "rb")
      on.exit({
        res <- close(con)
        if(length(res) && res) stop("dat error ", res)
      })
      readBin(con, raw(), n = 1e8)
    })
  }

  # Write binary data to dat
  dat_write_bin <- function(data, args){
    args <- paste(args, collapse = " ")
    in_datdir({
      con <- pipe(paste(dat, args), open = "wb")
      on.exit({
        res <- close(con)
        if(length(res) && res) stop("dat error ", res)
      })
      invisible(writeBin(data, con))
    })
  }

  # Initiate the dat repository
  if(is.null(remote)){
    dat_command("init")
  } else {
    dat_command(c("clone", remote, "."))
  }

  # Show dat version
  if(verbose)
    message("This is dat version ", dat_command("--version"))

  # Control object
  self <- local({

    insert <- function(data){
      stopifnot(is.data.frame(data))
      invisible(dat_stream_out(data, c("-d", dataset, "import -")))
    }

    write <- function(bin, filename){
      stopifnot(is.raw(bin))
      invisible(dat_write_bin(bin, c("write", filename, "-d", dataset, "-")))
    }

    read <- function(filename, version = NULL){
      if (is.null(version)) {
        dat_read_bin(c("read -d", dataset, filename))
      } else {
        dat_read_bin(c("read -d", dataset, "-c", version, filename))
      }
    }

    get <- function(version = NULL){
      out <- if(is.null(version)){
        dat_stream_in(c("export -d", dataset))
      } else {
        dat_stream_in(c("export -d", dataset, "-c", version))
      }
      as.data.frame(out)
    }

    status <- function()
      jsonlite::fromJSON(dat_command("status --json"))

    checkout <- function(key)
      invisible(dat_command(c("checkout", key)))

    forks <- function()
      dat_command("forks")

    diff <- function(version1, version2 = NULL){
      if(is.null(version2)){
        dat_stream_in(c("diff --json", version1))
      } else {
        dat_stream_in(c("diff --json", version1, version2))
      }
    }

    log <- function()
      dat_stream_in("log")

    path <- function()
      return(dat_path)

    pull <- function(){
      if(is.null(remote)){
        stop("This repository was not created from a remote.")
      } else {
        jsonlite::fromJSON(dat_command(c("pull --json", remote)))
      }
    }

    push <- function(){
      if(is.null(remote)){
        stop("This repository was not created from a remote.")
      } else {
        jsonlite::fromJSON(dat_command(c("push --json", remote)))
      }
    }

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
