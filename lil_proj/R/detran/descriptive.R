library(tidyr)
library(dplyr)
library(ggplot2)
library(gridExtra)

accident_type_frequency <- function(dataset) {
  dataset %>%
    group_by(tipo_acidente) %>%
    summarise(
      count = n(),
      percentage = round((n() / nrow(dataset)) * 100, 2)
    ) %>%
    arrange(desc(count))
}

victim_proportion <- function(dataset) {
  dataset %>%
    summarise(
      total_accidents = n(),
      total_deaths = sum(mortos, na.rm = TRUE),
      total_minor_injuries = sum(feridos_leves, na.rm = TRUE),
      total_serious_injuries = sum(feridos_graves, na.rm = TRUE),
      total_unharmed = sum(ilesos, na.rm = TRUE)
    ) %>%
    mutate(
      perc_deaths = round((total_deaths / total_accidents) * 100, 2),
      perc_minor_injuries = round((total_minor_injuries / total_accidents) * 100, 2),
      perc_serious_injuries = round((total_serious_injuries / total_accidents) * 100, 2),
      perc_unharmed = round((total_unharmed / total_accidents) * 100, 2)
    )
}

accident_outcome_proportion <- function(dataset) {
  dataset %>%
    summarise(
      total_accidents = n(),
      fatal_accidents = sum(mortos > 0, na.rm = TRUE),
      injured_accidents = sum((feridos_leves + feridos_graves) > 0, na.rm = TRUE),
      unharmed_accidents = sum((mortos + feridos_leves + feridos_graves) == 0 & ilesos > 0, na.rm = TRUE)
    ) %>%
    mutate(
      perc_fatal = round((fatal_accidents / total_accidents) * 100, 2),
      perc_injured = round((injured_accidents / total_accidents) * 100, 2),
      perc_unharmed = round((unharmed_accidents / total_accidents) * 100, 2)
    )
}

plot_accident_type <- function(dataset) {
  freq_data <- accident_type_frequency(dataset)
  
  ggplot(freq_data, aes(x = reorder(tipo_acidente, -count), y = count)) +
    geom_bar(stat = "identity", fill = "steelblue") +
    theme_minimal() +
    labs(
      title = "Accident Type Frequency",
      x = "Accident Type",
      y = "Count"
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

plot_top9_accident_type <- function(dataset) {
  top9_data <- accident_type_frequency(dataset) %>% head(9)
  
  ggplot(top9_data, aes(x = reorder(tipo_acidente, -count), y = count)) +
    geom_bar(stat = "identity", fill = "darkorange") +
    theme_minimal() +
    labs(
      title = "Top 9 Accident Types",
      x = "Accident Type",
      y = "Count"
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

plot_accident_outcome <- function(dataset) {
  outcome_data <- accident_outcome_proportion(dataset) %>%
    select(perc_fatal, perc_injured, perc_unharmed) %>%
    pivot_longer(everything(), names_to = "Legenda", values_to = "Percentage") %>%
    mutate(Legenda = case_when(
      Legenda == "perc_fatal" ~ "Mortos",
      Legenda == "perc_injured" ~ "Feridos",
      Legenda == "perc_unharmed" ~ "Ilesos"
    ))

  ggplot(outcome_data, aes(x = "", y = Percentage, fill = Legenda)) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar(theta = "y") +
    geom_text(aes(label = paste0(Percentage, "%")),
              position = position_stack(vjust = 0.5), color = "black", size = 5) +
    theme_void() +
    labs(title = "Condição das Vítimas") +
    scale_fill_manual(values = c("#ffd23f", "#7cc0ff", "#ff3d3d"))
}

# Central function
descriptive_analysis <- function(dataset) {
  cat("Summary of Accident Type Frequency:\n")
  print(accident_type_frequency(dataset))
  
  cat("\nProportion of Victims per Accident:\n")
  print(victim_proportion(dataset))
  
  cat("\nProportion of Fatal, Injured, and Unharmed Accidents:\n")
  print(accident_outcome_proportion(dataset))
  
  cat("\nAccident Type Bar Chart:\n")
  print(plot_accident_type(dataset))
  
  cat("\nTop 9 Accident Types Bar Chart:\n")
  print(plot_top9_accident_type(dataset))
  
  cat("\nAccident Outcome Pie Chart:\n")
  print(plot_accident_outcome(dataset))
}
