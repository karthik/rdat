# Internal functions to look for an install of node, get the most recent
# version
# Gleefully stolen from the rmarkdown package's approach to finding pandoc

# Environment used to cache the current node directory and version
.node <- new.env()
.node$dir <- NULL
.node$version <- NULL
.node$npm <- NULL
.node$npm_ver <- NULL
.node$messages <- character()

#' get the node binary
#' @noRd
node <- function() {
  find_node()
  file.path(.node$dir, "node")
}

#' @noRd
npm = function() {
  find_node()
  file.path(.node$npm, "npm")
}


# Scan for a copy of node and set the internal cache if it's found.
#' @noRd
find_node <- function() {

  if (is.null(.node$dir)) {

    # define potential sources
    sys_node <- Sys.which("node")
    sys_npm <- Sys.which("npm")
    sources <- c(getOption("NodePath"),
                 ifelse(nzchar(sys_node), dirname(sys_node), ""))
    sources_npm <- c(getOption("NpmPath"),
                 ifelse(nzchar(sys_npm), dirname(sys_node), ""))
    if (!is_windows()) {
      sources <- c(sources, path.expand("~/opt/node"))
      sources_npm <- c(sources_npm, path.expand("~/opt/npm"))
    }

    # determine the versions of the sources
    versions <- lapply(sources, function(src) {
      if (file.exists(src))
        get_node_version(src)
      else
        numeric_version("0")
    })
    
    versions_npm <- lapply(sources_npm, function(src) {
      if (file.exists(src))
        get_node_version(src)
      else
        numeric_version("0")
    })    

    # find the maximum version
    found_src <- NULL
    found_ver <- numeric_version("0")
    for (i in 1:length(sources)) {
      ver <- versions[[i]]
      if (ver > found_ver) {
        found_ver <- ver
        found_src <- sources[[i]]
      }
    }

    found_npm <- NULL
    found_npmver <- numeric_version("0")
    for (i in 1:length(sources_npm)) {
      ver <- versions_npm[[i]]
      if (ver > found_npmver) {
        found_npmver <- ver
        found_npm <- sources[[i]]
      }
    }

    # did we find a version?
    if (!is.null(found_src)) {
      .node$dir <- found_src
      .node$npm <- found_npm
      .node$version <- found_ver
      .node$npmver <- found_npmver
    }
  }
}

# Get an S3 numeric_version for the node utility at the specified path
#' @noRd
get_node_version <- function(node_dir) {
  node_path <- file.path(node_dir, "node")
  version_info <- system(paste(shQuote(node_path), "--version"),
                           intern = TRUE)
  version = sub("v", "", version_info)
  numeric_version(version)
}

#' @noRd
get_npm_version <- function(npm_dir) {
  node_path <- file.path(node_dir, "npm")
  version_info <- system(paste(shQuote(node_path), "--version"),
                           intern = TRUE)
  numeric_version(version)
}

#' @noRd
is_windows <- function() {
  identical(.Platform$OS.type, "windows")
}

#' Create a function to call a wrapped node.js package
#' 
#' @param node_package the directory name of the node package
#' @param node_cmd the 'bin' command of the node package.  Defaults to the package name
#' @param node_dir the directory where node packages are kept.  Defaults to
#'                 'node', which should be a directory under 'inst' when
#'                 creaing your own package.
#' @param r_package the package name which wraps the function.  Defaults to the
#'                  \link{parent.frame}, assuming that \code{node_fn_load} is
#'                  being used in a package.
#' @param return_list If \code{TRUE}, the new function will return a list of
#'                    the return value, stdout, and stderr from the call to the
#'                    node.js function.  If \code{FALSE}, the new function will
#'                    return the results of a \link{system2} call.
#' @param ...         Additional parameters to pass to \link{system2} if
#'                    \code{return_list=TRUE}
#'                    
#' @import jsonlite
#' @export 
node_fn_load = function(node_package, node_cmd = node_package, 
                        node_dir = "node", r_package = NULL,
                        return_list = TRUE, ...) {
  if(is.null(r_package)) r_package = environmentName(parent.frame())
  nodepath = system.file(node_dir, package=r_package)
  nodepackage_path = file.path(nodepath, node_package)
  package.json = file.path(nodepackage_path, "package.json")
  if(!file.exists(package.json)) {
    nodepackage_path = list.files(path=nodepath, pattern=node_package, 
                                  recursive=TRUE, include.dirs=TRUE)
    package.json = file.path(nodepath, nodepackage_path,"package.json")
    if(!file.exists(package.json)) {
      stop("Node package '", node_package, "' not found in R package '",
            r_package, "' under directory '", node_dir, "'.")
    }
  }
  package.data = fromJSON(package.json)
  package_name = package.data$name
  bin = package.data$bin[[node_cmd]]
  if(is.null(bin)) stop("Command '", bin,  "' not found in node package'",
                        node_package, "'.")
                               
  node_command = do.call(file.path, as.list(c(nodepackage_path,
                                              strsplit(bin, "/")[[1]])))
  fn = function(args=list()) {
     textargs = ifelse(length(args) > 0,
                       paste0("--", names(args), " ", args, collapse=" "),
                       "")
     node_command = c(node_command, textargs)
     outfile = tempfile()
     errfile = tempfile()
     if(return_list) {
       out = system3(node(), node_command)
     } else {
       out = system2(node(), node_command, ...)
     }
     return(out)
      }
  return(fn)
  }

