# climate_graph.R
plot_climate_pie <- function(dataset) {
  by_climate <- get_summarise(dataset, condicao_metereologica)
  colnames(by_climate) <- c("condicao", "quantidade")

  by_climate <- by_climate %>%
    mutate(
      percent = quantidade / sum(quantidade) * 100,
      condicao_label = paste0(
        condicao, " (", formatC(percent, format = "f", digits = 4), "%)"
      )
    ) %>%
    arrange(desc(quantidade))

  by_climate$condicao_label <- factor(by_climate$condicao_label,
                                      levels = by_climate$condicao_label)
  aes_climate <- aes(x = "", y = quantidade, fill = condicao_label)
  pie_chart <- ggplot(by_climate, aes_climate) +
    geom_col(width = 1, color = "white") +
    coord_polar(theta = "y") +
    labs(
      title = "Distribuição de Acidentes por Condição Meteorológica (2024)",
      fill = "Legenda e %"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank()
    )

  list(data = by_climate, chart = pie_chart)
}
