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
source(file.path(path, "state_graph.R"))
result_state <- plot_state_bar(dataset)
View(result_state$data) # 1. MG
print(result_state$chart)


# Probability of climate influence
source(file.path(path, "climate_graph.R"))
result_climate <- plot_climate_pie(dataset)
# View(result_climate$data)  # 1. Céu Claro
# print(result_climate$chart)


# How the day time affects accidents
# View(get_summarise(dataset, fase_dia)) # 1. Pleno dia

# Most common types of accidents
# View(get_summarise(dataset, causa_acidente))

# What insights there are about types of prominent accidents and their causes
