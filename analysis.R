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
    
    # make each item of the list into a seperate row
    unnest(SOUND) %>%
    
    # remove white space around the strs
    mutate(SOUND = str_trim(SOUND)) %>%
    
    # Drop empty strings from trailing commas
    filter(SOUND != "") %>%
    
    # Convert str to int
    mutate(SOUND = as.numeric(SOUND))

}

#head(vowels_long, 50)
vowels_long <- explode_groups(vowels)
# we can export this as a csv so we can refer to it later without reusing this function

write.csv(vowels_long, "data/exploded_data.csv")
#print(vowels_long, n = 10)


# Now we need to associate numbers in the exploded data to the vowels in the 
# stimulus excel. 

stimulus_merging <- function(participant_data, stimulus_data, group_col = "SOUND"){
  # we will look at each group and next to each number, put its corresponding stimulus
  # name so we can better look at how characteristics of sounds may have influenced
  # grouping. We will also have a boolean column for if the sound is palatalized or not
  # as well as female or male speaking column
  
  sound_data <- read_csv(participant_data)
  stimuli_data <- read_csv(stimulus_data)
  
  merged_data <- sound_data %>%
    left_join(
      stimuli_data,
      by = c(
        "SLIDE" = "Aslide",
        "SOUND" = "IconNumber"
      )
    )
  
  write.csv(merged_data, participant_data)
  
  # if we convert all the group numbers into a list, and then iterate through that list and make a list for each number
  # which includes the data from stimuli data, we can then convert those lists to hav each item on its own column
  # in the exploded data csv file
  
  
  
  print(merged_data)
}

stim_merge_test <- stimulus_merging("data/exploded_data.csv", "data/Stimuli.xlsx - Lookup Matrix.csv")
# print(stim_merge_test)
