plot_pizza <- function(dataset, field,
                       title_text = "Distribuição de Acidentes") {
  by_field <- dataset %>%
    group_by({{ field }}) %>%
    summarise(quantidade = n(), .groups = "drop") %>%
    arrange(desc(quantidade))

  colnames(by_field)[1] <- "categoria"

  by_field <- by_field %>%
    mutate(
      percent = quantidade / sum(quantidade) * 100,
      categoria_label = paste0(
        categoria, " (", 
        ifelse(round(percent, 2) == 0,
               formatC(percent, format = "f", digits = 4),
               formatC(percent, format = "f", digits = 2)),
        "%)"
      )
    )

  by_field$categoria_label <- factor(by_field$categoria_label,
    levels = by_field$categoria_label
  )

  pie_chart <- ggplot(
    by_field,
    aes(x = "", y = quantidade, fill = categoria_label)
  ) +
    geom_col(width = 1, color = "white") +
    coord_polar(theta = "y") +
    labs(
      title = title_text,
      fill = "Legenda e %"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank()
    )
  list(data = by_field, chart = pie_chart)
}
