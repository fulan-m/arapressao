<div align="center">
  
  # AraPresSão - Land Use/Land Cover Impacts on Precipitation
</div>

<div align="justify">
This repository contains some example scripts that I used to conduct my research. They are not the exact ones I used, as during the study, I learned much more efficient ways to analyze data without writing hundreds of (unnecessary) lines of code.

Essentially, this is a synthesis of the knowledge I gained. The full dataset is not publicly available, nor are the analysis methods I used, but the data obtained originated from processes similar to the ones shown in the four scripts.
</div>

## Script descriptions

### daee-downloader.py
<div align="justify">

The first script developed by me, and used in the research. Basically, it automatically downloads precipitation data from the Water and Electric Energy Department's (DAEE) weather stations. This is made using Mozilla Firefox's browser drive [GeckoDriver](https://github.com/mozilla/geckodriver), operated with the Selenium package.

After setting up a profile that disables download pop-ups, it accesses 5 obligatory dropdowns identified by its individual ids in the page (on dropdown 3, adding 1 more down key-press to select the next station), and finally the download button. The code can easily be adapted to most websites (if you manage to find out the ids).
</div>

### transform-tables.r

### filter-tables.r

### transform-tables.r

### land-use-analysis.ipynb

### chirps-clustering.ipynb
