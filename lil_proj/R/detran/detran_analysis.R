library(skimr)
library(dplyr)
library(ggplot2)

path <- "D:/Projects/random projects/notes/notes/lil_proj/R/detran"

# Set working directory and load data
setwd(file.path(path))
dataset <- read.csv(
  "datatran2024.csv",
  sep = ";",
  fileEncoding = "Windows-1252"
)
# View(dataset)

# Overview
# print(str(dataset))
# print(skim(dataset))

# Distinct values
source(file.path(path, "distinct.R"))
source(file.path(path, "get_summarise.R"))

# Ammount of accidents by state
by_state <- get_summarise(dataset, uf)
# View(by_state) # 1. MG
aes_var <- aes(x = reorder(uf, -acc), y = acc, fill = acc)
plot_state <- ggplot(by_state, aes_var) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "paleturquoise", high = "midnightblue") +
  labs(
    title = "Quantidade de Acidentes por Estado (2024)",
    x = "Estado (UF)",
    y = "Número de Acidentes",
    fill = "Número de Acidentes"
  ) +
  theme_minimal(base_size = 14)

# print(plot_state)

# Probability of climate influence
# View(get_summarise(dataset, condicao_metereologica)) # 1. Céu Claro


# How the day time affects accidents
# View(get_summarise(dataset, fase_dia)) # 1. Pleno dia

# Most common types of accidents
# View(get_summarise(dataset, causa_acidente))

# What insights there are about types of prominent accidents and their causes
