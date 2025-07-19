distinct_col <- function(var, set, col) {
  list(
    var = set %>% distinct(col)
  )
  set %>% distinct(across(all_of(col)))
}