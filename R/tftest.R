#' Runs `devtools::test` using different virtualenv environments.
#'
#' It will open one terminal tab for each environment so tests are run in
#' parallel.
#'
#' @param envs character of vector containing the names of virtual environments
#'   you want to test against.
#'
#' @export
tftest <- function(envs = c("tf-1.13.1", "tf-1.12.0", "tf-2.0.0", "tf-nightly")) {
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

tftest2 <- function(env = "tf-nightly") {
  env_eager <- paste0(env, "-eager")
  kill_terminal(env)
  kill_terminal(env_eager)

  id <- rstudioapi::terminalCreate(caption = env)
  id_eager <- rstudioapi::terminalCreate(caption = env_eager)

  rstudioapi::terminalSend(
    id = id,
    glue::glue("Rscript -e 'reticulate::use_virtualenv(\"{env}\");devtools::test()'")
  )
  rstudioapi::terminalSend(id, "\n")

  rstudioapi::terminalSend(
    id = id_eager,
    glue::glue("Rscript -e 'Sys.setenv(TENSORFLOW_EAGER='TRUE');reticulate::use_virtualenv(\"{env}\");devtools::test()'")
  )
  rstudioapi::terminalSend(id_eager, "\n")
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




