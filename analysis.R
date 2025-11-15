library(tidyverse)

data_file <- readLines("data/data_path.txt", warn = FALSE)
data_file <- stringr::str_trim(data_file)

vowels <- read_csv(data_file, show_col_types = FALSE)

# Because the CSV file is originally PART # | TRIAL | GROUP # | GROUP - It makes it hard to 
# analyze the data because GROUP is often a list of ints or strs. We will explode the data
# so each row is PART # | TRIAL | GROUP # | GROUP ITEM

explode_groups <- function(df, group_col = "GROUP"){
  df %>%
    # take all the vals in group column and turn them into lists called sound
    mutate(SOUND = str_split(GROUP, ",")) %>%
    
    # make each item of the list sound into a seperate row
    unnest(SOUND) %>%
    
    # making sure to remove white space
    mutate(SOUND = str_trim(SOUND)) %>%
    
    # Drop empty strings from trailing commas
    filter(SOUND != "") %>%
    
    # Convert str to int
    mutate(SOUND = as.numeric(SOUND))
}

#head(vowels_long, 50)
vowels_long <- explode_groups(vowels)
print(vowels_long, n = 50)


# Now we need to associate numbers in the exploded data to the vowels in the 
# stimulus excel. 

stimulus_mergine <- function(participant_data, stimulus_data, group_col = "SOUND"){
  print("placeholder")
}