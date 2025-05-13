library(dplyr)
library(tidyr)

# Set paths
input_dir <- "example-data/raw-tables"
output_dir <- "example-data/formatted-tables"

# Create output directory (including parent directories if needed)
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Get list of CSV files in the directory
csv_files <- list.files(path = input_dir, pattern = "\\.csv$", full.names = TRUE)

# Initialize empty data frame to store combined station info
combined_info <- data.frame()

# Function to process a single CSV file
process_csv_file <- function(file_path) {
  # Extract station code from filename (first 6 characters)
  st_code <- substr(basename(file_path), 1, 6)
  
  # Read the file
  codeTable <- read.csv(file_path, sep = ';', header = FALSE)
  dataTable <- read.csv(file_path, sep = ';', header = TRUE, skip = 11)
  
  # Process station info
  lat_long_raw <- codeTable[1:5, 2][5]
  lat_long_split <- strsplit(lat_long_raw, "\nLONGITUDE: ;")[[1]]
  
  format_dms <- function(dms) {
    if (!grepl('"$', dms)) {
      dms <- paste0(dms, '"')
    }
    return(dms)
  }
  
  infoTable <- data.frame(
    st_code = st_code,
    st_name = codeTable[1:5, 2][2],
    st_city = codeTable[1:5, 2][3],
    st_waterb = codeTable[1:5, 2][4],
    st_lat = format_dms(lat_long_split[1]),
    st_long = format_dms(lat_long_split[2])
  )
  
  # Process data table
  long_data <- dataTable %>%
    select(Mês.Ano, matches("^X\\d+$")) %>%
    pivot_longer(
      cols = -Mês.Ano,
      names_to = "day",
      values_to = "precipitation"
    ) %>%
    mutate(day = as.numeric(gsub("X", "", day))) %>%
    separate(Mês.Ano, into = c("month", "year"), sep = "/") %>%
    mutate(
      date = as.Date(paste(year, month, day, sep = "-"), format = "%Y-%m-%d"),
      precipitation = ifelse(precipitation == "---", NA, precipitation),
      precipitation = as.numeric(gsub(",", ".", precipitation))
    ) %>%
    filter(!is.na(date)) %>%
    select(date, precipitation) %>%
    arrange(date)
  
  # With 'date', let's output the 'st_start_dt' and 'st_end_dt'
  infoTable$st_start_dt <- min(long_data$date)
  infoTable$st_end_dt <- max(long_data$date)
  
  # Calculate error percentage
  date_range <- seq(min(long_data$date), max(long_data$date), by = "day")
  existing_but_na <- long_data %>% filter(is.na(precipitation))
  errors <- ((length(setdiff(date_range, long_data$date)) + nrow(existing_but_na)) / 
            length(date_range)) * 100
  
  infoTable$error_perc <- errors
  
  # Save individual long_data file to output directory
  output_filename <- file.path(output_dir, paste0(st_code, "_corrected.csv"))
  write.csv(long_data, output_filename, row.names = FALSE)
  
  return(infoTable)
}

# Process all files
for (file in csv_files) {
  station_info <- process_csv_file(file)
  combined_info <- bind_rows(combined_info, station_info)
}

# Save combined info table to output directory
write.csv(combined_info, file.path(output_dir, "infoTable.csv"), row.names = FALSE, fileEncoding = "UTF-8")

# Print summary
cat("Processed", length(csv_files), "files\n")
cat("Output files saved to:", normalizePath(output_dir), "\n")
cat("Created:\n")
cat("- infoTable.csv with", nrow(combined_info), "stations\n")
cat("- Individual long_data files for each station\n")