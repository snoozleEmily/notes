# PROBABILIDADE E ESTATÍSTICA PARA ANÁLISE DE DADOS
setwd("d:/Projects/random projects/notes/notes/lil_proj/R/detran")
dataset <- read.csv(
  "datatran2024.csv",
  sep = ";",
  fileEncoding = "Windows-1252"
)
# View(dataset)

# See specific values
source("D:/Projects/random projects/notes/notes/lil_proj/R/detran/distincts.R")
distincts <- cols(dataset)
View(distincts$condition) # cause, type, condition

