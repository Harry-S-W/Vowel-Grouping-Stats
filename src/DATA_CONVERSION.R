#---
# title: "DATA CONVERSION"
# author: "Harry Woodhouse"
# date: "`04/02/2026`"
# output: html_document
# license: "GPLv3


# DATA_CONVERSION.R
# Takes a standard CSV and tursn it into a Dissimilarity Matrix
# Exported to "data/FCmatrix.txt"
# ---

library(tidyverse)

run_conversion <- function(raw_csv, stimuli_csv, output_path = "data/FCmatrix.txt") {
  
  raw_data <- read.csv(raw_csv)
  stimuli  <- read.csv(stimuli_csv)
  
  n_participants <- length(unique(raw_data$PARTICIPANT))
  sim_matrix <- matrix(0, nrow = 40, ncol = 40)
  
  for(i in 1:nrow(raw_data)) {
    offset <- if(raw_data$SLIDE[i] == 1) 0 else 20
    items <- as.numeric(unlist(strsplit(as.character(raw_data$GROUP[i]), "[, ]+")))
    items <- items[!is.na(items)]
    
    if(length(items) > 1) {
      adj_items <- items + offset
      pairs <- combn(sort(adj_items), 2)
      for(j in 1:ncol(pairs)) {
        sim_matrix[pairs[1,j], pairs[2,j]] <- sim_matrix[pairs[1,j], pairs[2,j]] + 1
        sim_matrix[pairs[2,j], pairs[1,j]] <- sim_matrix[pairs[2,j], pairs[1,j]] + 1
      }
    }
  }
  
  dissim_matrix <- n_participants - sim_matrix
  diag(dissim_matrix) <- 0
  
  # label adding from stimuli csv :)
  labels <- stimuli$FileName[1:40]
  colnames(dissim_matrix) <- labels
  rownames(dissim_matrix) <- labels
  
  write.table(dissim_matrix, file = output_path, sep = "\t", quote = FALSE, col.names = NA)
  
  return(dissim_matrix)
}