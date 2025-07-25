library(dplyr)

distinct_col <- function(set, col, n_name = "n", perc_name = "perc") {
  set %>%
    group_by(across(all_of(col))) %>%
    summarise(n = n(), .groups = "drop") %>%
    mutate(perc = round((n / sum(n)) * 100, 2)) %>%
    rename(
      !!n_name := n,
      !!perc_name := perc
    )
}
