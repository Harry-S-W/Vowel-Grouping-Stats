# FILE PULLS CODE FROM DANIEL DAIDONES WEBSITE:
# https://www.ddaidone.com/uploads/1/0/5/2/105292729/mds_analysis.rmd

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# getting the data conversion file
source("DATA_CONVERSION.R")

# running the conversion on the dataset - I will remove the hardcoded path soon
my_matrix <- run_conversion("../data/speaker_data.csv", "../data/stimuli.csv", output_path = "../data/FCmatrix.txt")

# To comply with personal copyright this code here downloads Daidones code externally
daidone_url <- "https://www.ddaidone.com/uploads/1/0/5/2/105292729/mds_analysis.rmd"
dest_file <- "daidone_logic.Rmd"

if (!file.exists(dest_file)) {
  # We use 'method = "libcurl"' and custom headers to bypass the 403 error
  download.file(
    url = daidone_url, 
    destfile = dest_file, 
    method = "libcurl", 
    headers = c("User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/91.0.4472.124 Safari/537.36")
  )
}

# Now run the render
rmarkdown::render(dest_file, output_format = "html_document")


