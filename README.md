<div align="center">
  
  # AraPresSão - Land Use/Land Cover Impacts on Precipitation
  
</div>

<div align="justify">
This repository contains some example scripts that I used to conduct my research. They are not the exact ones I used, as during the study, I learned much more efficient ways to analyze data without writing hundreds of (unnecessary) lines of code.

Essentially, this is a synthesis of the knowledge I gained. The full dataset is not publicly available, nor are the analysis methods I used, but the data obtained originated from processes similar to the ones shown in the four scripts.
</div>

## Script descriptions

### [daee-downloader.py](https://github.com/fulan-m/arapressao/blob/main/python/daee-downloader.py)
<div align="justify">

The first script developed by me, and used in the research. Basically, it automatically downloads precipitation data from the Water and Electric Energy Department's (DAEE) weather stations. This is made using Mozilla Firefox's browser drive [GeckoDriver](https://github.com/mozilla/geckodriver), operated with the Selenium package.

After setting up a profile that disables download pop-ups, it accesses 5 obligatory dropdowns identified by its individual ids in the page (on dropdown 3, adding 1 more down key-press to select the next station), and finally the download button. The code can easily be adapted to most websites (if you manage to find out the ids).
</div>

### [transform-tables.r](https://github.com/fulan-m/arapressao/blob/main/r/transform-tables.r)
<div align="justify">

This script processes raw precipitation data from multiple weather station files, restructuring it into a standardized, analysis-ready format. It extracts station metadata (name, location, date range) and converts daily rainfall records from wide to long format, handling missing values and date parsing automatically. The cleaned data is saved in individual files per station, while a summary table compiles key details like coordinates, measurement periods, and error rates.

The output provides a consistent structure for further analysis, ensuring dates are properly formatted, values are numeric, and gaps in the data are quantified. This step is essential for merging datasets, validating data quality, and performing time-series or spatial analyses downstream.
</div>

### [filter-tables.r](https://github.com/fulan-m/arapressao/blob/main/r/filter-tables.r)
<div align="justify">

This script refines the weather station dataset by applying spatial, temporal, and quality filters to ensure only the most reliable data is retained. It first converts station coordinates from degrees-minutes-seconds to decimal degrees, then clips stations to a geographic boundary (AraPressão region). Interactive maps visualize the results at each step.

Next, it filters stations to meet strict criteria: locations must fall within the study area, contain continuous data from 1985–2023, and have fewer than 10% missing values. Validated station data is copied to a new directory, with filenames standardized for consistency. This process creates a curated dataset optimized for regional climate analysis.
</div>

### [land-use-analysis.ipynb](https://github.com/fulan-m/arapressao/blob/main/jupyter-notebook/land-use-analysis.ipynb)
<div align="justify">

This script analyzes land use changes around weather stations in the Arapressao region using Google Earth Engine and MapBiomas data. It processes station coordinates, filters them by location and data quality (removing stations with >10% errors), and calculates land cover statistics within a 12.5 km buffer of each station from 1985–2023. The script classifies areas into 71 land types (e.g., forests, crops, urban zones) and computes yearly averages across stations.

Results are visualized through two key plots: (1) line graphs tracking individual land types over time, and (2) stacked bar charts showing shifting land use composition. The analysis separates major categories (like pasture) from minor ones to highlight trends. Outputs provide insights into how urbanization, agriculture, and conservation have reshaped the landscape around monitoring stations.
</div>

### [chirps-clustering.ipynb](https://github.com/fulan-m/arapressao/blob/main/jupyter-notebook/chirps-clustering.ipynb)
<div align="justify">

This script analyzes precipitation patterns in the Arapressao region using CHIRPS satellite data. It processes annual rainfall totals (1985-2022) and applies machine learning clustering to identify distinct precipitation zones. The analysis includes three key components: (1) total accumulated rainfall patterns, (2) trends in rainfall change using Sen's slope method, and (3) smoothed versions of these trends for clearer spatial patterns.

The script uses Google Earth Engine for efficient large-scale computation, implementing k-means clustering (with 8 classes) to categorize areas with similar precipitation characteristics. Results are visualized through an interactive map showing the clustered outputs, with distinct color schemes highlighting regional variations in both rainfall amounts and long-term trends.
</div>
