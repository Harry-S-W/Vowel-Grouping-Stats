# FILE PULLS CODE FROM DANIEL DAIDONES WEBSITE:
# https://www.ddaidone.com/uploads/1/0/5/2/105292729/mds_analysis.rmd

# getting the data conversion file
source("scripts/conversion_logic.R")

# running the conversion on the dataset - I will remove the hardcoded path soon
my_matrix <- run_conversion("data/user_data.csv", "data/Stimuli.csv")


# To comply with personal copyright this code here downloads Daidones code externally
daidone_url <- "https://www.ddaidone.com/uploads/1/0/5/2/105292729/mds_analysis.rmd"
dest_file <- "scripts/daidone_logic.Rmd"

if (!file.exists(dest_file)) {
  download.file(daidone_url, dest_file)
}

rmarkdown::render(dest_file, output_format = "html_document")