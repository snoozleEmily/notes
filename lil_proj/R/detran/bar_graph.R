plot_bar <- function(dataset, field,
                     title_text = "Distribuição de Acidentes",
                     horizontal = FALSE) {
  # Summarise data
  by_field <- dataset %>%
    group_by({{ field }}) %>%
    summarise(acc = n(), .groups = "drop") %>%
    arrange(desc(acc))

  colnames(by_field)[1] <- "categoria"

  if (horizontal && nrow(by_field) > 32) {
    top_cats <- by_field[1:32, ]
    remaining_sum <- sum(by_field$acc[33:nrow(by_field)])
    outros_row <- data.frame(categoria = "Outros", acc = remaining_sum)

    by_field <- bind_rows(top_cats, outros_row)
  }

  # Reorder based on orientation
  if (!horizontal) {
    # Vertical: descending order left→right
    by_field$categoria <- factor(by_field$categoria,
      levels = by_field$categoria
    )

    chart <- ggplot(by_field, aes(x = categoria, y = acc, fill = acc)) +
      geom_bar(stat = "identity") +
      labs(
        title = title_text,
        x = "Categoria",
        y = "Número de Acidentes",
        fill = "Número de Acidentes"
      )
  } else {
    # Horizontal: descending order top→bottom
    by_field$categoria <- factor(by_field$categoria,
      levels = rev(by_field$categoria)
    )

    chart <- ggplot(by_field, aes(x = acc, y = categoria, fill = acc)) +
      geom_bar(stat = "identity") +
      labs(
        title = title_text,
        x = "Número de Acidentes",
        y = "Categoria",
        fill = "Número de Acidentes"
      )
  }

  # Common theme & colors
  chart <- chart +
    scale_fill_gradient(low = "paleturquoise", high = "midnightblue") +
    theme_minimal(base_size = 14)

  list(data = by_field, chart = chart)
}
