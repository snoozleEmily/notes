cols <- function(set) {
  list(
    cause = data.frame(unique(set[["causa_acidente"]])),
    type = data.frame(unique(set[["tipo_acidente"]])),
    condition = data.frame(unique(set[["condicao_metereologica"]]))
  )
}

# Get distinct dataframes from columns
distinct_col <- function(set, col) {
  data.frame(unique(set[[col]]))
}
