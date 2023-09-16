setwd("/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/Shared drives/Alpine Mammals Updated/GISData_Jan2018UpdatedNDVI")
outpath <- "/Users/elisehellwig/Library/CloudStorage/GoogleDrive-echellwig@ucdavis.edu/My Drive/Transfer/Data"

#Niche Factor Analysis
#Marmot Data
library(data.table)
library(ade4)
library(adehabitatHS)
source('enfa_functions.R')


acronyms <- c("Spebel", "Marfla", "Spelat")

pa <- fread(file.path(outpath, 'PresenceAvailableData.csv'))


#==============================================================================
# Niche factor analysis based on spatial locations of Marmot collected along 21
# transects in the Sierra Nevada from 2009 - 2012. In addition to 1703
# locations ("used points") 50,000 random points were generated as "available
# locations". Values of thirteen habitat variables were extracted for each point.
# The available points were then filtered for elevations > 2500 m (about 8500
# feet). 
#==============================================================================


enfa_list <- lapply(acronyms, run_enfa, pa)

saveRDS(enfa_list, file.path(outpath, 'ENFA_Model_Output.RDS'))

habavail.pca <- dudi.pca(Marflahabvars, scannf=FALSE)

saveRDS(habavail.pca, 'Marfla_PCA_output.RDS')
saveRDS(weights, 'Marfla_weights.RDS')

