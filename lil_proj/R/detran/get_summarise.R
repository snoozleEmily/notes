get_summarise <- function(by_col, col, acc = n()) {
  by_col %>%
    group_by({{ col }}) %>%
    summarise({{ acc }}, .groups = "drop") %>%
    arrange(desc({{ acc }})) %>%
    as.data.frame()
}