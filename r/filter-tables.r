# infoTable as point shapefile
library(sf)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

infoTable <- read.csv('example-data/formatted-tables/infoTable.csv', sep = ',', header = TRUE, encoding = 'LATIN1')

# Function to convert DMS to decimal degrees
dms_to_decimal <- function(dms) {
  parts <- strsplit(dms, "[°'\"]")[[1]]
  deg <- as.numeric(parts[1])
  min <- as.numeric(parts[2])
  sec <- as.numeric(parts[3])
  deg + min/60 + sec/3600
}

# Convert coordinates to decimal degrees
infoTable$latitude <- sapply(infoTable$st_lat, dms_to_decimal)
infoTable$longitude <- sapply(infoTable$st_long, dms_to_decimal)

# Add negative sign (Brazil)
infoTable$latitude <- ifelse(infoTable$latitude > 0, -infoTable$latitude, infoTable$latitude)
infoTable$longitude <- ifelse(infoTable$longitude > 0, -infoTable$longitude, infoTable$longitude)

# Create sf object
stations_sf <- st_as_sf(infoTable, coords = c("longitude", "latitude"), crs = 4326)

# Load 'arapressao' limit shapefile
arapressao <- st_read('example-data/arapressao-limits/arapressao.shp')

vis <- ggplot() +
    geom_sf(data = stations_sf, color = "blue", size = 2) + 
    geom_sf(data = arapressao, fill = NA, color = "red") +
    labs(title = "All example stations") +
    theme_classic()

print(vis)

# Now, we will filter out stations that do not meet the following criteria:
# 1. Must be within the 'arapressao' limits
# 2. Must have data from 1985-01-01 to 2023-12-31
# 3. Must not have more than 10% of missing data

# Fix CRS
if (st_crs(stations_sf) != st_crs(arapressao)) {
    stations_sf <- st_transform(stations_sf, st_crs(arapressao))
}

clippedStations <- st_intersection(stations_sf, arapressao)

# Visualize again, to check the result
visClip <- ggplot() +
    geom_sf(data = clippedStations, color = "blue", size = 2) + 
    geom_sf(data = arapressao, fill = NA, color = "red") +
    labs(title = "Filtered clipped stations") +
    theme_classic()

print(visClip)

# Filter for date and error percentage
# Now the st will be transformed back to a data frame
clippedStations_df <- as.data.frame(st_drop_geometry(clippedStations))

# Filter for date and error percentage
# 1. Must have data as early as 1985, and as late as 2023
clippedStations_df$st_start_dt <- as.Date(clippedStations_df$st_start_dt, format = "%Y-%m-%d")
clippedStations_df$st_end_dt <- as.Date(clippedStations_df$st_end_dt, format = "%Y-%m-%d")
clippedStations_df$start_year <- as.numeric(format(clippedStations_df$st_start_dt, "%Y"))
clippedStations_df$end_year <- as.numeric(format(clippedStations_df$st_end_dt, "%Y"))
clippedStations_df <- subset(clippedStations_df, start_year <= 1985 & end_year >= 2023)

# 2. Must not have more than 10% of missing data
clippedStations_df <- subset(clippedStations_df, error_perc < 10)

# Now, we have a list of stations that passed, now we will retrieve its matching
# precipitation tables and add to a new directory

formattedDir <- 'example-data/formatted-tables'
clippedDir <- 'example-data/clipped-tables'

formattedFiles <- list.files(formattedDir, pattern = "_corrected.csv", full.names = TRUE)

# Loop through each file and check if the st_code is in the clippedStations_df
for (file in formattedFiles) {

    # Extract the st_code from the filename
    st_code <- gsub("_corrected.csv", "", basename(file))
    
    # Check if the st_code is in the clippedStations_df
    if (st_code %in% clippedStations_df$st_code) {
        # Copy the file to the new directory
        file.copy(file, file.path(clippedDir, basename(file)))
    }
}

# Now, we will remove the '_corrected' from the filenames
clippedFiles <- list.files(clippedDir, pattern = "_corrected.csv", full.names = TRUE)
for (file in clippedFiles) {

    # Remove the '_corrected' from the filename
    new_file_name <- gsub("_corrected", "", basename(file))
    
    # Rename the file
    file.rename(file, file.path(clippedDir, new_file_name))
}