# SPEAKER MDS
# Makes a 5 dimensional multidimensional scale :) 
# It uses a correlational method 
# This is very new to me so if you spot a mistake please let me know
# Email: jgf526@york.ac.uk


library(dplyr)
library(tidyr)
library(purrr)


speaker_data <- read.csv("../data/speaker_data.csv")
n_items <- 40
participants <- unique(speaker_data$PARTICIPANT)

get_cooc_vector <- function(p_id, data) {
  group_data <- data %>% filter(PARTICIPANT == p_id)
  mat <- matrix(0, nrow = n_items, ncol = n_items)
  
  for (i in seq_len(nrow(group_data))) {
    row <- group_data[i, ]
    slide <- row$SLIDE
    group_str <- as.character(row$GROUP)
    
    if (is.na(group_str) || group_str == "" || tolower(group_str) == "nan") next
    
    idxs <- as.integer(unlist(strsplit(group_str, ",")))
    idxs <- idxs[!is.na(idxs)]
    
    adj_idxs <- idxs + ifelse(slide == 2, 20, 0)
    
    if (length(adj_idxs) >= 2) {
      pairs <- combn(adj_idxs, 2)
      for (p in 1:ncol(pairs)) {
        u <- pairs[1, p]
        v <- pairs[2, p]
        mat[u, v] <- 1
        mat[v, u] <- 1
      }
    }
  }
  return(mat[upper.tri(mat)])
}

vector_list <- map(participants, ~get_cooc_vector(.x, speaker_data))
X <- do.call(rbind, vector_list)
rownames(X) <- participants

run_mds_5d <- function(dist_matrix, filename) {
  # k = 5 for 5 dimensions
  mds_fit <- cmdscale(dist_matrix, k = 5)
  
  df <- as.data.frame(mds_fit)
  
  colnames(df) <- paste0("D", 1:5)
  
  write.csv(df, filename, row.names = TRUE)
}

X_safe <- X + 1e-9
cor_mat <- cor(t(X_safe))
dist_corr <- as.dist(1 - cor_mat)
run_mds_5d(dist_corr, "../data/speaker_coords.csv")
