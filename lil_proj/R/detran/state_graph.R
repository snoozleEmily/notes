plot_state_bar <- function(dataset) {
  by_state <- get_summarise(dataset, uf)

  aes_state <- aes(x = reorder(uf, -acc), y = acc, fill = acc)
  chart_state <- ggplot(by_state, aes_state) +
    geom_bar(stat = "identity") +
    scale_fill_gradient(low = "paleturquoise", high = "midnightblue") +
    labs(
      title = "Quantidade de Acidentes por Estado (2024)",
      x = "Estado (UF)",
      y = "Número de Acidentes",
      fill = "Número de Acidentes"
    ) +
    theme_minimal(base_size = 14)
  (list(data = by_state, chart = chart_state))
}
