plot_bar <- function(dataset, field,
                     title_text = "Distribuição de Acidentes",
                     horizontal = FALSE,
                     max_char = 25) {  
  
  by_field <- dataset %>%
    group_by({{ field }}) %>%
    summarise(acc = n(), .groups = "drop") %>%
    arrange(desc(acc))
  
  colnames(by_field)[1] <- "categoria"
  
  chart_list <- list()
  data_list <- list()
  
  wrap_labels <- function(x) {
    ifelse(nchar(x) > max_char,
           stringr::str_wrap(x, width = max_char),
           x)
  }
  
  if (horizontal && nrow(by_field) > 32) {
    # Split data for horizontal charts with many categories
    top_data <- by_field[1:32, ]
    rest_data <- by_field[33:nrow(by_field), ]
    
    create_horizontal_chart <- function(data, title_suffix) {
      data$categoria <- factor(data$categoria, levels = rev(data$categoria))
      
      ggplot(data, aes(x = acc, y = categoria, fill = acc)) +
        geom_bar(stat = "identity") +
        labs(
          title = paste(title_text, title_suffix),
          x = "Número de Acidentes",
          y = "Categoria",
          fill = "Número de Acidentes"
        ) +
        scale_fill_gradient(low = "midnightblue", high = "firebrick") +
        scale_y_discrete(labels = wrap_labels) + 
        theme_minimal(base_size = 14) +
        theme(axis.text.y = element_text(size = 10))  
    }
    
    chart_list <- list(
      create_horizontal_chart(top_data, "(Top 32)"),
      create_horizontal_chart(rest_data, "(Restante)")
    )
    data_list <- list(top_data, rest_data)
    
  } else {
    # Single chart case
    if (horizontal) {
      by_field$categoria <- factor(by_field$categoria, levels = rev(by_field$categoria))
      chart <- ggplot(by_field, aes(x = acc, y = categoria, fill = acc)) +
        geom_bar(stat = "identity") +
        scale_y_discrete(labels = wrap_labels)  
    } else {
      by_field$categoria <- factor(by_field$categoria, levels = by_field$categoria)
      chart <- ggplot(by_field, aes(x = categoria, y = acc, fill = acc)) +
        geom_bar(stat = "identity") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate for vertical
    }
    
    chart <- chart +
      labs(
        title = title_text,
        x = ifelse(horizontal, "Número de Acidentes", "Categoria"),
        y = ifelse(horizontal, "Categoria", "Número de Acidentes"),
        fill = "Número de Acidentes"
      ) +
      scale_fill_gradient(low = "midnightblue", high = "firebrick") +
      theme_minimal(base_size = 14)
    
    chart_list <- list(chart)
    data_list <- list(by_field)
  }
  
  list(data = data_list, charts = chart_list)
}