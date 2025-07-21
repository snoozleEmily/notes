plot_state_bar <- function(dataset, field,
                           title_text = "Distribuição de Acidentes") {
  by_field <- dataset %>%
    group_by({{ field }}) %>%
    summarise(acc = n(), .groups = "drop") %>%
    arrange(desc(acc))

  colnames(by_field)[1] <- "categoria"

  chart <- ggplot(by_field, aes(
    x = reorder(categoria, -acc), y = acc, fill = acc
  )) +
    geom_bar(stat = "identity") +
    scale_fill_gradient(low = "paleturquoise", high = "midnightblue") +
    labs(
      title = title_text,
      x = "Categoria",
      y = "Número de Acidentes",
      fill = "Número de Acidentes"
    ) +
    theme_minimal(base_size = 14)

  list(data = by_field, chart = chart)
}
