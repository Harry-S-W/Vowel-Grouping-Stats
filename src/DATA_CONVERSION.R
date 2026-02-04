run_conversion <- function(raw_csv, stimuli_csv, output_path = "../data/FCmatrix.txt") {
  
  raw_data <- read.csv(raw_csv)
  stimuli  <- read.csv(stimuli_csv)
  
  # 1. Dynamically count participants to avoid negative distances
  unique_ppts <- unique(raw_data$PARTICIPANT)
  n_participants <- length(unique_ppts)
  
  # Initialize matrix (40x40)
  sim_matrix <- matrix(0, nrow = 40, ncol = 40)
  
  for(i in 1:nrow(raw_data)) {
    # Clean the GROUP string before splitting to avoid NAs
    clean_group <- gsub("[^0-9, ]", "", as.character(raw_data$GROUP[i]))
    items <- as.numeric(unlist(strsplit(clean_group, "[, ]+")))
    items <- items[!is.na(items) & items > 0 & items <= 20] # Bounds check
    
    if(length(items) > 1) {
      offset <- if(raw_data$SLIDE[i] == 1) 0 else 20
      adj_items <- items + offset
      
      # Ensure we don't exceed matrix bounds (1-40)
      adj_items <- adj_items[adj_items >= 1 & adj_items <= 40]
      
      if(length(adj_items) > 1) {
        pairs <- combn(sort(adj_items), 2)
        for(j in 1:ncol(pairs)) {
          sim_matrix[pairs[1,j], pairs[2,j]] <- sim_matrix[pairs[1,j], pairs[2,j]] + 1
          sim_matrix[pairs[2,j], pairs[1,j]] <- sim_matrix[pairs[2,j], pairs[1,j]] + 1
        }
      }
    }
  }
  
  # 2. Convert to Dissimilarity (Distance)
  dissim_matrix <- n_participants - sim_matrix
  
  # 3. Safety Floor: Distances cannot be negative or NA
  dissim_matrix[dissim_matrix < 0] <- 0
  diag(dissim_matrix) <- 0
  
  # 4. Apply Labels
  labels <- as.character(stimuli$FileName[1:40])
  colnames(dissim_matrix) <- labels
  rownames(dissim_matrix) <- labels
  
  # 5. Export CLEANly (Standard tab-separated format)
  # We avoid 'col.names = NA' to keep the header simple for Danielle's script
  write.table(dissim_matrix, file = output_path, sep = "\t", quote = FALSE, col.names = TRUE, row.names = TRUE)
  
  return(dissim_matrix)
}