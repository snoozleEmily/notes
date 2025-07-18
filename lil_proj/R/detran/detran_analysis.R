library(skimr) 
library(dplyr) # Ignore linter warnings
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c("%>%", "distinct", "across", "all_of"))
}


# Set working directory and load data
setwd("d:/Projects/random projects/notes/notes/lil_proj/R/detran")
dataset <- read.csv(
  "datatran2024.csv",
  sep = ";",
  fileEncoding = "Windows-1252"
)
# View(dataset)

# Overview
# print(str(dataset))
print(skim(dataset))

# Distinct values
source("D:/Projects/random projects/notes/notes/lil_proj/R/detran/distinct.R")
distincts <- cols(dataset)
# View(distincts$cause)  # cause, type, condition
