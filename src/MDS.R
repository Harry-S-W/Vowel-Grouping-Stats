# FILE PULLS CODE FROM DANIEL DAIDONES WEBSITE:
# https://www.ddaidone.com/uploads/1/0/5/2/105292729/mds_analysis.rmd

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("DATA_CONVERSION.R")

# converting the csv data to a dissimilarity matrix 
my_matrix <- run_conversion("../data/speaker_data.csv", "../data/stimuli.csv", output_path = "../data/FCmatrix.txt")

# downloading daniel daidones code from her website. 
# please email jgf526@york.ac.uk if this link stops working and I will try to find a new one
# I am not claiming ownership but I also won't put someone else email in a git repo

daidone_url <- "https://www.ddaidone.com/uploads/1/0/5/2/105292729/mds_analysis.rmd"
raw_file <- "daidone_raw.Rmd"
clean_file <- "daidone_logic.Rmd"

if (!file.exists(raw_file)) {
  download.file(url = daidone_url, destfile = raw_file, method = "libcurl", 
                headers = c("User-Agent" = "Mozilla/5.0"))
}

content <- readLines(raw_file)

# Because Daidones code has some hard coded paths we have to comment them out
content <- gsub("knitr::opts_knit\\$set\\(root.dir", "# knitr::opts_knit\\$set\\(root.dir", content)

# Similar to above but now we are changing the hard coded matrix path to our matrix path
content <- gsub('read.table\\("Output_Matrix_AllContexts_percent_dis.txt"', 
                'read.table("../data/FCmatrix.txt"', content)

content <- gsub('FCmatrixAll=read.table', 
                'FCmatrixAll_raw=read.table', content)

fix_line <- "FCmatrixAll <- as.matrix(FCmatrixAll_raw[, sapply(FCmatrixAll_raw, is.numeric)]); FCmatrixAll[FCmatrixAll < 0] <- 0; diag(FCmatrixAll) <- 0"
content <- append(content, fix_line, after = grep("FCmatrixAll_raw=read.table", content))

writeLines(content, clean_file)

rmarkdown::render(clean_file, output_format = "html_document")

# All outputs go to data_output 
# if there isn't one, it makes one automatically. 

output_folder <- "../data_output"
if (!dir.exists(output_folder)) dir.create(output_folder)

rmarkdown::render(
  input = clean_file, 
  output_format = "html_document",
  output_dir = output_folder,        # Directs the HTML file
  intermediates_dir = output_folder   # Directs the 'hidden' math files
)

if (file.exists("FCmatrix.txt")) {
  file.copy("FCmatrix.txt", "../data/FCmatrix.txt", overwrite = TRUE)
}

if (file.exists("../data/FCmatrix.txt")) {
  file.copy("../data/FCmatrix.txt", file.path(output_folder, "FCmatrix_Final.txt"), overwrite = TRUE)
}

# Just trying to remove any extra files that might stay in /src which should only contain source code
survivors <- list.files(pattern = ".*\\.(png|txt|csv)$")
if (length(survivors) > 0) {
  file.copy(survivors, file.path(output_folder, survivors))
  file.remove(survivors)
}