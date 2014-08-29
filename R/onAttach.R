#' @import rnodejs
.onAttach = function(...) {
  check_node_installed()
  check_node_fn_deps("dat", r_package="rDat")
}