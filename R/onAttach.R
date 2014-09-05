#' @import rnodejs
.onAttach = function(...) {
  check_node_installed()  
  check_node_deps("dat", "rDat")
}