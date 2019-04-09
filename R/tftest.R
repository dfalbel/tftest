#' Runs `devtools::test` using different virtualenv environments.
#'
#' It will open one terminal tab for each environment so tests are run in
#' parallel.
#'
#' @param envs character of vector containing the names of virtual environments
#'   you want to test against.
#'
#' @export
tftest <- function(envs = c("tf-1.13.1", "tf-1.12.0", "tf-2.0.0")) {
  for (env in envs) {
    kill_terminal(env)
    id <- rstudioapi::terminalCreate(caption = env)
    rstudioapi::terminalSend(
      id = id,
      glue::glue("Rscript -e 'reticulate::use_virtualenv(\"{env}\");devtools::test()'")
    )
    rstudioapi::terminalSend(id, "\n")
  }
}

get_all_terminal <- function() {
  purrr::map_dfr(
    rstudioapi::terminalList(),
    ~tibble::as_tibble(rstudioapi::terminalContext(.x)[c("handle", "caption")])
    )
}

kill_terminal <- function(caption) {
  terms <- get_all_terminal()
  ind <- which(terms$caption == caption)

  if (length(ind) == 1) {
    id <- terms$handle[ind]
    rstudioapi::terminalKill(id)
  }

}