#' @noRd
node_deps_update = function(nodepackage_path, verbose=FALSE) {
  if(!verbose) {
    npm_out=system3(npm(), args=paste0("install --prefix ", nodepackage_path))
    return(npm_out$output)
  } else {
    npm_out = system2(npm(), args=paste0("install --prefix ", nodepackage_path))
    status = attr(npm_out, "status")
    if(length(status)==0) status=0
    return(status)
  }
}

#' @noRd
node_deps_installed = function(nodepackage_path) {
  out = system3(npm(), args=paste0("outdated --prefix ", nodepackage_path))
  out = stri_replace_all_fixed(out$stdout, " > ", ">")
  out = stri_replace_all_regex(out, "[^\\S\\n]+", ",")
  out = read.csv(text=out, stringsAsFactors=FALSE)
  if(any(out$Current=="MISSING")) {
    return(FALSE)
  } else {
    Wanted = numeric_version(out$Wanted)
    Current = numeric_version(out$Current)
    if(any(Current < Wanted)) return(FALSE)
  }
  return(TRUE)
}


#' Check if node is installed
#' 
#' Put this function in \link{.onAttach} for in your package containing a node
#' module.  It will stop package loading (by throwing an error) if node is not 
#' available, and print a message if it is.
#' @export 
check_node_installed = function() {
  find_node()
  if (is.null(.node$dir)) {
    stop("This package requires node.js, which does not appear to be installed on your machine.  Get node at http://nodejs.org.\nIf you have node installed in a non-standard directory, set the directory path with:\n\noptions(NodePath=PATH)")
  } else {
    message("You have node.js ", .node$version, " installed.")
  }
}

#' Check node module dependencies and install if missing
#' 
#' Put this function in \link{.onAttach} to check and install node module
#' dependencies.  This is useful because some dependencies are binary and can
#' not be hosted on CRAN.
#' 
#' @param node_package the directory name of the node package in the R package
#' @param node_dir the directory where node packages are kept.  Defaults to
#'                 'node', which should be a directory under 'inst' when
#'                 creaing your own package.
#' @param r_package the package name which wraps the function. Must be specified
#'                  as the function can't automatically detect the package
#'                  inside \link{.onAttach}
#' @param ask Ask before installing dependencies?
#' @param verbose Show verbose installation?  If \code{ask=TRUE}, user decides
#' @export
check_node_fn_deps = function(node_package, node_dir = "node", r_package = NULL,
                              ask=TRUE, verbose=FALSE) {
  
  if(is.null(r_package)) r_package = environmentName(parent.frame())
  nodepath = system.file(node_dir, package=r_package)
  nodepackage_path = file.path(nodepath, node_package)
  package.json = file.path(nodepackage_path, "package.json")
  if(!file.exists(package.json)) {
    nodepackage_path = list.files(path=nodepath, pattern=node_package, 
                                  recursive=TRUE, include.dirs=TRUE)
    package.json = file.path(nodepath, nodepackage_path,"package.json")
    if(!file.exists(package.json)) {
      stop("Node package '", node_package, "' not found in R package '",
            r_package, "' under directory '", node_dir, "'.")
    }
  }
  package.data = fromJSON(package.json)
  package_name = package.data$name
  node_ver_req = package.data$engines["node"]
  
  message(package_name, " requires node ", node_ver_req, ". You have node ",
          .node$version)
  
  installed = node_deps_installed(nodepackage_path)
  if(installed) {
    message(package_name, " dependencies are installed.")
  } else {
    if(ask) {
      ask = readline(paste0(package_name, " has missing dependencies.  Install from www.npmjs.org? (y/n, default no, 'v' for verbose install): "))
      if(ask=="v") {
        verbose=TRUE
        ask="yes"
      }
      if (ask=="") {
        ask = FALSE
      } else {
        ask = match.arg(ask, c("yes", "no"))
        ask = ask=="yes"
      }
    }
    if(ask) {
        inst_success = node_deps_update(nodepackage_path, verbose=verbose)
      if(inst_success != 0) {
        stop("Install failed")
      } else {
        message("Install successful!")
      }
    } else {
      message("Package functions will likely fail without dependencies. Re-load to try installing again")
      if(interactive()) stop()
    }
  }
}


system3 = function(command, args=character(), ...) {
     outfile = tempfile()
     errfile = tempfile()
     output = system2(command, args, stdout=outfile, stderr=errfile, ...)
     return(list(output=output,
                 stdout = readChar(outfile, file.info(outfile)$size),
                 stderr = readChar(errfile, file.info(errfile)$size)))
}