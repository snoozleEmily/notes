library(skimr)
library(dplyr)

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
View(get_summarise(dataset, uf))

# Probability of climate influence
View(get_summarise(dataset, condicao_meterologica))

# How the day time affects accidents
View(get_summarise(dataset, fase_dia))


# What insights there are about types of prominent accidents and their causes
