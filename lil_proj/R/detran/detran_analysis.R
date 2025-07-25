library(skimr)
library(dplyr)
library(ggplot2)
library(gridExtra)

path <- "D:/Projects/random projects/notes/notes/lil_proj/R/detran"
setwd(file.path(path))
dataset <- read.csv(
  "datatran2024.csv",
  sep = ";",
  fileEncoding = "Windows-1252"
)

# Overview
View(dataset)
print(str(dataset))
print(skim(dataset))

# Distinct values
source(file.path(path, "distinct.R"))
source(file.path(path, "get_summarise.R"))
source(file.path(path, "pizza_graph.R"))
source(file.path(path, "bar_graph.R"))

# Ammount of accidents by state
result_state <- plot_bar(dataset, uf,
  title_text = "Quantidade de Acidentes por Estado (2024)"
)
View(result_state$data)
print(result_state$chart)

# Probability of climate influence
result_climate <- plot_pizza(dataset, condicao_metereologica,
  title_text = "Distribuição por Condição Meteorológica (2024)"
)
View(result_climate$data) 
print(result_climate$chart)


# How the day time affects accidents
result_day <- plot_pizza(dataset, fase_dia,
  title_text = "Distribuição por Fase do Dia (2024)"
)
View(result_day$data)
print(result_day$chart)

# Most common types of accidents
result_types <- plot_bar(dataset, causa_acidente,
  title_text = "Distribuição por Causa do Acidente (2024)",
  horizontal = TRUE
)
View(result_types$data)
grid.arrange(grobs = result_types$charts, ncol = 1)

# Overview on BR accidents
View(distinct_col(dataset, "br",
  n_name = "quantidade_accidents",
  perc_name = "porcentagem_acidentes"
))