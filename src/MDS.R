# FILE PULLS CODE FROM DANIEL DAIDONES WEBSITE:
# https://www.ddaidone.com/uploads/1/0/5/2/105292729/mds_analysis.rmd

base_path <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(base_path)

data_folder <- file.path(base_path, "../data")
output_folder <- file.path(base_path, "../data_output")

if (!dir.exists(data_folder)) dir.create(data_folder)
if (!dir.exists(output_folder)) dir.create(output_folder)

source("DATA_CONVERSION.R")

# We call the DATA_CONVERTER.R file to turn our csv datasets into dissimilarity matrixes
matrix_path <- file.path(data_folder, "FCmatrix.txt")
my_matrix <- run_conversion("../data/speaker_data.csv", "../data/stimuli.csv", output_path = matrix_path)

# Downloading daidones code
# if this link stops working, email me at jgf526@york.ac.uk

daidone_url <- "https://www.ddaidone.com/uploads/1/0/5/2/105292729/mds_analysis.rmd"
raw_file <- "daidone_raw.Rmd"
clean_file <- "daidone_logic.Rmd"

if (!file.exists(raw_file)) {
  download.file(url = daidone_url, destfile = raw_file, method = "libcurl", 
                headers = c("User-Agent" = "Mozilla/5.0"))
}

content <- readLines(raw_file)

# Comment out hardcoded root directory
content <- gsub("knitr::opts_knit\\$set\\(root.dir", "# knitr::opts_knit\\$set\\(root.dir", content)

# We then change the paths in daidones file to ours
content <- gsub('read.table\\("Output_Matrix_AllContexts_percent_dis.txt"', 
                paste0('read.table("', matrix_path, '"'), content)

content <- gsub('FCmatrixAll=read.table', 'FCmatrixAll_raw=read.table', content)
fix_line <- "FCmatrixAll <- as.matrix(FCmatrixAll_raw[, sapply(FCmatrixAll_raw, is.numeric)]); FCmatrixAll[FCmatrixAll < 0] <- 0; diag(FCmatrixAll) <- 0"
content <- append(content, fix_line, after = grep("FCmatrixAll_raw=read.table", content))

writeLines(content, clean_file)

rmarkdown::render(
  input = clean_file, 
  output_format = "html_document",
  output_dir = output_folder,
  clean = TRUE 
)

# moving dimension plots to /data_output before we purge unwanted files in /src
all_files_in_src <- list.files(base_path)
rescues <- all_files_in_src[grepl("\\.(png|txt|csv)$", all_files_in_src)]
rescues <- rescues[!rescues %in% c(raw_file, clean_file, "FCmatrix.txt", "DATA_CONVERSION.R", "MDS.R")]

if (length(rescues) > 0) {
  file.copy(file.path(base_path, rescues), file.path(output_folder, rescues), overwrite = TRUE)
  file.remove(file.path(base_path, rescues))
}

final_files_in_src <- list.files(base_path)
keep_these <- c("MDS.R", "DATA_CONVERSION.R", "daidone_raw.Rmd", "daidone_logic.Rmd")
to_delete <- final_files_in_src[!(final_files_in_src %in% keep_these)]

for(f in to_delete) {
  target <- file.path(base_path, f)
  if(!dir.exists(target)) file.remove(target)
}

message("Processing complete")