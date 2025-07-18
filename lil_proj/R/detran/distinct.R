cols <- function(set) {
  list(
    cause = set %>% distinct(causa_acidente),
    type = set %>% distinct(tipo_acidente),
    condition = set %>% distinct(condicao_metereologica)
  )
}

distinct_col <- function(set, col) {
  set %>% distinct(across(all_of(col)))
}